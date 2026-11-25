import pytest

from app.config import resolve_secret_key

AVATAR = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="


def assert_error(response, status_code):
    body = response.json()
    assert response.status_code == status_code
    assert isinstance(body["message"], str) and body["message"]
    assert body["code"] == str(status_code)
    assert isinstance(body["details"], dict)
    assert "detail" not in body


def auth_header(token):
    return {"Authorization": f"Bearer {token}"}


def register(client, email="user@example.com", password="secret"):
    response = client.post("/api/auth/register", json={"email": email, "password": password})
    assert response.status_code == 201, response.text
    return response.json()


def create_task(client, token, **overrides):
    payload = {
        "title": "Write tests",
        "description": "Cover the API",
        "priority": "low",
    }
    payload.update(overrides)
    response = client.post("/api/tasks", json=payload, headers=auth_header(token))
    assert response.status_code == 201, response.text
    return response.json()


def test_production_secret_is_required():
    with pytest.raises(RuntimeError):
        resolve_secret_key("production", None)
    with pytest.raises(RuntimeError):
        resolve_secret_key("production", "super_secret_key_change_in_production")
    with pytest.raises(RuntimeError):
        resolve_secret_key("production", "   ")
    assert resolve_secret_key("production", "unique-production-secret") == "unique-production-secret"


def test_development_does_not_keep_the_known_default_secret():
    generated = resolve_secret_key("development", "super_secret_key_change_in_production")
    assert generated != "super_secret_key_change_in_production"
    assert resolve_secret_key("development", "local-dev-secret") == "local-dev-secret"


def test_register_login_and_profile_serialization(client):
    created = register(client)
    assert created["token_type"] == "bearer"
    assert created["access_token"]
    user = created["user"]
    assert user["email"] == "user@example.com"
    assert user["id"]
    assert user["avatarColor"] == "#facc15"
    assert user["avatarImage"] is None
    assert "avatar_color" not in user
    assert "hashed_password" not in user

    login = client.post("/api/auth/login", json={"email": "user@example.com", "password": "secret"})
    assert login.status_code == 200
    assert login.json()["user"]["avatarColor"] == "#facc15"
    assert login.json()["access_token"]

    me = client.get("/api/users/me", headers=auth_header(created["access_token"]))
    assert me.status_code == 200
    assert me.json()["avatarColor"] == "#facc15"
    assert me.json()["avatarImage"] is None


def test_register_conflict_and_validation_use_error_response(client):
    register(client)
    duplicate = client.post("/api/auth/register", json={"email": "user@example.com", "password": "secret"})
    assert_error(duplicate, 409)

    invalid = client.post("/api/auth/register", json={"email": "not-an-email", "password": "x"})
    assert_error(invalid, 400)
    assert "email" in invalid.json()["details"]
    assert "password" in invalid.json()["details"]


def test_login_rejects_bad_credentials_and_short_password(client):
    register(client)
    wrong = client.post("/api/auth/login", json={"email": "user@example.com", "password": "nope!"})
    assert_error(wrong, 401)

    short = client.post("/api/auth/login", json={"email": "user@example.com", "password": "ab"})
    assert_error(short, 400)


def test_missing_and_invalid_token_are_unauthorized(client):
    assert_error(client.get("/api/users/me"), 401)
    assert_error(client.get("/api/tasks"), 401)
    assert_error(client.get("/api/users/me", headers={"Authorization": "Token abc"}), 401)
    assert_error(client.post("/api/auth/logout"), 401)


def test_profile_update_avatar_and_reset(client):
    token = register(client)["access_token"]
    headers = auth_header(token)

    updated = client.patch(
        "/api/users/me",
        json={"avatarColor": "#112233", "avatarImage": AVATAR},
        headers=headers,
    )
    assert updated.status_code == 200
    assert updated.json()["avatarColor"] == "#112233"
    assert updated.json()["avatarImage"] == AVATAR

    color_only = client.patch("/api/users/me", json={"avatarColor": "#abcdef"}, headers=headers)
    assert color_only.status_code == 200
    assert color_only.json()["avatarColor"] == "#abcdef"
    assert color_only.json()["avatarImage"] == AVATAR

    cleared = client.patch("/api/users/me", json={"avatarImage": ""}, headers=headers)
    assert cleared.status_code == 200
    assert cleared.json()["avatarImage"] is None
    assert cleared.json()["avatarColor"] == "#abcdef"

    bad_color = client.patch("/api/users/me", json={"avatarColor": "yellow"}, headers=headers)
    assert_error(bad_color, 400)

    unsupported = client.patch(
        "/api/users/me",
        json={"avatarImage": "https://example.com/avatar.png"},
        headers=headers,
    )
    assert_error(unsupported, 415)

    too_large = client.patch(
        "/api/users/me",
        json={"avatarImage": "data:image/png;base64," + ("A" * (5 * 1024 * 1024))},
        headers=headers,
    )
    assert_error(too_large, 413)

    reset = client.delete("/api/users/me/avatar", headers=headers)
    assert reset.status_code == 204
    assert reset.content == b""
    profile = client.get("/api/users/me", headers=headers)
    assert profile.json()["avatarColor"] == "#facc15"
    assert profile.json()["avatarImage"] is None


def test_task_crud_filter_deadline_and_ownership(client):
    owner = register(client, "owner@example.com")
    other = register(client, "other@example.com")
    owner_headers = auth_header(owner["access_token"])
    other_headers = auth_header(other["access_token"])

    created = create_task(client, owner["access_token"], deadline="2026-12-01")
    assert created["status"] == "todo"
    assert created["deadline"] == "2026-12-01"
    assert created["title"] == "Write tests"

    second = create_task(
        client,
        owner["access_token"],
        title="Review API",
        description="",
        priority="high",
    )
    create_task(client, other["access_token"], title="Foreign task", description="hidden", priority="medium")

    listed = client.get("/api/tasks", headers=owner_headers)
    assert listed.status_code == 200
    assert sorted(task["title"] for task in listed.json()) == ["Review API", "Write tests"]

    todo_only = client.get("/api/tasks", params={"status": "todo"}, headers=owner_headers)
    assert todo_only.status_code == 200
    assert len(todo_only.json()) == 2

    moved = client.patch(
        f"/api/tasks/{second['id']}/status",
        json={"status": "review"},
        headers=owner_headers,
    )
    assert moved.status_code == 200
    assert moved.json()["status"] == "review"

    review_only = client.get("/api/tasks", params={"status": "review"}, headers=owner_headers)
    assert [task["id"] for task in review_only.json()] == [second["id"]]

    invalid_status = client.get("/api/tasks", params={"status": "archived"}, headers=owner_headers)
    assert_error(invalid_status, 400)

    fetched = client.get(f"/api/tasks/{created['id']}", headers=owner_headers)
    assert fetched.status_code == 200
    assert fetched.json()["id"] == created["id"]

    missing = client.get(f"/api/tasks/{created['id']}", headers=other_headers)
    assert_error(missing, 404)
    assert_error(client.get("/api/tasks/missing-id", headers=owner_headers), 404)

    edited = client.patch(
        f"/api/tasks/{created['id']}",
        json={
            "title": "  Write more tests  ",
            "description": "Deadline moved",
            "priority": "medium",
            "deadline": "2026-12-31",
        },
        headers=owner_headers,
    )
    assert edited.status_code == 200
    assert edited.json()["title"] == "Write more tests"
    assert edited.json()["description"] == "Deadline moved"
    assert edited.json()["priority"] == "medium"
    assert edited.json()["deadline"] == "2026-12-31"
    assert edited.json()["status"] == "todo"

    kept_deadline = client.patch(
        f"/api/tasks/{created['id']}",
        json={"title": "Write more tests", "description": "Deadline stays", "priority": "high"},
        headers=owner_headers,
    )
    assert kept_deadline.json()["deadline"] == "2026-12-31"
    assert kept_deadline.json()["priority"] == "high"

    cleared_deadline = client.patch(
        f"/api/tasks/{created['id']}",
        json={
            "title": "Write more tests",
            "description": "Deadline cleared",
            "priority": "high",
            "deadline": None,
        },
        headers=owner_headers,
    )
    assert cleared_deadline.json()["deadline"] is None

    bad_deadline = client.patch(
        f"/api/tasks/{created['id']}",
        json={
            "title": "Write more tests",
            "description": "Bad date",
            "priority": "low",
            "deadline": "31-12-2026",
        },
        headers=owner_headers,
    )
    assert_error(bad_deadline, 400)

    partial = client.patch(
        f"/api/tasks/{created['id']}",
        json={"title": "Only title"},
        headers=owner_headers,
    )
    assert_error(partial, 400)

    assert_error(
        client.patch(
            f"/api/tasks/{created['id']}",
            json={"title": "Nope", "description": "Nope", "priority": "low"},
            headers=other_headers,
        ),
        404,
    )
    assert_error(
        client.patch(
            f"/api/tasks/{created['id']}/status",
            json={"status": "done"},
            headers=other_headers,
        ),
        404,
    )

    deleted = client.delete(f"/api/tasks/{created['id']}", headers=owner_headers)
    assert deleted.status_code == 204
    assert_error(client.get(f"/api/tasks/{created['id']}", headers=owner_headers), 404)
    assert_error(client.delete(f"/api/tasks/{second['id']}", headers=other_headers), 404)


def test_logout_revokes_the_current_token(client):
    token = register(client)["access_token"]
    headers = auth_header(token)

    logout = client.post("/api/auth/logout", headers=headers)
    assert logout.status_code == 204
    assert logout.content == b""

    assert_error(client.get("/api/users/me", headers=headers), 401)
    assert_error(client.post("/api/auth/logout", headers=headers), 401)

    login = client.post("/api/auth/login", json={"email": "user@example.com", "password": "secret"})
    assert login.status_code == 200
    fresh = login.json()["access_token"]
    assert fresh != token
    assert client.get("/api/users/me", headers=auth_header(fresh)).status_code == 200

import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { apiRequest } from '../api';

interface AuthResponse {
  user: {
    id: string;
    email: string;
    avatarColor: string;
    avatarImage?: string | null;
  };
  access_token: string;
  token_type: string;
}

export default function Login() {
  const navigate = useNavigate();
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const [isCatTheme, setIsCatTheme] = useState(
    () => localStorage.getItem('catTheme') === 'true'
  );

  useEffect(() => {
    localStorage.setItem('catTheme', String(isCatTheme));
  }, [isCatTheme]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!email.includes('@')) {
      setError('Введите корректный Email');
      return;
    }

    if (password.length < 3) {
      setError('Пароль должен быть не меньше 3 символов');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const result = await apiRequest<AuthResponse>(
        isLogin ? '/api/auth/login' : '/api/auth/register',
        {
          method: 'POST',
          body: JSON.stringify({ email, password }),
        }
      );

      localStorage.setItem('access_token', result.access_token);
      localStorage.setItem('userEmail', result.user.email);
      localStorage.setItem('avatarColor', result.user.avatarColor);

      navigate('/board');
    } catch (err) {
      setError(
        err instanceof Error ? err.message : 'Не удалось выполнить запрос'
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={`login-container ${isCatTheme ? 'cat-theme' : ''}`}>
      <button
        className="cat-toggle-btn"
        onClick={() => setIsCatTheme(!isCatTheme)}
        style={{ position: 'absolute', top: '20px', right: '20px' }}
        title="Включить/выключить кото-режим"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <circle cx="12" cy="16" r="4" />
          <circle cx="7" cy="10" r="2" />
          <circle cx="17" cy="10" r="2" />
          <circle cx="10" cy="5" r="2" />
          <circle cx="14" cy="5" r="2" />
        </svg>
      </button>

      <form onSubmit={handleSubmit} className="login-form">
        <h2>
          {isLogin
            ? isCatTheme ? 'С возвращением, хозяин!' : 'С возвращением!'
            : isCatTheme ? 'Создать ошейник' : 'Создать аккаунт'}
        </h2>

        <p className="login-subtitle">
          {isLogin
            ? isCatTheme
              ? 'Войдите чтобы продолжить охоту'
              : 'Войдите, чтобы продолжить работу'
            : isCatTheme
              ? 'Зарегистрируйтесь чтобы начать охоту'
              : 'Зарегистрируйтесь, чтобы начать'}
        </p>

        {error && <div className="error-message">{error}</div>}

        <div className="input-group">
          <input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
        </div>

        <div className="input-group">
          <input
            type="password"
            placeholder="Пароль"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </div>

        <button type="submit" className="login-btn" disabled={loading}>
          {loading
            ? 'Подождите...'
            : isLogin ? 'Войти' : 'Зарегистрироваться'}
        </button>

        <p
          className="toggle-auth"
          onClick={() => {
            setIsLogin(!isLogin);
            setError('');
          }}
        >{isLogin
            ? isCatTheme
              ? 'Нету ошейника? Зарегистрироваться'
              : 'Нет аккаунта? Зарегистрироваться'
            : isCatTheme
              ? 'У тебя уже есть ошейник? Войти'
              : 'Уже есть аккаунт? Войти'}
        </p>
      </form>
    </div>
  );
}
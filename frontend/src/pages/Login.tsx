import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { apiRequest } from '../api';
import { useAuthStore } from '../store/useAuthStore';
import loginTexts from '../loginTexts.json';

interface LoginTexts {
  catTheme: {
    loginTitle: string;
    registerTitle: string;
    loginSubtitle: string;
    registerSubtitle: string;
    loginButton: string;
    registerButton: string;
    loading: string;
    toggleToRegister: string;
    toggleToLogin: string;
    themeButton: string;
  };
  defaultTheme: {
    loginTitle: string;
    registerTitle: string;
    loginSubtitle: string;
    registerSubtitle: string;
    loginButton: string;
    registerButton: string;
    loading: string;
    toggleToRegister: string;
    toggleToLogin: string;
    themeButton: string;
  };
}

const data = loginTexts as LoginTexts;

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

type Theme = 'cat' | 'default';

export default function Login() {
  const navigate = useNavigate();
  const setToken = useAuthStore((state) => state.setToken);

  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const [theme, setTheme] = useState<Theme>(() => {
    return localStorage.getItem('theme') === 'cat' ? 'cat' : 'default';
  });

  const [authResult, setAuthResult] = useState<AuthResponse | null>(null);

  const isCatTheme = theme === 'cat';
  const texts = isCatTheme
    ? data.catTheme
    : data.defaultTheme;

  const submitButtonText = loading
    ? texts.loading
    : isLogin
      ? texts.loginButton
      : texts.registerButton;

  const toggleAuthText = isLogin
    ? texts.toggleToRegister
    : texts.toggleToLogin;

  const title = isLogin ? texts.loginTitle : texts.registerTitle;
  const subtitle = isLogin
    ? texts.loginSubtitle
    : texts.registerSubtitle;

  useEffect(() => {
    localStorage.setItem('theme', theme);
  }, [theme]);

  useEffect(() => {
    if (!authResult) return;

    localStorage.setItem('access_token', authResult.access_token);
    localStorage.setItem('userEmail', authResult.user.email);
    localStorage.setItem('avatarColor', authResult.user.avatarColor);

    setToken(authResult.access_token);

    navigate('/board');
  }, [authResult, navigate, setToken]);

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
        null,
        {
          method: 'POST',
          body: JSON.stringify({ email, password }),
        }
      );

      setAuthResult(result);
    } catch (err) {
      const errorMessage = err instanceof Error
        ? err.message
        : 'Не удалось выполнить запрос';

      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={`login-container ${isCatTheme ? 'cat-theme' : ''}`}>
      <button
        className="cat-toggle-btn"
        onClick={() =>
          setTheme(isCatTheme ? 'default' : 'cat')
        }
        style={{ position: 'absolute', top: '20px', right: '20px' }}
        title={texts.themeButton}
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
        <h2>{title}</h2>

        <p className="login-subtitle">{subtitle}</p>

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
          {submitButtonText}
        </button>

        <p
          className="toggle-auth"
          onClick={() => {
            setIsLogin(!isLogin);
            setError('');
          }}
        >
          {toggleAuthText}
        </p>
      </form>
    </div>
  );
}
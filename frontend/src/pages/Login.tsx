import { useState } from 'react';
import { useNavigate } from 'react-router-dom';

export default function Login() {
  const navigate = useNavigate();
  
  // Стейт для переключения между входом и регистрацией
  const [isLogin, setIsLogin] = useState(true); 
  
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!email.includes('@')) {
      setError('Введите корректный Email');
      return;
    }
    if (password.length < 3) {
      setError('Пароль должен быть не меньше 3 символов');
      return;
    }
    
    setError('');
    
    // Сохраняем email для отображения аватарки в шапке
    localStorage.setItem('userEmail', email);
    
    // Если это регистрация, можно было бы сделать запрос к бэкенду.
    // Пока просто перекидываем на доску.
    navigate('/board'); 
  };

  return (
    <div className="login-container">
      <form onSubmit={handleSubmit} className="login-form">
        {/* Меняем заголовок в зависимости от режима */}
        <h2>{isLogin ? 'С возвращением!' : 'Создать аккаунт'}</h2>
        <p className="login-subtitle">
          {isLogin ? 'Войдите, чтобы продолжить работу' : 'Зарегистрируйтесь, чтобы начать'}
        </p>
        
        {error && <div className="error-message">{error}</div>}
        
        <div className="input-group">
          <input 
            type="email" 
            placeholder="Email" 
            value={email} 
            onChange={(e) => setEmail(e.target.value)} 
          />
        </div>
        
        <div className="input-group">
          <input 
            type="password" 
            placeholder="Пароль" 
            value={password} 
            onChange={(e) => setPassword(e.target.value)} 
          />
        </div>
        
        <button type="submit" className="login-btn">
          {isLogin ? 'Войти' : 'Зарегистрироваться'}
        </button>

        {/* Кнопка переключения режима */}
        <p className="toggle-auth" onClick={() => { setIsLogin(!isLogin); setError(''); }}>
          {isLogin ? 'Нет аккаунта? Зарегистрироваться' : 'Уже есть аккаунт? Войти'}
        </p>
      </form>
    </div>
  );
}
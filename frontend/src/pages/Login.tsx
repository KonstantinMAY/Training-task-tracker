import { useState } from 'react';
import { useNavigate } from 'react-router-dom';

export default function Login() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleLogin = (e: React.FormEvent) => {
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
    localStorage.setItem('userEmail', email);
    navigate('/board'); 
  };

  return (
    <div className="login-container">
      <form onSubmit={handleLogin} className="login-form">
        <h2>С возвращением!</h2>
        <p className="login-subtitle">Войдите, чтобы продолжить работу</p>
        
        {error && <div className="error-message">{error}</div>}
        
        {/* Блоки input-group остались, но без иконок внутри */}
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
        
        <button type="submit" className="login-btn">Войти</button>
      </form>
    </div>
  );
}
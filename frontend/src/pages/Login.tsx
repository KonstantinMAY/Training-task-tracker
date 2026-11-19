import { useNavigate } from 'react-router-dom';

export default function Login() {
  const navigate = useNavigate();

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault(); // Чтобы страница не перезагружалась
    // Тут Фронтендер 2 может добавить проверку полей
    // А пока просто перекидываем на доску
    navigate('/board');
  };

  return (
    <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
      <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', gap: '10px', width: '300px' }}>
        <h2>Вход в систему</h2>
        {/* ФРОНТЕНДЕР 2: Добавь сюда красивые инпуты для Email и Пароля */}
        <input type="email" placeholder="Email" required style={{ padding: '8px' }} />
        <input type="password" placeholder="Пароль" required style={{ padding: '8px' }} />
        <button type="submit" style={{ padding: '10px', background: '#1e1e1e', color: 'white', cursor: 'pointer' }}>
          Войти
        </button>
      </form>
    </div>
  );
}
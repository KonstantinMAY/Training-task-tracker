import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import KanbanBoard from '../components/KanbanBoard';
import AddTaskModal from '../components/AddTaskModal';
import ProfileModal from '../components/ProfileModal';

export default function Board() {
  const navigate = useNavigate();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isProfileOpen, setIsProfileOpen] = useState(false);
  
  // Стейт для темы (по умолчанию проверяем localStorage)
  const [isDarkTheme, setIsDarkTheme] = useState(() => {
    return localStorage.getItem('theme') !== 'light';
  });

  // Применяем класс к body при изменении темы
  useEffect(() => {
    if (isDarkTheme) {
      document.body.classList.add('dark-theme');
      localStorage.setItem('theme', 'dark');
    } else {
      document.body.classList.remove('dark-theme');
      localStorage.setItem('theme', 'light');
    }
  }, [isDarkTheme]);

  // Данные пользователя
  const userEmail = localStorage.getItem('userEmail') || 'User';
  const avatarLetter = userEmail.charAt(0).toUpperCase();
  
  // Настройки аватарки
  const avatarColor = localStorage.getItem('avatarColor') || '#facc15';
  const avatarImage = localStorage.getItem('avatarImage') || '';

  return (
    <div className="app-container">
      <header className="app-header">
        <div className="logo">
          TaskTracker
        </div>
        
        <div className="header-right">
          {/* Кнопка переключения темы */}
          <button className="theme-btn" onClick={() => setIsDarkTheme(!isDarkTheme)}>
            {isDarkTheme ? '☀️ Светлая' : '🌙 Тёмная'}
          </button>

          <div className="user-profile">
            {/* Аватарка с обработчиком клика */}
            <div 
              className="avatar" 
              onClick={() => setIsProfileOpen(true)}
              style={{ 
                cursor: 'pointer',
                backgroundColor: avatarImage ? 'transparent' : avatarColor,
                backgroundImage: avatarImage ? `url(${avatarImage})` : 'none',
                backgroundSize: 'cover',
                backgroundPosition: 'center'
              }}
            >
              {!avatarImage && avatarLetter}
            </div>
            <span className="user-email">{userEmail}</span>
          </div>
          
          <button className="logout-btn" onClick={() => navigate('/login')}>
            Выйти
          </button>
        </div>
      </header>
      
      <main className="board-container">
        <div className="board-header-actions">
          <button className="btn-add-task" onClick={() => setIsModalOpen(true)}>
            + Добавить задачу
          </button>
        </div>

        <KanbanBoard />
      </main>

      {/* Модалка создания задачи */}
      <AddTaskModal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
      />

      {/* Модалка профиля */}
      <ProfileModal 
        isOpen={isProfileOpen} 
        onClose={() => setIsProfileOpen(false)} 
      />
    </div>
  );
}
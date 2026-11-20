import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import KanbanBoard from '../components/KanbanBoard';
import AddTaskModal from '../components/AddTaskModal';
import ProfileModal from '../components/ProfileModal';

export default function Board() {
  const navigate = useNavigate();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isProfileOpen, setIsProfileOpen] = useState(false);
  
  // Стейт для темы (их логика)
  const [isDarkTheme, setIsDarkTheme] = useState(() => {
    return localStorage.getItem('theme') !== 'light';
  });

  useEffect(() => {
    if (isDarkTheme) {
      document.body.classList.add('dark-theme');
      localStorage.setItem('theme', 'dark');
    } else {
      document.body.classList.remove('dark-theme');
      localStorage.setItem('theme', 'light');
    }
  }, [isDarkTheme]);

  const userEmail = localStorage.getItem('userEmail') || 'User';
  const avatarLetter = userEmail.charAt(0).toUpperCase();
  
  // Настройки аватарки из их логики
  const avatarColor = localStorage.getItem('avatarColor') || '#facc15';
  const avatarImage = localStorage.getItem('avatarImage') || '';

  return (
    <div className="app-container">
      <header className="app-header">
        <div className="logo">TaskTracker</div>
        
        <div className="header-right">
          {/* Кнопка переключения темы (наши SVG иконки) */}
          <button className="theme-toggle" onClick={() => setIsDarkTheme(!isDarkTheme)} title="Переключить тему">
            {isDarkTheme ? (
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>
            ) : (
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>
            )}
          </button>

          <div className="user-profile">
            {/* Аватарка с их логикой картинок */}
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
          
          <button className="logout-btn" onClick={() => navigate('/login')}>Выйти</button>
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

      <AddTaskModal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
      <ProfileModal isOpen={isProfileOpen} onClose={() => setIsProfileOpen(false)} />
    </div>
  );
}
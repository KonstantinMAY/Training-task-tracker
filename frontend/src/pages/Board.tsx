import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import KanbanBoard from '../components/KanbanBoard';
import AddTaskModal from '../components/AddTaskModal';
import ProfileModal from '../components/ProfileModal';

export default function Board() {
  const navigate = useNavigate();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isProfileOpen, setIsProfileOpen] = useState(false);
  
  const [isDarkTheme, setIsDarkTheme] = useState(() => localStorage.getItem('theme') !== 'light');
  // Читаем кото-тему из памяти
  const [isCatTheme, setIsCatTheme] = useState(() => localStorage.getItem('catTheme') === 'true');

  useEffect(() => {
    if (isDarkTheme) {
      document.body.classList.add('dark-theme');
      localStorage.setItem('theme', 'dark');
    } else {
      document.body.classList.remove('dark-theme');
      localStorage.setItem('theme', 'light');
    }
  }, [isDarkTheme]);

  // Сохраняем кото-тему в память
  useEffect(() => {
    localStorage.setItem('catTheme', String(isCatTheme));
  }, [isCatTheme]);

  const userEmail = localStorage.getItem('userEmail') || 'User';
  const avatarLetter = userEmail.charAt(0).toUpperCase();
  const avatarColor = localStorage.getItem('avatarColor') || '#facc15';
  const avatarImage = localStorage.getItem('avatarImage') || '';

  return (
    <div className={`app-container ${isCatTheme ? 'cat-theme' : ''}`}>
      <header className="app-header">
        <div className="logo">TaskTracker</div>
        
        <div className="header-right">
          <button className="cat-toggle-btn" onClick={() => setIsCatTheme(!isCatTheme)} title="Включить/выключить кото-режим">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="12" cy="16" r="4" /><circle cx="7" cy="10" r="2" /><circle cx="17" cy="10" r="2" /><circle cx="10" cy="5" r="2" /><circle cx="14" cy="5" r="2" />
            </svg>
          </button>

          {!isCatTheme && (
            <button className="theme-toggle" onClick={() => setIsDarkTheme(!isDarkTheme)} title="Переключить тему">
              {isDarkTheme ? (
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>
              ) : (
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>
              )}
            </button>
          )}

          <div className="user-profile">
            <div className="avatar" onClick={() => setIsProfileOpen(true)} style={{ cursor: 'pointer', backgroundColor: avatarImage ? 'transparent' : avatarColor, backgroundImage: avatarImage ? `url(${avatarImage})` : 'none', backgroundSize: 'cover', backgroundPosition: 'center' }}>
              {!avatarImage && avatarLetter}
            </div>
            <span className="user-email">{userEmail}</span>
          </div>
          
          <button className="logout-btn" onClick={() => navigate('/login')}>Выйти</button>
        </div>
      </header>
      
      <main className="board-container">
        <div className="board-header-actions">
          <button className="btn-add-task" onClick={() => setIsModalOpen(true)}>+ Добавить задачу</button>
        </div>
        
        <KanbanBoard isCatTheme={isCatTheme} />
      </main>

      <AddTaskModal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
      <ProfileModal isOpen={isProfileOpen} onClose={() => setIsProfileOpen(false)} />
    </div>
  );
}
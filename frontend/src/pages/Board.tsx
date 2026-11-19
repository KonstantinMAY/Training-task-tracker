import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import KanbanBoard from '../components/KanbanBoard';
import AddTaskModal from '../components/AddTaskModal';

export default function Board() {
  const navigate = useNavigate();
  const [isModalOpen, setIsModalOpen] = useState(false);

  // Достаем email пользователя для аватарки
  const userEmail = localStorage.getItem('userEmail') || 'User';
  const avatarLetter = userEmail.charAt(0).toUpperCase();

  return (
    <div className="app-container">
      {/* --- ШАПКА С АВАТАРКОЙ (молния убрана) --- */}
      <header className="app-header">
        <div className="logo">
          Мой Трекер
        </div>
        
        <div className="header-right">
          <div className="user-profile">
            <div className="avatar">{avatarLetter}</div>
            <span className="user-email">{userEmail}</span>
          </div>
          <button className="logout-btn" onClick={() => navigate('/login')}>
            Выйти
          </button>
        </div>
      </header>
      
      <main className="board-container">
        {/* --- ЛОГИКА ДОБАВЛЕНИЯ ЗАДАЧИ --- */}
        <div className="board-header-actions">
          <button className="btn-add-task" onClick={() => setIsModalOpen(true)}>
            + Добавить задачу
          </button>
        </div>

        <KanbanBoard />
      </main>

      {/* --- МОДАЛКА --- */}
      <AddTaskModal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
      />
    </div>
  );
}
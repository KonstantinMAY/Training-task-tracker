import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import KanbanBoard from '../components/KanbanBoard';
import AddTaskModal from '../components/AddTaskModal';

export default function Board() {
  const navigate = useNavigate();
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <div className="app-container">
      <header className="app-header">
        <div className="logo">Мой Трекер</div>
        <button className="logout-btn" onClick={() => navigate('/login')}>
          Выйти
        </button>
      </header>
      
      <main className="board-container">
        {/* Кнопка добавления задачи */}
        <div className="board-header-actions">
          <button className="btn-add-task" onClick={() => setIsModalOpen(true)}>
            + Добавить задачу
          </button>
        </div>

        <KanbanBoard />
      </main>

      {/* Сама модалка */}
      <AddTaskModal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
      />
    </div>
  );
}
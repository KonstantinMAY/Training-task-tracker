import { useState } from 'react';
import { useTaskStore } from '../store/useTaskStore';
import type { Task } from '../mockData';

interface AddTaskModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function AddTaskModal({ isOpen, onClose }: AddTaskModalProps) {
  const addTask = useTaskStore((state) => state.addTask);
  
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [priority, setPriority] = useState<'low' | 'high'>('low');

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) return; // Запрещаем создавать пустые задачи

    const newTask: Task = {
      id: Date.now().toString(), // Генерируем уникальный ID на основе времени
      title,
      description,
      status: 'todo', // Новая задача всегда падает в "Нужно сделать"
      priority,
    };

    addTask(newTask);
    
    // Очищаем форму и закрываем окно
    setTitle('');
    setDescription('');
    setPriority('low');
    onClose();
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <h2>Новая задача</h2>
        <form onSubmit={handleSubmit} className="modal-form">
          <input
            type="text"
            placeholder="Название задачи"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            required
          />
          <textarea
            placeholder="Описание задачи"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          />
          
          <select 
            value={priority} 
            onChange={(e) => setPriority(e.target.value as 'low' | 'high')}
          >
            <option value="low">Низкий приоритет</option>
            <option value="high">Высокий приоритет</option>
          </select>

          <div className="modal-actions">
            <button type="button" onClick={onClose} className="btn-cancel">Отмена</button>
            <button type="submit" className="btn-submit">Создать</button>
          </div>
        </form>
      </div>
    </div>
  );
}
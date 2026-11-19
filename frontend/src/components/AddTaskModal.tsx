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
  const [priority, setPriority] = useState<'low' | 'medium' | 'high'>('low');

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) return;

    const newTask: Task = {
      id: Date.now().toString(),
      title,
      description,
      status: 'todo',
      priority,
    };

    addTask(newTask);
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
            onChange={(e) => setPriority(e.target.value as 'low' | 'medium' | 'high')}
          >
            <option value="low">Низкий приоритет</option>
            <option value="medium">Средний приоритет</option>
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
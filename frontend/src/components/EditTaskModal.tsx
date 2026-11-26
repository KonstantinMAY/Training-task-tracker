import { useState } from 'react';
import { useTaskStore } from '../store/useTaskStore';
import type { Task } from '../mockData';

interface EditTaskModalProps {
  task: Task | null;
  isOpen: boolean;
  onClose: () => void;
}

interface EditTaskFormProps {
  task: Task;
  onClose: () => void;
}

function EditTaskForm({ task, onClose }: EditTaskFormProps) {
  const updateTask = useTaskStore((state) => state.updateTask);

  const [title, setTitle] = useState(task.title);
  const [description, setDescription] = useState(task.description);
  const [priority, setPriority] = useState<'low' | 'medium' | 'high'>(task.priority);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!title.trim()) return;

    await updateTask({
      ...task,
      title: title.trim(),
      description,
      priority,
    });

    onClose();
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <h2>Редактировать задачу</h2>

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
            <button type="button" onClick={onClose} className="btn-cancel">
              Отмена
            </button>
            <button type="submit" className="btn-submit">
              Сохранить
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function EditTaskModal({ task, isOpen, onClose }: EditTaskModalProps) {
  if (!isOpen || !task) return null;

  return (
    <EditTaskForm
      key={task.id}
      task={task}
      onClose={onClose}
    />
  );
}
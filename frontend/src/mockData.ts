export interface Task {
  id: string;
  title: string;
  description: string;
  status: 'todo' | 'in_progress' | 'review' | 'done';
  priority: 'low' | 'high';
}

export const mockTasks: Task[] = [
  { id: '1', title: 'Сделать верстку логина', description: 'Просто форма', status: 'todo', priority: 'high' },
  { id: '2', title: 'Настроить Vite', description: 'Уже готово', status: 'done', priority: 'low' },
  { id: '3', title: 'Сделать канбан', description: 'Перетаскивание карточек', status: 'in_progress', priority: 'high' },
  { id: '4', title: 'Написать ТЗ', description: 'Для аналитика', status: 'review', priority: 'low' },
];
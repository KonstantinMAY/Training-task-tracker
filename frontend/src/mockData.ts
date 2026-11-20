export interface Task {
  id: string;
  title: string;
  description: string;
  status: 'todo' | 'in_progress' | 'review' | 'done';
  priority: 'low' | 'medium' | 'high';
  deadline?: string;
}

const getDate = (offsetDays: number) => {
  const d = new Date();
  d.setDate(d.getDate() + offsetDays);
  return d.toISOString().split('T')[0];
};

export const mockTasks: Task[] = [
  { id: '1', title: 'Сделать верстку логина', description: 'Просто форма', status: 'todo', priority: 'high', deadline: getDate(0) },
  { id: '2', title: 'Настроить Vite', description: 'Уже готово', status: 'done', priority: 'low', deadline: getDate(1) },
  { id: '3', title: 'Сделать канбан', description: 'Перетаскивание карточек', status: 'in_progress', priority: 'high', deadline: getDate(5) },
  { id: '4', title: 'Написать ТЗ', description: 'Для аналитика', status: 'review', priority: 'medium', deadline: getDate(-2) },
];
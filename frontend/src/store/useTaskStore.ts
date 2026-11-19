import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { mockTasks, type Task } from '../mockData';

interface TaskState {
  tasks: Task[];
  moveTask: (taskId: string, newStatus: Task['status']) => void;
  addTask: (task: Task) => void;
  deleteTask: (taskId: string) => void;
  updateTask: (updatedTask: Task) => void;
}

export const useTaskStore = create<TaskState>()(
  persist(
    (set) => ({
      tasks: mockTasks,
      
      moveTask: (taskId, newStatus) =>
        set((state) => ({
          tasks: state.tasks.map((task) =>
            task.id === taskId ? { ...task, status: newStatus } : task
          ),
        })),

      addTask: (newTask) =>
        set((state) => ({
          tasks: [...state.tasks, newTask],
        })),

      deleteTask: (taskId) =>
        set((state) => ({
          tasks: state.tasks.filter((task) => task.id !== taskId),
        })),

      updateTask: (updatedTask) =>
        set((state) => ({
          tasks: state.tasks.map((task) =>
            task.id === updatedTask.id ? updatedTask : task
          ),
        })),
    }),
    {
      name: 'kanban-storage',
    }
  )
);
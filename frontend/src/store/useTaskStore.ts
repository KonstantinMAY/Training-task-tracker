import { create } from 'zustand';
import { apiRequest } from '../api';
import { useAuthStore } from './useAuthStore';
import type { Task } from '../mockData';

interface TaskState {
  tasks: Task[];
  isLoading: boolean;
  error: string | null;

  loadTasks: () => Promise<void>;
  addTask: (task: Omit<Task, 'id' | 'status'>) => Promise<void>;
  deleteTask: (taskId: string) => Promise<void>;
  updateTask: (task: Task) => Promise<void>;
  moveTask: (taskId: string, newStatus: Task['status']) => Promise<void>;
  resetTasks: () => void;
}

export const useTaskStore = create<TaskState>((set) => ({
  tasks: [],
  isLoading: false,
  error: null,

  loadTasks: async () => {
    set({ isLoading: true, error: null });

    try {
      const token = useAuthStore.getState().token;
      const tasks = await apiRequest<Task[]>('/api/tasks', token);

      set({ tasks, isLoading: false });
    } catch (error) {
      const errorMessage = error instanceof Error
        ? error.message
        : 'Не удалось загрузить задачи';

      set({
        error: errorMessage,
        isLoading: false,
      });
    }
  },

  addTask: async (taskData) => {
    try {
      const token = useAuthStore.getState().token;

      const newTask = await apiRequest<Task>('/api/tasks', token, {
        method: 'POST',
        body: JSON.stringify(taskData),
      });

      set((state) => ({
        tasks: [...state.tasks, newTask],
        error: null,
      }));
    } catch (error) {
      set({
        error: error instanceof Error
          ? error.message
          : 'Не удалось создать задачу',
      });
    }
  },

  deleteTask: async (taskId) => {
    try {
      const token = useAuthStore.getState().token;

      await apiRequest<void>(`/api/tasks/${taskId}`, token, {
        method: 'DELETE',
      });

      set((state) => ({
        tasks: state.tasks.filter((task) => task.id !== taskId),
        error: null,
      }));
    } catch (error) {
      const errorMessage = error instanceof Error
        ? error.message
        : 'Не удалось удалить задачу';

      set({
        error: errorMessage,
      });
    }
  },

  updateTask: async (task) => {
    try {
      const token = useAuthStore.getState().token;

      const updatedTask = await apiRequest<Task>(
        `/api/tasks/${task.id}`,
        token,
        {
          method: 'PATCH',
          body: JSON.stringify({
            title: task.title,
            description: task.description,
            priority: task.priority,
            deadline: task.deadline ?? null,
          }),
        }
      );

      set((state) => ({
        tasks: state.tasks.map((item) =>
          item.id === task.id ? updatedTask : item
        ),
        error: null,
      }));
    } catch (error) {
      set({
        error: error instanceof Error
          ? error.message
          : 'Не удалось обновить задачу',
      });
    }
  },

  moveTask: async (taskId, newStatus) => {
    try {
      const token = useAuthStore.getState().token;

      const updatedTask = await apiRequest<Task>(
        `/api/tasks/${taskId}/status`,
        token,
        {
          method: 'PATCH',
          body: JSON.stringify({ status: newStatus }),
        }
      );

      set((state) => ({
        tasks: state.tasks.map((task) =>
          task.id === taskId ? updatedTask : task
        ),
        error: null,
      }));
    } catch (error) {
      const errorMessage = error instanceof Error
        ? error.message
        : 'Не удалось переместить задачу';

      set({
        error: errorMessage,
      });
    }
  },

  resetTasks: () => {
    set({
      tasks: [],
      error: null,
      isLoading: false,
    });
  },
}));
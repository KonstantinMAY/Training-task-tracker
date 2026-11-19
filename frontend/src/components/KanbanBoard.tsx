import { useState } from 'react';
import {
  DndContext,
  DragOverlay,
  closestCorners,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  useDroppable,
} from '@dnd-kit/core';
import type { DragEndEvent, DragStartEvent } from '@dnd-kit/core';
import { SortableContext, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import type { Task } from '../mockData';
import { useTaskStore } from '../store/useTaskStore';
import EditTaskModal from './EditTaskModal';

const COLUMNS = ['todo', 'in_progress', 'review', 'done'];

const COLUMN_TITLES: Record<string, string> = {
  todo: 'Нужно сделать',
  in_progress: 'В работе',
  review: 'На проверке',
  done: 'Готово',
};

// Компонент карточки
function TaskCard({ task, onEdit }: { task: Task; onEdit: (task: Task) => void }) {
  const { attributes, listeners, setNodeRef, transform, transition } = useSortable({ id: task.id });
  const deleteTask = useTaskStore((state) => state.deleteTask);

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  const handleDelete = (e: React.MouseEvent) => {
    e.stopPropagation();
    deleteTask(task.id);
  };

  const handleEdit = (e: React.MouseEvent) => {
    e.stopPropagation();
    onEdit(task);
  };

  return (
    <div ref={setNodeRef} style={style} {...attributes} {...listeners} className="task-card">
      <div className="task-header">
        <h4>{task.title}</h4>
        <div className="task-actions">
          <button className="edit-btn" onClick={handleEdit} title="Редактировать">
            Ред.
          </button>
          <button className="delete-btn" onClick={handleDelete} title="Удалить">
            Удал.
          </button>
        </div>
      </div>
      <p>{task.description}</p>
      <span className={`priority ${task.priority}`}>{task.priority}</span>
    </div>
  );
}

// Компонент колонки
function Column({ id, tasks, onEditTask }: { id: string; tasks: Task[]; onEditTask: (task: Task) => void }) {
  const { setNodeRef } = useDroppable({ id: id });

  return (
    <div className="kanban-column">
      <h3>{COLUMN_TITLES[id]}</h3>
      <div className="column-content" ref={setNodeRef}>
        <SortableContext items={tasks.map((t) => t.id)} strategy={verticalListSortingStrategy}>
          {tasks.map((task) => (
            <TaskCard key={task.id} task={task} onEdit={onEditTask} />
          ))}
        </SortableContext>
      </div>
    </div>
  );
}

// Главный компонент
export default function KanbanBoard() {
  const tasks = useTaskStore((state) => state.tasks);
  const moveTask = useTaskStore((state) => state.moveTask);
  
  const [activeTask, setActiveTask] = useState<Task | null>(null);
  const [editingTask, setEditingTask] = useState<Task | null>(null);

  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 5 } }),
    useSensor(KeyboardSensor)
  );

  const handleDragStart = (event: DragStartEvent) => {
    const task = tasks.find((t) => t.id === event.active.id);
    if (task) setActiveTask(task);
  };

  const handleDragEnd = (event: DragEndEvent) => {
    setActiveTask(null);
    const { active, over } = event;
    if (!over) return;

    const activeId = active.id as string;
    const overId = over.id as string;

    if (activeId === overId) return;

    const activeTask = tasks.find((t) => t.id === activeId);
    if (!activeTask) return;

    if (COLUMNS.includes(overId)) {
      moveTask(activeId, overId as Task['status']);
      return;
    }

    const overTask = tasks.find((t) => t.id === overId);
    if (overTask && activeTask.status !== overTask.status) {
      moveTask(activeId, overTask.status);
    }
  };

  return (
    <DndContext
      sensors={sensors}
      collisionDetection={closestCorners}
      onDragStart={handleDragStart}
      onDragEnd={handleDragEnd}
    >
      <div className="kanban-board">
        {COLUMNS.map((col) => (
          <Column 
            key={col} 
            id={col} 
            tasks={tasks.filter((t) => t.status === col)} 
            onEditTask={(task) => setEditingTask(task)} 
          />
        ))}
      </div>
      <DragOverlay>
        {activeTask ? (
          <div className="task-card dragging">
            <h4>{activeTask.title}</h4>
          </div>
        ) : null}
      </DragOverlay>

      <EditTaskModal 
        isOpen={!!editingTask} 
        task={editingTask} 
        onClose={() => setEditingTask(null)} 
      />
    </DndContext>
  );
}
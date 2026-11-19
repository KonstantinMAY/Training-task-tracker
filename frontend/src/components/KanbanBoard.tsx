import { useDroppable } from '@dnd-kit/core';
import { useState } from 'react';
import {
  DndContext,
  DragOverlay,
  closestCorners,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
} from '@dnd-kit/core';
import type { DragEndEvent, DragStartEvent } from '@dnd-kit/core';
import { SortableContext, arrayMove, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { mockTasks } from '../mockData';
import type { Task } from '../mockData';

const COLUMNS = ['todo', 'in_progress', 'review', 'done'];

const COLUMN_TITLES: Record<string, string> = {
  todo: 'Нужно сделать',
  in_progress: 'В работе',
  review: 'На проверке',
  done: 'Готово',
};

// Компонент одной карточки
function TaskCard({ task }: { task: Task }) {
  const { attributes, listeners, setNodeRef, transform, transition } = useSortable({ id: task.id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  return (
    <div ref={setNodeRef} style={style} {...attributes} {...listeners} className="task-card">
      <h4>{task.title}</h4>
      <p>{task.description}</p>
      <span className={`priority ${task.priority}`}>{task.priority}</span>
    </div>
  );
}

function Column({ id, tasks }: { id: string; tasks: Task[] }) {
  // Делаем колонку зоной, куда можно сбрасывать
  const { setNodeRef } = useDroppable({
    id: id,
  });

  return (
    <div className="kanban-column">
      <h3>{COLUMN_TITLES[id]}</h3>
      {/* Добавляем setNodeRef сюда, чтобы вся область колонки ловила дроп */}
      <div className="column-content" ref={setNodeRef}>
        <SortableContext items={tasks.map((t) => t.id)} strategy={verticalListSortingStrategy}>
          {tasks.map((task) => (
            <TaskCard key={task.id} task={task} />
          ))}
        </SortableContext>
      </div>
    </div>
  );
}

// Главный компонент доски
export default function KanbanBoard() {
  const [tasks, setTasks] = useState<Task[]>(mockTasks);
  const [activeTask, setActiveTask] = useState<Task | null>(null);

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

    const activeId = active.id;
    const overId = over.id;

    if (activeId === overId) return;

    const activeTask = tasks.find((t) => t.id === activeId);
    if (!activeTask) return;

    // Если перетащили в другую колонку
    if (COLUMNS.includes(overId as string)) {
      setTasks((prev) =>
        prev.map((t) => (t.id === activeId ? { ...t, status: overId as Task['status'] } : t))
      );
      return;
    }

    // Если перетащили на другую карточку
    const overTask = tasks.find((t) => t.id === overId);
    if (overTask && activeTask.status !== overTask.status) {
      setTasks((prev) =>
        prev.map((t) => (t.id === activeId ? { ...t, status: overTask.status } : t))
      );
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
          <Column key={col} id={col} tasks={tasks.filter((t) => t.status === col)} />
        ))}
      </div>
      <DragOverlay>
        {activeTask ? (
          <div className="task-card dragging">
            <h4>{activeTask.title}</h4>
          </div>
        ) : null}
      </DragOverlay>
    </DndContext>
  );
}
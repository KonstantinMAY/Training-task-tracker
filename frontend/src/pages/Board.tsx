import KanbanBoard from '../components/KanbanBoard';

export default function Board() {
  return (
    <div className="app-container">
      {/* ФРОНТЕНДЕР 3: Сделай этот header красивым! Добавь лого, название и кнопку "Выйти" */}
      <header className="app-header">
        <h1>Учебный трекер задач</h1>
      </header>
      
      <main className="board-container">
        <KanbanBoard />
      </main>
    </div>
  );
}
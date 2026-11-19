import './App.css'
import KanbanBoard from './components/KanbanBoard'

function App() {
  return (
    <div className="app-container">
      <header className="app-header">
        <h1>Учебный трекер задач</h1>
      </header>
      <main className="board-container">
        <KanbanBoard />
      </main>
    </div>
  )
}

export default App
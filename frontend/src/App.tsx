import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/Login';
import Board from './pages/Board';
import './App.css';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* По умолчанию перекидываем на страницу логина */}
        <Route path="/" element={<Navigate to="/login" replace />} />
        {/* Страница входа (делает Фронтендер 2) */}
        <Route path="/login" element={<Login />} />
        {/* Сама доска (делает Тимлид + Фронтендер 3) */}
        <Route path="/board" element={<Board />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
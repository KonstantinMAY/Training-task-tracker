import { useState, useEffect } from 'react';

interface ProfileModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function ProfileModal({ isOpen, onClose }: ProfileModalProps) {
  const userEmail = localStorage.getItem('userEmail') || 'user@example.com';
  
  // Состояния для цвета и картинки
  const [avatarColor, setAvatarColor] = useState(() => {
    return localStorage.getItem('avatarColor') || '#facc15';
  });
  const [avatarImage, setAvatarImage] = useState(() => {
    return localStorage.getItem('avatarImage') || '';
  });

  // При загрузке файла конвертируем его в base64
  const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onloadend = () => {
      const base64String = reader.result as string;
      setAvatarImage(base64String);
    };
    reader.readAsDataURL(file);
  };

  const handleSave = () => {
    localStorage.setItem('avatarColor', avatarColor);
    localStorage.setItem('avatarImage', avatarImage);
    onClose();
    window.location.reload(); // Перезагружаем, чтобы шапка подхватила новые данные
  };

  const handleReset = () => {
    setAvatarImage('');
    setAvatarColor('#facc15');
  };

  if (!isOpen) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <h2>Профиль</h2>
        
        <div style={{ marginBottom: '20px', textAlign: 'center' }}>
          <p style={{ margin: '0 0 10px 0', color: 'var(--text-muted)' }}>{userEmail}</p>
          
          {/* Превью аватарки */}
          <div 
            style={{ 
              width: '80px', height: '80px', borderRadius: '50%', margin: '0 auto', 
              backgroundColor: avatarImage ? 'transparent' : avatarColor,
              backgroundImage: avatarImage ? `url(${avatarImage})` : 'none',
              backgroundSize: 'cover', backgroundPosition: 'center',
              display: 'flex', justifyContent: 'center', alignItems: 'center',
              color: '#000', fontSize: '32px', fontWeight: 'bold'
            }}
          >
            {!avatarImage && userEmail.charAt(0).toUpperCase()}
          </div>
        </div>

        <div className="modal-form">
          {/* Выбор цвета */}
          <div>
            <label style={{ fontSize: '14px' }}>Цвет аватарки:</label>
            <input 
              type="color" 
              value={avatarColor} 
              onChange={(e) => setAvatarColor(e.target.value)}
              style={{ width: '100%', height: '40px', cursor: 'pointer', marginTop: '5px' }}
            />
          </div>

          {/* Загрузка фото */}
          <div>
            <label style={{ fontSize: '14px' }}>Или загрузите фото:</label>
            <input 
              type="file" 
              accept="image/*" 
              onChange={handleImageUpload}
              style={{ width: '100%', marginTop: '5px' }}
            />
          </div>

          <div className="modal-actions" style={{ justifyContent: 'space-between' }}>
            <button type="button" onClick={handleReset} className="btn-cancel">Сбросить</button>
            <div style={{ display: 'flex', gap: '10px' }}>
              <button type="button" onClick={onClose} className="btn-cancel">Отмена</button>
              <button type="button" onClick={handleSave} className="btn-submit">Сохранить</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
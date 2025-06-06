import React, { useState, useEffect } from 'react';
import LoginForm from './components/LoginForm';
import Dashboard from './components/Dashboard';
import { authService } from './services/authService';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Verificar si hay una sesión activa al cargar la aplicación
    const checkAuthStatus = async () => {
      if (authService.isAuthenticated()) {
        try {
          const userData = await authService.getCurrentUser();
          console.log('User data from API:', userData); // Debug log
          setUser(userData.user || userData.usuario); // Intentar ambas estructuras
          setIsAuthenticated(true);
        } catch (error) {
          console.error('Error getting current user:', error); // Debug log
          // Si hay error, limpiar la sesión
          authService.logout();
          setIsAuthenticated(false);
          setUser(null);
        }
      }
      setLoading(false);
    };

    checkAuthStatus();
  }, []);

  const handleLoginSuccess = (response) => {
    console.log('Login response:', response); // Debug log
    setUser(response.usuario || response.user); // Intentar ambas estructuras
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    setUser(null);
  };

  if (loading) {
    return (
      <div style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        height: '100vh',
        fontSize: '18px',
        color: '#333'
      }}>
        Cargando...
      </div>
    );
  }

  return (
    <div className="App">
      {isAuthenticated ? (
        <Dashboard user={user} onLogout={handleLogout} />
      ) : (
        <LoginForm onLoginSuccess={handleLoginSuccess} />
      )}
    </div>
  );
}

export default App;

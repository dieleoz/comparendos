import React, { useState } from 'react';
import { authService } from '../services/authService';

const LoginForm = ({ onLoginSuccess }) => {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  // Credenciales de prueba predefinidas
  const testCredentials = [
    {
      role: 'Operador Norte Neiva',
      email: 'operador.nn@comparendos.com',
      password: 'operador123'
    },
    {
      role: 'Operador Sur Neiva',
      email: 'operador.sn@comparendos.com',
      password: 'operador123'
    },
    {
      role: 'Policía',
      email: 'police@comparendos.com',
      password: 'police123'
    },
    {
      role: 'Coordinador ITS',
      email: 'coordinador.its@comparendos.com',
      password: 'coordinador123'
    },
    {
      role: 'Regulador ANI',
      email: 'ani@comparendos.com',
      password: 'ani123'
    }
  ];

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
    // Limpiar error cuando el usuario empiece a escribir
    if (error) setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await authService.login(formData.email, formData.password);
      onLoginSuccess(response);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const fillCredentials = (credential) => {
    setFormData({
      email: credential.email,
      password: credential.password,
    });
    setError('');
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <div className="login-header">
          <h1 className="login-title">Iniciar Sesión</h1>
          <p className="login-subtitle">Sistema de Comparendos - HU-COMP-000</p>
        </div>

        {error && (
          <div className="error-message">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="email" className="form-label">
              Usuario (Email)
            </label>
            <input
              type="email"
              id="email"
              name="email"
              className="form-input"
              placeholder="Ingrese su email"
              value={formData.email}
              onChange={handleChange}
              required
              disabled={loading}
            />
          </div>

          <div className="form-group">
            <label htmlFor="password" className="form-label">
              Contraseña
            </label>
            <input
              type="password"
              id="password"
              name="password"
              className="form-input"
              placeholder="Ingrese su contraseña"
              value={formData.password}
              onChange={handleChange}
              required
              disabled={loading}
            />
          </div>

          <button
            type="submit"
            className="login-button"
            disabled={loading}
          >
            {loading ? 'Iniciando sesión...' : 'LOGIN'}
          </button>
        </form>

        <div className="credentials-section">
          <h3 className="credentials-title">🔑 Credenciales de Prueba</h3>
          {testCredentials.map((credential, index) => (
            <div
              key={index}
              className="credential-item"
              onClick={() => fillCredentials(credential)}
              style={{ cursor: 'pointer' }}
              title="Click para usar estas credenciales"
            >
              <div className="credential-role">{credential.role}</div>
              <div className="credential-email">📧 {credential.email}</div>
              <div className="credential-password">🔒 {credential.password}</div>
            </div>
          ))}
          <p style={{ fontSize: '12px', color: '#666', textAlign: 'center', marginTop: '10px' }}>
            💡 Haz click en cualquier credencial para usarla automáticamente
          </p>
        </div>
      </div>
    </div>
  );
};

export default LoginForm;

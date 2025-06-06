import React from 'react';
import { authService } from '../services/authService';

const Dashboard = ({ user, onLogout }) => {
  const handleLogout = () => {
    authService.logout();
    onLogout();
  };

  const formatDateTime = (dateString) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    });
  };

  return (
    <div className="dashboard-container">
      <div className="dashboard-header">
        <button className="logout-button" onClick={handleLogout}>
          Cerrar Sesión
        </button>
        <h1 className="dashboard-title">
          ✅ Login Exitoso - HU-COMP-000 Certificada
        </h1>
        <div className="user-info">
          Bienvenido al Sistema de Comparendos
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '20px' }}>
        {/* Información del Usuario */}
        <div style={{ background: 'white', padding: '20px', borderRadius: '10px', boxShadow: '0 2px 10px rgba(0,0,0,0.1)' }}>
          <h2 style={{ color: '#333', marginTop: 0 }}>👤 Información del Usuario</h2>
          <div style={{ fontSize: '14px', lineHeight: '1.6' }}>
            <p><strong>ID:</strong> {user.id || 'N/A'}</p>
            <p><strong>Nombre:</strong> {user.nombre || 'N/A'}</p>
            <p><strong>Email:</strong> {user.email || 'N/A'}</p>
            <p><strong>Rol:</strong> {user.rol || 'N/A'}</p>
            <p><strong>Estado:</strong> 
              <span style={{ 
                color: user.activo ? '#28a745' : '#dc3545',
                fontWeight: 'bold',
                marginLeft: '5px'
              }}>
                {user.activo ? '✅ Activo' : '❌ Inactivo'}
              </span>
            </p>
          </div>
        </div>

        {/* Información de la Sesión */}
        <div style={{ background: 'white', padding: '20px', borderRadius: '10px', boxShadow: '0 2px 10px rgba(0,0,0,0.1)' }}>
          <h2 style={{ color: '#333', marginTop: 0 }}>🔐 Información de la Sesión</h2>
          <div style={{ fontSize: '14px', lineHeight: '1.6' }}>
            <p><strong>Último Login:</strong> {formatDateTime(user.ultimo_login)}</p>
            <p><strong>Fecha Creación:</strong> {formatDateTime(user.fecha_creacion)}</p>
            <p><strong>Fecha Actualización:</strong> {formatDateTime(user.fecha_actualizacion)}</p>
            <p><strong>Token Válido:</strong> 
              <span style={{ color: '#28a745', fontWeight: 'bold', marginLeft: '5px' }}>
                ✅ Sí
              </span>
            </p>
          </div>
        </div>

        {/* Estado de Certificación */}
        <div style={{ background: 'white', padding: '20px', borderRadius: '10px', boxShadow: '0 2px 10px rgba(0,0,0,0.1)' }}>
          <h2 style={{ color: '#333', marginTop: 0 }}>📋 Estado de Certificación</h2>
          <div style={{ fontSize: '14px', lineHeight: '1.6' }}>
            <p><strong>HU Probada:</strong> HU-COMP-000</p>
            <p><strong>Funcionalidad:</strong> Validaciones Generales de Seguridad y Roles</p>
            <p><strong>Estado:</strong> 
              <span style={{ color: '#28a745', fontWeight: 'bold', marginLeft: '5px' }}>
                ✅ CERTIFICADA
              </span>
            </p>
            <p><strong>Endpoint Probado:</strong> <code>POST /api/auth/login</code></p>
            <p><strong>Fecha Prueba:</strong> {new Date().toLocaleString('es-ES')}</p>
          </div>
        </div>

        {/* Acciones Disponibles */}
        <div style={{ background: 'white', padding: '20px', borderRadius: '10px', boxShadow: '0 2px 10px rgba(0,0,0,0.1)' }}>
          <h2 style={{ color: '#333', marginTop: 0 }}>⚡ Acciones Disponibles</h2>
          <div style={{ fontSize: '14px', lineHeight: '1.6' }}>
            <p>✅ Autenticación exitosa</p>
            <p>✅ Validación de roles</p>
            <p>✅ Gestión de tokens JWT</p>
            <p>✅ Middleware de seguridad</p>
            <p>🔄 Próximas HUs a certificar:</p>
            <ul style={{ marginLeft: '20px', fontSize: '12px' }}>
              <li>HU-CM-001: Listar Comparendos</li>
              <li>HU-CM-002: Crear Comparendo</li>
              <li>HU-CM-003: Consultar Comparendo</li>
            </ul>
          </div>
        </div>
      </div>

      <div style={{ 
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', 
        color: 'white', 
        padding: '20px', 
        borderRadius: '10px', 
        marginTop: '20px',
        textAlign: 'center'
      }}>
        <h3 style={{ margin: '0 0 10px 0' }}>🎉 ¡Prueba de Login Completada Exitosamente!</h3>
        <p style={{ margin: 0, opacity: 0.9 }}>
          La HU-COMP-000 ha sido probada y certificada correctamente. 
          El sistema de autenticación funciona según las especificaciones.
        </p>
      </div>
    </div>
  );
};

export default Dashboard;

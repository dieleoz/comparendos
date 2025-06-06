import axios from 'axios';

// En producción (Docker), usar el proxy de nginx (/api)
// En desarrollo, usar directamente el backend (http://localhost:6002)
const API_BASE_URL = process.env.NODE_ENV === 'production' 
  ? '/api' 
  : (process.env.REACT_APP_API_URL || 'http://localhost:6002');

// Crear instancia de axios con configuración base
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor para incluir token en las peticiones
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Interceptor para manejar respuestas y errores
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const authService = {
  // Login de usuario
  login: async (email, password) => {
    try {
      const response = await api.post('/auth/login', {
        email: email,  
        password,
      });
      
      if (response.data.token) {
        localStorage.setItem('token', response.data.token);
        localStorage.setItem('user', JSON.stringify(response.data.usuario));
      }
      
      return response.data;
    } catch (error) {
      console.error('Error en login:', error);
      console.error('Response:', error.response);
      console.error('Status:', error.response?.status);
      console.error('Data:', error.response?.data);
      console.error('Message:', error.response?.data?.message);
      
      throw new Error(
        error.response?.data?.message || 
        `Error ${error.response?.status || 'desconocido'}: ${error.message}`
      );
    }
  },

  // Obtener información del usuario actual
  getCurrentUser: async () => {
    try {
      const response = await api.get('/auth/me');
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message || 'Error al obtener información del usuario'
      );
    }
  },

  // Cerrar sesión
  logout: () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  },

  // Verificar si el usuario está autenticado
  isAuthenticated: () => {
    return !!localStorage.getItem('token');
  },

  // Obtener usuario del localStorage
  getStoredUser: () => {
    const user = localStorage.getItem('user');
    return user ? JSON.parse(user) : null;
  },
};

export default api;

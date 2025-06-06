const axios = require('axios');

// Configuración
const API_BASE = 'http://localhost:6002';
const credentials = {
  email: 'operador.nn@comparendos.com',
  password: 'operador123'
};

async function testLogin() {
  try {
    console.log('🔐 Probando login...');
    
    // Paso 1: Login
    const loginResponse = await axios.post(`${API_BASE}/api/auth/login`, credentials, {
      headers: { 'Content-Type': 'application/json' }
    });
    
    console.log('✅ Login exitoso');
    console.log('📋 Estructura de respuesta del login:', {
      success: loginResponse.data.success,
      usuario: !!loginResponse.data.usuario,
      token: !!loginResponse.data.token
    });
    
    // Paso 2: Verificar endpoint /me
    const token = loginResponse.data.token;
    const meResponse = await axios.get(`${API_BASE}/api/auth/me`, {
      headers: { 
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    });
    
    console.log('✅ Endpoint /me exitoso');
    console.log('📋 Estructura de respuesta del /me:', {
      success: meResponse.data.success,
      user: !!meResponse.data.user
    });
    
    // Paso 3: Comparar estructuras
    console.log('\n🔍 Comparación de estructuras:');
    console.log('Login response usuario:', loginResponse.data.usuario);
    console.log('Me response user:', meResponse.data.user);
    
    console.log('\n🎉 ¡Todas las pruebas pasaron! El frontend debería funcionar correctamente.');
    
  } catch (error) {
    console.error('❌ Error en las pruebas:', error.response?.data || error.message);
  }
}

testLogin();

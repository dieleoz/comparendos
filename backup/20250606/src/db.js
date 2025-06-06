const { Pool } = require('pg');

// ⚠️ NO MODIFICAR ESTA CONFIGURACIÓN BAJO NINGÚN CIRCUNSTANCIA
// Son valores críticos para el funcionamiento en producción
const pool = new Pool({
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  max: 20, // Número máximo de conexiones
  idleTimeoutMillis: 30000, // Tiempo máximo de inactividad
  connectionTimeoutMillis: 2000, // Tiempo máximo para establecer conexión
});

// Método para verificar la conexión
const checkConnection = async () => {
  try {
    const client = await pool.connect();
    const res = await client.query('SELECT 1');
    console.log('✅ Conexión exitosa a la base de datos');
    client.release();
    return true;
  } catch (error) {
    console.error('❌ Error al conectar a la base de datos:', error.message);
    return false;
  }
};

// Verificar conexión al iniciar
checkConnection();

module.exports = {
  pool,
  checkConnection
};

const express = require('express');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');
const YAML = require('yamljs');
const path = require('path');
require('dotenv').config();
const { pool } = require('./db');

// La conexión a la base de datos se maneja en db.js
// No necesitamos conectarnos aquí explícitamente

const app = express();

// Middleware global
app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, curl, etc.)
    if (!origin) return callback(null, true);
    
    const allowedOrigins = [
      'http://localhost:60005',
      'http://10.11.10.96:60005',
      'http://localhost:30005',
      'http://10.11.10.96:30005',
      'https://comparendos.autovia360.cc'
    ];
    
    // Check if the origin is in the allowed origins
    if (allowedOrigins.indexOf(origin) !== -1) {
      return callback(null, true);
    }
    
    // Allow any localhost origin for development
    if (origin.includes('localhost') || origin.includes('127.0.0.1') || origin.includes('10.11.10.96')) {
      return callback(null, true);
    }
    
    const msg = 'The CORS policy for this site does not allow access from the specified Origin.';
    return callback(new Error(msg), false);
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  exposedHeaders: ['X-Total-Count', 'X-Page-Count']
}));
app.use(express.json({
  limit: '10mb',
  type: 'application/json',
  strict: true
}));
app.use(express.urlencoded({ extended: true }));

// Configuración de Swagger
const swaggerSpec = YAML.load('/app/documentation/api/swagger.yaml');

// Configurar Swagger UI
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  explorer: true,
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'Sistema de Comparendos - API Docs',
  swaggerOptions: {
    persistAuthorization: true,
    displayRequestDuration: true,
    filter: true,
    showExtensions: true,
    showCommonExtensions: true
  }
}));

// Endpoint para obtener la especificación JSON
app.get('/api-docs.json', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpec);
});

// Importar rutas y middleware
console.log('=== LOADING ROUTES ===');
const authRoutes = require('./routes/auth.routes');
const authMiddleware = require('./middleware/auth.middleware');
console.log('Auth routes loaded successfully');

// Middleware para loggear todas las peticiones
app.use((req, res, next) => {
    console.log(`=== REQUEST: ${req.method} ${req.url} ===`);
    console.log('Body:', req.body);
    console.log('Headers:', req.headers);
    next();
});

// Rutas públicas (sin autenticación)
console.log('=== REGISTERING AUTH ROUTES ===');
app.use('/api/auth', authRoutes);
console.log('Auth routes registered at /api/auth');

// Rutas protegidas (aplicar middleware solo a rutas específicas, no a /auth)
app.use('/api/ping', authMiddleware.verifyToken, require('./routes/pingRoutes'));

// Ruta raíz
app.get('/', (req, res) => {
    res.json({ message: 'API Comparendos está funcionando' });
});

// Manejo de errores
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        success: false,
        message: 'Error interno del servidor'
    });
});

const PORT = process.env.PORT || 6002;
app.listen(PORT, () => {
    console.log(`🚀 Servidor funcionando en puerto ${PORT}`);
});

module.exports = app;

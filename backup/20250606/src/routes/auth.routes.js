const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { verifyToken } = require('../middleware/auth.middleware');

console.log('=== AUTH ROUTES LOADED ===');

// Middleware para loggear todas las peticiones a auth
router.use((req, res, next) => {
    console.log('=== AUTH ROUTE MIDDLEWARE ===');
    console.log('Route:', req.path);
    console.log('Method:', req.method);
    console.log('Body:', req.body);
    next();
});

// Rutas públicas
router.post('/login', (req, res, next) => {
    console.log('=== LOGIN ROUTE HIT ===');
    console.log('About to call authController.login');
    authController.login(req, res, next);
});

// Rutas protegidas
router.get('/me', verifyToken, authController.me);
router.post('/logout', verifyToken, authController.logout);

module.exports = router;

const express = require('express');
const router = express.Router();
const usuariosController = require('../controllers/usuarios.controller');
const { verifyToken } = require('../middleware/auth.middleware');

// Rutas protegidas
router.get('/', verifyToken, usuariosController.getAll);

module.exports = router;

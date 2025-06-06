const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { pool } = require('../db');

const authController = {
    login: async (req, res) => {
        try {
            console.log('=== AUTH CONTROLLER LOGIN START ===');
            console.log('Request body received:', JSON.stringify(req.body, null, 2));
            console.log('Request headers:', JSON.stringify(req.headers, null, 2));
            console.log('Request method:', req.method);
            console.log('Request URL:', req.url);
            
            // Verificar si el body es un objeto
            if (typeof req.body !== 'object' || req.body === null) {
                console.error('❌ Request body is not an object');
                console.error('Body type:', typeof req.body);
                console.error('Body value:', req.body);
                return res.status(400).json({
                    success: false,
                    message: 'Body de la solicitud debe ser un objeto'
                });
            }
            
            // Verificar el tipo del body completo
            console.log('=== BODY TYPE CHECK ===');
            console.log('Body type:', typeof req.body);
            console.log('Body raw:', JSON.stringify(req.body));
            
            // Verificar si el body es un objeto
            if (typeof req.body !== 'object' || req.body === null) {
                console.error('❌ Body is not a valid object');
                console.error('Body type:', typeof req.body);
                console.error('Body value:', req.body);
                return res.status(400).json({
                    success: false,
                    message: 'Body de la solicitud debe ser un objeto válido'
                });
            }
            
            const { email, password } = req.body;
            
            // Verificar el tipo de cada propiedad antes de la desestructuración
            console.log('=== PROPERTY TYPE CHECK ===');
            console.log('Email type:', typeof req.body.email);
            console.log('Password type:', typeof req.body.password);
            
            console.log('Extracted email:', email);
            console.log('Extracted password:', password ? '***' : 'undefined');
            console.log('Password type:', typeof password);
            console.log('Password raw value:', password);
            
            // Verificar si la contraseña es una cadena de texto
            if (typeof password !== 'string') {
                console.error('❌ Password is not a string');
                console.error('Password type:', typeof password);
                console.error('Password value:', password);
                return res.status(400).json({
                    success: false,
                    message: 'La contraseña debe ser una cadena de texto'
                });
            }

            if (!email || !password) {
                console.log('=== VALIDATION FAILED ===');
                console.log('Email provided:', !!email);
                console.log('Password provided:', !!password);
                return res.status(400).json({ 
                    success: false, 
                    message: 'Email y contraseña son requeridos' 
                });
            }

            // Validar que la contraseña sea una cadena de texto
            if (typeof password !== 'string') {
                console.log('=== INVALID PASSWORD TYPE ===');
                console.log('Password type:', typeof password);
                return res.status(400).json({
                    success: false,
                    message: 'La contraseña debe ser una cadena de texto'
                });
            }
            
            console.log('=== VALIDATION PASSED ===');

            const user = await pool.query(
                'SELECT * FROM usuarios WHERE email = $1',
                [email]
            );
            console.log('Query result:', user);
            console.log('User found:', user.rows[0]);

            if (!user.rows.length) {
                console.log('=== USER NOT FOUND ===');
                return res.status(401).json({ 
                    success: false, 
                    message: 'Credenciales inválidas' 
                });
            }

            const userData = user.rows[0];
            console.log('=== USER DATA ===');
            console.log('User ID:', userData.id);
            console.log('User Email:', userData.email);
            console.log('User Password Hash:', userData.password_hash);
            console.log('User Role:', userData.rol);

            if (!userData.password_hash) {
                console.log('=== NO PASSWORD HASH ===');
                return res.status(401).json({ 
                    success: false, 
                    message: 'Credenciales inválidas' 
                });
            }

            console.log('=== BCRYPT COMPARISON DEBUG ===');
            console.log('Password to compare:', password);
            console.log('Password type:', typeof password);
            console.log('Password length:', password ? password.length : 'null');
            console.log('Hash from DB:', userData.password_hash);
            console.log('Hash type:', typeof userData.password_hash);
            console.log('Hash length:', userData.password_hash ? userData.password_hash.length : 'null');
            
            // Asegurar que tanto password como hash sean strings
            const passwordStr = String(password);
            const hashStr = String(userData.password_hash);
            
            console.log('=== CONVERTED VALUES ===');
            console.log('Password string:', passwordStr);
            console.log('Password string type:', typeof passwordStr);
            console.log('Hash string:', hashStr);
            console.log('Hash string type:', typeof hashStr);
            console.log('Password string length:', passwordStr.length);
            console.log('Hash string length:', hashStr.length);
            
            // Verificación adicional de tipos antes de bcrypt.compare
            if (typeof passwordStr !== 'string') {
                throw new Error(`Password is not a string: ${typeof passwordStr}`);
            }
            if (typeof hashStr !== 'string') {
                throw new Error(`Hash is not a string: ${typeof hashStr}`);
            }
            
            console.log('=== ABOUT TO CALL BCRYPT.COMPARE ===');
            console.log('bcrypt.compare arguments:');
            console.log('  arg1 (password):', passwordStr);
            console.log('  arg1 type:', typeof passwordStr);
            console.log('  arg1 constructor:', passwordStr.constructor.name);
            console.log('  arg2 (hash):', hashStr);
            console.log('  arg2 type:', typeof hashStr);
            console.log('  arg2 constructor:', hashStr.constructor.name);
            
            // Verificación extrema de tipos
            console.log('  arg1 === string?', passwordStr === String(passwordStr));
            console.log('  arg2 === string?', hashStr === String(hashStr));
            console.log('  arg1 JSON:', JSON.stringify(passwordStr));
            console.log('  arg2 JSON:', JSON.stringify(hashStr));
            
            // Verificar la contraseña usando bcrypt
            const validPassword = await bcrypt.compare(passwordStr, hashStr);
            
            console.log('=== PASSWORD VERIFICATION ===');
            console.log('Provided password:', password);
            console.log('Is password valid:', validPassword);
            
            if (!validPassword) {
                console.log('=== INVALID PASSWORD ===');
                return res.status(401).json({ 
                    success: false, 
                    message: 'Credenciales inválidas' 
                });
            }

            console.log('=== PASSWORD VALID ===');
            console.log('Generating token with secret:', process.env.JWT_SECRET);
            
            if (!process.env.JWT_SECRET) {
                console.error('=== JWT_SECRET NOT SET ===');
                throw new Error('JWT_SECRET environment variable is not set');
            }

            const token = jwt.sign(
                { 
                    id: userData.id,
                    email: userData.email,
                    rol: userData.rol
                },
                process.env.JWT_SECRET,
                { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
            );
            console.log('Generated token:', token);
            
            return res.json({
                success: true,
                usuario: {
                    id: userData.id,
                    email: userData.email,
                    rol: userData.rol
                },
                token: token,
                expires_in: 86400
            });
        } catch (error) {
            console.error('=== ERROR IN LOGIN ===');
            console.error('Error message:', error.message);
            console.error('Error stack:', error.stack);
            return res.status(500).json({
                success: false,
                message: 'Error interno del servidor'
            });
        }
    },

    me: async (req, res) => {
        try {
            res.json({ 
                success: true,
                user: req.user
            });
        } catch (error) {
            console.error('Error en me:', error);
            res.status(500).json({ 
                success: false, 
                message: 'Error interno del servidor' 
            });
        }
    },

    logout: (req, res) => {
        res.json({ 
            success: true,
            message: 'Sesión cerrada correctamente'
        });
    }
};

module.exports = authController;

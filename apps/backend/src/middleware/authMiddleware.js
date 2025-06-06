const jwt = require('jsonwebtoken');

const verificarTokenJWT = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ error: 'Token no proporcionado' });
        }

        const token = authHeader.split(' ')[1];
        if (!token) {
            return res.status(401).json({ error: 'Token inválido' });
        }

        try {
            const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_key');
            req.usuario = decoded;
            next();
        } catch (err) {
            return res.status(401).json({ error: 'Token inválido o expirado' });
        }
    } catch (error) {
        return res.status(500).json({ error: 'Error interno del servidor' });
    }
};

module.exports = verificarTokenJWT;

const jwt = require('jsonwebtoken');

const authMiddleware = {
    verifyToken: (req, res, next) => {
        // Excluir rutas públicas específicas
        const publicPaths = ['/api/auth/login', '/api/auth/register'];
        
        if (publicPaths.includes(req.path)) {
            return next();
        }
        
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({
                success: false,
                message: 'Token no proporcionado'
            });
        }
        
        const token = authHeader.split(' ')[1];
        if (!token) {
            return res.status(401).json({
                success: false,
                message: 'Token inválido'
            });
        }
        
        try {
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            req.user = decoded;
            next();
        } catch (err) {
            return res.status(401).json({
                success: false,
                message: 'Token inválido o expirado'
            });
        }
    },
    
    checkRole: (roles) => {
        return (req, res, next) => {
            if (!roles.includes(req.user.rol)) {
                return res.status(403).json({
                    success: false,
                    message: 'No tiene permisos para esta operación'
                });
            }
            next();
        };
    },
    
    checkStationAccess: (req, res, next) => {
        if (!req.user.id_estacion) {
            return res.status(403).json({
                success: false,
                message: 'No tiene asignada una estación'
            });
        }
        next();
    }
};

module.exports = authMiddleware;

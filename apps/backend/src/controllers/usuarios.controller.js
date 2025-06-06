const { pool } = require('../db');

const usuariosController = {
    getAll: async (req, res) => {
        try {
            const { page = 1, limit = 20 } = req.query;
            const offset = (page - 1) * limit;

            const { rows: usuarios, rowCount } = await pool.query(
                'SELECT id, nombre, email, activo, telefono, cargo, rol, created_at, updated_at 
                 FROM usuarios 
                 WHERE activo = true 
                 ORDER BY created_at DESC 
                 LIMIT $1 OFFSET $2',
                [limit, offset]
            );

            const totalPages = Math.ceil(rowCount / limit);

            res.header('X-Total-Count', rowCount);
            res.header('X-Page-Count', totalPages);

            return res.json(usuarios);
        } catch (error) {
            console.error('Error al obtener usuarios:', error);
            return res.status(500).json({
                success: false,
                message: 'Error al obtener usuarios'
            });
        }
    }
};

module.exports = usuariosController;

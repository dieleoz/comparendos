const { pool } = require('../db');

const auditService = {
    // Registrar una acción en el sistema de auditoría
    logAction: async (userId, action, details) => {
        try {
            await pool.query(
                'INSERT INTO auditoria (id_usuario, accion, detalles, fecha) VALUES ($1, $2, $3, NOW())',
                [userId, action, details]
            );
        } catch (error) {
            console.error('Error al registrar auditoría:', error);
            throw error;
        }
    },

    // Obtener registro de auditoría
    getAuditLog: async (options = {}) => {
        try {
            const { userId, startDate, endDate, action, limit = 100 } = options;

            let query = 'SELECT * FROM auditoria WHERE 1=1';
            const values = [];

            if (userId) {
                query += ' AND id_usuario = $1';
                values.push(userId);
            }

            if (startDate) {
                query += ' AND fecha >= $' + (values.length + 1);
                values.push(startDate);
            }

            if (endDate) {
                query += ' AND fecha <= $' + (values.length + 1);
                values.push(endDate);
            }

            if (action) {
                query += ' AND accion = $' + (values.length + 1);
                values.push(action);
            }

            query += ' ORDER BY fecha DESC LIMIT $' + (values.length + 1);
            values.push(limit);

            const result = await pool.query(query, values);
            return result.rows;
        } catch (error) {
            console.error('Error al obtener registro de auditoría:', error);
            throw error;
        }
    }
};

module.exports = auditService;

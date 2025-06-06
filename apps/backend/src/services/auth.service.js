const bcryptjs = require('bcryptjs');
const path = require('path');
const { pool } = require(path.join(__dirname, './db'));

const authService = {
  // Verificar credenciales de usuario
  async validateCredentials(email, password) {
    try {
      const client = await pool.connect();
      try {
        const result = await client.query(
          'SELECT id, email, rol, password_hash FROM usuarios WHERE email = $1',
          [email]
        );
        
        if (result.rows.length === 0) {
          client.release();
          return null;
        }

        const user = result.rows[0];
        const validPassword = await bcryptjs.compare(password, user.password_hash);
        
        client.release();
        
        if (validPassword) {
          return {
            id: user.id,
            email: user.email,
            rol: user.rol
          };
        }
        
        return null;
      } catch (error) {
        client.release();
        throw error;
      }
    } catch (error) {
      throw error;
    }
  },

  // Generar token JWT
  generateToken(user) {
    const { id, username, role } = user;
    const payload = { id, username, role };
    const token = jwt.sign(payload, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN
    });
    return token;
  },

  // Verificar token JWT
  verifyToken(token) {
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      return decoded;
    } catch (error) {
      throw error;
    }
  }
};

module.exports = authService;

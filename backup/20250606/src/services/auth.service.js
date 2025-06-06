const path = require('path');
const { pool } = require(path.join(__dirname, './db'));

const authService = {
  // Verificar credenciales de usuario
  async validateCredentials(username, password) {
    try {
      const client = await pool.connect();
      try {
        const result = await client.query(
          'SELECT id, username, role FROM users WHERE username = $1 AND password = crypt($2, password)',
          [username, password]
        );
        
        client.release();
        return result.rows[0];
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

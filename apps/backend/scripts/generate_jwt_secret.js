const crypto = require('crypto');

// Generar una clave segura de 32 bytes (256 bits)
const secret = crypto.randomBytes(32).toString('hex');

console.log('Nueva clave JWT segura:', secret);
console.log('Longitud:', secret.length, 'bytes');

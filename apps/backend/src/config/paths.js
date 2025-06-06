const path = require('path');

module.exports = {
  baseDir: path.join(__dirname, '..'),
  controllersDir: path.join(__dirname, '../controllers'),
  servicesDir: path.join(__dirname, '../services'),
  modelsDir: path.join(__dirname, '../models'),
  middlewareDir: path.join(__dirname, '../middleware'),
  utilsDir: path.join(__dirname, '../utils'),
  dbDir: path.join(__dirname, '../db'),
  routesDir: path.join(__dirname, '../routes')
};

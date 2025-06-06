# 🧪 HU-COMP-000 Test Suite

Este directorio contiene las pruebas y documentación relacionada con la Historia de Usuario COMP-000 (Validaciones Generales de Seguridad y Roles).

## 📁 Estructura

```
tests/hu-comp-000/
├── README.md                 # Este archivo
├── DEBUGGING_REPORT.md      # Reporte detallado de debugging
├── test_login_api.js        # Script de prueba de API
└── test_results/            # Resultados de pruebas (futuro)
```

## 🎯 Objetivo de las Pruebas

Verificar que el sistema de autenticación funciona correctamente:

- ✅ Login de usuarios
- ✅ Validación de tokens JWT
- ✅ Endpoint `/auth/me`
- ✅ Manejo de errores
- ✅ Interfaz de usuario

## 🚀 Ejecutar Pruebas

### 🔧 Configuración de Puertos

Este proyecto utiliza Docker para evitar conflictos de puertos:

- **Backend**: http://localhost:6002
- **Frontend Producción**: http://localhost:60005 (Recomendado)
- **Frontend Desarrollo**: http://localhost:6000 (Con hot reload)

**Nota**: El puerto 3000 NO se utiliza externamente en este proyecto para evitar conflictos con otros proyectos React.

### Prueba de API (Backend)
```bash
cd /home/administrador/docker/comparendos/apps/frontend/tests/hu-comp-000
npm install axios  # Solo la primera vez
node test_login_api.js
```

### Prueba Manual (Frontend)
1. Abrir: http://localhost:60005 (Producción Docker) o http://localhost:6000 (Desarrollo Docker)
2. Hacer click en cualquier credencial de prueba
3. Verificar que el dashboard carga sin errores
4. Verificar que la información del usuario se muestra correctamente

## 🔑 Credenciales de Prueba

```javascript
const testCredentials = [
  {
    role: 'Operador Norte Neiva',
    email: 'operador.nn@comparendos.com',
    password: 'operador123'
  },
  {
    role: 'Operador Sur Neiva', 
    email: 'operador.sn@comparendos.com',
    password: 'operador123'
  },
  {
    role: 'Policía',
    email: 'police@comparendos.com', 
    password: 'police123'
  },
  {
    role: 'Coordinador ITS',
    email: 'coordinador.its@comparendos.com',
    password: 'coordinador123'
  },
  {
    role: 'Regulador ANI',
    email: 'ani@comparendos.com',
    password: 'ani123'
  }
];
```

## 📊 Resultados Esperados

### Respuesta de Login
```json
{
  "success": true,
  "usuario": {
    "id": 41,
    "email": "operador.nn@comparendos.com",
    "rol": 2
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 86400
}
```

### Respuesta de /auth/me
```json
{
  "success": true,
  "user": {
    "id": 41,
    "email": "operador.nn@comparendos.com",
    "rol": 2,
    "iat": 1749236816,
    "exp": 1749323216
  }
}
```

## 🐛 Problemas Conocidos y Soluciones

Ver `DEBUGGING_REPORT.md` para detalles completos sobre:

- Error `Cannot read properties of undefined (reading 'id')`
- Inconsistencias en estructuras de datos
- Soluciones implementadas

## 📝 Log de Cambios

### 6 de Junio 2025
- ✅ Creada estructura de pruebas
- ✅ Solucionado error de propiedades undefined
- ✅ Implementadas validaciones defensivas
- ✅ Documentado proceso de debugging
- ✅ HU-COMP-000 certificada
- ✅ Actualizada configuración de puertos (eliminado puerto 3000)
- ✅ Scripts de testing actualizados para usar puertos Docker correctos

## 🧪 Ejecución de Pruebas Automatizadas

### Script Automatizado Completo
```bash
# Ejecutar todas las pruebas de HU-COMP-000
cd /home/administrador/docker/comparendos/apps/frontend/tests/hu-comp-000
./run-tests.sh
```

### Pruebas Individuales

#### 1. Prueba de Regresión del Error
```bash
# Verifica que el error esté completamente resuelto
node error-resolution.js
```

#### 2. Compilación Frontend
```bash
cd /home/administrador/docker/comparendos/apps/frontend
npm run build
```

## 📋 Checklist de Validación

- [ ] Backend corriendo en puerto 6002
- [ ] Frontend corriendo en puerto 60005 (Producción) o 6000 (Desarrollo)
- [ ] Frontend compila sin errores
- [ ] Login endpoint retorna estructura correcta
- [ ] Me endpoint retorna estructura correcta
- [ ] Dashboard.js contiene validación defensiva
- [ ] Dashboard.js usa optional chaining
- [ ] App.js maneja ambas estructuras de datos
- [ ] Aplicación carga sin errores en navegador
- [ ] Login funciona correctamente en UI

---

**Mantenido por:** Team Dev - Sistema de Comparendos  
**Última actualización:** 6 de Junio 2025

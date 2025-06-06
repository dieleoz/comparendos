# 📚 README SWAGGER - Sistema de Comparendos

## 🚨 GUÍA COMPLETA DE SWAGGER - NUNCA MÁS PROBLEMAS

Esta guía está diseñada para evitar los problemas recurrentes con Swagger cada vez que se cambia de HU. **SIGUE ESTA GUÍA AL PIE DE LA LETRA**.

---

## 📦 DEPENDENCIAS REQUERIDAS

### 1. Dependencias NPM (package.json)
```json
{
  "swagger-jsdoc": "^6.2.8",
  "swagger-ui-express": "^4.6.3",
  "yamljs": "^0.3.0"
}
```

### 2. Instalación
```bash
cd /home/administrador/docker/comparendos/apps/backend
npm install swagger-jsdoc@6.2.8 swagger-ui-express@4.6.3 yamljs@0.3.0
```

---

## 📁 ESTRUCTURA DE ARCHIVOS SWAGGER

```
/home/administrador/docker/comparendos/
├── documentation/
│   └── api/
│       ├── swagger.yaml                 # ← ARCHIVO PRINCIPAL MONOLÍTICO
│       └── hu-specs/                    # ← ESPECIFICACIONES POR HU
│           ├── hu-comp-000.yaml         # HU-COMP-000 (Autenticación y Roles)
│           ├── hu-comp-001.yaml         # HU-COMP-001 (Gestión de Vehículos)
│           ├── hu-comp-002.yaml         # HU-COMP-002 (Registro de Eventos de Pesaje)
│           ├── hu-comp-003.yaml         # HU-COMP-003 (Generación de Comparendos)
│           └── hu-comp-004.yaml         # HU-COMP-004 (Reportes y Auditoría)
└── apps/backend/
    ├── src/
    │   └── app.js                       # ← CONFIGURACIÓN SWAGGER
    └── documentation/                   # ← COPIA PARA DOCKER
        └── api/
            └── swagger.yaml             # ← COPIA DEL PRINCIPAL
```

---

## ⚙️ CONFIGURACIÓN EN APP.JS

### Configuración Completa (apps/backend/src/app.js)
```javascript
// Swagger Dependencies
const swaggerUi = require('swagger-ui-express');
const swaggerJSDoc = require('swagger-jsdoc');
const YAML = require('yamljs');
const path = require('path');

// Swagger Configuration
const swaggerSpec = YAML.load(path.join(__dirname, '../documentation/api/swagger.yaml'));

// Swagger UI Options
const swaggerOptions = {
  explorer: true,
  swaggerOptions: {
    persistAuthorization: true,
    docExpansion: 'list',
    defaultModelsExpandDepth: 1,
    defaultModelExpandDepth: 1
  }
};

// Swagger Routes
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, swaggerOptions));
app.get('/api-docs.json', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpec);
});
```

---

## 🔧 PROCESO DE ACTUALIZACIÓN SWAGGER

### 1. Al Certificar una Nueva HU
```bash
# 1. Actualizar la HU específica
nano /home/administrador/docker/comparendos/documentation/api/hu-specs/hu-comp-XXX.yaml

# 2. Actualizar el archivo principal
nano /home/administrador/docker/comparendos/documentation/api/swagger.yaml

# 3. Copiar al backend para Docker
cp /home/administrador/docker/comparendos/documentation/api/swagger.yaml \
   /home/administrador/docker/comparendos/apps/backend/documentation/api/swagger.yaml

# 4. Reconstruir contenedor
cd /home/administrador/docker/comparendos
docker-compose build comparendos-back

# 5. Reiniciar servicio
docker-compose restart comparendos-back

# 6. Verificar funcionamiento
curl -I http://localhost:6002/api-docs
```

### 2. Verificación Post-Actualización
```bash
# Verificar que Swagger carga
curl -s http://localhost:6002/api-docs.json | jq '.info.title'

# Verificar que la HU específica está integrada
curl -s http://localhost:6002/api-docs.json | jq '.paths | keys[]' | grep -E "(auth|vehiculos|pesajes|comparendos|reportes)"
```

---

## 🏗️ TEMPLATE PARA ARCHIVO SWAGGER PRINCIPAL

### Estructura Base (documentation/api/swagger.yaml)
```yaml
openapi: 3.0.3
info:
  title: Sistema de Comparendos - API Principal
  description: |
    ## 🚨 Sistema Integral de Gestión de Comparendos
    
    ### 🏗️ Estado de Certificación
    - **HU-COMP-000**: ✅ CERTIFICADA Y COMPLETADA (Autenticación y Roles)
      - 🔐 Sistema de autenticación JWT implementado
      - 🔑 Roles y permisos configurados
      - 📝 Documentación actualizada
      - ✅ Scripts de prueba funcionando
    - **HU-COMP-001**: ⏳ En Desarrollo (Gestión de Vehículos)
    - **HU-COMP-002**: ⏳ Pendiente (Registro de Eventos de Pesaje)
    - **HU-COMP-003**: ⏳ Pendiente (Generación de Comparendos)
    - **HU-COMP-004**: ⏳ Pendiente (Reportes y Auditoría)
    
  version: 1.0.0
  contact:
    name: Sistema de Comparendos
    email: admin@comparendos.com

servers:
  - url: http://localhost:6002/api
    description: Servidor de Desarrollo

security:
  - BearerAuth: []

tags:
  - name: authentication
    description: Autenticación y gestión de sesiones
  - name: vehiculos
    description: Gestión de vehículos de carga
  - name: pesajes
    description: Registro de eventos de pesaje
  - name: comparendos
    description: Generación y gestión de comparendos
  - name: reportes
    description: Reportes y auditoría
  - name: sistema
    description: Endpoints del sistema y salud

paths:
  # Sistema
  /ping:
    get:
      tags: [sistema]
      summary: Verificar estado del servidor
      security: []
      responses:
        '200':
          description: Servidor operativo
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    type: string
                    example: "pong"

  # HU-COMP-000: Autenticación (INTEGRAR CUANDO ESTÉ CERTIFICADA)
  /auth/login:
    post:
      tags: [authentication]
      summary: Iniciar sesión en el sistema
      security: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                email:
                  type: string
                  format: email
                password:
                  type: string
                  minLength: 6
      responses:
        '200':
          description: Login exitoso
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  usuario:
                    type: object
                    properties:
                      id:
                        type: integer
                      email:
                        type: string
                      rol:
                        type: string
                  token:
                    type: string
                  expires_in:
                    type: integer

components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: 'JWT token obtenido del endpoint /auth/login'
```

---

## 🚨 SOLUCIÓN A ERRORES COMUNES

### Error: "Unable to render this definition"
**Causa**: Archivo swagger.yaml vacío o formato inválido
**Solución**:
```bash
# 1. Verificar que el archivo no esté vacío
ls -la /home/administrador/docker/comparendos/documentation/api/swagger.yaml

# 2. Si está vacío, recrearlo
cp /home/administrador/docker/comparendos/apps/backend/tests/hu-comp-000/swagger/hu-comp-000.yaml \
   /home/administrador/docker/comparendos/documentation/api/swagger.yaml

# 3. Copiar al backend
cp /home/administrador/docker/comparendos/documentation/api/swagger.yaml \
   /home/administrador/docker/comparendos/apps/backend/documentation/api/swagger.yaml

# 4. Reconstruir
docker-compose build comparendos-back && docker-compose restart comparendos-back
```

### Error: "Cannot GET /api-docs"
**Causa**: Configuración incorrecta en app.js
**Solución**:
```bash
# 1. Verificar configuración en app.js
grep -A 10 "swagger" /home/administrador/docker/comparendos/apps/backend/src/app.js

# 2. Si falta configuración, agregarla según la plantilla arriba
# 3. Reconstruir contenedor
```

### Error: Referencias $ref no resueltas
**Causa**: Referencias incorrectas entre archivos
**Solución**:
```bash
# Usar paths absolutos en lugar de referencias $ref por ahora
# Integrar todo en el archivo principal swagger.yaml
```

---

## 📋 CHECKLIST PRE-CERTIFICACIÓN HU

### Antes de Certificar cualquier HU:
- [ ] ✅ Dependencias NPM instaladas
- [ ] ✅ Archivo swagger.yaml principal existe y no está vacío
- [ ] ✅ Configuración en app.js correcta
- [ ] ✅ Contenedor reconstruido
- [ ] ✅ Servicio reiniciado
- [ ] ✅ Swagger UI accesible en http://localhost:6002/api-docs
- [ ] ✅ JSON API accesible en http://localhost:6002/api-docs.json

### Durante la Certificación:
- [ ] ✅ HU específica documentada en hu-specs/
- [ ] ✅ Endpoints integrados en swagger.yaml principal
- [ ] ✅ Ejemplos de request/response incluidos
- [ ] ✅ Códigos de error documentados
- [ ] ✅ Autenticación especificada correctamente

### Post-Certificación:
- [ ] ✅ Swagger actualizado y funcionando
- [ ] ✅ Curl tests ejecutados exitosamente
- [ ] ✅ README principal actualizado con estado ✅ CERTIFICADA
- [ ] ✅ Documentación de certificación creada

---

## 🔄 WORKFLOW PARA CADA HU

### 1. Preparación
```bash
# Verificar estado inicial
curl -I http://localhost:6002/api-docs
curl -s http://localhost:6002/api-docs.json | jq '.info.title'
```

### 2. Desarrollo
```bash
# Crear/actualizar HU específica
nano /home/administrador/docker/comparendos/documentation/api/hu-specs/hu-comp-XXX.yaml
```

### 3. Integración
```bash
# Actualizar archivo principal
nano /home/administrador/docker/comparendos/documentation/api/swagger.yaml

# Copiar al backend
cp /home/administrador/docker/comparendos/documentation/api/swagger.yaml \
   /home/administrador/docker/comparendos/apps/backend/documentation/api/swagger.yaml
```

### 4. Despliegue
```bash
# Reconstruir y reiniciar
docker-compose build comparendos-back
docker-compose restart comparendos-back
```

### 5. Verificación
```bash
# Verificar Swagger
curl -I http://localhost:6002/api-docs
curl -s http://localhost:6002/api-docs.json | jq '.paths | keys[]'

# Probar endpoints con curl
curl -X POST "http://localhost:6002/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin.comparendos@testing.com","password":"AdminComparendos123!"}'
```

---

## 📞 ENDPOINTS SWAGGER

- **Swagger UI**: http://localhost:6002/api-docs
- **Swagger JSON**: http://localhost:6002/api-docs.json
- **API Base**: http://localhost:6002/api

---

## 🏆 ESTADO ACTUAL DEL SISTEMA

### HU Certificadas ✅
- **HU-COMP-000**: Autenticación y Roles - COMPLETAMENTE CERTIFICADA

### HU Pendientes ⏳
- **HU-COMP-001**: Gestión de Vehículos
- **HU-COMP-002**: Registro de Eventos de Pesaje
- **HU-COMP-003**: Generación de Comparendos
- **HU-COMP-004**: Reportes y Auditoría

---

## 🆘 COMANDOS DE EMERGENCIA

### Resetear Swagger Completamente
```bash
# 1. Parar servicios
docker-compose stop

# 2. Limpiar archivos
rm -f /home/administrador/docker/comparendos/documentation/api/swagger.yaml
rm -f /home/administrador/docker/comparendos/apps/backend/documentation/api/swagger.yaml

# 3. Recrear desde plantilla
# (usar template arriba)

# 4. Reconstruir todo
docker-compose build comparendos-back
docker-compose up -d
```

### Verificar Estado Rápido
```bash
# One-liner para verificar todo
echo "🔍 Verificando Swagger..." && \
curl -s -I http://localhost:6002/api-docs | head -1 && \
curl -s http://localhost:6002/api-docs.json | jq -r '.info.title' && \
echo "✅ Swagger funcionando correctamente"
```

---

**📌 NOTA IMPORTANTE**: Mantén este README actualizado cada vez que se certifique una HU nueva. Es la fuente de verdad para todo lo relacionado con Swagger en el proyecto.

**🎯 OBJETIVO**: Que cualquier desarrollador pueda tomar el proyecto y tener Swagger funcionando en menos de 5 minutos siguiendo esta guía.

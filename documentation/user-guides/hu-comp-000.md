# HU-COMP-000 – Validaciones Generales de Seguridad y Roles del Sistema Comparendos

## 📋 Información General
- **ID**: HU-COMP-000
- **Título**: Validaciones Generales de Seguridad y Roles del Sistema Comparendos
- **Origen**: HU-VH-000 (Sistema Vehiculos) - Adaptación completa
- **Prioridad**: CRÍTICA (Base de seguridad)
- **Fase**: 0 - Prerrequisito de todas las HU
- **Reutilización**: 85% - APIs de auth + nuevos roles específicos

---

## 🎯 Descripción
Como **equipo de desarrollo y QA del sistema comparendos**, quiero verificar que todas las rutas protegidas exigen un token válido y aplican correctamente las reglas de rol específicas para operaciones de báscula, generación de comparendos y gestión de sobrepesos, para garantizar seguridad integral y control de acceso granular en las 4 estaciones de control.

---

## 🏗️ Contexto Técnico

### **Sistema Base Reutilizado**
```javascript
// APIs heredadas del sistema vehiculos (Mantener exactas)
POST /api/auth/login     // ✅ Mantener - Login JWT
GET /api/auth/me         // ✅ Mantener - Perfil usuario
POST /api/auth/logout    // ✅ Mantener - Logout seguro
```

### **Nuevos Roles del Sistema Comparendos**
| Rol ID | Nombre | Descripción | Permisos Principales |
|--------|--------|-------------|-------------------|
| 1 | `ADMIN` | Administrador General | Acceso total al sistema |
| 2 | `OPERADOR_BASCULA` | Operador de Báscula | Pesajes, eventos, consultas básicas |
| 3 | `AUDITOR` | Auditor de Procesos | Consultas, reportes, sin modificaciones |
| 4 | `POLICIA` | Agente de Policía | Generación de comparendos únicamente |
| 5 | `COORDINADOR_ITS` | Coordinador ITS | Supervisión, reportes, validaciones |
| 6 | `COORDINADOR_CCO` | Coordinador CCO | Monitoreo, dashboards, incidentes |
| 7 | `INGENIERO_RESIDENTE` | Ingeniero Residente | Autorizaciones especiales, anulaciones |

### **Estaciones de Control (Contexto)**
- **Neiva Norte** (ID: 1) - Control peso dirección Norte
- **Neiva Sur** (ID: 2) - Control peso dirección Sur  
- **Flandes Norte** (ID: 3) - Control peso dirección Norte
- **Flandes Sur** (ID: 4) - Control peso dirección Sur

---

## ✅ Criterios de Aceptación

### **CA-000-01: Validación de Token JWT**
- ✅ Todas las rutas protegidas DEBEN retornar `401 Unauthorized` si no se incluye token
- ✅ Token malformado o expirado DEBE retornar `401 Unauthorized`
- ✅ Token válido DEBE permitir acceso a rutas autorizadas por rol
- ✅ Headers DEBEN incluir `Authorization: Bearer <token>`

### **CA-000-02: Validación de Roles Granulares**
- ✅ Rutas DEBEN retornar `403 Forbidden` si el rol no tiene permisos suficientes
- ✅ OPERADOR_BASCULA solo puede acceder a su estación asignada
- ✅ POLICIA solo puede crear/consultar comparendos, NO modificar pesajes
- ✅ AUDITOR puede consultar TODO pero NO modificar nada
- ✅ COORDINADORES tienen acceso de supervisión sin operaciones críticas
- ✅ INGENIERO_RESIDENTE puede autorizar anulaciones especiales

### **CA-000-03: Middleware de Seguridad**
- ✅ `verificarToken` DEBE validar JWT correctamente en todas las rutas protegidas
- ✅ `verificarRol` DEBE estar presente en rutas con acceso restringido por rol
- ✅ `verificarEstacion` DEBE validar que operador accede solo a su estación
- ✅ Middleware DEBE registrar intentos de acceso no autorizado

### **CA-000-04: Rutas Específicas del Sistema Comparendos**
- ✅ `/api/pesajes/*` - Solo OPERADOR_BASCULA y ADMIN
- ✅ `/api/comparendos/crear` - Solo POLICIA y ADMIN
- ✅ `/api/comparendos/anular/*` - Solo INGENIERO_RESIDENTE y ADMIN
- ✅ `/api/vehiculos/*` - Todos excepto POLICIA (solo lectura para algunos)
- ✅ `/api/reportes-ani/*` - Solo COORDINADOR_ITS y ADMIN
- ✅ `/api/dashboard/*` - COORDINADOR_CCO, COORDINADOR_ITS y ADMIN

### **CA-000-05: Validaciones de Estación por Usuario**
- ✅ OPERADOR_BASCULA solo puede registrar pesajes en su estación asignada
- ✅ Consultas de pesajes DEBEN filtrar por estación según usuario
- ✅ Sistema DEBE rechazar operaciones cross-estación sin permisos ADMIN

---

## 🔧 Especificaciones Técnicas

### **Middleware Adaptado (`authMiddleware.js`)**
```javascript
// Reutilizar middleware base + nuevas validaciones
const verificarToken = (req, res, next) => {
    // ✅ Mantener lógica existente del sistema vehiculos
    // ✅ Agregar logging de accesos para auditoría
};

const verificarRol = (rolesPermitidos) => {
    // ✅ Expandir validación para nuevos roles 1-7
    // ✅ Incluir validación de estación para OPERADOR_BASCULA
};

// NUEVO: Middleware específico para estaciones
const verificarEstacion = (req, res, next) => {
    if (req.usuario.rol === 2) { // OPERADOR_BASCULA
        const estacionOperacion = req.body.id_estacion || req.params.id_estacion;
        if (estacionOperacion !== req.usuario.estacion_asignada) {
            return res.status(403).json({
                error: 'Acceso denegado: No puede operar en esta estación'
            });
        }
    }
    next();
};
```

### **Rutas Protegidas del Sistema Comparendos**
```javascript
// Pesajes - Solo operadores y admin
router.get('/api/pesajes', verificarToken, verificarRol([1, 2, 3]));
router.post('/api/pesajes', verificarToken, verificarRol([1, 2]), verificarEstacion);

// Comparendos - Roles específicos
router.post('/api/comparendos', verificarToken, verificarRol([1, 4])); // ADMIN, POLICIA
router.put('/api/comparendos/:id/anular', verificarToken, verificarRol([1, 7])); // ADMIN, INGENIERO

// Reportes - Solo coordinadores
router.get('/api/reportes-ani/*', verificarToken, verificarRol([1, 5])); // ADMIN, COORDINADOR_ITS

// Dashboard - Supervisores
router.get('/api/dashboard/*', verificarToken, verificarRol([1, 5, 6])); // ADMIN, COORDINADORES
```

### **Tabla de Usuarios Expandida**
```sql
-- Adaptar tabla usuarios existente
ALTER TABLE usuarios ADD COLUMN estacion_asignada INTEGER;
ALTER TABLE usuarios ADD COLUMN fecha_ultimo_acceso TIMESTAMP;
ALTER TABLE usuarios ADD COLUMN intentos_fallidos INTEGER DEFAULT 0;
ALTER TABLE usuarios ADD COLUMN cuenta_bloqueada BOOLEAN DEFAULT false;

-- Constraint para roles del sistema comparendos
ALTER TABLE usuarios DROP CONSTRAINT usuarios_rol_check;
ALTER TABLE usuarios ADD CONSTRAINT usuarios_rol_check 
    CHECK (rol IN (1, 2, 3, 4, 5, 6, 7));

-- Foreign key para estaciones
ALTER TABLE usuarios ADD FOREIGN KEY (estacion_asignada) 
    REFERENCES estaciones_control(id_estacion);
```

---

## 🧪 Plan de Pruebas

### **Pruebas de Seguridad Base (Heredadas)**
```javascript
describe('HU-COMP-000: Validaciones de Seguridad', () => {
    
    describe('Validación de Token', () => {
        test('401 - Acceso sin token a ruta protegida', async () => {
            const response = await request(app)
                .get('/api/pesajes')
                .expect(401);
        });
        
        test('401 - Token malformado', async () => {
            const response = await request(app)
                .get('/api/pesajes')
                .set('Authorization', 'Bearer token_invalido')
                .expect(401);
        });
        
        test('200 - Token válido permite acceso', async () => {
            const token = generarTokenValido({ rol: 1 });
            const response = await request(app)
                .get('/api/pesajes')
                .set('Authorization', `Bearer ${token}`)
                .expect(200);
        });
    });
    
    describe('Validación de Roles Específicos', () => {
        test('403 - POLICIA no puede acceder a pesajes', async () => {
            const token = generarTokenValido({ rol: 4, nombre: 'Agente Pérez' });
            await request(app)
                .get('/api/pesajes')
                .set('Authorization', `Bearer ${token}`)
                .expect(403);
        });
        
        test('200 - OPERADOR_BASCULA puede acceder a pesajes', async () => {
            const token = generarTokenValido({ rol: 2, estacion_asignada: 1 });
            await request(app)
                .get('/api/pesajes')
                .set('Authorization', `Bearer ${token}`)
                .expect(200);
        });
        
        test('403 - OPERADOR no puede crear comparendos', async () => {
            const token = generarTokenValido({ rol: 2 });
            await request(app)
                .post('/api/comparendos')
                .set('Authorization', `Bearer ${token}`)
                .send({ /* datos comparendo */ })
                .expect(403);
        });
    });
    
    describe('Validación de Estaciones', () => {
        test('403 - Operador no puede registrar pesaje en otra estación', async () => {
            const token = generarTokenValido({ rol: 2, estacion_asignada: 1 });
            await request(app)
                .post('/api/pesajes')
                .set('Authorization', `Bearer ${token}`)
                .send({ id_estacion: 2, placa: 'ABC123' }) // Estación diferente
                .expect(403);
        });
        
        test('200 - Operador puede registrar pesaje en su estación', async () => {
            const token = generarTokenValido({ rol: 2, estacion_asignada: 1 });
            await request(app)
                .post('/api/pesajes')
                .set('Authorization', `Bearer ${token}`)
                .send({ id_estacion: 1, placa: 'ABC123' }) // Su estación
                .expect(200);
        });
    });
});
```

### **Casos de Prueba Específicos para Comparendos**
```javascript
describe('Casos Específicos Sistema Comparendos', () => {
    test('POLICIA puede crear comparendo pero no modificar pesaje', async () => {
        const tokenPolicia = generarTokenValido({ rol: 4 });
        
        // ✅ Puede crear comparendo
        await request(app)
            .post('/api/comparendos')
            .set('Authorization', `Bearer ${tokenPolicia}`)
            .send({ evento_pesaje_id: 1, agente_policia: 'Agente Pérez' })
            .expect(201);
            
        // ❌ No puede modificar pesaje
        await request(app)
            .put('/api/pesajes/1')
            .set('Authorization', `Bearer ${tokenPolicia}`)
            .send({ peso_bruto_kg: 25000 })
            .expect(403);
    });
    
    test('INGENIERO_RESIDENTE puede anular comparendos', async () => {
        const tokenIngeniero = generarTokenValido({ rol: 7 });
        
        await request(app)
            .put('/api/comparendos/1/anular')
            .set('Authorization', `Bearer ${tokenIngeniero}`)
            .send({ motivo_anulacion: 'Error de clasificación BASCAM' })
            .expect(200);
    });
    
    test('AUDITOR puede consultar todo pero no modificar', async () => {
        const tokenAuditor = generarTokenValido({ rol: 3 });
        
        // ✅ Puede consultar
        await request(app)
            .get('/api/pesajes')
            .set('Authorization', `Bearer ${tokenAuditor}`)
            .expect(200);
            
        await request(app)
            .get('/api/comparendos')
            .set('Authorization', `Bearer ${tokenAuditor}`)
            .expect(200);
            
        // ❌ No puede modificar
        await request(app)
            .post('/api/pesajes')
            .set('Authorization', `Bearer ${tokenAuditor}`)
            .send({ placa: 'ABC123' })
            .expect(403);
    });
});
```

---

## 🔍 Consideraciones Técnicas

### **Archivos a Revisar/Adaptar**
- ✅ `middleware/authMiddleware.js` - Expandir roles y validaciones
- ✅ `routes/authRoutes.js` - Mantener exacto del sistema vehiculos
- ✅ `routes/pesajesRoutes.js` - Nuevo, adaptar de pasoRoutes.js
- ✅ `routes/comparendosRoutes.js` - Expandir protecciones por rol
- ✅ `controllers/auth.controller.js` - Incluir nuevos campos usuario

### **Configuración de Roles**
```javascript
const ROLES_SISTEMA = {
    ADMIN: 1,
    OPERADOR_BASCULA: 2,
    AUDITOR: 3,
    POLICIA: 4,
    COORDINADOR_ITS: 5,
    COORDINADOR_CCO: 6,
    INGENIERO_RESIDENTE: 7
};

const PERMISOS_POR_ROL = {
    [ROLES_SISTEMA.ADMIN]: ['*'], // Acceso total
    [ROLES_SISTEMA.OPERADOR_BASCULA]: ['pesajes:crud', 'vehiculos:read', 'comparendos:read'],
    [ROLES_SISTEMA.AUDITOR]: ['*:read'], // Solo lectura todo
    [ROLES_SISTEMA.POLICIA]: ['comparendos:create', 'comparendos:read'],
    [ROLES_SISTEMA.COORDINADOR_ITS]: ['reportes:*', 'dashboard:*', '*:read'],
    [ROLES_SISTEMA.COORDINADOR_CCO]: ['dashboard:*', 'incidentes:*', '*:read'],
    [ROLES_SISTEMA.INGENIERO_RESIDENTE]: ['comparendos:anular', '*:read']
};
```

### **Logs de Auditoría de Seguridad**
```javascript
const logAccesoSeguridad = (req, resultado) => {
    console.log({
        timestamp: new Date().toISOString(),
        usuario_id: req.usuario?.id,
        rol: req.usuario?.rol,
        estacion: req.usuario?.estacion_asignada,
        ruta: req.originalUrl,
        metodo: req.method,
        ip: req.ip,
        user_agent: req.get('User-Agent'),
        resultado: resultado, // 'PERMITIDO', 'DENEGADO_TOKEN', 'DENEGADO_ROL', 'DENEGADO_ESTACION'
        parametros: req.body
    });
};
```

---

## 📋 Definición de Terminado (DoD)

### **Validaciones Técnicas**
- ✅ Todos los tests de seguridad pasan (>95% cobertura)
- ✅ Middleware de autenticación funcional en todas las rutas
- ✅ Validación de roles granular implementada
- ✅ Logging de accesos configurado
- ✅ Documentación de API actualizada con permisos

### **Validaciones de Negocio**
- ✅ Operadores solo pueden trabajar en su estación asignada
- ✅ Policía puede crear comparendos pero no modificar pesajes
- ✅ Auditores tienen acceso completo de lectura, cero escritura
- ✅ Ingenieros pueden autorizar anulaciones especiales
- ✅ Coordinadores tienen acceso supervisorio según su área

### **Validaciones de Seguridad**
- ✅ Penetration testing básico aprobado
- ✅ Tokens JWT configurados con expiración segura
- ✅ Rate limiting configurado en rutas críticas
- ✅ Logs de seguridad funcionando correctamente

---

## 🚀 Notas de Implementación

### **Orden de Desarrollo**
1. **Adaptar middleware existente** - Expandir roles 1-7
2. **Configurar nuevos usuarios** - Poblar tabla con roles específicos
3. **Implementar validación de estación** - Middleware nuevo
4. **Actualizar todas las rutas** - Aplicar protecciones granulares
5. **Testing exhaustivo** - Casos positivos y negativos
6. **Documentación Swagger** - Especificar permisos por endpoint

### **Datos de Prueba - Credenciales Actualizadas**

#### **Operadores de Báscula**
```sql
-- Norte Neiva (Estación 1)
INSERT INTO usuarios (nombre, email, password_hash, rol, estacion_asignada, cargo) VALUES
('Operador Norte Neiva', 'operador.nn@comparendos.com', '$2b$10$DaaDfccyXbi9M5aDBJung.YXbN1GkMuVIc0zpM5ctO1nIaMvky', 2, 1, 'Operador Báscula Norte Neiva');

-- Sur Neiva (Estación 2)
INSERT INTO usuarios (nombre, email, password_hash, rol, estacion_asignada, cargo) VALUES
('Operador Sur Neiva', 'operador.sn@comparendos.com', '$2b$10$DaaDfccyXbi9M5aDBJung.YXbN1GkMuVIc0zpM5ctO1nIaMvky', 2, 2, 'Operador Báscula Sur Neiva');

-- Norte Flandes (Estación 3)
INSERT INTO usuarios (nombre, email, password_hash, rol, estacion_asignada, cargo) VALUES
('Operador Norte Flandes', 'operador.nf@comparendos.com', '$2b$10$DaaDfccyXbi9M5aDBJung.YXbN1GkMuVIc0zpM5ctO1nIaMvky', 2, 3, 'Operador Báscula Norte Flandes');

-- Sur Flandes (Estación 4)
INSERT INTO usuarios (nombre, email, password_hash, rol, estacion_asignada, cargo) VALUES
('Operador Sur Flandes', 'operador.sf@comparendos.com', '$2b$10$DaaDfccyXbi9M5aDBJung.YXbN1GkMuVIc0zpM5ctO1nIaMvky', 2, 4, 'Operador Báscula Sur Flandes');
```

#### **Otros Roles del Sistema**
```sql
-- Agente de Policía
INSERT INTO usuarios (nombre, email, password_hash, rol, estacion_asignada, cargo) VALUES
('Agente de Policía', 'police@comparendos.com', '$2b$10$30DxGPykoUMdSMkKjYpL6O4WwJuMu6Y/pgllgND8q.24W9DKqUh7u', 4, NULL, 'Agente Policía');

-- Coordinador ITS
INSERT INTO usuarios (nombre, email, password_hash, rol, estacion_asignada, cargo) VALUES
('Coordinador ITS', 'coordinador.its@comparendos.com', '$2b$10$yKeZqWfysilZU03D1w2hduBOQatXHNVYv7.2tBPSNZ3G6oigCy8AO', 5, NULL, 'Coordinador ITS');

-- Coordinador CCO
INSERT INTO usuarios (nombre, email, password_hash, rol, estacion_asignada, cargo) VALUES
('Coordinador CCO', 'coordinador.cco@comparendos.com', '$2b$10$yKeZqWfysilZU03D1w2hduBOQatXHNVYv7.2tBPSNZ3G6oigCy8AO', 6, NULL, 'Coordinador CCO');

-- Regulador ANI
INSERT INTO usuarios (nombre, email, password_hash, rol, estacion_asignada, cargo) VALUES
('Regulador ANI', 'ani@comparendos.com', '$2b$10$Cj0zzxKk2jE7RWtuH9NWWe37i9tUEb88nFFjOZ0O3vE7XH4Xzu4si', 5, NULL, 'Regulador ANI');

-- Transportista
INSERT INTO usuarios (nombre, email, password_hash, rol, estacion_asignada, cargo) VALUES
('Transportista', 'transportista@comparendos.com', '$2b$10$C8BKbqWYoUYspc0ihDniWOyveRVu4p2nwsFgZydFXyn2wuVAfrC7i', 3, NULL, 'Transportista');
```

#### **Credenciales de Acceso para Pruebas**
| Usuario | Email | Contraseña | Rol | Estación |
|---------|-------|-----------|-----|----------|
| **Operador Norte Neiva** | `operador.nn@comparendos.com` | `operador123` | OPERADOR_BASCULA | Neiva Norte |
| **Operador Sur Neiva** | `operador.sn@comparendos.com` | `operador123` | OPERADOR_BASCULA | Neiva Sur |
| **Operador Norte Flandes** | `operador.nf@comparendos.com` | `operador123` | OPERADOR_BASCULA | Flandes Norte |
| **Operador Sur Flandes** | `operador.sf@comparendos.com` | `operador123` | OPERADOR_BASCULA | Flandes Sur |
| **Agente Policía** | `police@comparendos.com` | `police123` | POLICIA | - |
| **Coordinador ITS** | `coordinador.its@comparendos.com` | `coordinador123` | COORDINADOR_ITS | - |
| **Coordinador CCO** | `coordinador.cco@comparendos.com` | `coordinador123` | COORDINADOR_CCO | - |
| **Regulador ANI** | `ani@comparendos.com` | `ani123` | COORDINADOR_ITS | - |
| **Transportista** | `transportista@comparendos.com` | `transportista123` | AUDITOR | - |

**⚠️ IMPORTANTE**: Estas credenciales son únicamente para pruebas de desarrollo. En producción deben utilizarse contraseñas seguras y únicas.

---

**Esta HU-COMP-000 es la base de seguridad crítica que habilita el desarrollo seguro de todas las demás historias de usuario del sistema comparendos, reutilizando eficientemente la infraestructura del sistema vehiculos mientras añade las validaciones específicas del nuevo modelo de negocio.**
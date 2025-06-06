# HU-COMP-001 – Autenticación y Gestión de Roles del Sistema Comparendos

## 📋 Información General
- **ID**: HU-COMP-001
- **Título**: Autenticación y Gestión de Roles del Sistema Comparendos
- **Origen**: Nueva funcionalidad core (no reutilizable de vehiculos)
- **Prioridad**: CRÍTICA (Base del sistema)
- **Fase**: 1 - Fundamentos
- **Dependencias**: HU-COMP-000 (Validaciones de Seguridad)

---

## 🎯 Descripción
Como **usuario del sistema comparendos** según mi rol específico (Operador de Báscula, Agente de Policía, Coordinador ITS, etc.),
quiero autenticarme de forma segura y acceder únicamente a las funcionalidades autorizadas para mi rol y estación asignada,
para garantizar que las operaciones de pesaje, generación de comparendos y supervisión se realicen con control de acceso granular según las responsabilidades definidas en el protocolo BASCAM.

---

## 👥 Actores y Contexto Operativo

### **Roles del Sistema Comparendos**
| Rol ID | Nombre | Responsabilidad Principal | Estación | Correo Ejemplo |
|--------|--------|--------------------------|----------|---------------|
| 1 | **ADMIN** | Administración completa del sistema | Todas | admin.comparendos@autovia.com.co |
| 2 | **OPERADOR_BASCULA** | Registro de pesajes y eventos | Asignada | operador.neiva.norte@autovia.com.co |
| 3 | **AUDITOR** | Supervisión y consultas (solo lectura) | Todas | auditor.comparendos@autovia.com.co |
| 4 | **POLICIA** | Generación de comparendos únicamente | Móvil | agente.perez@policia.gov.co |
| 5 | **COORDINADOR_ITS** | Reportes ANI y supervisión técnica | Oficina | coordinador.its@autovia.com.co |
| 6 | **COORDINADOR_CCO** | Monitoreo y dashboards operativos | CCO | coordinador.cco@autovia.com.co |
| 7 | **INGENIERO_RESIDENTE** | Autorizaciones especiales y anulaciones | Oficina | ingeniero.residente@autovia.com.co |

### **Estaciones de Control**
| ID | Estación | Ubicación | Dirección | Básculas |
|----|----------|-----------|-----------|----------|
| 1 | Neiva Norte | Km 25+500 | Norte → Espinal | 2 activas |
| 2 | Neiva Sur | Km 25+300 | Sur → Neiva | 2 activas |
| 3 | Flandes Norte | Km 12+200 | Norte → Bogotá | 2 activas |
| 4 | Flandes Sur | Km 12+000 | Sur → Girardot | 2 activas |

---

## 🔄 Flujo Funcional

### **1. Proceso de Autenticación**
1. **Login con credenciales**
   - Email corporativo o institucional
   - Password con política de seguridad
   - Validación de cuenta activa

2. **Generación de token JWT**
   - Incluye: rol, estación_asignada, permisos
   - Expiración: 8 horas (turno completo)
   - Refresh automático cada 4 horas

3. **Validación de estación**
   - OPERADOR_BASCULA: solo su estación asignada
   - Otros roles: acceso según permisos

### **2. Gestión de Sesiones**
- **Sesión única**: Un usuario, una sesión activa
- **Timeout automático**: 30 minutos inactividad
- **Logout seguro**: Invalidación de token
- **Auditoría**: Log de todos los accesos

### **3. Control de Acceso por Funcionalidad**

#### **OPERADOR_BASCULA (Rol 2)**
```javascript
Permisos: [
  'pesajes:create',    // Registrar eventos de pesaje
  'pesajes:read',      // Consultar pesajes de su estación
  'vehiculos:read',    // Consultar datos de vehículos
  'comparendos:read'   // Ver comparendos (solo lectura)
]
Restricciones: [
  'estacion_asignada', // Solo su estación
  'no_anular',         // No puede anular comparendos
  'no_reportes_ani'    // No acceso a reportes oficiales
]
```

#### **POLICIA (Rol 4)**
```javascript
Permisos: [
  'comparendos:create', // Generar comparendos
  'comparendos:read',   // Consultar comparendos
  'pesajes:read',       // Ver eventos de sobrepeso
  'evidencias:upload'   // Subir fotos evidencia
]
Restricciones: [
  'no_pesajes_create',  // No puede registrar pesajes
  'no_vehiculos_edit',  // No editar datos vehiculos
  'solo_comparendos'    // Acceso limitado
]
```

#### **COORDINADOR_ITS (Rol 5)**
```javascript
Permisos: [
  'reportes:ani',       // Generar reportes ANI
  'dashboard:full',     // Dashboard completo
  'pesajes:read_all',   // Ver todas las estaciones
  'comparendos:read_all',
  'vehiculos:manage'    // Gestión vehiculos
]
Restricciones: [
  'no_operacion',       // No operación directa
  'solo_supervision'    // Solo supervisión
]
```

---

## ✅ Criterios de Aceptación

### **CA-001-01: Autenticación Básica**
- ✅ Usuario DEBE autenticarse con email y password válidos
- ✅ Sistema DEBE generar token JWT con 8 horas de expiración
- ✅ Token DEBE incluir: id, rol, estacion_asignada, permisos
- ✅ Credenciales incorrectas DEBEN retornar error 401
- ✅ Cuenta bloqueada DEBE retornar error 403

### **CA-001-02: Control de Roles Granular**
- ✅ OPERADOR_BASCULA solo puede operar en su estación asignada
- ✅ POLICIA solo puede crear/consultar comparendos, NO modificar pesajes
- ✅ AUDITOR puede consultar TODO pero NO modificar NADA
- ✅ COORDINADORES tienen acceso de supervisión sin operación directa
- ✅ INGENIERO_RESIDENTE puede autorizar anulaciones especiales

### **CA-001-03: Validaciones de Estación**
- ✅ OPERADOR solo ve pesajes/comparendos de su estación
- ✅ Intento de acceso a otra estación DEBE retornar 403
- ✅ Coordinadores pueden ver todas las estaciones
- ✅ Sistema DEBE validar estacion_asignada en cada operación

### **CA-001-04: Gestión de Sesiones**
- ✅ Una sesión activa por usuario (logout automático sesiones previas)
- ✅ Timeout 30 minutos inactividad
- ✅ Refresh token automático cada 4 horas
- ✅ Logout DEBE invalidar token inmediatamente

### **CA-001-05: Auditoría y Seguridad**
- ✅ TODOS los accesos DEBEN quedar registrados en log
- ✅ Intentos fallidos DEBEN incrementar contador (3 intentos = bloqueo temporal)
- ✅ Cambios de password DEBEN ser obligatorios cada 90 días
- ✅ Datos sensibles NO DEBEN exponerse en logs

---

## 🔧 APIs Principales

### **Autenticación**
```javascript
// Login
POST /api/auth/login
Content-Type: application/json
{
  "email": "operador.neiva.norte@autovia.com.co",
  "password": "password123"
}

Response 200:
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "rt_abc123...",
    "user": {
      "id": 2,
      "nombre": "Juan Pérez",
      "email": "operador.neiva.norte@autovia.com.co",
      "rol": 2,
      "rol_nombre": "OPERADOR_BASCULA",
      "estacion_asignada": 1,
      "estacion_nombre": "Neiva Norte",
      "permisos": ["pesajes:create", "pesajes:read", "vehiculos:read"]
    },
    "expires_in": 28800 // 8 horas
  }
}

// Perfil usuario
GET /api/auth/me
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "data": {
    "usuario": { /* datos usuario completos */ },
    "sesion": {
      "inicio": "2025-06-05T06:00:00Z",
      "expiracion": "2025-06-05T14:00:00Z",
      "ultima_actividad": "2025-06-05T10:30:00Z"
    }
  }
}

// Logout
POST /api/auth/logout
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "message": "Sesión cerrada correctamente"
}

// Refresh token
POST /api/auth/refresh
Content-Type: application/json
{
  "refresh_token": "rt_abc123..."
}
```

### **Gestión de Usuarios (Solo ADMIN)**
```javascript
// Listar usuarios
GET /api/usuarios
Authorization: Bearer {admin_token}

// Crear usuario
POST /api/usuarios
{
  "nombre": "Carlos Ruiz",
  "email": "operador.flandes.sur@autovia.com.co",
  "rol": 2,
  "estacion_asignada": 4,
  "cargo": "Operador de Báscula",
  "telefono": "300-123-4567"
}

// Actualizar usuario
PUT /api/usuarios/:id

// Bloquear/desbloquear usuario
PUT /api/usuarios/:id/toggle-block
```

---

## 🗄️ Estructura de Base de Datos

### **Tabla usuarios (Expandida)**
```sql
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    rol INTEGER NOT NULL CHECK (rol IN (1,2,3,4,5,6,7)),
    estacion_asignada INTEGER,
    cargo VARCHAR(100),
    telefono VARCHAR(20),
    activo BOOLEAN DEFAULT true,
    cuenta_bloqueada BOOLEAN DEFAULT false,
    intentos_fallidos INTEGER DEFAULT 0,
    ultimo_cambio_password TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_ultimo_acceso TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (estacion_asignada) REFERENCES estaciones_control(id_estacion)
);

-- Datos iniciales de usuarios
INSERT INTO usuarios (nombre, email, password_hash, rol, estacion_asignada, cargo) VALUES
('Admin Sistema', 'admin.comparendos@autovia.com.co', '$2b$10$hash...', 1, NULL, 'Administrador'),
('Juan Pérez', 'operador.neiva.norte@autovia.com.co', '$2b$10$hash...', 2, 1, 'Operador Báscula'),
('María García', 'operador.neiva.sur@autovia.com.co', '$2b$10$hash...', 2, 2, 'Operador Báscula'),
('Carlos Ruiz', 'operador.flandes.norte@autovia.com.co', '$2b$10$hash...', 2, 3, 'Operador Báscula'),
('Ana López', 'operador.flandes.sur@autovia.com.co', '$2b$10$hash...', 2, 4, 'Operador Báscula'),
('Agente Pérez', 'agente.perez@policia.gov.co', '$2b$10$hash...', 4, NULL, 'Agente Policía'),
('Auditor Sistema', 'auditor.comparendos@autovia.com.co', '$2b$10$hash...', 3, NULL, 'Auditor'),
('Coordinador ITS', 'coordinador.its@autovia.com.co', '$2b$10$hash...', 5, NULL, 'Coordinador ITS'),
('Coordinador CCO', 'coordinador.cco@autovia.com.co', '$2b$10$hash...', 6, NULL, 'Coordinador CCO'),
('Ingeniero Res.', 'ingeniero.residente@autovia.com.co', '$2b$10$hash...', 7, NULL, 'Ingeniero Residente');
```

### **Tabla sesiones_activas**
```sql
CREATE TABLE sesiones_activas (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL,
    token_hash VARCHAR(64) NOT NULL,
    refresh_token_hash VARCHAR(64),
    ip_origen INET,
    user_agent TEXT,
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP NOT NULL,
    ultima_actividad TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activa BOOLEAN DEFAULT true,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    INDEX idx_sesiones_token (token_hash),
    INDEX idx_sesiones_usuario (usuario_id, activa)
);
```

### **Tabla auditoria_accesos**
```sql
CREATE TABLE auditoria_accesos (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER,
    email_intento VARCHAR(100),
    resultado VARCHAR(20), -- 'EXITOSO', 'CREDENCIALES_INVALIDAS', 'CUENTA_BLOQUEADA'
    ip_origen INET,
    user_agent TEXT,
    timestamp_acceso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    detalles JSONB,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_timestamp (timestamp_acceso),
    INDEX idx_auditoria_resultado (resultado)
);
```

---

## 🧪 Plan de Pruebas

### **Pruebas de Autenticación**
```javascript
describe('HU-COMP-001: Autenticación y Roles', () => {
    
    describe('Login básico', () => {
        test('Login exitoso con credenciales válidas', async () => {
            const response = await request(app)
                .post('/api/auth/login')
                .send({
                    email: 'operador.neiva.norte@autovia.com.co',
                    password: 'password123'
                })
                .expect(200);
                
            expect(response.body.data.token).toBeDefined();
            expect(response.body.data.user.rol).toBe(2);
            expect(response.body.data.user.estacion_asignada).toBe(1);
        });
        
        test('Login fallido con credenciales incorrectas', async () => {
            await request(app)
                .post('/api/auth/login')
                .send({
                    email: 'operador.neiva.norte@autovia.com.co',
                    password: 'password_incorrect'
                })
                .expect(401);
        });
        
        test('Bloqueo automático después de 3 intentos', async () => {
            // 3 intentos fallidos
            for (let i = 0; i < 3; i++) {
                await request(app)
                    .post('/api/auth/login')
                    .send({
                        email: 'operador.neiva.norte@autovia.com.co',
                        password: 'password_incorrect'
                    })
                    .expect(401);
            }
            
            // 4to intento debe devolver cuenta bloqueada
            await request(app)
                .post('/api/auth/login')
                .send({
                    email: 'operador.neiva.norte@autovia.com.co',
                    password: 'password123' // Incluso con password correcto
                })
                .expect(403);
        });
    });
    
    describe('Control de roles', () => {
        test('Operador solo ve pesajes de su estación', async () => {
            const token = await loginAsOperador(1); // Estación 1
            
            const response = await request(app)
                .get('/api/pesajes?id_estacion=1')
                .set('Authorization', `Bearer ${token}`)
                .expect(200);
                
            // Intento acceso a otra estación debe fallar
            await request(app)
                .get('/api/pesajes?id_estacion=2')
                .set('Authorization', `Bearer ${token}`)
                .expect(403);
        });
        
        test('Policía puede crear comparendos pero no pesajes', async () => {
            const token = await loginAsPolicia();
            
            // Puede crear comparendo
            await request(app)
                .post('/api/comparendos')
                .set('Authorization', `Bearer ${token}`)
                .send({ evento_pesaje_id: 1, agente_policia: 'Agente Pérez' })
                .expect(201);
                
            // No puede crear pesaje
            await request(app)
                .post('/api/pesajes')
                .set('Authorization', `Bearer ${token}`)
                .send({ placa: 'ABC123', peso_bruto_kg: 25000 })
                .expect(403);
        });
        
        test('Auditor solo lectura en todo', async () => {
            const token = await loginAsAuditor();
            
            // Puede leer
            await request(app)
                .get('/api/pesajes')
                .set('Authorization', `Bearer ${token}`)
                .expect(200);
                
            await request(app)
                .get('/api/comparendos')
                .set('Authorization', `Bearer ${token}`)
                .expect(200);
                
            // No puede escribir
            await request(app)
                .post('/api/pesajes')
                .set('Authorization', `Bearer ${token}`)
                .send({ placa: 'ABC123' })
                .expect(403);
        });
    });
    
    describe('Gestión de sesiones', () => {
        test('Token expira después del tiempo configurado', async () => {
            // Mock fecha futura
            const futureDate = new Date(Date.now() + 9 * 60 * 60 * 1000); // 9 horas
            jest.useFakeTimers().setSystemTime(futureDate);
            
            const token = await loginAsOperador(1);
            
            await request(app)
                .get('/api/auth/me')
                .set('Authorization', `Bearer ${token}`)
                .expect(401); // Token expirado
        });
        
        test('Logout invalida token inmediatamente', async () => {
            const token = await loginAsOperador(1);
            
            // Logout
            await request(app)
                .post('/api/auth/logout')
                .set('Authorization', `Bearer ${token}`)
                .expect(200);
                
            // Token ya no válido
            await request(app)
                .get('/api/auth/me')
                .set('Authorization', `Bearer ${token}`)
                .expect(401);
        });
    });
});
```

---

## 📋 Definición de Terminado (DoD)

### **Validaciones Técnicas**
- ✅ Sistema de autenticación JWT funcionando
- ✅ Control de roles granular implementado
- ✅ Validación de estaciones por operador
- ✅ Gestión de sesiones y tokens
- ✅ Tests de seguridad pasando >95%

### **Validaciones de Negocio**
- ✅ Operadores limitados a su estación
- ✅ Roles específicos con permisos correctos
- ✅ Auditoría completa de accesos
- ✅ Bloqueo automático por intentos fallidos

### **Validaciones de Seguridad**
- ✅ Passwords encriptados con bcrypt
- ✅ Tokens JWT seguros con expiración
- ✅ Logs de auditoría completos
- ✅ Validación de entrada en todas las APIs

---

**Esta HU-COMP-001 establece la base de autenticación y control de acceso específica para el sistema comparendos, sin reutilizar conceptos incompatibles del sistema vehiculos, enfocándose en las necesidades reales del control de sobrepeso vehicular.**
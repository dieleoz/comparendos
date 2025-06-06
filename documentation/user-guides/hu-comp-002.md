# HU-COMP-002 – Gestión de Vehículos de Carga

## 📋 Información General
- **ID**: HU-COMP-002
- **Título**: Gestión de Vehículos de Carga con Clasificación BASCAM
- **Origen**: HU-VH-002 (Carga de vehículos) - Reutilización 90%
- **Prioridad**: CRÍTICA (Base de datos vehiculares)
- **Fase**: 1 - Fundamentos
- **Dependencias**: HU-COMP-001 (Autenticación y Roles)

---

## 🎯 Descripción
Como **usuario autorizado del sistema comparendos** (Administrador, Coordinador ITS, Operador de Báscula),
quiero gestionar la información completa de vehículos de carga sujetos a control de peso,
para mantener actualizada la base de datos vehicular con clasificación BASCAM, datos de empresa transportadora y configuración de límites normativos, facilitando la correcta aplicación de controles de sobrepeso según la Resolución 2460/2022.

---

## 🚛 Contexto del Negocio

### **Evolución del Concepto Original**
| Concepto Original | Concepto Comparendos | Mejora |
|-------------------|---------------------|---------|
| Vehículos con tarifa especial | Vehículos de carga controlados | ✅ De comercial a regulatorio |
| Categoría por beneficio | Categoría BASCAM normativa | ✅ Clasificación técnica |
| Conteo de pasos | Historial de pesajes | ✅ Control de peso vs volumen |
| Multi-peaje | Multi-estación | ✅ Mantiene lógica territorial |

### **Tipos de Vehículos Controlados**
Según el modelo BASCAM, se controlan vehículos de carga con las siguientes categorías:

| Categoría | Descripción | Peso Máximo | Total Permitido | Uso Típico |
|-----------|-------------|-------------|-----------------|------------|
| **C2** | Camión 2 ejes | 17,000 kg | 17,700 kg | Distribución urbana |
| **C3** | Camión 3 ejes | 28,000 kg | 29,200 kg | Carga media |
| **2S2** | Tracto 2 + Semirrem 2 | 29,000 kg | 29,725 kg | Transporte estándar |
| **2S3** | Tracto 2 + Semirrem 3 | 40,500 kg | 41,513 kg | Carga pesada |
| **3S3** | Tracto 3 + Semirrem 3 | 52,000 kg | 53,300 kg | Carga máxima |

---

## 👥 Actores y Permisos

| Rol | Acciones Habilitadas | Limitaciones |
|-----|---------------------|-------------|
| **Administrador** (1) | CRUD completo, carga masiva, exportar | Sin restricciones |
| **Coordinador ITS** (5) | CRUD completo, reportes, carga masiva | Sin limitaciones operativas |
| **Operador Báscula** (2) | Consultar, crear básico | Solo vehículos de su estación |
| **Auditor** (3) | Consultar, exportar | Solo lectura |
| **Coordinador CCO** (6) | Consultar, dashboards | Solo visualización |

---

## 🔄 Flujo Funcional

### **1. Registro de Vehículo de Carga**
```javascript
// Datos obligatorios
{
    "placa": "ABC123",           // Formato colombiano validado
    "categoria_id": 5,           // ID tabla categoria_vehiculo (BASCAM)
    "empresa_transporte": "Transportes Ejemplo S.A.S",
    "numero_interno": "FL-001",  // Número interno de la empresa
    "marca_vehiculo": "Volvo",
    "color_vehiculo": "Blanco",
    "tipo_servicio": "CARGA"     // Siempre CARGA para comparendos
}

// Datos opcionales
{
    "codigo_tarjeta": "TAG123456", // Si tiene TAG
    "conductor_cedula": "12345678",
    "conductor_nombre": "Juan Pérez",
    "usuario": "Empresa Transportes", // Campo heredado
    "observaciones": "Vehículo articulado especial"
}
```

### **2. Consulta de Vehículos**
**Filtros disponibles:**
- Por placa (búsqueda exacta)
- Por empresa transportadora
- Por categoría BASCAM
- Por estación de control (para operadores)
- Por estado (activo/inactivo)

**Información mostrada:**
- ✅ Datos básicos: Placa, marca, color, empresa
- ✅ Clasificación: Categoría BASCAM, límite de peso
- ✅ Historial: Último pesaje, total pesajes realizados
- ✅ Estado: Activo, bloqueado, en revisión

### **3. Actualización de Datos**
- **Cambio de categoría**: Requiere justificación (error inicial, modificación vehicular)
- **Cambio de empresa**: Actualización por venta/traspaso
- **Datos conductor**: Actualización por cambio de conductor habitual
- **Estado del vehículo**: Activación/desactivación

### **4. Carga Masiva**
**Formatos soportados:**
- ✅ **Excel (.xlsx)**: Plantilla predefinida con validaciones
- ✅ **CSV**: Formato estándar con separador coma
- ✅ **JSON**: Para integraciones automáticas

**Validaciones automáticas:**
- Formato de placa colombiana
- Existencia de categoría BASCAM
- Unicidad de placa
- Empresa transportadora válida

---

## ✅ Criterios de Aceptación

### **CA-002-01: Registro de Vehículos**
- ✅ Placa DEBE validar formato colombiano (AAA123, AAA12A, etc.)
- ✅ Categoría BASCAM DEBE existir en tabla categoria_vehiculo
- ✅ Empresa transportadora DEBE ser obligatoria y mínimo 5 caracteres
- ✅ Sistema DEBE evitar duplicados de placa
- ✅ Registro DEBE incluir usuario que lo creó y timestamp

### **CA-002-02: Validaciones de Negocio**
- ✅ Categoría BASCAM DEBE determinar automáticamente límites de peso
- ✅ Cambio de categoría DEBE requerir justificación obligatoria
- ✅ Vehículos inactivos NO DEBEN aparecer en consultas operativas
- ✅ Número interno DEBE ser único por empresa transportadora

### **CA-002-03: Control por Roles**
- ✅ Operador báscula solo ve vehículos que han pasado por su estación
- ✅ Operador NO puede modificar categorías BASCAM
- ✅ Solo Admin y Coordinador ITS pueden hacer carga masiva
- ✅ Auditor puede exportar pero NO modificar

### **CA-002-04: Integridad de Datos**
- ✅ Eliminación DEBE ser lógica (activo=false), NO física
- ✅ Cambios DEBEN quedar auditados en tabla historial
- ✅ Relación con categoria_vehiculo DEBE mantenerse consistente
- ✅ Datos históricos de pesajes DEBEN preservarse

### **CA-002-05: Performance y Usabilidad**
- ✅ Búsqueda por placa DEBE responder en <500ms
- ✅ Lista paginada máximo 50 vehículos por página
- ✅ Exportación DEBE completarse en <30 segundos para 10,000 registros
- ✅ Carga masiva DEBE validar en tiempo real (feedback inmediato)

---

## 🔧 APIs Principales (Reutilizadas y Adaptadas)

### **CRUD Básico (90% Reutilización)**
```javascript
// Consultar vehículos - REUTILIZAR EXACTA
GET /api/vehiculos?page=1&limit=50&placa=ABC123&empresa=Transportes&categoria_id=5&activo=true

Response 200:
{
    "success": true,
    "data": {
        "vehiculos": [
            {
                "placa": "ABC123",
                "codigo_tarjeta": "TAG123456",
                "marca_vehiculo": "Volvo",
                "empresa_transporte": "Transportes Ejemplo S.A.S",
                "numero_interno": "FL-001",
                "color_vehiculo": "Blanco",
                "categoria_vehiculo": {
                    "id": 5,
                    "codigo_bascam": "2S2",
                    "descripcion_bascam": "Tracto 2 + Semirrem 2",
                    "peso_maximo_kg": 29000,
                    "tolerancia_kg": 725,
                    "peso_total_permitido_kg": 29725
                },
                "tipo_servicio": "CARGA",
                "activo": true,
                "usuario": "Transportes Ejemplo",
                "conductor_nombre": "Juan Pérez",
                "conductor_cedula": "12345678",
                "created_at": "2025-06-01T10:00:00Z",
                "updated_at": "2025-06-03T15:30:00Z",
                "ultimo_pesaje": "2025-06-05T09:15:00Z",
                "total_pesajes": 15,
                "observaciones": "Vehículo articulado especial"
            }
        ],
        "pagination": {
            "page": 1,
            "limit": 50,
            "total": 1247,
            "total_pages": 25
        }
    }
}

// Consultar por placa - REUTILIZAR EXACTA
GET /api/vehiculos/placa/:placa

// Crear vehículo - ADAPTAR (nuevos campos)
POST /api/vehiculos
Content-Type: application/json
{
    "placa": "DEF456",
    "categoria_id": 8,
    "empresa_transporte": "Logística Nacional LTDA",
    "numero_interno": "LN-042",
    "marca_vehiculo": "Mercedes-Benz",
    "color_vehiculo": "Azul",
    "tipo_servicio": "CARGA",
    "conductor_cedula": "87654321",
    "conductor_nombre": "María García",
    "observaciones": "Vehículo para carga refrigerada"
}

// Actualizar vehículo - ADAPTAR (validaciones adicionales)
PUT /api/vehiculos/:placa
Content-Type: application/json
{
    "empresa_transporte": "Nueva Empresa Transportes S.A.S",
    "conductor_nombre": "Carlos Ruiz",
    "conductor_cedula": "11223344",
    "observaciones": "Cambio de conductor por rotación"
}

// Cambio de categoría (requiere justificación)
PUT /api/vehiculos/:placa/categoria
Content-Type: application/json
{
    "nueva_categoria_id": 6,
    "justificacion": "Error en clasificación inicial - vehículo modificado con eje adicional",
    "autorizado_por": "Coordinador ITS"
}

// Activar/Desactivar vehículo - REUTILIZAR
PUT /api/vehiculos/:placa/toggle-status
```

### **Carga Masiva (Reutilizar con Adaptaciones)**
```javascript
// Carga desde Excel - ADAPTAR validaciones
POST /api/vehiculos/carga-excel
Content-Type: multipart/form-data
File: vehiculos_carga.xlsx

Response 200:
{
    "success": true,
    "data": {
        "procesados": 156,
        "exitosos": 152,
        "fallidos": 4,
        "errores": [
            {
                "fila": 15,
                "placa": "XYZ999",
                "error": "Categoría BASCAM 'C5' no existe"
            },
            {
                "fila": 23,
                "placa": "ABC123",
                "error": "Placa duplicada en el sistema"
            }
        ]
    }
}

// Carga desde JSON - NUEVA funcionalidad
POST /api/vehiculos/carga-json
Content-Type: application/json
{
    "vehiculos": [
        {
            "placa": "GHI789",
            "categoria_id": 2,
            "empresa_transporte": "Express Carga S.A.S",
            "numero_interno": "EC-015"
        }
    ]
}

// Exportar vehículos - REUTILIZAR
POST /api/vehiculos/exportar
Content-Type: application/json
{
    "formato": "excel", // excel, csv, pdf
    "filtros": {
        "categoria_id": 5,
        "empresa": "Transportes",
        "activo": true
    },
    "incluir_historial": true
}
```

### **APIs Nuevas Específicas**
```javascript
// Validar placa disponible
GET /api/vehiculos/validar-placa/:placa
Response 200: { "disponible": true }
Response 409: { "disponible": false, "motivo": "Placa ya registrada" }

// Obtener plantilla Excel
GET /api/vehiculos/plantilla-excel
Response: Descarga archivo vehiculos_plantilla.xlsx

// Estadísticas de vehículos
GET /api/vehiculos/estadisticas
Response 200:
{
    "total_vehiculos": 1247,
    "activos": 1198,
    "por_categoria": {
        "C2": 245,
        "C3": 389,
        "2S2": 312,
        "2S3": 178,
        "3S3": 74
    },
    "por_empresa": {
        "Transportes ABC": 156,
        "Logística XYZ": 98
    }
}

// Historial de cambios por vehículo
GET /api/vehiculos/:placa/historial
```

---

## 🗄️ Estructura de Base de Datos

### **Tabla vehiculos (Adaptada del Sistema Original)**
```sql
-- Tabla base del sistema vehiculos + campos nuevos para comparendos
CREATE TABLE vehiculos (
    placa VARCHAR(10) PRIMARY KEY,  -- Mantener como PK
    codigo_tarjeta VARCHAR(50),     -- MANTENER - TAG vehicular
    marca_vehiculo VARCHAR(50),     -- MANTENER
    empresa_transporte VARCHAR(200) NOT NULL, -- NUEVO - Obligatorio
    numero_interno VARCHAR(50),     -- NUEVO - Número interno empresa
    color_vehiculo VARCHAR(30),     -- MANTENER
    categoria_id INTEGER NOT NULL,  -- NUEVO - FK a categoria_vehiculo (BASCAM)
    tipo_servicio VARCHAR(50) DEFAULT 'CARGA', -- ADAPTAR - Siempre CARGA
    conductor_cedula VARCHAR(20),   -- NUEVO - Documento conductor
    conductor_nombre VARCHAR(100),  -- NUEVO - Nombre conductor
    usuario VARCHAR(100),           -- MANTENER - Por compatibilidad
    activo BOOLEAN DEFAULT true,    -- MANTENER
    observaciones TEXT,             -- NUEVO - Observaciones generales
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- NUEVO
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- NUEVO
    created_by INTEGER,             -- NUEVO - Usuario que creó
    updated_by INTEGER,             -- NUEVO - Usuario que modificó
    
    -- Foreign Keys
    FOREIGN KEY (categoria_id) REFERENCES categoria_vehiculo(id),
    FOREIGN KEY (created_by) REFERENCES usuarios(id),
    FOREIGN KEY (updated_by) REFERENCES usuarios(id),
    
    -- Indices para performance
    INDEX idx_vehiculos_empresa (empresa_transporte),
    INDEX idx_vehiculos_categoria (categoria_id),
    INDEX idx_vehiculos_activo (activo),
    INDEX idx_vehiculos_created (created_at)
);

-- Constraint para validar formato placa colombiana
ALTER TABLE vehiculos ADD CONSTRAINT chk_placa_formato 
    CHECK (placa ~ '^[A-Z]{3}[0-9]{2}[A-Z]$|^[A-Z]{3}[0-9]{3}$');
```

### **Tabla categoria_vehiculo (Nueva - Core BASCAM)**
```sql
CREATE TABLE categoria_vehiculo (
    id SERIAL PRIMARY KEY,
    codigo_bascam VARCHAR(10) NOT NULL UNIQUE,
    descripcion_bascam VARCHAR(100) NOT NULL,
    configuracion_normativa VARCHAR(50),
    peso_maximo_kg NUMERIC(8,1) NOT NULL,
    tolerancia_kg NUMERIC(8,1) NOT NULL,
    peso_total_permitido_kg NUMERIC(8,1) GENERATED ALWAYS AS 
        (peso_maximo_kg + tolerancia_kg) STORED,
    norma_referencia VARCHAR(50) DEFAULT '2460/22-Anexo II',
    vigencia_desde DATE DEFAULT CURRENT_DATE,
    vigencia_hasta DATE,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Poblar con datos BASCAM del modelo de negocio
INSERT INTO categoria_vehiculo (codigo_bascam, descripcion_bascam, configuracion_normativa, peso_maximo_kg, tolerancia_kg) VALUES
('C2', 'Camión 2 ejes', 'Rígido 2 ejes', 17000, 700),
('C3', 'Camión 3 ejes', 'Rígido 3 ejes', 28000, 1200),
('C4-2', 'Camión 4 ejes', 'Rígido 4 ejes', 35000, 1500),
('2S1', 'Tracto 2 + Semirrem 1', 'Tractocamión 2S1', 25000, 625),
('2S2', 'Tracto 2 + Semirrem 2', 'Tractocamión 2S2', 29000, 725),
('2S3', 'Tracto 2 + Semirrem 3', 'Tractocamión 2S3', 40500, 1013),
('3S1', 'Tracto 3 + Semirrem 1', 'Tractocamión 3S1', 33000, 825),
('3S2', 'Tracto 3 + Semirrem 2', 'Tractocamión 3S2', 48000, 1200),
('3S3', 'Tracto 3 + Semirrem 3', 'Tractocamión 3S3', 52000, 1300),
('2R2', 'Camión 2 + Remolque 2', 'Articulado 2R2', 28000, 1200),
('3R2', 'Camión 3 + Remolque 2', 'Articulado 3R2', 35000, 1500),
('3R3', 'Camión 3 + Remolque 3', 'Articulado 3R3', 43000, 1500),
('3B1', 'Biarticulado 3+1', 'Biarticulado 3B1', 40000, 1000);
```

### **Tabla historial_vehiculos (Nueva - Auditoría)**
```sql
CREATE TABLE historial_vehiculos (
    id SERIAL PRIMARY KEY,
    placa VARCHAR(10) NOT NULL,
    campo_modificado VARCHAR(50) NOT NULL,
    valor_anterior TEXT,
    valor_nuevo TEXT,
    justificacion TEXT,
    usuario_id INTEGER NOT NULL,
    timestamp_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (placa) REFERENCES vehiculos(placa),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    INDEX idx_historial_placa (placa),
    INDEX idx_historial_timestamp (timestamp_cambio)
);
```

### **Vista para Consultas Optimizadas**
```sql
CREATE VIEW v_vehiculos_completo AS
SELECT 
    v.placa,
    v.codigo_tarjeta,
    v.marca_vehiculo,
    v.empresa_transporte,
    v.numero_interno,
    v.color_vehiculo,
    v.conductor_nombre,
    v.conductor_cedula,
    v.activo,
    v.observaciones,
    v.created_at,
    v.updated_at,
    -- Datos categoría BASCAM
    cv.id as categoria_id,
    cv.codigo_bascam,
    cv.descripcion_bascam,
    cv.peso_maximo_kg,
    cv.tolerancia_kg,
    cv.peso_total_permitido_kg,
    -- Estadísticas de uso
    COALESCE(ep.ultimo_pesaje, '1900-01-01'::timestamp) as ultimo_pesaje,
    COALESCE(ep.total_pesajes, 0) as total_pesajes,
    -- Usuario creación
    u_creado.nombre as creado_por_nombre,
    u_actualizado.nombre as actualizado_por_nombre
FROM vehiculos v
LEFT JOIN categoria_vehiculo cv ON v.categoria_id = cv.id
LEFT JOIN usuarios u_creado ON v.created_by = u_creado.id
LEFT JOIN usuarios u_actualizado ON v.updated_by = u_actualizado.id
LEFT JOIN (
    SELECT 
        placa, 
        MAX(fecha_pesaje) as ultimo_pesaje,
        COUNT(*) as total_pesajes
    FROM eventos_pesaje 
    GROUP BY placa
) ep ON v.placa = ep.placa;
```

---

## 🧪 Plan de Pruebas

### **Pruebas de CRUD Básico**
```javascript
describe('HU-COMP-002: Gestión de Vehículos', () => {
    
    describe('Registro de vehículos', () => {
        test('Crear vehículo con datos válidos', async () => {
            const vehiculoData = {
                placa: 'TEST123',
                categoria_id: 5,
                empresa_transporte: 'Transportes Test S.A.S',
                numero_interno: 'TT-001',
                marca_vehiculo: 'Volvo',
                color_vehiculo: 'Blanco'
            };
            
            const response = await request(app)
                .post('/api/vehiculos')
                .set('Authorization', `Bearer ${adminToken}`)
                .send(vehiculoData)
                .expect(201);
                
            expect(response.body.data.placa).toBe('TEST123');
            expect(response.body.data.categoria_vehiculo.codigo_bascam).toBe('2S2');
        });
        
        test('Rechazar vehículo con placa inválida', async () => {
            const vehiculoData = {
                placa: 'INVALID',
                categoria_id: 5,
                empresa_transporte: 'Transportes Test S.A.S'
            };
            
            await request(app)
                .post('/api/vehiculos')
                .set('Authorization', `Bearer ${adminToken}`)
                .send(vehiculoData)
                .expect(400);
        });
        
        test('Rechazar vehículo con categoría inexistente', async () => {
            const vehiculoData = {
                placa: 'TEST456',
                categoria_id: 999,
                empresa_transporte: 'Transportes Test S.A.S'
            };
            
            await request(app)
                .post('/api/vehiculos')
                .set('Authorization', `Bearer ${adminToken}`)
                .send(vehiculoData)
                .expect(400);
        });
        
        test('Rechazar placa duplicada', async () => {
            // Crear primer vehículo
            await crearVehiculoTest('DUP123');
            
            // Intentar crear segundo con misma placa
            const vehiculoData = {
                placa: 'DUP123',
                categoria_id: 2,
                empresa_transporte: 'Otra Empresa'
            };
            
            await request(app)
                .post('/api/vehiculos')
                .set('Authorization', `Bearer ${adminToken}`)
                .send(vehiculoData)
                .expect(409);
        });
    });
    
    describe('Consultas y filtros', () => {
        test('Buscar por placa exacta', async () => {
            await crearVehiculoTest('BUSQ123');
            
            const response = await request(app)
                .get('/api/vehiculos/placa/BUSQ123')
                .set('Authorization', `Bearer ${operadorToken}`)
                .expect(200);
                
            expect(response.body.data.placa).toBe('BUSQ123');
        });
        
        test('Filtrar por empresa transportadora', async () => {
            const response = await request(app)
                .get('/api/vehiculos?empresa=Transportes Test')
                .set('Authorization', `Bearer ${coordinadorToken}`)
                .expect(200);
                
            expect(response.body.data.vehiculos.every(v => 
                v.empresa_transporte.includes('Transportes Test')
            )).toBe(true);
        });
        
        test('Filtrar por categoría BASCAM', async () => {
            const response = await request(app)
                .get('/api/vehiculos?categoria_id=5')
                .set('Authorization', `Bearer ${adminToken}`)
                .expect(200);
                
            expect(response.body.data.vehiculos.every(v => 
                v.categoria_vehiculo.codigo_bascam === '2S2'
            )).toBe(true);
        });
        
        test('Operador solo ve vehículos de su estación', async () => {
            const tokenOperadorEstacion1 = await loginAsOperador(1);
            
            const response = await request(app)
                .get('/api/vehiculos')
                .set('Authorization', `Bearer ${tokenOperadorEstacion1}`)
                .expect(200);
                
            // Verificar que solo ve vehículos que han pasado por estación 1
            // (implementación depende de lógica de negocio específica)
        });
    });
    
    describe('Cambio de categoría', () => {
        test('Admin puede cambiar categoría con justificación', async () => {
            await crearVehiculoTest('CAT123', 2); // Categoría C3
            
            const response = await request(app)
                .put('/api/vehiculos/CAT123/categoria')
                .set('Authorization', `Bearer ${adminToken}`)
                .send({
                    nueva_categoria_id: 5,
                    justificacion: 'Vehículo modificado - agregado semirremolque',
                    autorizado_por: 'Admin Sistema'
                })
                .expect(200);
                
            expect(response.body.data.categoria_vehiculo.codigo_bascam).toBe('2S2');
        });
        
        test('Operador no puede cambiar categoría', async () => {
            await crearVehiculoTest('CAT456', 2);
            
            await request(app)
                .put('/api/vehiculos/CAT456/categoria')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send({
                    nueva_categoria_id: 5,
                    justificacion: 'Intento no autorizado'
                })
                .expect(403);
        });
    });
    
    describe('Carga masiva', () => {
        test('Carga Excel válida procesa correctamente', async () => {
            const excelBuffer = await generarExcelPrueba([
                {
                    placa: 'MASS001',
                    categoria_bascam: 'C2',
                    empresa_transporte: 'Carga Masiva S.A.S',
                    numero_interno: 'CM-001',
                    marca_vehiculo: 'Mercedes'
                },
                {
                    placa: 'MASS002',
                    categoria_bascam: '2S3',
                    empresa_transporte: 'Carga Masiva S.A.S',
                    numero_interno: 'CM-002',
                    marca_vehiculo: 'Volvo'
                }
            ]);
            
            const response = await request(app)
                .post('/api/vehiculos/carga-excel')
                .set('Authorization', `Bearer ${coordinadorITSToken}`)
                .attach('file', excelBuffer, 'vehiculos_test.xlsx')
                .expect(200);
                
            expect(response.body.data.exitosos).toBe(2);
            expect(response.body.data.fallidos).toBe(0);
        });
        
        test('Carga con errores reporta correctamente', async () => {
            const excelBuffer = await generarExcelPrueba([
                {
                    placa: 'INVALID',  // Placa inválida
                    categoria_bascam: 'C2',
                    empresa_transporte: 'Test'
                },
                {
                    placa: 'ERR002',
                    categoria_bascam: 'INEXISTENTE', // Categoría inexistente
                    empresa_transporte: 'Test'
                }
            ]);
            
            const response = await request(app)
                .post('/api/vehiculos/carga-excel')
                .set('Authorization', `Bearer ${adminToken}`)
                .attach('file', excelBuffer, 'vehiculos_errores.xlsx')
                .expect(200);
                
            expect(response.body.data.fallidos).toBe(2);
            expect(response.body.data.errores).toHaveLength(2);
        });
    });
});
```

### **Datos de Prueba**
```sql
-- Vehículos de prueba para testing
INSERT INTO vehiculos (placa, categoria_id, empresa_transporte, numero_interno, marca_vehiculo, color_vehiculo, created_by) VALUES
('TEST001', 1, 'Transportes Prueba C2 S.A.S', 'TP-001', 'Chevrolet', 'Blanco', 1),
('TEST002', 2, 'Transportes Prueba C3 S.A.S', 'TP-002', 'Ford', 'Azul', 1),
('TEST003', 5, 'Logística Test 2S2 LTDA', 'LT-003', 'Volvo', 'Rojo', 1),
('TEST004', 8, 'Transportes Pesados 3S2 S.A.S', 'TP-004', 'Mercedes-Benz', 'Negro', 1),
('TEST005', 9, 'Carga Máxima 3S3 S.A.S', 'CM-005', 'Scania', 'Verde', 1);
```

---

## 📊 Plantillas y Formatos

### **Plantilla Excel para Carga Masiva**
```javascript
// Estructura de columnas obligatorias
const COLUMNAS_EXCEL = {
    A: 'placa',                    // Formato: ABC123 o ABC12D
    B: 'categoria_bascam',         // Código: C2, C3, 2S2, 2S3, 3S3, etc.
    C: 'empresa_transporte',       // Mínimo 5 caracteres
    D: 'numero_interno',           // Número interno empresa
    E: 'marca_vehiculo',           // Opcional
    F: 'color_vehiculo',           // Opcional
    G: 'conductor_cedula',         // Opcional
    H: 'conductor_nombre',         // Opcional
    I: 'observaciones'             // Opcional
};

// Validaciones por columna
const VALIDACIONES_EXCEL = {
    placa: {
        requerido: true,
        formato: /^[A-Z]{3}[0-9]{2}[A-Z]$|^[A-Z]{3}[0-9]{3}$/,
        mensaje: 'Formato placa inválido (ej: ABC123 o ABC12D)'
    },
    categoria_bascam: {
        requerido: true,
        valores_validos: ['C2', 'C3', 'C4-2', '2S1', '2S2', '2S3', '3S1', '3S2', '3S3', '2R2', '3R2', '3R3', '3B1'],
        mensaje: 'Categoría BASCAM no válida'
    },
    empresa_transporte: {
        requerido: true,
        min_length: 5,
        mensaje: 'Empresa transportadora mínimo 5 caracteres'
    }
};
```

### **Formato de Exportación**
```javascript
// Exportación Excel con metadatos
const formatoExportacion = {
    hoja1: 'Vehiculos_Activos',
    columnas: [
        'Placa',
        'Categoría BASCAM',
        'Descripción Categoría', 
        'Peso Máximo (kg)',
        'Límite Total (kg)',
        'Empresa Transportadora',
        'Número Interno',
        'Marca',
        'Color',
        'Conductor',
        'Último Pesaje',
        'Total Pesajes',
        'Estado',
        'Fecha Registro'
    ],
    metadatos: {
        generado_por: 'Sistema Comparendos AUTOVÍA',
        fecha_generacion: '2025-06-05T14:30:00Z',
        total_registros: 1247,
        filtros_aplicados: 'categoria_id=5, activo=true'
    }
};
```

---

## 🎨 Interfaz de Usuario

### **Formulario de Registro**
```javascript
// Componente React para registro de vehículo
const FormularioVehiculo = ({ modo = 'crear', vehiculo = null }) => {
    const [formData, setFormData] = useState({
        placa: '',
        categoria_id: '',
        empresa_transporte: '',
        numero_interno: '',
        marca_vehiculo: '',
        color_vehiculo: '',
        conductor_cedula: '',
        conductor_nombre: '',
        observaciones: ''
    });
    
    const [categoriasBascam, setCategoriasBascam] = useState([]);
    const [validaciones, setValidaciones] = useState({});
    
    return (
        <form className="form-vehiculo">
            <div className="grid grid-cols-2 gap-4">
                <div className="form-group">
                    <label className="label-required">Placa</label>
                    <input
                        type="text"
                        pattern="^[A-Z]{3}[0-9]{2,3}[A-Z]?$"
                        placeholder="ABC123"
                        className={`input ${validaciones.placa ? 'input-error' : ''}`}
                        value={formData.placa}
                        onChange={handlePlacaChange}
                        disabled={modo === 'editar'}
                    />
                    {validaciones.placa && (
                        <span className="error-message">{validaciones.placa}</span>
                    )}
                </div>
                
                <div className="form-group">
                    <label className="label-required">Categoría BASCAM</label>
                    <select
                        className={`select ${validaciones.categoria_id ? 'select-error' : ''}`}
                        value={formData.categoria_id}
                        onChange={handleCategoriaChange}
                    >
                        <option value="">Seleccionar categoría</option>
                        {categoriasBascam.map(cat => (
                            <option key={cat.id} value={cat.id}>
                                {cat.codigo_bascam} - {cat.descripcion_bascam} 
                                (Máx: {cat.peso_total_permitido_kg.toLocaleString()} kg)
                            </option>
                        ))}
                    </select>
                </div>
                
                <div className="form-group col-span-2">
                    <label className="label-required">Empresa Transportadora</label>
                    <input
                        type="text"
                        placeholder="Transportes Ejemplo S.A.S"
                        className={`input ${validaciones.empresa_transporte ? 'input-error' : ''}`}
                        value={formData.empresa_transporte}
                        onChange={handleEmpresaChange}
                    />
                </div>
                
                <div className="form-group">
                    <label>Número Interno</label>
                    <input
                        type="text"
                        placeholder="FL-001"
                        className="input"
                        value={formData.numero_interno}
                        onChange={e => setFormData({...formData, numero_interno: e.target.value})}
                    />
                </div>
                
                <div className="form-group">
                    <label>Marca</label>
                    <input
                        type="text"
                        placeholder="Volvo"
                        className="input"
                        value={formData.marca_vehiculo}
                        onChange={e => setFormData({...formData, marca_vehiculo: e.target.value})}
                    />
                </div>
            </div>
            
            <div className="form-actions">
                <button type="button" className="btn-cancel" onClick={onCancel}>
                    Cancelar
                </button>
                <button type="submit" className="btn-primary" disabled={!formValido}>
                    {modo === 'crear' ? 'Registrar Vehículo' : 'Actualizar Vehículo'}
                </button>
            </div>
        </form>
    );
};
```

### **Vista de Lista con Filtros**
```javascript
const ListaVehiculos = () => {
    const [vehiculos, setVehiculos] = useState([]);
    const [filtros, setFiltros] = useState({
        placa: '',
        empresa: '',
        categoria_id: '',
        activo: true
    });
    const [paginacion, setPaginacion] = useState({ page: 1, limit: 50 });
    
    return (
        <div className="lista-vehiculos">
            <div className="filtros-bar">
                <input
                    type="text"
                    placeholder="Buscar por placa"
                    value={filtros.placa}
                    onChange={e => setFiltros({...filtros, placa: e.target.value})}
                    className="filtro-input"
                />
                
                <input
                    type="text"
                    placeholder="Empresa transportadora"
                    value={filtros.empresa}
                    onChange={e => setFiltros({...filtros, empresa: e.target.value})}
                    className="filtro-input"
                />
                
                <select
                    value={filtros.categoria_id}
                    onChange={e => setFiltros({...filtros, categoria_id: e.target.value})}
                    className="filtro-select"
                >
                    <option value="">Todas las categorías</option>
                    {categoriasBascam.map(cat => (
                        <option key={cat.id} value={cat.id}>
                            {cat.codigo_bascam} - {cat.descripcion_bascam}
                        </option>
                    ))}
                </select>
                
                <button className="btn-primary" onClick={handleBuscar}>
                    Buscar
                </button>
                
                <button className="btn-export" onClick={handleExportar}>
                    Exportar Excel
                </button>
            </div>
            
            <div className="tabla-vehiculos">
                <table className="table">
                    <thead>
                        <tr>
                            <th>Placa</th>
                            <th>Categoría BASCAM</th>
                            <th>Límite Peso (kg)</th>
                            <th>Empresa</th>
                            <th>Último Pesaje</th>
                            <th>Total Pesajes</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        {vehiculos.map(vehiculo => (
                            <FilaVehiculo 
                                key={vehiculo.placa} 
                                vehiculo={vehiculo}
                                onEditar={handleEditar}
                                onToggleStatus={handleToggleStatus}
                                onVerHistorial={handleVerHistorial}
                            />
                        ))}
                    </tbody>
                </table>
            </div>
            
            <Paginacion
                current={paginacion.page}
                total={paginacion.total_pages}
                onChange={handleCambioPagina}
            />
        </div>
    );
};
```

---

## 🔍 Validaciones y Reglas de Negocio

### **Validaciones de Placa Colombiana**
```javascript
const validarPlacaColombiana = (placa) => {
    const formatosValidos = [
        /^[A-Z]{3}[0-9]{3}$/,     // ABC123 (formato estándar)
        /^[A-Z]{3}[0-9]{2}[A-Z]$/ // ABC12D (formato nuevo)
    ];
    
    return formatosValidos.some(formato => formato.test(placa));
};

const validarPlacaDisponible = async (placa) => {
    const response = await api.get(`/api/vehiculos/validar-placa/${placa}`);
    return response.data.disponible;
};
```

### **Validaciones de Empresa**
```javascript
const validarEmpresa = (empresa) => {
    const validaciones = {
        longitud: empresa.length >= 5,
        formato: /^[A-Za-z0-9\s\.\-&áéíóúÁÉÍÓÚñÑ]+$/.test(empresa),
        palabrasValidas: !/(test|prueba|ejemplo)/i.test(empresa)
    };
    
    return {
        valida: Object.values(validaciones).every(v => v),
        errores: Object.keys(validaciones).filter(k => !validaciones[k])
    };
};
```

### **Reglas de Cambio de Categoría**
```javascript
const validarCambioCategoria = (categoriaActual, categoriaNueva, justificacion) => {
    // Solo ciertos roles pueden cambiar categoría
    if (!['ADMIN', 'COORDINADOR_ITS'].includes(usuarioActual.rol)) {
        return { valido: false, error: 'Sin permisos para cambiar categoría' };
    }
    
    // Justificación obligatoria
    if (!justificacion || justificacion.length < 10) {
        return { valido: false, error: 'Justificación obligatoria (mínimo 10 caracteres)' };
    }
    
    // Validar cambios lógicos
    const cambiosProhibidos = [
        { desde: 'C2', hacia: '3S3', razon: 'Cambio físicamente imposible' },
        { desde: '3S3', hacia: 'C2', razon: 'Degradación no permitida sin evidencia' }
    ];
    
    const cambioProhibido = cambiosProhibidos.find(c => 
        c.desde === categoriaActual.codigo_bascam && 
        c.hacia === categoriaNueva.codigo_bascam
    );
    
    if (cambioProhibido) {
        return { valido: false, error: cambioProhibido.razon };
    }
    
    return { valido: true };
};
```

---

## 📋 Definición de Terminado (DoD)

### **Validaciones Técnicas**
- ✅ CRUD completo funcionando con todas las validaciones
- ✅ APIs de carga masiva procesando correctamente Excel/CSV
- ✅ Validaciones de placa colombiana implementadas
- ✅ Relación con categorías BASCAM funcionando
- ✅ Tests de integración pasando >95%
- ✅ Performance <500ms en búsquedas por placa

### **Validaciones de Negocio**
- ✅ Operadores limitados según su estación
- ✅ Solo roles autorizados pueden cambiar categorías
- ✅ Historial de cambios completo y auditado
- ✅ Eliminación lógica preservando histórico
- ✅ Carga masiva con validaciones en tiempo real

### **Validaciones de Usuario**
- ✅ Formularios intuitivos con validaciones en tiempo real
- ✅ Búsquedas rápidas y filtros efectivos
- ✅ Exportaciones en formatos requeridos
- ✅ Mensajes de error claros y accionables
- ✅ UI responsiva para diferentes dispositivos

### **Validaciones de Datos**
- ✅ Integridad referencial mantenida
- ✅ Datos BASCAM poblados correctamente
- ✅ Migración desde sistema original sin pérdidas
- ✅ Backup automático antes de cargas masivas

---

## 🚀 Estrategia de Migración

### **Migración desde Sistema Vehiculos Original**
```sql
-- Script de migración de datos existentes
-- 1. Agregar columnas nuevas con valores por defecto
ALTER TABLE vehiculos ADD COLUMN empresa_transporte VARCHAR(200) DEFAULT 'Por Clasificar';
ALTER TABLE vehiculos ADD COLUMN categoria_id INTEGER DEFAULT 1; -- C2 por defecto

-- 2. Migrar datos existentes aplicando lógica de negocio
UPDATE vehiculos SET 
    empresa_transporte = COALESCE(usuario, 'Empresa No Registrada'),
    categoria_id = CASE 
        WHEN categoria_vehiculo LIKE '%2 ejes%' THEN 1  -- C2
        WHEN categoria_vehiculo LIKE '%3 ejes%' THEN 2  -- C3
        WHEN categoria_vehiculo LIKE '%articulado%' THEN 5  -- 2S2 por defecto
        ELSE 1  -- C2 por defecto
    END;

-- 3. Establecer restricciones después de migración
ALTER TABLE vehiculos ALTER COLUMN empresa_transporte SET NOT NULL;
ALTER TABLE vehiculos ALTER COLUMN categoria_id SET NOT NULL;

-- 4. Crear respaldo de datos originales
CREATE TABLE vehiculos_respaldo_migracion AS 
    SELECT * FROM vehiculos_pre_migracion;
```

### **Validación Post-Migración**
```javascript
const validarMigracion = async () => {
    const resultados = {
        vehiculos_migrados: 0,
        errores_categoria: 0,
        empresas_sin_clasificar: 0,
        placas_duplicadas: 0
    };
    
    // Contar registros migrados
    resultados.vehiculos_migrados = await db.count('vehiculos');
    
    // Verificar categorías asignadas
    resultados.errores_categoria = await db.count('vehiculos', { categoria_id: null });
    
    // Verificar empresas por clasificar
    resultados.empresas_sin_clasificar = await db.count('vehiculos', { 
        empresa_transporte: 'Por Clasificar' 
    });
    
    // Verificar duplicados
    const duplicados = await db.query(`
        SELECT placa, COUNT(*) as count 
        FROM vehiculos 
        GROUP BY placa 
        HAVING COUNT(*) > 1
    `);
    resultados.placas_duplicadas = duplicados.length;
    
    return resultados;
};
```

---

**Esta HU-COMP-002 aprovecha eficientemente el 90% de la funcionalidad del sistema vehiculos original, adaptándola específicamente para el control de sobrepeso vehicular con clasificación BASCAM, manteniendo la robustez y añadiendo las funcionalidades específicas del nuevo modelo de negocio.**
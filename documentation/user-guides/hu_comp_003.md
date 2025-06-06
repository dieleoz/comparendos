# HU-COMP-003 – Clasificación Automática BASCAM y Detección de Sobrepeso

## 📋 Información General
- **ID**: HU-COMP-003
- **Título**: Clasificación Automática BASCAM y Detección de Sobrepeso en Tiempo Real
- **Origen**: NUEVA (Core del modelo de negocio comparendos)
- **Prioridad**: CRÍTICA (Funcionalidad central del sistema)
- **Fase**: 1 - Fundamentos
- **Dependencias**: HU-COMP-001 (Autenticación), HU-COMP-002 (Vehículos)
- **Reutilización**: 0% - Funcionalidad completamente nueva

---

## 🎯 Descripción
Como **operador de báscula** del sistema comparendos,
quiero que el sistema clasifique automáticamente los vehículos según el estándar BASCAM y detecte sobrepesos en tiempo real,
para procesar eficientemente el flujo vehicular y activar inmediatamente los protocolos de control de peso cuando se detecten infracciones, garantizando cumplimiento de la Resolución 2460/2022 y reduciendo tiempo de procesamiento por vehículo.

---

## 🚛 Contexto del Negocio BASCAM

### **¿Qué es BASCAM?**
**BASCAM** (Basic Automatic System for Classification and Monitoring) es el sistema automático que:
- **Detecta configuración de ejes** del vehículo mediante sensores
- **Clasifica automáticamente** según códigos normativos (C2, C3, 2S2, 2S3, 3S3, etc.)
- **Determina límites de peso** aplicables según Resolución 2460/2022
- **Calcula sobrepeso instantáneamente** comparando peso real vs límite + tolerancia

### **Flujo Operativo Real**
1. **Vehículo ingresa** a báscula (velocidad <5 km/h)
2. **Sensores detectan** configuración de ejes y peso bruto
3. **BASCAM clasifica** automáticamente (ej: "2S2" = Tracto 2 + Semirremolque 2)
4. **Sistema consulta** tabla categoria_vehiculo para obtener límites
5. **Evalúa sobrepeso** en tiempo real (peso > límite + tolerancia)
6. **Activa protocolo** según resultado: normal o sobrepeso

### **Volumen Operativo**
- **Flujo estimado**: 1,152 vehículos/día (4 estaciones × 12 vh/h × 24h)
- **Tiempo procesamiento**: <30 segundos por vehículo
- **Sobrepesos esperados**: ~8% (≈90/día)
- **Clasificaciones más frecuentes**: C2 (35%), C3 (25%), 2S2 (20%), 2S3 (15%), otros (5%)

---

## 👥 Actores y Responsabilidades

| Actor | Responsabilidad | Acciones en el Sistema |
|-------|-----------------|----------------------|
| **OPERADOR_BASCULA** | Supervisar proceso automático | Validar clasificación, autorizar paso/retención |
| **COORDINADOR_ITS** | Configurar parámetros BASCAM | Ajustar tolerancias, calibrar clasificación |
| **INGENIERO_RESIDENTE** | Autorizar excepciones | Sobrescribir clasificación, autorizar paso especial |
| **ADMIN** | Gestión completa del sistema | Configurar WebService, mantener tablas maestras |

---

## 🔄 Flujo Funcional Detallado

### **1. Integración con WebService BASCAM**
```javascript
// Endpoint del WebService existente
WebService URL: http://bascam.autovia.local/Service1.asmx
Métodos disponibles:
- PesajesActuales()          // Últimos 20 pesajes con clasificación
- PesajePorIdRegistro(id)    // Pesaje específico por ID
- PesajesPorFecha(inicio, fin) // Rango de fechas
```

### **2. Proceso de Clasificación Automática**
```javascript
// Datos recibidos del WebService BASCAM
{
    "id_registro": 12345,
    "fecha_pesaje": "2025-06-05T10:30:00",
    "placa": "ABC123",
    "peso_bruto_kg": 31500,
    "codigo_bascam": "2S2",
    "configuracion_ejes": "Tracto 2 + Semirremolque 2",
    "id_bascula": 1,
    "id_estacion": 1,
    "foto_vehiculo_path": "/evidencias/2025/06/05/ABC123_103000.jpg"
}
```

### **3. Evaluación de Sobrepeso**
```javascript
// Algoritmo de evaluación
const evaluarSobrepeso = async (pesaje) => {
    // 1. Obtener categoría BASCAM
    const categoria = await obtenerCategoriaBASCAM(pesaje.codigo_bascam);
    
    // 2. Calcular límite aplicable
    const limite_total = categoria.peso_maximo_kg + categoria.tolerancia_kg;
    
    // 3. Evaluar sobrepeso
    const exceso_kg = Math.max(0, pesaje.peso_bruto_kg - limite_total);
    const tiene_sobrepeso = exceso_kg > 0;
    
    // 4. Determinar severidad
    const porcentaje_exceso = (exceso_kg / categoria.peso_maximo_kg) * 100;
    let severidad = 'NORMAL';
    if (porcentaje_exceso > 0 && porcentaje_exceso <= 10) severidad = 'LEVE';
    if (porcentaje_exceso > 10 && porcentaje_exceso <= 20) severidad = 'MODERADO';
    if (porcentaje_exceso > 20) severidad = 'GRAVE';
    
    return {
        limite_aplicado_kg: limite_total,
        exceso_kg: exceso_kg,
        tiene_sobrepeso: tiene_sobrepeso,
        severidad: severidad,
        porcentaje_exceso: porcentaje_exceso.toFixed(2)
    };
};
```

---

## ✅ Criterios de Aceptación

### **CA-003-01: Integración WebService BASCAM**
- ✅ Sistema DEBE consultar WebService cada 10 segundos para nuevos pesajes
- ✅ Timeout de conexión NO DEBE exceder 5 segundos
- ✅ Sistema DEBE funcionar en modo offline si WebService falla
- ✅ Reintento automático cada 30 segundos cuando WebService esté caído
- ✅ Log completo de errores de comunicación con BASCAM

### **CA-003-02: Clasificación Automática**
- ✅ Código BASCAM DEBE mapear automáticamente a categoria_vehiculo
- ✅ Sistema DEBE rechazar códigos BASCAM inexistentes en tabla maestra
- ✅ Clasificación manual DEBE estar disponible como respaldo
- ✅ Operador PUEDE sobrescribir clasificación automática con justificación
- ✅ Histórico DEBE mantener tanto clasificación automática como manual

### **CA-003-03: Detección de Sobrepeso**
- ✅ Cálculo de sobrepeso DEBE ser instantáneo (<1 segundo)
- ✅ Tolerancia DEBE aplicarse según tabla categoria_vehiculo
- ✅ Sistema DEBE alertar inmediatamente cuando detecte sobrepeso
- ✅ Severidad DEBE calcularse según porcentaje de exceso
- ✅ Evidencia fotográfica DEBE capturarse automáticamente

### **CA-003-04: Gestión de Alertas**
- ✅ Sobrepeso LEVE: Alerta amarilla, registro normal
- ✅ Sobrepeso MODERADO: Alerta naranja, retención recomendada
- ✅ Sobrepeso GRAVE: Alerta roja, retención obligatoria
- ✅ Vehículo oficial exento DEBE omitir alertas de sobrepeso
- ✅ Dashboard DEBE mostrar alertas en tiempo real

### **CA-003-05: Contingencias y Respaldo**
- ✅ Modo offline DEBE permitir clasificación manual
- ✅ Datos offline DEBEN sincronizarse automáticamente al restaurar conexión
- ✅ Respaldo en Excel DEBE incluir todos los campos de clasificación
- ✅ Validaciones DEBEN funcionar igual en modo online y offline

---

## 🔧 APIs Principales

### **Integración BASCAM**
```javascript
// Estado del WebService
GET /api/bascam/status
Response 200:
{
    "success": true,
    "data": {
        "webservice_url": "http://bascam.autovia.local/Service1.asmx",
        "estado": "ONLINE",
        "ultima_conexion": "2025-06-05T10:30:15Z",
        "latencia_ms": 150,
        "version": "2.1.3",
        "estaciones_activas": [1, 2, 3, 4]
    }
}

// Pesajes actuales desde BASCAM
GET /api/bascam/pesajes-actuales
Response 200:
{
    "success": true,
    "data": {
        "pesajes": [
            {
                "id_registro": 12345,
                "fecha_pesaje": "2025-06-05T10:30:00Z",
                "placa": "ABC123",
                "peso_bruto_kg": 31500,
                "codigo_bascam": "2S2",
                "id_bascula": 1,
                "procesado": false
            }
        ],
        "total_pendientes": 3,
        "ultimo_sync": "2025-06-05T10:30:15Z"
    }
}

// Procesar pesaje específico
POST /api/bascam/procesar-pesaje
Content-Type: application/json
{
    "id_registro": 12345,
    "clasificacion_manual": null,  // null = usar automática
    "observaciones": "Procesamiento normal"
}

Response 201:
{
    "success": true,
    "data": {
        "evento_pesaje_id": 567,
        "clasificacion_usada": "AUTOMATICA",
        "codigo_bascam": "2S2",
        "categoria_id": 5,
        "limite_aplicado_kg": 29725,
        "peso_detectado_kg": 31500,
        "exceso_kg": 1775,
        "tiene_sobrepeso": true,
        "severidad": "LEVE",
        "accion_recomendada": "RETENCION_OPCIONAL"
    }
}

// Clasificación manual (override)
POST /api/bascam/clasificar-manual
Content-Type: application/json
{
    "id_registro": 12345,
    "codigo_bascam_manual": "2S3",
    "justificacion": "Error de sensores - vehículo tiene 3 ejes en semirremolque",
    "operador_id": 2
}
```

### **Gestión de Categorías BASCAM**
```javascript
// Listar categorías disponibles
GET /api/categorias-bascam
Response 200:
{
    "success": true,
    "data": {
        "categorias": [
            {
                "id": 1,
                "codigo_bascam": "C2",
                "descripcion": "Camión 2 ejes",
                "peso_maximo_kg": 17000,
                "tolerancia_kg": 700,
                "peso_total_permitido_kg": 17700,
                "configuracion": "Rígido 2 ejes",
                "activo": true
            },
            {
                "id": 5,
                "codigo_bascam": "2S2",
                "descripcion": "Tracto 2 + Semirrem 2",
                "peso_maximo_kg": 29000,
                "tolerancia_kg": 725,
                "peso_total_permitido_kg": 29725,
                "configuracion": "Tractocamión 2S2",
                "activo": true
            }
        ]
    }
}

// Obtener categoría específica
GET /api/categorias-bascam/:codigo
Response 200:
{
    "success": true,
    "data": {
        "categoria": {
            "id": 5,
            "codigo_bascam": "2S2",
            "descripcion": "Tracto 2 + Semirrem 2",
            "peso_maximo_kg": 29000,
            "tolerancia_kg": 725,
            "peso_total_permitido_kg": 29725,
            "normativa": "Resolución 2460/2022 - Anexo II",
            "ejemplos_vehiculos": ["Tractocamión con semirremolque de 2 ejes"],
            "activo": true
        }
    }
}

// Actualizar tolerancias (solo COORDINADOR_ITS y ADMIN)
PUT /api/categorias-bascam/:id/tolerancia
Authorization: Bearer {coordinador_token}
Content-Type: application/json
{
    "nueva_tolerancia_kg": 800,
    "justificacion": "Ajuste según nueva directriz ANI",
    "vigencia_desde": "2025-06-10"
}
```

### **Procesamiento de Eventos**
```javascript
// Crear evento de pesaje desde BASCAM
POST /api/eventos-pesaje
Authorization: Bearer {operador_token}
Content-Type: application/json
{
    "id_registro_bascam": 12345,
    "placa": "ABC123",
    "fecha_pesaje": "2025-06-05T10:30:00Z",
    "peso_bruto_kg": 31500,
    "codigo_bascam": "2S2",
    "id_estacion": 1,
    "id_bascula": 1,
    "foto_evidencia_path": "/evidencias/2025/06/05/ABC123_103000.jpg",
    "operador_id": 2,
    "modo_procesamiento": "AUTOMATICO"
}

Response 201:
{
    "success": true,
    "data": {
        "evento_id": 567,
        "placa": "ABC123",
        "categoria_aplicada": {
            "id": 5,
            "codigo_bascam": "2S2",
            "limite_kg": 29725
        },
        "evaluacion_peso": {
            "peso_detectado_kg": 31500,
            "limite_aplicado_kg": 29725,
            "exceso_kg": 1775,
            "tiene_sobrepeso": true,
            "severidad": "LEVE",
            "porcentaje_exceso": "6.12"
        },
        "acciones_siguientes": {
            "retener_vehiculo": false,
            "generar_comparendo": true,
            "llamar_policia": false,
            "imprimir_tiquete_especial": true
        },
        "tiquete_numero": "NEI-001-2025-000567",
        "created_at": "2025-06-05T10:30:18Z"
    }
}

// Consultar eventos con sobrepeso del día
GET /api/eventos-pesaje/sobrepesos?fecha=2025-06-05&id_estacion=1
Authorization: Bearer {operador_token}
Response 200:
{
    "success": true,
    "data": {
        "eventos_sobrepeso": [
            {
                "evento_id": 567,
                "hora": "10:30:00",
                "placa": "ABC123",
                "codigo_bascam": "2S2",
                "exceso_kg": 1775,
                "severidad": "LEVE",
                "estado": "PROCESADO",
                "comparendo_generado": false
            }
        ],
        "resumen": {
            "total_pesajes_dia": 156,
            "total_sobrepesos": 12,
            "porcentaje_sobrepeso": 7.69,
            "severidad_promedio": "LEVE"
        }
    }
}
```

---

## 🗄️ Estructura de Base de Datos

### **Tabla eventos_pesaje (Nueva - Core)**
```sql
CREATE TABLE eventos_pesaje (
    id SERIAL PRIMARY KEY,
    id_registro_bascam INTEGER UNIQUE, -- ID del WebService BASCAM
    placa VARCHAR(10) NOT NULL,
    fecha_pesaje TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_estacion INTEGER NOT NULL,
    id_bascula INTEGER,
    
    -- Datos de peso
    peso_bruto_kg NUMERIC(8,1) NOT NULL,
    peso_neto_kg NUMERIC(8,1),
    
    -- Clasificación BASCAM
    codigo_bascam VARCHAR(10) NOT NULL,
    categoria_id INTEGER NOT NULL,
    clasificacion_modo VARCHAR(20) DEFAULT 'AUTOMATICA', -- 'AUTOMATICA', 'MANUAL'
    clasificacion_justificacion TEXT,
    
    -- Evaluación de sobrepeso
    limite_aplicado_kg NUMERIC(8,1) NOT NULL,
    exceso_kg NUMERIC(8,1) DEFAULT 0,
    tiene_sobrepeso BOOLEAN DEFAULT false,
    severidad VARCHAR(20) DEFAULT 'NORMAL', -- 'NORMAL', 'LEVE', 'MODERADO', 'GRAVE'
    porcentaje_exceso NUMERIC(5,2) DEFAULT 0,
    
    -- Evidencia y trazabilidad
    foto_evidencia_path TEXT,
    tiquete_numero VARCHAR(50) UNIQUE,
    operador_id INTEGER NOT NULL,
    procesado_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Estados del proceso
    estado_evento VARCHAR(20) DEFAULT 'COMPLETADO', -- 'PENDIENTE', 'COMPLETADO', 'ANULADO'
    requiere_retencion BOOLEAN DEFAULT false,
    vehiculo_retenido BOOLEAN DEFAULT false,
    liberado_en TIMESTAMP,
    liberado_por_id INTEGER,
    
    -- Observaciones
    observaciones TEXT,
    datos_bascam_raw JSONB, -- Datos completos del WebService
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (categoria_id) REFERENCES categoria_vehiculo(id),
    FOREIGN KEY (id_estacion) REFERENCES estaciones_control(id_estacion),
    FOREIGN KEY (id_bascula) REFERENCES basculas(id_bascula),
    FOREIGN KEY (operador_id) REFERENCES usuarios(id),
    FOREIGN KEY (liberado_por_id) REFERENCES usuarios(id),
    
    -- Indices para performance
    INDEX idx_eventos_fecha_estacion (fecha_pesaje, id_estacion),
    INDEX idx_eventos_placa (placa),
    INDEX idx_eventos_sobrepeso (tiene_sobrepeso, severidad),
    INDEX idx_eventos_bascam (id_registro_bascam),
    INDEX idx_eventos_tiquete (tiquete_numero)
);
```

### **Tabla sincronizacion_bascam (Nueva - Control)**
```sql
CREATE TABLE sincronizacion_bascam (
    id SERIAL PRIMARY KEY,
    fecha_sync TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_sync VARCHAR(20) NOT NULL, -- 'AUTOMATICA', 'MANUAL', 'RECOVERY'
    registros_procesados INTEGER DEFAULT 0,
    registros_nuevos INTEGER DEFAULT 0,
    registros_error INTEGER DEFAULT 0,
    estado_webservice VARCHAR(20) DEFAULT 'ONLINE', -- 'ONLINE', 'OFFLINE', 'ERROR'
    latencia_ms INTEGER,
    errores_detalle JSONB,
    usuario_sync_id INTEGER,
    
    FOREIGN KEY (usuario_sync_id) REFERENCES usuarios(id),
    INDEX idx_sync_fecha (fecha_sync),
    INDEX idx_sync_estado (estado_webservice)
);
```

### **Tabla alertas_sobrepeso (Nueva - Monitoreo)**
```sql
CREATE TABLE alertas_sobrepeso (
    id SERIAL PRIMARY KEY,
    evento_pesaje_id INTEGER NOT NULL,
    severidad VARCHAR(20) NOT NULL,
    mensaje_alerta TEXT NOT NULL,
    timestamp_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operador_notificado_id INTEGER,
    leida BOOLEAN DEFAULT false,
    leida_at TIMESTAMP,
    acciones_tomadas TEXT,
    
    FOREIGN KEY (evento_pesaje_id) REFERENCES eventos_pesaje(id),
    FOREIGN KEY (operador_notificado_id) REFERENCES usuarios(id),
    INDEX idx_alertas_timestamp (timestamp_alerta),
    INDEX idx_alertas_leida (leida)
);
```

### **Vista optimizada para consultas**
```sql
CREATE VIEW v_eventos_pesaje_completo AS
SELECT 
    ep.id,
    ep.placa,
    ep.fecha_pesaje,
    ep.peso_bruto_kg,
    ep.codigo_bascam,
    ep.exceso_kg,
    ep.tiene_sobrepeso,
    ep.severidad,
    ep.tiquete_numero,
    ep.estado_evento,
    
    -- Datos categoría
    cv.descripcion_bascam,
    cv.peso_maximo_kg,
    cv.tolerancia_kg,
    cv.peso_total_permitido_kg,
    
    -- Datos estación
    ec.nombre_estacion,
    ec.direccion_flujo,
    
    -- Datos báscula
    b.nombre as nombre_bascula,
    
    -- Datos operador
    u.nombre as operador_nombre,
    
    -- Datos vehículo (si existe)
    v.empresa_transporte,
    v.numero_interno,
    v.es_oficial
    
FROM eventos_pesaje ep
LEFT JOIN categoria_vehiculo cv ON ep.categoria_id = cv.id
LEFT JOIN estaciones_control ec ON ep.id_estacion = ec.id_estacion
LEFT JOIN basculas b ON ep.id_bascula = b.id_bascula
LEFT JOIN usuarios u ON ep.operador_id = u.id
LEFT JOIN vehiculos v ON ep.placa = v.placa;
```

---

## 🧪 Plan de Pruebas

### **Pruebas de Integración BASCAM**
```javascript
describe('HU-COMP-003: Clasificación BASCAM', () => {
    
    describe('Integración WebService', () => {
        test('Conexión exitosa con WebService BASCAM', async () => {
            const response = await request(app)
                .get('/api/bascam/status')
                .set('Authorization', `Bearer ${operadorToken}`)
                .expect(200);
                
            expect(response.body.data.estado).toBe('ONLINE');
            expect(response.body.data.latencia_ms).toBeLessThan(5000);
        });
        
        test('Obtener pesajes actuales desde BASCAM', async () => {
            const response = await request(app)
                .get('/api/bascam/pesajes-actuales')
                .set('Authorization', `Bearer ${operadorToken}`)
                .expect(200);
                
            expect(response.body.data.pesajes).toBeInstanceOf(Array);
            if (response.body.data.pesajes.length > 0) {
                const pesaje = response.body.data.pesajes[0];
                expect(pesaje).toHaveProperty('codigo_bascam');
                expect(pesaje).toHaveProperty('peso_bruto_kg');
                expect(pesaje).toHaveProperty('placa');
            }
        });
        
        test('Manejo de WebService offline', async () => {
            // Simular WebService caído
            mockWebServiceOffline();
            
            const response = await request(app)
                .get('/api/bascam/status')
                .set('Authorization', `Bearer ${operadorToken}`)
                .expect(200);
                
            expect(response.body.data.estado).toBe('OFFLINE');
        });
    });
    
    describe('Clasificación Automática', () => {
        test('Mapeo correcto código BASCAM a categoría', async () => {
            const pesajeData = {
                id_registro_bascam: 12345,
                placa: 'TEST123',
                peso_bruto_kg: 31500,
                codigo_bascam: '2S2',
                id_estacion: 1,
                id_bascula: 1
            };
            
            const response = await request(app)
                .post('/api/eventos-pesaje')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send(pesajeData)
                .expect(201);
                
            // Verificar que NO se creó alerta para vehículo oficial
            const alertas = await db.query(
                'SELECT * FROM alertas_sobrepeso WHERE evento_pesaje_id = ?',
                [response.body.data.evento_id]
            );
            
            expect(alertas.length).toBe(0);
            expect(response.body.data.evaluacion_peso.tiene_sobrepeso).toBe(false); // Exento
        });
    });
    
    describe('Contingencias y Modo Offline', () => {
        test('Funcionamiento en modo offline', async () => {
            // Simular WebService offline
            mockWebServiceOffline();
            
            const pesajeData = {
                placa: 'OFF001',
                peso_bruto_kg: 30000,
                codigo_bascam: '2S2', // Clasificación manual
                id_estacion: 1,
                modo_procesamiento: 'MANUAL'
            };
            
            const response = await request(app)
                .post('/api/eventos-pesaje')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send(pesajeData)
                .expect(201);
                
            expect(response.body.data.clasificacion_usada).toBe('MANUAL');
            expect(response.body.data.evaluacion_peso.tiene_sobrepeso).toBe(true);
        });
        
        test('Sincronización automática al restaurar conexión', async () => {
            // Registrar eventos en modo offline
            await crearEventosOffline(['OFF002', 'OFF003']);
            
            // Restaurar conexión
            mockWebServiceOnline();
            
            const response = await request(app)
                .post('/api/bascam/sincronizar')
                .set('Authorization', `Bearer ${coordinadorToken}`)
                .expect(200);
                
            expect(response.body.data.registros_sincronizados).toBeGreaterThan(0);
        });
    });
});
```

### **Datos de Prueba BASCAM**
```sql
-- Categorías BASCAM para testing
INSERT INTO categoria_vehiculo (codigo_bascam, descripcion_bascam, peso_maximo_kg, tolerancia_kg) VALUES
('C2', 'Camión 2 ejes TEST', 17000, 700),
('2S2', 'Tracto 2 + Semirrem 2 TEST', 29000, 725),
('2S3', 'Tracto 2 + Semirrem 3 TEST', 40500, 1013),
('3S3', 'Tracto 3 + Semirrem 3 TEST', 52000, 1300);

-- Vehículos de prueba
INSERT INTO vehiculos (placa, categoria_id, empresa_transporte, es_oficial) VALUES
('TEST123', 5, 'Transportes Test 2S2', false),
('SOB001', 5, 'Transportes Sobrepeso', false),
('OFI001', 5, 'Ambulancias Cruz Roja', true),
('GRA001', 5, 'Transportes Pesados', false);

-- Eventos de prueba
INSERT INTO eventos_pesaje (placa, peso_bruto_kg, codigo_bascam, categoria_id, limite_aplicado_kg, exceso_kg, tiene_sobrepeso, severidad, operador_id, id_estacion) VALUES
('TEST123', 28000, '2S2', 5, 29725, 0, false, 'NORMAL', 2, 1),
('SOB001', 30000, '2S2', 5, 29725, 275, true, 'LEVE', 2, 1),
('GRA001', 36000, '2S2', 5, 29725, 6275, true, 'GRAVE', 2, 1);
```

---

## 🎨 Interfaz de Usuario

### **Dashboard de Clasificación BASCAM**
```javascript
const DashboardBASCAM = () => {
    const [estadoWebService, setEstadoWebService] = useState('ONLINE');
    const [pesajesRecientes, setPesajesRecientes] = useState([]);
    const [alertasSobrepeso, setAlertasSobrepeso] = useState([]);
    
    return (
        <div className="dashboard-bascam">
            <div className="status-bar">
                <div className={`webservice-status ${estadoWebService.toLowerCase()}`}>
                    <span className="status-indicator"></span>
                    WebService BASCAM: {estadoWebService}
                </div>
                
                <div className="sync-info">
                    Última sincronización: {ultimaSync}
                </div>
            </div>
            
            <div className="grid grid-cols-3 gap-6">
                <div className="pesajes-tiempo-real">
                    <h3>Pesajes en Tiempo Real</h3>
                    {pesajesRecientes.map(pesaje => (
                        <div key={pesaje.id} className={`pesaje-item ${pesaje.severidad.toLowerCase()}`}>
                            <div className="pesaje-header">
                                <span className="placa">{pesaje.placa}</span>
                                <span className="hora">{formatHora(pesaje.fecha_pesaje)}</span>
                            </div>
                            <div className="pesaje-details">
                                <span className="categoria">{pesaje.codigo_bascam}</span>
                                <span className="peso">{pesaje.peso_bruto_kg.toLocaleString()} kg</span>
                                {pesaje.tiene_sobrepeso && (
                                    <span className="exceso">+{pesaje.exceso_kg} kg</span>
                                )}
                            </div>
                        </div>
                    ))}
                </div>
                
                <div className="alertas-sobrepeso">
                    <h3>Alertas de Sobrepeso</h3>
                    {alertasSobrepeso.map(alerta => (
                        <div key={alerta.id} className={`alerta-item severity-${alerta.severidad.toLowerCase()}`}>
                            <div className="alerta-header">
                                <span className="placa">{alerta.placa}</span>
                                <span className="severidad">{alerta.severidad}</span>
                            </div>
                            <div className="alerta-details">
                                <span className="exceso">{alerta.exceso_kg} kg exceso</span>
                                <span className="porcentaje">{alerta.porcentaje_exceso}%</span>
                            </div>
                            <div className="alerta-acciones">
                                <button 
                                    className="btn-retener"
                                    onClick={() => retenerVehiculo(alerta.evento_id)}
                                >
                                    Retener
                                </button>
                                <button 
                                    className="btn-autorizar"
                                    onClick={() => autorizarPaso(alerta.evento_id)}
                                >
                                    Autorizar
                                </button>
                            </div>
                        </div>
                    ))}
                </div>
                
                <div className="clasificaciones-bascam">
                    <h3>Clasificaciones del Día</h3>
                    <div className="charts-container">
                        <ClasificacionChart data={estadisticasClasificacion} />
                        <SobrepesoChart data={estadisticasSobrepeso} />
                    </div>
                </div>
            </div>
        </div>
    );
};
```

### **Modal de Clasificación Manual**
```javascript
const ModalClasificacionManual = ({ pesaje, onClose, onConfirm }) => {
    const [categoriaSeleccionada, setCategoriaSeleccionada] = useState('');
    const [justificacion, setJustificacion] = useState('');
    
    return (
        <div className="modal-overlay">
            <div className="modal-clasificacion">
                <h3>Clasificación Manual - {pesaje.placa}</h3>
                
                <div className="clasificacion-automatica">
                    <label>Clasificación Automática BASCAM:</label>
                    <div className="categoria-automatica">
                        {pesaje.codigo_bascam} - {pesaje.descripcion_bascam}
                        <span className="limite">Límite: {pesaje.limite_kg.toLocaleString()} kg</span>
                    </div>
                </div>
                
                <div className="clasificacion-manual">
                    <label>Nueva Clasificación:</label>
                    <select
                        value={categoriaSeleccionada}
                        onChange={e => setCategoriaSeleccionada(e.target.value)}
                        className="categoria-select"
                    >
                        <option value="">Seleccionar categoría</option>
                        {categoriasBascam.map(cat => (
                            <option key={cat.id} value={cat.codigo_bascam}>
                                {cat.codigo_bascam} - {cat.descripcion_bascam} 
                                (Límite: {cat.peso_total_permitido_kg.toLocaleString()} kg)
                            </option>
                        ))}
                    </select>
                </div>
                
                <div className="justificacion">
                    <label>Justificación (obligatoria):</label>
                    <textarea
                        value={justificacion}
                        onChange={e => setJustificacion(e.target.value)}
                        placeholder="Describa por qué es necesario cambiar la clasificación automática..."
                        className="justificacion-textarea"
                        required
                    />
                </div>
                
                <div className="impacto-cambio">
                    {categoriaSeleccionada && (
                        <div className="nueva-evaluacion">
                            <h4>Nuevo Resultado:</h4>
                            <div className="resultado-grid">
                                <span>Nuevo límite: {calcularNuevoLimite(categoriaSeleccionada)}</span>
                                <span>Nuevo exceso: {calcularNuevoExceso(pesaje.peso_bruto_kg, categoriaSeleccionada)}</span>
                                <span className={`nueva-severidad ${calcularNuevaSeveridad(pesaje, categoriaSeleccionada).toLowerCase()}`}>
                                    {calcularNuevaSeveridad(pesaje, categoriaSeleccionada)}
                                </span>
                            </div>
                        </div>
                    )}
                </div>
                
                <div className="modal-acciones">
                    <button className="btn-cancel" onClick={onClose}>
                        Cancelar
                    </button>
                    <button 
                        className="btn-confirm" 
                        onClick={() => onConfirm(categoriaSeleccionada, justificacion)}
                        disabled={!categoriaSeleccionada || !justificacion}
                    >
                        Aplicar Clasificación Manual
                    </button>
                </div>
            </div>
        </div>
    );
};
```

---

## 🔍 Validaciones y Reglas de Negocio

### **Validaciones de Clasificación BASCAM**
```javascript
const validarClasificacionBASCAM = (codigoBascam) => {
    const codigosValidos = [
        'C2', 'C3', 'C4-2', '2S1', '2S2', '2S3', 
        '3S1', '3S2', '3S3', '2R2', '3R2', '3R3', '3B1'
    ];
    
    return {
        valido: codigosValidos.includes(codigoBascam),
        mensaje: codigosValidos.includes(codigoBascam) 
            ? null 
            : `Código BASCAM '${codigoBascam}' no existe en tabla maestra`
    };
};

const calcularSeveridadSobrepeso = (pesoKg, limiteKg) => {
    if (pesoKg <= limiteKg) return 'NORMAL';
    
    const excesoKg = pesoKg - limiteKg;
    const porcentajeExceso = (excesoKg / (limiteKg * 0.9)) * 100; // Base sin tolerancia
    
    if (porcentajeExceso <= 10) return 'LEVE';
    if (porcentajeExceso <= 20) return 'MODERADO';
    return 'GRAVE';
};

const determinarAccionesPorSeveridad = (severidad, esVehiculoOficial) => {
    if (esVehiculoOficial) {
        return {
            retener_vehiculo: false,
            generar_comparendo: false,
            llamar_policia: false,
            imprimir_tiquete_especial: true,
            observacion: 'Vehículo oficial exento'
        };
    }
    
    switch (severidad) {
        case 'LEVE':
            return {
                retener_vehiculo: false,
                generar_comparendo: true,
                llamar_policia: false,
                imprimir_tiquete_especial: true
            };
        case 'MODERADO':
            return {
                retener_vehiculo: true,
                generar_comparendo: true,
                llamar_policia: true,
                imprimir_tiquete_especial: true
            };
        case 'GRAVE':
            return {
                retener_vehiculo: true,
                generar_comparendo: true,
                llamar_policia: true,
                imprimir_tiquete_especial: true,
                requiere_autorizacion_especial: true
            };
        default:
            return {
                retener_vehiculo: false,
                generar_comparendo: false,
                llamar_policia: false,
                imprimir_tiquete_especial: false
            };
    }
};
```

---

## 📋 Definición de Terminado (DoD)

### **Validaciones Técnicas**
- ✅ Integración WebService BASCAM funcionando al 100%
- ✅ Clasificación automática mapea todos los códigos BASCAM
- ✅ Detección de sobrepeso precisa según normatividad
- ✅ Modo offline funcional con sincronización automática
- ✅ Tests de integración pasando >95%
- ✅ Performance <1 segundo para evaluación de sobrepeso

### **Validaciones de Negocio**
- ✅ Alertas correctas según severidad de sobrepeso
- ✅ Vehículos oficiales exentos de alertas
- ✅ Clasificación manual disponible como respaldo
- ✅ Auditoría completa de clasificaciones y cambios
- ✅ Contingencias funcionando sin pérdida de datos

### **Validaciones de Usuario**
- ✅ Dashboard en tiempo real mostrando estado BASCAM
- ✅ Alertas visuales claras según severidad
- ✅ Clasificación manual intuitiva con justificación
- ✅ Información completa del proceso de pesaje
- ✅ Respaldo offline transparente al usuario

### **Validaciones de Datos**
- ✅ Integridad de datos entre WebService y BD local
- ✅ Sincronización automática sin duplicados
- ✅ Evidencia fotográfica preservada
- ✅ Trazabilidad completa de clasificaciones manuales

---

## 🚀 Estrategia de Implementación

### **Fase 1: Integración Base (3 días)**
- Configurar comunicación con WebService BASCAM
- Implementar tabla categoria_vehiculo con datos normativos
- APIs básicas de estado y consulta

### **Fase 2: Clasificación Automática (4 días)**
- Algoritmo de mapeo código_bascam → categoría
- Cálculo de sobrepeso y severidad
- Generación automática de alertas

### **Fase 3: Contingencias y Respaldo (3 días)**
- Modo offline con clasificación manual
- Sincronización automática
- Validaciones y testing

### **Fase 4: UI y Dashboard (3 días)**
- Dashboard tiempo real
- Modal de clasificación manual
- Sistema de alertas visuales

---

**Esta HU-COMP-003 es el corazón del sistema comparendos, implementando la funcionalidad central que diferencia este sistema de cualquier otro: la clasificación automática BASCAM integrada con detección de sobrepeso en tiempo real, cumpliendo con la normatividad vigente y proporcionando las bases para la generación de comparendos.**)
                .expect(201);
                
            expect(response.body.data.categoria_aplicada.codigo_bascam).toBe('2S2');
            expect(response.body.data.categoria_aplicada.limite_kg).toBe(29725);
        });
        
        test('Rechazo de código BASCAM inexistente', async () => {
            const pesajeData = {
                placa: 'TEST456',
                peso_bruto_kg: 25000,
                codigo_bascam: 'INEXISTENTE',
                id_estacion: 1
            };
            
            await request(app)
                .post('/api/eventos-pesaje')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send(pesajeData)
                .expect(400);
        });
        
        test('Clasificación manual override', async () => {
            const overrideData = {
                id_registro: 12345,
                codigo_bascam_manual: '2S3',
                justificacion: 'Error de sensores - vehículo modificado'
            };
            
            const response = await request(app)
                .post('/api/bascam/clasificar-manual')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send(overrideData)
                .expect(200);
                
            expect(response.body.data.clasificacion_usada).toBe('MANUAL');
            expect(response.body.data.codigo_bascam).toBe('2S3');
        });
    });
    
    describe('Detección de Sobrepeso', () => {
        test('Detección correcta de sobrepeso leve', async () => {
            const pesajeData = {
                placa: 'SOB001',
                peso_bruto_kg: 30000, // 2S2 límite 29725
                codigo_bascam: '2S2',
                id_estacion: 1
            };
            
            const response = await request(app)
                .post('/api/eventos-pesaje')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send(pesajeData)
                .expect(201);
                
            expect(response.body.data.evaluacion_peso.tiene_sobrepeso).toBe(true);
            expect(response.body.data.evaluacion_peso.severidad).toBe('LEVE');
            expect(response.body.data.evaluacion_peso.exceso_kg).toBe(275);
        });
        
        test('Detección correcta de peso normal', async () => {
            const pesajeData = {
                placa: 'NOR001',
                peso_bruto_kg: 28000, // Dentro del límite
                codigo_bascam: '2S2',
                id_estacion: 1
            };
            
            const response = await request(app)
                .post('/api/eventos-pesaje')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send(pesajeData)
                .expect(201);
                
            expect(response.body.data.evaluacion_peso.tiene_sobrepeso).toBe(false);
            expect(response.body.data.evaluacion_peso.severidad).toBe('NORMAL');
            expect(response.body.data.evaluacion_peso.exceso_kg).toBe(0);
        });
        
        test('Cálculo correcto de severidad grave', async () => {
            const pesajeData = {
                placa: 'GRA001',
                peso_bruto_kg: 36000, // Más del 20% de exceso
                codigo_bascam: '2S2',
                id_estacion: 1
            };
            
            const response = await request(app)
                .post('/api/eventos-pesaje')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send(pesajeData)
                .expect(201);
                
            expect(response.body.data.evaluacion_peso.severidad).toBe('GRAVE');
            expect(parseFloat(response.body.data.evaluacion_peso.porcentaje_exceso)).toBeGreaterThan(20);
        });
    });
    
    describe('Gestión de Alertas', () => {
        test('Generación automática de alerta por sobrepeso', async () => {
            const pesajeData = {
                placa: 'ALR001',
                peso_bruto_kg: 32000,
                codigo_bascam: '2S2',
                id_estacion: 1
            };
            
            const response = await request(app)
                .post('/api/eventos-pesaje')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send(pesajeData)
                .expect(201);
                
            // Verificar que se creó la alerta
            const alertas = await db.query(
                'SELECT * FROM alertas_sobrepeso WHERE evento_pesaje_id = ?',
                [response.body.data.evento_id]
            );
            
            expect(alertas.length).toBe(1);
            expect(alertas[0].severidad).toBe('LEVE');
        });
        
        test('No generar alerta para vehículo oficial', async () => {
            // Primero marcar vehículo como oficial
            await db.query(
                'UPDATE vehiculos SET es_oficial = true WHERE placa = ?',
                ['OFI001']
            );
            
            const pesajeData = {
                placa: 'OFI001',
                peso_bruto_kg: 35000, // Sobrepeso pero oficial
                codigo_bascam: '2S2',
                id_estacion: 1
            };
            
            const response = await request(app)
                .post('/api/eventos-pesaje')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send(pesajeData
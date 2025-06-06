# HU-COMP-004 – Registro de Eventos de Pesaje

## 📋 Información General
- **ID**: HU-COMP-004
- **Título**: Registro de Eventos de Pesaje y Gestión de Flujo Vehicular
- **Origen**: HU-VH-003 (Conteo de pasos) - Evolución conceptual 70%
- **Prioridad**: CRÍTICA (Operación diaria del sistema)
- **Fase**: 1 - Fundamentos
- **Dependencias**: HU-COMP-001 (Auth), HU-COMP-002 (Vehículos), HU-COMP-003 (BASCAM)

---

## 🎯 Descripción
Como **operador de báscula** del sistema comparendos,
quiero registrar sistemáticamente todos los eventos de pesaje que ocurren en mi estación,
para mantener un control completo del flujo vehicular, generar tiquetes de pesaje, capturar evidencia digital cuando se detecten sobrepesos, y proporcionar la base de datos necesaria para la generación posterior de comparendos y reportes normativos.

---

## 🔄 Contexto de Evolución del Sistema Original

### **Transformación Conceptual**
| Concepto Original (Pasos) | Concepto Nuevo (Eventos Pesaje) | Evolución |
|---------------------------|----------------------------------|-----------|
| Conteo de pasos por peaje | Registro de pesajes por estación | ✅ De cantidad a peso |
| Beneficio tarifario | Control normativo | ✅ De comercial a regulatorio |
| Límite mensual (70 pasos) | Sin límites (flujo continuo) | ✅ De cíclico a permanente |
| Conteo acumulativo | Evento individual evaluado | ✅ De suma a análisis |

### **Reutilización Estratégica**
| Funcionalidad Original | Adaptación para Comparendos | Reutilización |
|------------------------|----------------------------|---------------|
| **APIs de consulta** | Mantener estructura base | 🟢 **90%** |
| **Filtros por peaje** | Filtros por estación | 🟢 **95%** |
| **Carga masiva Excel** | Carga de pesajes manuales | 🟢 **85%** |
| **Validaciones de datos** | Validaciones de peso/clasificación | 🟡 **60%** |
| **Sistema de auditoría** | Auditoría de eventos | 🟢 **100%** |

---

## 👥 Actores y Responsabilidades

| Actor | Función Principal | Eventos de Pesaje |
|-------|------------------|------------------|
| **OPERADOR_BASCULA** | Registrar y supervisar pesajes | CRUD completo en su estación |
| **COORDINADOR_ITS** | Supervisar y validar datos | Consultar todas las estaciones, correcciones |
| **AUDITOR** | Revisar y exportar datos | Solo consulta y exportación |
| **ADMIN** | Gestión completa del sistema | Acceso total, configuraciones |
| **INGENIERO_RESIDENTE** | Autorizar excepciones | Anular eventos, autorizar correcciones |

---

## 🔄 Flujo Funcional

### **1. Registro Automático desde BASCAM**
```javascript
// Flujo normal: Datos llegan automáticamente del WebService
const procesarEventoAutomatico = async (datosBascam) => {
    // 1. Validar datos del WebService
    const validacion = validarDatosBascam(datosBascam);
    if (!validacion.valida) {
        throw new Error(`Datos BASCAM inválidos: ${validacion.errores}`);
    }
    
    // 2. Clasificar automáticamente (usando HU-COMP-003)
    const clasificacion = await clasificarAutomaticamente(datosBascam.codigo_bascam);
    
    // 3. Evaluar sobrepeso
    const evaluacion = evaluarSobrepeso(
        datosBascam.peso_bruto_kg, 
        clasificacion.peso_total_permitido_kg
    );
    
    // 4. Crear evento de pesaje
    const evento = await crearEventoPesaje({
        ...datosBascam,
        clasificacion,
        evaluacion,
        modo_registro: 'AUTOMATICO'
    });
    
    // 5. Generar tiquete
    const tiquete = await generarTiquetePesaje(evento);
    
    // 6. Si hay sobrepeso, activar alertas
    if (evaluacion.tiene_sobrepeso) {
        await activarAlertaSobrepeso(evento);
    }
    
    return evento;
};
```

### **2. Registro Manual (Contingencia)**
```javascript
// Flujo contingencia: Operador registra manualmente
const procesarEventoManual = async (datosOperador, operadorId) => {
    // 1. Validar permisos de estación
    const operador = await validarOperadorEstacion(operadorId, datosOperador.id_estacion);
    
    // 2. Validar datos obligatorios
    const validacion = validarDatosManual(datosOperador);
    if (!validacion.valida) {
        throw new Error(`Datos incompletos: ${validacion.errores}`);
    }
    
    // 3. Clasificar según código BASCAM proporcionado
    const clasificacion = await obtenerClasificacionBascam(datosOperador.codigo_bascam);
    
    // 4. Evaluar sobrepeso
    const evaluacion = evaluarSobrepeso(
        datosOperador.peso_bruto_kg,
        clasificacion.peso_total_permitido_kg
    );
    
    // 5. Crear evento con flag manual
    const evento = await crearEventoPesaje({
        ...datosOperador,
        clasificacion,
        evaluacion,
        modo_registro: 'MANUAL',
        registrado_por: operadorId,
        requiere_validacion: true
    });
    
    return evento;
};
```

### **3. Consulta y Filtrado de Eventos**
```javascript
// Consulta optimizada con filtros múltiples
const consultarEventos = async (filtros, usuario) => {
    let query = `
        SELECT * FROM v_eventos_pesaje_completo 
        WHERE 1=1
    `;
    const params = [];
    
    // Filtro por estación (obligatorio para operadores)
    if (usuario.rol === 'OPERADOR_BASCULA') {
        query += ` AND id_estacion = ?`;
        params.push(usuario.estacion_asignada);
    } else if (filtros.id_estacion) {
        query += ` AND id_estacion = ?`;
        params.push(filtros.id_estacion);
    }
    
    // Filtros de fecha (máximo 30 días para operadores)
    if (filtros.fecha_desde) {
        query += ` AND fecha_pesaje >= ?`;
        params.push(filtros.fecha_desde);
    }
    if (filtros.fecha_hasta) {
        query += ` AND fecha_pesaje <= ?`;
        params.push(filtros.fecha_hasta);
    }
    
    // Validar rango máximo para operadores
    if (usuario.rol === 'OPERADOR_BASCULA') {
        const rangoMaximo = 30; // días
        validarRangoFecha(filtros.fecha_desde, filtros.fecha_hasta, rangoMaximo);
    }
    
    // Filtros específicos
    if (filtros.placa) {
        query += ` AND placa ILIKE ?`;
        params.push(`%${filtros.placa}%`);
    }
    if (filtros.tiene_sobrepeso !== undefined) {
        query += ` AND tiene_sobrepeso = ?`;
        params.push(filtros.tiene_sobrepeso);
    }
    if (filtros.severidad) {
        query += ` AND severidad = ?`;
        params.push(filtros.severidad);
    }
    
    // Ordenamiento y paginación
    query += ` ORDER BY fecha_pesaje DESC LIMIT ? OFFSET ?`;
    params.push(filtros.limit || 50, (filtros.page - 1) * (filtros.limit || 50));
    
    return await db.query(query, params);
};
```

---

## ✅ Criterios de Aceptación

### **CA-004-01: Registro de Eventos**
- ✅ Evento DEBE registrarse automáticamente desde WebService BASCAM
- ✅ Registro manual DEBE estar disponible cuando WebService falle
- ✅ Todos los campos obligatorios DEBEN validarse antes de guardar
- ✅ Tiquete único DEBE generarse por cada evento de pesaje
- ✅ Evidencia fotográfica DEBE capturarse para sobrepesos

### **CA-004-02: Control por Estación**
- ✅ OPERADOR_BASCULA solo puede registrar eventos en su estación asignada
- ✅ Intento de registro en otra estación DEBE retornar error 403
- ✅ Consultas DEBEN filtrar automáticamente por estación del operador
- ✅ Coordinadores pueden ver eventos de todas las estaciones

### **CA-004-03: Validaciones de Negocio**
- ✅ Peso bruto DEBE ser mayor a 0 y menor a 100,000 kg
- ✅ Código BASCAM DEBE existir en tabla categoria_vehiculo
- ✅ Placa DEBE tener formato colombiano válido
- ✅ Fecha de pesaje NO puede ser futura ni anterior a 7 días
- ✅ Duplicados en misma estación/hora DEBEN ser detectados y alertados

### **CA-004-04: Performance y Volumen**
- ✅ Consulta de eventos DEBE responder en <2 segundos
- ✅ Registro de evento DEBE completarse en <1 segundo
- ✅ Sistema DEBE soportar 150+ eventos por hora por estación
- ✅ Filtros de fecha DEBEN estar limitados a máximo 30 días para operadores
- ✅ Exportación DEBE manejar hasta 10,000 registros sin timeout

### **CA-004-05: Auditoría y Trazabilidad**
- ✅ TODOS los eventos DEBEN quedar registrados en auditoría
- ✅ Modificaciones DEBEN requerir justificación obligatoria
- ✅ Eliminación física DEBE estar prohibida (solo anulación lógica)
- ✅ Usuario que registra DEBE quedar identificado en cada evento
- ✅ Cambios manuales DEBEN generar flag de validación pendiente

---

## 🔧 APIs Principales

### **CRUD de Eventos de Pesaje**
```javascript
// Listar eventos con filtros (REUTILIZAR de pasos con adaptaciones)
GET /api/eventos-pesaje?page=1&limit=50&fecha_desde=2025-06-01&fecha_hasta=2025-06-05&id_estacion=1&tiene_sobrepeso=true&severidad=LEVE
Authorization: Bearer {token}

Response 200:
{
    "success": true,
    "data": {
        "eventos": [
            {
                "id": 567,
                "placa": "ABC123",
                "fecha_pesaje": "2025-06-05T10:30:00Z",
                "peso_bruto_kg": 31500,
                "codigo_bascam": "2S2",
                "categoria_vehiculo": {
                    "id": 5,
                    "codigo_bascam": "2S2",
                    "descripcion": "Tracto 2 + Semirrem 2",
                    "peso_total_permitido_kg": 29725
                },
                "evaluacion_peso": {
                    "limite_aplicado_kg": 29725,
                    "exceso_kg": 1775,
                    "tiene_sobrepeso": true,
                    "severidad": "LEVE",
                    "porcentaje_exceso": "6.12"
                },
                "estacion": {
                    "id": 1,
                    "nombre": "Neiva Norte",
                    "direccion_flujo": "NORTE"
                },
                "tiquete_numero": "NEI-001-2025-000567",
                "estado_evento": "COMPLETADO",
                "modo_registro": "AUTOMATICO",
                "operador": {
                    "id": 2,
                    "nombre": "Juan Pérez"
                },
                "evidencias": [
                    {
                        "tipo": "FOTO_VEHICULO",
                        "archivo_path": "/evidencias/2025/06/05/ABC123_103000.jpg"
                    }
                ],
                "created_at": "2025-06-05T10:30:18Z"
            }
        ],
        "pagination": {
            "page": 1,
            "limit": 50,
            "total": 1247,
            "total_pages": 25
        },
        "resumen": {
            "total_eventos": 1247,
            "eventos_sobrepeso": 98,
            "porcentaje_sobrepeso": 7.87,
            "peso_promedio_kg": 28500
        }
    }
}

// Obtener evento específico
GET /api/eventos-pesaje/:id
Authorization: Bearer {token}

// Crear evento manual (Contingencia)
POST /api/eventos-pesaje
Authorization: Bearer {operador_token}
Content-Type: application/json
{
    "placa": "DEF456",
    "peso_bruto_kg": 32000,
    "codigo_bascam": "2S2",
    "id_estacion": 1,
    "id_bascula": 1,
    "observaciones": "Registro manual - WebService BASCAM temporalmente fuera de servicio",
    "modo_registro": "MANUAL"
}

Response 201:
{
    "success": true,
    "data": {
        "evento_id": 568,
        "placa": "DEF456",
        "tiquete_numero": "NEI-001-2025-000568",
        "evaluacion_peso": {
            "tiene_sobrepeso": true,
            "severidad": "LEVE",
            "exceso_kg": 2275
        },
        "acciones_requeridas": {
            "retener_vehiculo": false,
            "generar_comparendo": true,
            "imprimir_tiquete_especial": true
        },
        "requiere_validacion": true,
        "mensaje": "Evento registrado manualmente - pendiente validación coordinador"
    }
}

// Actualizar evento (solo correcciones menores)
PUT /api/eventos-pesaje/:id
Authorization: Bearer {coordinador_token}
Content-Type: application/json
{
    "observaciones": "Corrección: Vehículo transportaba carga médica de emergencia",
    "justificacion_cambio": "Clasificado como vehículo oficial por emergencia médica"
}

// Anular evento (solo INGENIERO_RESIDENTE)
PUT /api/eventos-pesaje/:id/anular
Authorization: Bearer {ingeniero_token}
Content-Type: application/json
{
    "motivo_anulacion": "Error de báscula detectado - calibración incorrecta",
    "autorizado_por": "Ingeniero Residente"
}
```

### **Carga Masiva (Contingencia)**
```javascript
// Carga masiva desde Excel (ADAPTAR de sistema original)
POST /api/eventos-pesaje/carga-excel
Authorization: Bearer {coordinador_token}
Content-Type: multipart/form-data
File: eventos_pesaje_contingencia.xlsx

Response 200:
{
    "success": true,
    "data": {
        "procesados": 156,
        "exitosos": 152,
        "fallidos": 4,
        "eventos_sobrepeso": 12,
        "errores": [
            {
                "fila": 15,
                "placa": "XYZ999",
                "error": "Código BASCAM 'INVALID' no existe"
            },
            {
                "fila": 23,
                "peso_bruto_kg": 150000,
                "error": "Peso fuera del rango válido (0-100000 kg)"
            }
        ],
        "advertencias": [
            {
                "fila": 8,
                "placa": "ABC123",
                "advertencia": "Evento registrado con sobrepeso - verificar clasificación"
            }
        ]
    }
}

// Plantilla Excel para carga masiva
GET /api/eventos-pesaje/plantilla-excel
Authorization: Bearer {coordinador_token}
Response: Descarga archivo eventos_pesaje_plantilla.xlsx

// Validar Excel antes de carga
POST /api/eventos-pesaje/validar-excel
Authorization: Bearer {coordinador_token}
Content-Type: multipart/form-data
File: eventos_pesaje_validar.xlsx

Response 200:
{
    "success": true,
    "data": {
        "total_filas": 156,
        "filas_validas": 152,
        "filas_error": 4,
        "estimado_sobrepesos": 12,
        "advertencias": ["Algunos eventos tienen sobrepeso > 10%"],
        "puede_procesar": true
    }
}
```

### **Estadísticas y Reportes**
```javascript
// Estadísticas del día por estación
GET /api/eventos-pesaje/estadisticas?fecha=2025-06-05&id_estacion=1
Authorization: Bearer {operador_token}

Response 200:
{
    "success": true,
    "data": {
        "fecha": "2025-06-05",
        "estacion": {
            "id": 1,
            "nombre": "Neiva Norte"
        },
        "resumen_dia": {
            "total_eventos": 156,
            "eventos_normales": 144,
            "eventos_sobrepeso": 12,
            "porcentaje_sobrepeso": 7.69,
            "peso_promedio_kg": 28500,
            "peso_maximo_kg": 52000,
            "hora_pico": "14:00-15:00"
        },
        "por_categoria": {
            "C2": { "count": 45, "sobrepesos": 2 },
            "C3": { "count": 38, "sobrepesos": 3 },
            "2S2": { "count": 35, "sobrepesos": 4 },
            "2S3": { "count": 28, "sobrepesos": 2 },
            "3S3": { "count": 10, "sobrepesos": 1 }
        },
        "por_severidad": {
            "NORMAL": 144,
            "LEVE": 8,
            "MODERADO": 3,
            "GRAVE": 1
        },
        "flujo_horario": [
            { "hora": "06:00", "eventos": 12, "sobrepesos": 1 },
            { "hora": "07:00", "eventos": 15, "sobrepesos": 0 },
            // ... datos por hora
        ]
    }
}

// Exportar eventos con filtros
POST /api/eventos-pesaje/exportar
Authorization: Bearer {auditor_token}
Content-Type: application/json
{
    "formato": "excel", // excel, csv, pdf
    "filtros": {
        "fecha_desde": "2025-06-01",
        "fecha_hasta": "2025-06-05",
        "id_estacion": 1,
        "tiene_sobrepeso": true
    },
    "incluir_evidencias": false,
    "incluir_detalles_categoria": true
}

Response 200:
{
    "success": true,
    "data": {
        "archivo_url": "/exports/eventos_pesaje_20250605.xlsx",
        "total_registros": 98,
        "tamano_archivo": "2.5 MB",
        "expires_at": "2025-06-06T10:30:00Z"
    }
}
```

### **Gestión de Turnos**
```javascript
// Iniciar turno de operador
POST /api/turnos/iniciar
Authorization: Bearer {operador_token}
Content-Type: application/json
{
    "id_estacion": 1,
    "hora_inicio": "06:00"
}

// Cerrar turno con resumen
POST /api/turnos/cerrar
Authorization: Bearer {operador_token}
Content-Type: application/json
{
    "observaciones": "Turno normal, 1 evento de sobrepeso grave requirió retención",
    "archivo_respaldo_excel": "/respaldos/turno_neiva_norte_20250605.xlsx"
}

Response 200:
{
    "success": true,
    "data": {
        "turno_id": 456,
        "resumen": {
            "duracion_horas": 8,
            "total_pesajes": 156,
            "total_sobrepesos": 12,
            "efficiency_rate": 19.5, // pesajes por hora
            "incidentes": 1
        }
    }
}
```

---

## 🗄️ Estructura de Base de Datos

### **Tabla eventos_pesaje (Ya definida en HU-003, expandir si necesario)**
```sql
-- Añadir campos adicionales si son necesarios
ALTER TABLE eventos_pesaje ADD COLUMN turno_id INTEGER;
ALTER TABLE eventos_pesaje ADD COLUMN validado_por_id INTEGER;
ALTER TABLE eventos_pesaje ADD COLUMN fecha_validacion TIMESTAMP;
ALTER TABLE eventos_pesaje ADD COLUMN requiere_validacion BOOLEAN DEFAULT false;

-- Foreign Keys adicionales
ALTER TABLE eventos_pesaje ADD FOREIGN KEY (turno_id) REFERENCES turnos(id);
ALTER TABLE eventos_pesaje ADD FOREIGN KEY (validado_por_id) REFERENCES usuarios(id);

-- Indices adicionales para performance
CREATE INDEX idx_eventos_turno ON eventos_pesaje(turno_id);
CREATE INDEX idx_eventos_validacion ON eventos_pesaje(requiere_validacion, fecha_pesaje);
CREATE INDEX idx_eventos_modo_registro ON eventos_pesaje(modo_registro);
```

### **Tabla turnos (Ya definida en contexto, expandir)**
```sql
-- Expandir tabla turnos si es necesario
ALTER TABLE turnos ADD COLUMN eventos_registrados INTEGER DEFAULT 0;
ALTER TABLE turnos ADD COLUMN eventos_validados INTEGER DEFAULT 0;
ALTER TABLE turnos ADD COLUMN eventos_pendientes INTEGER DEFAULT 0;
ALTER TABLE turnos ADD COLUMN incidentes_reportados INTEGER DEFAULT 0;

-- Trigger para actualizar estadísticas de turno
CREATE OR REPLACE FUNCTION actualizar_estadisticas_turno()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE turnos 
        SET eventos_registrados = eventos_registrados + 1,
            total_pesajes = total_pesajes + 1,
            total_sobrepesos = total_sobrepesos + CASE WHEN NEW.tiene_sobrepeso THEN 1 ELSE 0 END
        WHERE id = NEW.turno_id;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_eventos_pesaje_stats
    AFTER INSERT ON eventos_pesaje
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_estadisticas_turno();
```

### **Tabla duplicados_detectados (Nueva - Control de calidad)**
```sql
CREATE TABLE duplicados_detectados (
    id SERIAL PRIMARY KEY,
    evento_original_id INTEGER NOT NULL,
    evento_duplicado_id INTEGER NOT NULL,
    criterio_deteccion VARCHAR(50) NOT NULL, -- 'PLACA_HORA', 'PESO_EXACTO', 'MANUAL'
    fecha_deteccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resuelto BOOLEAN DEFAULT false,
    accion_tomada VARCHAR(50), -- 'MANTENER_ORIGINAL', 'MANTENER_DUPLICADO', 'FUSIONAR'
    resuelto_por_id INTEGER,
    observaciones TEXT,
    
    FOREIGN KEY (evento_original_id) REFERENCES eventos_pesaje(id),
    FOREIGN KEY (evento_duplicado_id) REFERENCES eventos_pesaje(id),
    FOREIGN KEY (resuelto_por_id) REFERENCES usuarios(id),
    
    INDEX idx_duplicados_resuelto (resuelto),
    INDEX idx_duplicados_fecha (fecha_deteccion)
);
```

### **Vista para Dashboard Operativo**
```sql
CREATE VIEW v_dashboard_eventos_estacion AS
SELECT 
    ec.id_estacion,
    ec.nombre_estacion,
    DATE(ep.fecha_pesaje) as fecha,
    COUNT(*) as total_eventos,
    COUNT(CASE WHEN ep.tiene_sobrepeso THEN 1 END) as eventos_sobrepeso,
    ROUND(
        (COUNT(CASE WHEN ep.tiene_sobrepeso THEN 1 END) * 100.0 / COUNT(*)), 2
    ) as porcentaje_sobrepeso,
    AVG(ep.peso_bruto_kg) as peso_promedio,
    MAX(ep.peso_bruto_kg) as peso_maximo,
    COUNT(CASE WHEN ep.severidad = 'GRAVE' THEN 1 END) as sobrepesos_graves,
    COUNT(CASE WHEN ep.modo_registro = 'MANUAL' THEN 1 END) as eventos_manuales,
    COUNT(CASE WHEN ep.requiere_validacion THEN 1 END) as pendientes_validacion
FROM eventos_pesaje ep
JOIN estaciones_control ec ON ep.id_estacion = ec.id_estacion
WHERE ep.estado_evento = 'COMPLETADO'
GROUP BY ec.id_estacion, ec.nombre_estacion, DATE(ep.fecha_pesaje)
ORDER BY fecha DESC, ec.id_estacion;
```

---

## 🧪 Plan de Pruebas

### **Pruebas de Registro de Eventos**
```javascript
describe('HU-COMP-004: Registro de Eventos de Pesaje', () => {
    
    describe('Registro automático desde BASCAM', () => {
        test('Crear evento automático con datos válidos', async () => {
            const eventoBascam = {
                id_registro_bascam: 12345,
                placa: 'AUTO123',
                peso_bruto_kg: 28500,
                codigo_bascam: '2S2',
                id_estacion: 1,
                id_bascula: 1,
                fecha_pesaje: '2025-06-05T10:30:00Z'
            };
            
            const response = await request(app)
                .post('/api/eventos-pesaje')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send(eventoBascam)
                .expect(201);
                
            expect(response.body.data.evento_id).toBeDefined();
            expect(response.body.data.tiquete_numero).toMatch(/NEI-001-2025-\d{6}/);
            expect(response.body.data.evaluacion_peso.tiene_sobrepeso).toBe(false);
        });
        
        test('Detectar sobrepeso automáticamente', async () => {
            const eventoSobrepeso = {
                placa: 'SOB123',
                peso_bruto_kg: 31500, // Excede límite 2S2 (29725)
                codigo_bascam: '2S2',
                id_estacion: 1
            };
            
            const response = await request(app)
                .post('/api/eventos-pesaje')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send(eventoSobrepeso)
                .expect(201);
                
            expect(response.body.data.evaluacion_peso.tiene_sobrepeso).toBe(true);
            expect(response.body.data.evaluacion_peso.severidad).toBe('LEVE');
            expect(response.body.data.evaluacion_peso.exceso_kg).toBe(1775);
        });
        
        test('Rechazar evento con código BASCAM inválido', async () => {
            const eventoInvalido = {
                placa: 'INV123',
                peso_bruto_kg: 25000,
                codigo_bascam: 'INVALID',
                id_estacion: 1
            };
            
            await request(app)
                .post('/api/eventos-pesaje')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send(eventoInvalido)
                .expect(400);
        });
    });
    
    describe('Control por estación', () => {
        test('Operador solo puede registrar en su estación', async () => {
            const tokenOperadorEstacion1 = await loginAsOperador(1);
            
            const eventoOtraEstacion = {
                placa: 'EST123',
                peso_bruto_kg: 25000,
                codigo_bascam: 'C2',
                id_estacion: 2 // Estación diferente
            };
            
            await request(app)
                .post('/api/eventos-pesaje')
                .set('Authorization', `Bearer ${tokenOperadorEstacion1}`)
                .send(eventoOtraEstacion)
                .expect(403);
        });
        
        test('Coordinador puede registrar en cualquier estación', async () => {
            const eventoCoordinador = {
                placa: 'COORD123',
                peso_bruto_kg: 25000,
                codigo_bascam: 'C2',
                id_estacion: 3,
                modo_registro: 'MANUAL'
            };
            
            const response = await request(app)
                .post('/api/eventos-pesaje')
                .set('Authorization', `Bearer ${coordinadorToken}`)
                .send(eventoCoordinador)
                .expect(201);
                
            expect(response.body.data.evento_id).toBeDefined();
        });
    });
    
    describe('Consultas y filtros', () => {
        test('Filtrar eventos por fecha y estación', async () => {
            const response = await request(app)
                .get('/api/eventos-pesaje?fecha_desde=2025-06-01&fecha_hasta=2025-06-05&id_estacion=1')
                .set('Authorization', `Bearer ${operadorToken}`)
                .expect(200);
                
            expect(response.body.data.eventos).toBeInstanceOf(Array);
            response.body.data.eventos.forEach(evento => {
                expect(evento.estacion.id).toBe(1);
                expect(new Date(evento.fecha_pesaje)).toBeGreaterThanOrEqual(new Date('2025-06-01'));
                expect(new Date(evento.fecha_pesaje)).toBeLessThanOrEqual(new Date('2025-06-05'));
            });
        });
        
        test('Filtrar solo eventos con sobrepeso', async () => {
            const response = await request(app)
                .get('/api/eventos-pesaje?tiene_sobrepeso=true&severidad=GRAVE')
                .set('Authorization', `Bearer ${coordinadorToken}`)
                .expect(200);
                
            response.body.data.eventos.forEach(evento => {
                expect(evento.evaluacion_peso.tiene_sobrepeso).toBe(true);
                expect(evento.evaluacion_peso.severidad).toBe('GRAVE');
            });
        });
        
        test('Búsqueda por placa específica', async () => {
            const response = await request(app)
                .get('/api/eventos-pesaje?placa=ABC123')
                .set('Authorization', `Bearer ${operadorToken}`)
                .expect(200);
                
            response.body.data.eventos.forEach(evento => {
                expect(evento.placa).toContain('ABC123');
            });
        });
        
        test('Operador limitado a máximo 30 días de consulta', async () => {
            const fechaAntigua = new Date();
            fechaAntigua.setDate(fechaAntigua.getDate() - 35);
            
            await request(app)
                .get(`/api/eventos-pesaje?fecha_desde=${fechaAntigua.toISOString().split('T')[0]}`)
                .set('Authorization', `Bearer ${operadorToken}`)
                .expect(400);
        });
    });
    
    describe('Carga masiva Excel', () => {
        test('Carga exitosa de eventos desde Excel', async () => {
            const excelBuffer = await generarExcelEventos([
                {
                    placa: 'MASS001',
                    peso_bruto_kg: 28000,
                    codigo_bascam: 'C2',
                    fecha_pesaje: '2025-06-05 10:30:00',
                    id_estacion: 1
                },
                {
                    placa: 'MASS002',
                    peso_bruto_kg: 31000,
                    codigo_bascam: '2S2',
                    fecha_pesaje: '2025-06-05 10:35:00',
                    id_estacion: 1
                }
            ]);
            
            const response = await request(app)
                .post('/api/eventos-pesaje/carga-excel')
                .set('Authorization', `Bearer ${coordinadorToken}`)
                .attach('file', excelBuffer, 'eventos_test.xlsx')
                .expect(200);
                
            expect(response.body.data.exitosos).toBe(2);
            expect(response.body.data.eventos_sobrepeso).toBe(1);
        });
        
        test('Validar Excel antes de procesar', async () => {
            const excelBuffer = await generarExcelEventos([
                {
                    placa: 'INVALID',
                    peso_bruto_kg: 'abc', // Peso inválido
                    codigo_bascam: 'INEXISTENTE',
                    fecha_pesaje: '2025-06-05 10:30:00'
                }
            ]);
            
            const response = await request(app)
                .post('/api/eventos-pesaje/validar-excel')
                .set('Authorization', `Bearer ${coordinadorToken}`)
                .attach('file', excelBuffer, 'eventos_invalidos.xlsx')
                .expect(200);
                
            expect(response.body.data.puede_procesar).toBe(false);
            expect(response.body.data.filas_error).toBeGreaterThan(0);
        });
    });
    
    describe('Gestión de turnos', () => {
        test('Iniciar turno de operador', async () => {
            const response = await request(app)
                .post('/api/turnos/iniciar')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send({
                    id_estacion: 1,
                    hora_inicio: '06:00'
                })
                .expect(201);
                
            expect(response.body.data.turno_id).toBeDefined();
            expect(response.body.data.estado_turno).toBe('ACTIVO');
        });
        
        test('Cerrar turno con estadísticas', async () => {
            // Crear eventos durante el turno
            await crearEventosDeTurno(operadorToken, 1, 10);
            
            const response = await request(app)
                .post('/api/turnos/cerrar')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send({
                    observaciones: 'Turno completado sin incidentes'
                })
                .expect(200);
                
            expect(response.body.data.resumen.total_pesajes).toBe(10);
            expect(response.body.data.resumen.duracion_horas).toBeGreaterThan(0);
        });
    });
    
    describe('Detección de duplicados', () => {
        test('Detectar evento duplicado por placa y hora', async () => {
            const eventoOriginal = {
                placa: 'DUP123',
                peso_bruto_kg: 28000,
                codigo_bascam: 'C2',
                fecha_pesaje: '2025-06-05T10:30:00Z',
                id_estacion: 1
            };
            
            // Crear evento original
            await request(app)
                .post('/api/eventos-pesaje')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send(eventoOriginal)
                .expect(201);
            
            // Intentar crear duplicado
            const response = await request(app)
                .post('/api/eventos-pesaje')
                .set('Authorization', `Bearer ${operadorToken}`)
                .send({
                    ...eventoOriginal,
                    peso_bruto_kg: 28100 // Peso ligeramente diferente
                })
                .expect(409);
                
            expect(response.body.error).toContain('duplicado');
        });
    });
    
    describe('Anulaciones y correcciones', () => {
        test('Ingeniero puede anular evento', async () => {
            const evento = await crearEventoTest('ANUL123', 28000);
            
            const response = await request(app)
                .put(`/api/eventos-pesaje/${evento.id}/anular`)
                .set('Authorization', `Bearer ${ingenieroToken}`)
                .send({
                    motivo_anulacion: 'Error de báscula - peso incorrecto'
                })
                .expect(200);
                
            expect(response.body.data.estado_evento).toBe('ANULADO');
        });
        
        test('Operador no puede anular eventos', async () => {
            const evento = await crearEventoTest('NOANU123', 28000);
            
            await request(app)
                .put(`/api/eventos-pesaje/${evento.id}/anular`)
                .set('Authorization', `Bearer ${operadorToken}`)
                .send({
                    motivo_anulacion: 'Intento no autorizado'
                })
                .expect(403);
        });
        
        test('Coordinador puede corregir observaciones', async () => {
            const evento = await crearEventoTest('CORR123', 28000);
            
            const response = await request(app)
                .put(`/api/eventos-pesaje/${evento.id}`)
                .set('Authorization', `Bearer ${coordinadorToken}`)
                .send({
                    observaciones: 'Corrección: Vehículo transportaba carga especial autorizada',
                    justificacion_cambio: 'Actualización de información posterior al pesaje'
                })
                .expect(200);
                
            expect(response.body.data.observaciones).toContain('carga especial');
        });
    });
});
```

### **Datos de Prueba**
```sql
-- Eventos de prueba para testing
INSERT INTO eventos_pesaje (placa, peso_bruto_kg, codigo_bascam, categoria_id, limite_aplicado_kg, exceso_kg, tiene_sobrepeso, severidad, id_estacion, operador_id, tiquete_numero) VALUES
('TEST001', 16500, 'C2', 1, 17700, 0, false, 'NORMAL', 1, 2, 'NEI-001-2025-000001'),
('TEST002', 30000, '2S2', 5, 29725, 275, true, 'LEVE', 1, 2, 'NEI-001-2025-000002'),
('TEST003', 35000, '2S2', 5, 29725, 5275, true, 'GRAVE', 2, 3, 'NEI-002-2025-000003'),
('TEST004', 50000, '3S3', 9, 53300, 0, false, 'NORMAL', 3, 4, 'FLA-003-2025-000004');
```

---

## 🎨 Interfaz de Usuario

### **Lista de Eventos de Pesaje**
```javascript
const ListaEventosPesaje = () => {
    const [eventos, setEventos] = useState([]);
    const [filtros, setFiltros] = useState({
        fecha_desde: format(new Date(), 'yyyy-MM-dd'),
        fecha_hasta: format(new Date(), 'yyyy-MM-dd'),
        placa: '',
        tiene_sobrepeso: '',
        severidad: '',
        id_estacion: usuario.rol === 'OPERADOR_BASCULA' ? usuario.estacion_asignada : ''
    });
    const [loading, setLoading] = useState(false);
    
    return (
        <div className="eventos-pesaje-container">
            <div className="filtros-section">
                <div className="filtros-row">
                    <div className="filtro-grupo">
                        <label>Desde:</label>
                        <input
                            type="date"
                            value={filtros.fecha_desde}
                            onChange={e => setFiltros({...filtros, fecha_desde: e.target.value})}
                            max={format(new Date(), 'yyyy-MM-dd')}
                        />
                    </div>
                    
                    <div className="filtro-grupo">
                        <label>Hasta:</label>
                        <input
                            type="date"
                            value={filtros.fecha_hasta}
                            onChange={e => setFiltros({...filtros, fecha_hasta: e.target.value})}
                            max={format(new Date(), 'yyyy-MM-dd')}
                        />
                    </div>
                    
                    <div className="filtro-grupo">
                        <label>Placa:</label>
                        <input
                            type="text"
                            placeholder="ABC123"
                            value={filtros.placa}
                            onChange={e => setFiltros({...filtros, placa: e.target.value})}
                        />
                    </div>
                    
                    {usuario.rol !== 'OPERADOR_BASCULA' && (
                        <div className="filtro-grupo">
                            <label>Estación:</label>
                            <select
                                value={filtros.id_estacion}
                                onChange={e => setFiltros({...filtros, id_estacion: e.target.value})}
                            >
                                <option value="">Todas las estaciones</option>
                                {estaciones.map(est => (
                                    <option key={est.id} value={est.id}>
                                        {est.nombre}
                                    </option>
                                ))}
                            </select>
                        </div>
                    )}
                    
                    <div className="filtro-grupo">
                        <label>Sobrepeso:</label>
                        <select
                            value={filtros.tiene_sobrepeso}
                            onChange={e => setFiltros({...filtros, tiene_sobrepeso: e.target.value})}
                        >
                            <option value="">Todos</option>
                            <option value="true">Solo sobrepesos</option>
                            <option value="false">Solo normales</option>
                        </select>
                    </div>
                    
                    <div className="filtro-grupo">
                        <label>Severidad:</label>
                        <select
                            value={filtros.severidad}
                            onChange={e => setFiltros({...filtros, severidad: e.target.value})}
                        >
                            <option value="">Todas</option>
                            <option value="LEVE">Leve</option>
                            <option value="MODERADO">Moderado</option>
                            <option value="GRAVE">Grave</option>
                        </select>
                    </div>
                    
                    <button className="btn-buscar" onClick={buscarEventos} disabled={loading}>
                        {loading ? 'Buscando...' : 'Buscar'}
                    </button>
                    
                    <button className="btn-exportar" onClick={exportarEventos}>
                        Exportar Excel
                    </button>
                </div>
            </div>
            
            <div className="eventos-tabla">
                <table className="table">
                    <thead>
                        <tr>
                            <th>Hora</th>
                            <th>Placa</th>
                            <th>Clasificación</th>
                            <th>Peso (kg)</th>
                            <th>Límite (kg)</th>
                            <th>Exceso (kg)</th>
                            <th>Severidad</th>
                            <th>Tiquete</th>
                            <th>Estación</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        {eventos.map(evento => (
                            <FilaEvento 
                                key={evento.id}
                                evento={evento}
                                onVerDetalle={verDetalleEvento}
                                onCorregir={corregirEvento}
                                onAnular={anularEvento}
                                usuario={usuario}
                            />
                        ))}
                    </tbody>
                </table>
            </div>
            
            <div className="eventos-paginacion">
                <Paginacion
                    current={paginacion.page}
                    total={paginacion.total_pages}
                    onChange={cambiarPagina}
                />
            </div>
            
            <div className="eventos-resumen">
                <div className="resumen-card">
                    <h4>Resumen del Filtro</h4>
                    <div className="resumen-stats">
                        <span>Total eventos: <strong>{resumen.total_eventos}</strong></span>
                        <span>Sobrepesos: <strong>{resumen.eventos_sobrepeso}</strong></span>
                        <span>% Sobrepeso: <strong>{resumen.porcentaje_sobrepeso}%</strong></span>
                        <span>Peso promedio: <strong>{resumen.peso_promedio_kg.toLocaleString()} kg</strong></span>
                    </div>
                </div>
            </div>
        </div>
    );
};
```

### **Fila de Evento Individual**
```javascript
const FilaEvento = ({ evento, onVerDetalle, onCorregir, onAnular, usuario }) => {
    const puedeCorregir = ['ADMIN', 'COORDINADOR_ITS'].includes(usuario.rol);
    const puedeAnular = ['ADMIN', 'INGENIERO_RESIDENTE'].includes(usuario.rol);
    
    return (
        <tr className={`evento-row ${evento.evaluacion_peso.severidad.toLowerCase()}`}>
            <td>{formatHora(evento.fecha_pesaje)}</td>
            <td className="placa">{evento.placa}</td>
            <td>
                <span className="categoria-badge">
                    {evento.codigo_bascam}
                </span>
                <small>{evento.categoria_vehiculo.descripcion}</small>
            </td>
            <td className="peso">{evento.peso_bruto_kg.toLocaleString()}</td>
            <td className="limite">{evento.evaluacion_peso.limite_aplicado_kg.toLocaleString()}</td>
            <td className={`exceso ${evento.evaluacion_peso.tiene_sobrepeso ? 'sobrepeso' : ''}`}>
                {evento.evaluacion_peso.exceso_kg > 0 ? `+${evento.evaluacion_peso.exceso_kg}` : '0'}
            </td>
            <td>
                <span className={`severidad-badge ${evento.evaluacion_peso.severidad.toLowerCase()}`}>
                    {evento.evaluacion_peso.severidad}
                </span>
            </td>
            <td className="tiquete">{evento.tiquete_numero}</td>
            <td>{evento.estacion.nombre}</td>
            <td className="acciones">
                <button 
                    className="btn-detalle" 
                    onClick={() => onVerDetalle(evento.id)}
                    title="Ver detalle completo"
                >
                    👁️
                </button>
                
                {evento.evidencias.length > 0 && (
                    <button 
                        className="btn-evidencias" 
                        onClick={() => verEvidencias(evento.id)}
                        title="Ver evidencias"
                    >
                        📷
                    </button>
                )}
                
                {puedeCorregir && (
                    <button 
                        className="btn-corregir" 
                        onClick={() => onCorregir(evento.id)}
                        title="Corregir evento"
                    >
                        ✏️
                    </button>
                )}
                
                {puedeAnular && evento.estado_evento === 'COMPLETADO' && (
                    <button 
                        className="btn-anular" 
                        onClick={() => onAnular(evento.id)}
                        title="Anular evento"
                    >
                        ❌
                    </button>
                )}
                
                {evento.requiere_validacion && (
                    <span className="flag-validacion" title="Requiere validación">
                        ⚠️
                    </span>
                )}
            </td>
        </tr>
    );
};
```

### **Modal de Registro Manual**
```javascript
const ModalRegistroManual = ({ isOpen, onClose, onSubmit, estacionAsignada }) => {
    const [formData, setFormData] = useState({
        placa: '',
        peso_bruto_kg: '',
        codigo_bascam: '',
        id_estacion: estacionAsignada || '',
        observaciones: '',
        motivo_manual: ''
    });
    const [clasificacionPreview, setClasificacionPreview] = useState(null);
    
    useEffect(() => {
        if (formData.codigo_bascam && formData.peso_bruto_kg) {
            calcularClasificacionPreview();
        }
    }, [formData.codigo_bascam, formData.peso_bruto_kg]);
    
    return (
        <Modal isOpen={isOpen} onClose={onClose} size="large">
            <div className="modal-registro-manual">
                <h3>Registro Manual de Evento de Pesaje</h3>
                
                <div className="alert alert-warning">
                    <strong>Modo Manual:</strong> Use solo cuando WebService BASCAM no esté disponible
                </div>
                
                <form onSubmit={handleSubmit}>
                    <div className="form-grid">
                        <div className="form-group">
                            <label className="required">Placa:</label>
                            <input
                                type="text"
                                placeholder="ABC123"
                                value={formData.placa}
                                onChange={e => setFormData({...formData, placa: e.target.value.toUpperCase()})}
                                pattern="^[A-Z]{3}[0-9]{2,3}[A-Z]?$"
                                required
                            />
                        </div>
                        
                        <div className="form-group">
                            <label className="required">Peso Bruto (kg):</label>
                            <input
                                type="number"
                                min="1000"
                                max="100000"
                                value={formData.peso_bruto_kg}
                                onChange={e => setFormData({...formData, peso_bruto_kg: e.target.value})}
                                required
                            />
                        </div>
                        
                        <div className="form-group">
                            <label className="required">Clasificación BASCAM:</label>
                            <select
                                value={formData.codigo_bascam}
                                onChange={e => setFormData({...formData, codigo_bascam: e.target.value})}
                                required
                            >
                                <option value="">Seleccionar clasificación</option>
                                {categoriasBascam.map(cat => (
                                    <option key={cat.codigo_bascam} value={cat.codigo_bascam}>
                                        {cat.codigo_bascam} - {cat.descripcion_bascam} 
                                        (Límite: {cat.peso_total_permitido_kg.toLocaleString()} kg)
                                    </option>
                                ))}
                            </select>
                        </div>
                        
                        <div className="form-group">
                            <label className="required">Estación:</label>
                            <select
                                value={formData.id_estacion}
                                onChange={e => setFormData({...formData, id_estacion: e.target.value})}
                                disabled={!!estacionAsignada}
                                required
                            >
                                <option value="">Seleccionar estación</option>
                                {estaciones.map(est => (
                                    <option key={est.id} value={est.id}>
                                        {est.nombre}
                                    </option>
                                ))}
                            </select>
                        </div>
                        
                        <div className="form-group full-width">
                            <label className="required">Motivo del registro manual:</label>
                            <select
                                value={formData.motivo_manual}
                                onChange={e => setFormData({...formData, motivo_manual: e.target.value})}
                                required
                            >
                                <option value="">Seleccionar motivo</option>
                                <option value="WEBSERVICE_CAIDO">WebService BASCAM fuera de servicio</option>
                                <option value="ERROR_AUTOMATICO">Error en clasificación automática</option>
                                <option value="CONTINGENCIA">Contingencia operativa</option>
                                <option value="CORRECCION">Corrección de datos</option>
                            </select>
                        </div>
                        
                        <div className="form-group full-width">
                            <label>Observaciones:</label>
                            <textarea
                                placeholder="Descripción adicional del evento..."
                                value={formData.observaciones}
                                onChange={e => setFormData({...formData, observaciones: e.target.value})}
                                rows="3"
                            />
                        </div>
                    </div>
                    
                    {clasificacionPreview && (
                        <div className="clasificacion-preview">
                            <h4>Vista Previa de Evaluación:</h4>
                            <div className="preview-grid">
                                <div className="preview-item">
                                    <span>Límite aplicable:</span>
                                    <strong>{clasificacionPreview.limite_kg.toLocaleString()} kg</strong>
                                </div>
                                <div className="preview-item">
                                    <span>Exceso detectado:</span>
                                    <strong className={clasificacionPreview.exceso_kg > 0 ? 'sobrepeso' : ''}>
                                        {clasificacionPreview.exceso_kg > 0 ? `+${clasificacionPreview.exceso_kg}` : '0'} kg
                                    </strong>
                                </div>
                                <div className="preview-item">
                                    <span>Severidad:</span>
                                    <span className={`severidad-badge ${clasificacionPreview.severidad.toLowerCase()}`}>
                                        {clasificacionPreview.severidad}
                                    </span>
                                </div>
                                {clasificacionPreview.tiene_sobrepeso && (
                                    <div className="preview-item full-width">
                                        <div className="alert alert-warning">
                                            <strong>⚠️ Sobrepeso Detectado:</strong> Este evento requerirá validación adicional
                                        </div>
                                    </div>
                                )}
                            </div>
                        </div>
                    )}
                    
                    <div className="form-actions">
                        <button type="button" className="btn-cancel" onClick={onClose}>
                            Cancelar
                        </button>
                        <button type="submit" className="btn-primary">
                            Registrar Evento Manual
                        </button>
                    </div>
                </form>
            </div>
        </Modal>
    );
};
```

---

## 📋 Definición de Terminado (DoD)

### **Validaciones Técnicas**
- ✅ CRUD completo de eventos de pesaje funcionando
- ✅ Integración automática con WebService BASCAM
- ✅ Registro manual de contingencia operativo
- ✅ Carga masiva Excel validando datos correctamente
- ✅ Performance <2 segundos en consultas con filtros
- ✅ Tests de integración pasando >95%

### **Validaciones de Negocio**
- ✅ Control territorial: operadores limitados a su estación
- ✅ Validación automática de sobrepesos según BASCAM
- ✅ Detección de duplicados funcionando
- ✅ Gestión de turnos con estadísticas correctas
- ✅ Auditoría completa de modificaciones y anulaciones

### **Validaciones de Usuario**
- ✅ Interfaz intuitiva para registro y consulta
- ✅ Filtros efectivos y respuesta rápida
- ✅ Exportación Excel funcional
- ✅ Alertas visuales claras para sobrepesos
- ✅ Modal de registro manual para contingencias

### **Validaciones de Datos**
- ✅ Integridad referencial con categorías BASCAM
- ✅ Tiquetes únicos generados automáticamente
- ✅ Evidencia fotográfica preservada correctamente
- ✅ Sincronización entre eventos automáticos y manuales

---

## 🚀 Estrategia de Implementación

### **Fase 1: Base de Datos y APIs Core (4 días)**
- Tabla eventos_pesaje completamente funcional
- APIs CRUD básicas adaptadas del sistema original
- Integración con tabla categoria_vehiculo

### **Fase 2: Integración BASCAM (3 días)**
- Procesamiento automático desde WebService
- Validaciones y mapeo de clasificación
- Sistema de alertas por sobrepeso

### **Fase 3: Contingencias y Respaldo (3 días)**
- Registro manual con validaciones
- Carga masiva Excel
- Detección de duplicados

### **Fase 4: UI y Funcionalidades Avanzadas (3 días)**
- Interfaz de consulta con filtros
- Dashboard de eventos en tiempo real
- Gestión de turnos y estadísticas

---

**Esta HU-COMP-004 completa el núcleo operativo del sistema, aprovechando exitosamente 70% de la funcionalidad del sistema original "pasos" y evolucionándola hacia un sistema completo de gestión de eventos de pesaje con integración BASCAM, control de sobrepesos y capacidades de contingencia robustas.**
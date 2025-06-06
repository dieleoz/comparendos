-- Script de inicialización completo para Comparendos
-- Combina el dump existente con las nuevas tablas de la migración

-- Configuración inicial
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- Crear la base de datos y roles
CREATE DATABASE comparendos_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';
ALTER DATABASE comparendos_db OWNER TO comparendos_user;

-- Conectar a la base de datos
\connect comparendos_db

-- Configuración de la base de datos
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- Crear esquema
CREATE SCHEMA public;
ALTER SCHEMA public OWNER TO comparendos_user;

-- Incluir el contenido del dump existente
-- (Este contenido ya incluye las tablas básicas: basculas, comparendos, configuracion_notificaciones, etc.)

-- Incluir las nuevas tablas de la migración
-- Tabla de categorías BASCAM
CREATE TABLE IF NOT EXISTS categoria_vehiculo (
    id SERIAL PRIMARY KEY,
    codigo_bascam VARCHAR(10) NOT NULL UNIQUE,
    descripcion_bascam VARCHAR(100) NOT NULL,
    configuracion_normativa VARCHAR(50),
    peso_maximo_kg NUMERIC(8,1) NOT NULL,
    tolerancia_kg NUMERIC(8,1) NOT NULL,
    peso_total_permitido_kg NUMERIC(8,1) GENERATED ALWAYS AS 
        (peso_maximo_kg + tolerancia_kg) STORED,
    norma_referencia VARCHAR(50) DEFAULT 'Resolución 2460/2022',
    vigencia_desde DATE DEFAULT CURRENT_DATE,
    vigencia_hasta DATE,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de eventos de pesaje
CREATE TABLE IF NOT EXISTS eventos_pesaje (
    id SERIAL PRIMARY KEY,
    id_registro_bascam INTEGER UNIQUE,
    placa VARCHAR(10) NOT NULL,
    fecha_pesaje TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_estacion INTEGER NOT NULL,
    id_bascula INTEGER,
    peso_bruto_kg NUMERIC(8,1) NOT NULL,
    peso_neto_kg NUMERIC(8,1),
    codigo_bascam VARCHAR(10) NOT NULL,
    categoria_id INTEGER NOT NULL,
    clasificacion_modo VARCHAR(20) DEFAULT 'AUTOMATICA',
    clasificacion_justificacion TEXT,
    limite_aplicado_kg NUMERIC(8,1) NOT NULL,
    exceso_kg NUMERIC(8,1) DEFAULT 0,
    tiene_sobrepeso BOOLEAN DEFAULT false,
    severidad VARCHAR(20) DEFAULT 'NORMAL',
    porcentaje_exceso NUMERIC(5,2) DEFAULT 0,
    foto_evidencia_path TEXT,
    tiquete_numero VARCHAR(50) UNIQUE,
    operador_id INTEGER NOT NULL,
    procesado_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_evento VARCHAR(20) DEFAULT 'COMPLETADO',
    requiere_retencion BOOLEAN DEFAULT false,
    vehiculo_retenido BOOLEAN DEFAULT false,
    liberado_en TIMESTAMP,
    liberado_por_id INTEGER,
    observaciones TEXT,
    datos_bascam_raw JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categoria_vehiculo(id),
    FOREIGN KEY (id_bascula) REFERENCES basculas(id_bascula),
    FOREIGN KEY (operador_id) REFERENCES usuarios(id),
    FOREIGN KEY (liberado_por_id) REFERENCES usuarios(id)
);

-- Tabla de infracciones
CREATE TABLE IF NOT EXISTS infracciones (
    id SERIAL PRIMARY KEY,
    codigo_infraccion VARCHAR(20) NOT NULL UNIQUE,
    descripcion TEXT NOT NULL,
    tipo_infraccion VARCHAR(50),
    severidad VARCHAR(20),
    valor_base NUMERIC(12,2) NOT NULL,
    tipo_calculo VARCHAR(20) DEFAULT 'FIJO',
    factor_exceso NUMERIC(12,2) DEFAULT 0,
    unidad_calculo VARCHAR(20) DEFAULT 'UNIDAD',
    normativa_referencia VARCHAR(100),
    articulo_referencia VARCHAR(50),
    descuento_pronto_pago NUMERIC(5,2) DEFAULT 50,
    dias_vencimiento_descuento INTEGER DEFAULT 30,
    dias_vencimiento_total INTEGER DEFAULT 90,
    activo BOOLEAN DEFAULT true,
    vigencia_desde DATE DEFAULT CURRENT_DATE,
    vigencia_hasta DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de multas
CREATE TABLE IF NOT EXISTS multas (
    id SERIAL PRIMARY KEY,
    comparendo_id INTEGER NOT NULL,
    numero_multa VARCHAR(50) UNIQUE,
    valor_total NUMERIC(12,2) NOT NULL,
    valor_con_descuento NUMERIC(12,2) NOT NULL,
    descuento_porcentaje NUMERIC(5,2) DEFAULT 50,
    fecha_vencimiento_descuento DATE NOT NULL,
    fecha_vencimiento_total DATE NOT NULL,
    estado_pago VARCHAR(20) DEFAULT 'PENDIENTE',
    fecha_pago TIMESTAMP,
    valor_pagado NUMERIC(12,2),
    metodo_pago VARCHAR(50),
    referencia_pago VARCHAR(100),
    entidad_recaudadora VARCHAR(100),
    observaciones_pago TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (comparendo_id) REFERENCES comparendos(id)
);

-- Tabla de evidencias
CREATE TABLE IF NOT EXISTS evidencias (
    id SERIAL PRIMARY KEY,
    evento_pesaje_id INTEGER,
    comparendo_id INTEGER,
    tipo_evidencia VARCHAR(30),
    archivo_nombre VARCHAR(255) NOT NULL,
    archivo_path TEXT NOT NULL,
    archivo_url TEXT,
    archivo_size BIGINT,
    archivo_mime_type VARCHAR(100),
    archivo_hash VARCHAR(64),
    descripcion TEXT,
    tomada_por_id INTEGER,
    fecha_captura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT true,
    FOREIGN KEY (evento_pesaje_id) REFERENCES eventos_pesaje(id),
    FOREIGN KEY (comparendo_id) REFERENCES comparendos(id),
    FOREIGN KEY (tomada_por_id) REFERENCES usuarios(id)
);

-- Tabla de auditoría
CREATE TABLE IF NOT EXISTS auditoria_sistema (
    id SERIAL PRIMARY KEY,
    tabla_afectada VARCHAR(50) NOT NULL,
    operacion VARCHAR(10) NOT NULL,
    registro_id INTEGER,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario_id INTEGER,
    ip_origen INET,
    user_agent TEXT,
    timestamp_operacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observaciones TEXT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Tabla de turnos
CREATE TABLE IF NOT EXISTS turnos (
    id SERIAL PRIMARY KEY,
    operador_id INTEGER NOT NULL,
    id_estacion INTEGER NOT NULL,
    fecha_turno DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME,
    total_pesajes INTEGER DEFAULT 0,
    total_sobrepesos INTEGER DEFAULT 0,
    total_comparendos INTEGER DEFAULT 0,
    archivo_respaldo_excel TEXT,
    observaciones TEXT,
    estado_turno VARCHAR(20) DEFAULT 'ACTIVO',
    cerrado_por_id INTEGER,
    fecha_cierre TIMESTAMP,
    FOREIGN KEY (operador_id) REFERENCES usuarios(id),
    FOREIGN KEY (cerrado_por_id) REFERENCES usuarios(id)
);

-- Crear vistas
CREATE OR REPLACE VIEW v_eventos_pesaje_completo AS
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
    cv.descripcion_bascam,
    cv.peso_maximo_kg,
    cv.tolerancia_kg,
    cv.peso_total_permitido_kg,
    ec.nombre_estacion,
    ec.direccion_flujo,
    b.nombre as nombre_bascula,
    u.nombre as operador_nombre,
    v.empresa_transporte,
    v.numero_interno,
    v.es_oficial
FROM eventos_pesaje ep
LEFT JOIN categoria_vehiculo cv ON ep.categoria_id = cv.id
LEFT JOIN estaciones_control ec ON ep.id_estacion = ec.id_estacion
LEFT JOIN basculas b ON ep.id_bascula = b.id_bascula
LEFT JOIN usuarios u ON ep.operador_id = u.id
LEFT JOIN vehiculos v ON ep.placa = v.placa;

CREATE OR REPLACE VIEW v_comparendos_completo AS
SELECT 
    c.id,
    c.numero_comparendo,
    c.fecha_imposicion,
    c.placa,
    c.estado_comparendo,
    ep.peso_bruto_kg,
    ep.codigo_bascam,
    ep.exceso_kg,
    ep.severidad,
    ep.fecha_pesaje,
    cv.descripcion_bascam,
    cv.peso_total_permitido_kg,
    i.codigo_infraccion,
    i.descripcion as infraccion_descripcion,
    i.normativa_referencia,
    i.articulo_referencia,
    m.valor_total,
    m.valor_con_descuento,
    m.estado_pago,
    m.fecha_vencimiento_descuento,
    c.agente_policia,
    c.codigo_agente,
    c.unidad_policial,
    c.conductor_nombre,
    c.conductor_cedula,
    ec.nombre_estacion,
    c.latitud,
    c.longitud,
    c.direccion_exacta,
    c.runt_numero,
    c.runt_estado,
    u_creado.nombre as creado_por,
    u_completado.nombre as completado_por,
    c.created_at,
    c.updated_at
FROM comparendos c
LEFT JOIN eventos_pesaje ep ON c.evento_pesaje_id = ep.id
LEFT JOIN categoria_vehiculo cv ON c.categoria_id = cv.id
LEFT JOIN infracciones i ON c.infraccion_id = i.id
LEFT JOIN multas m ON c.id = m.comparendo_id
LEFT JOIN estaciones_control ec ON ep.id_estacion = ec.id_estacion
LEFT JOIN usuarios u_creado ON c.created_by_id = u_creado.id
LEFT JOIN usuarios u_completado ON c.completado_por_id = u_completado.id;

-- Crear índices
CREATE INDEX IF NOT EXISTS idx_eventos_pesaje_placa ON eventos_pesaje(placa);
CREATE INDEX IF NOT EXISTS idx_eventos_pesaje_fecha ON eventos_pesaje(fecha_pesaje);
CREATE INDEX IF NOT EXISTS idx_comparendos_placa ON comparendos(placa);
CREATE INDEX IF NOT EXISTS idx_comparendos_fecha ON comparendos(fecha_imposicion);
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
CREATE INDEX IF NOT EXISTS idx_estaciones_nombre ON estaciones_control(nombre_estacion);

-- Otorgar permisos
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO comparendos_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO comparendos_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO vehiculos_user;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO vehiculos_user;

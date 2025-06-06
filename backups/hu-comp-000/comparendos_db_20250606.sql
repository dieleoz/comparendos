--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13 (Debian 15.13-1.pgdg120+1)
-- Dumped by pg_dump version 15.13 (Debian 15.13-1.pgdg120+1)

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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: comparendos_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO comparendos_user;

--
-- Name: guardar_en_historico(); Type: FUNCTION; Schema: public; Owner: comparendos_user
--

CREATE FUNCTION public.guardar_en_historico() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO historico_pasos (
        placa, conteo_pasos, codigo_tarjeta, consecutivo_tarjeta, 
        marca_vehiculo, usuario, color_vehiculo, categoria_vehiculo, activo
    )
    VALUES (
        OLD.placa, OLD.conteo_pasos, OLD.codigo_tarjeta, OLD.consecutivo_tarjeta, 
        OLD.marca_vehiculo, OLD.usuario, OLD.color_vehiculo, OLD.categoria_vehiculo, OLD.activo
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.guardar_en_historico() OWNER TO comparendos_user;

--
-- Name: limpiar_conteo_registros(); Type: FUNCTION; Schema: public; Owner: comparendos_user
--

CREATE FUNCTION public.limpiar_conteo_registros() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM conteo_registros;
END;
$$;


ALTER FUNCTION public.limpiar_conteo_registros() OWNER TO comparendos_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auditoria_sistema; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.auditoria_sistema (
    id integer NOT NULL,
    tabla_afectada character varying(50) NOT NULL,
    operacion character varying(10) NOT NULL,
    registro_id integer,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    usuario_id integer,
    ip_origen inet,
    user_agent text,
    timestamp_operacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    observaciones text
);


ALTER TABLE public.auditoria_sistema OWNER TO comparendos_user;

--
-- Name: auditoria_sistema_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.auditoria_sistema_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auditoria_sistema_id_seq OWNER TO comparendos_user;

--
-- Name: auditoria_sistema_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.auditoria_sistema_id_seq OWNED BY public.auditoria_sistema.id;


--
-- Name: basculas; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.basculas (
    id_bascula integer NOT NULL,
    nombre character varying(100) NOT NULL,
    activo boolean DEFAULT true
);


ALTER TABLE public.basculas OWNER TO comparendos_user;

--
-- Name: basculas_id_bascula_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.basculas_id_bascula_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.basculas_id_bascula_seq OWNER TO comparendos_user;

--
-- Name: basculas_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.basculas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.basculas_id_seq OWNER TO comparendos_user;

--
-- Name: basculas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.basculas_id_seq OWNED BY public.basculas.id_bascula;


--
-- Name: categoria_vehiculo; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.categoria_vehiculo (
    id integer NOT NULL,
    codigo_bascam character varying(10) NOT NULL,
    descripcion_bascam character varying(100) NOT NULL,
    configuracion_normativa character varying(50),
    peso_maximo_kg numeric(8,1) NOT NULL,
    tolerancia_kg numeric(8,1) NOT NULL,
    peso_total_permitido_kg numeric(8,1) GENERATED ALWAYS AS ((peso_maximo_kg + tolerancia_kg)) STORED,
    norma_referencia character varying(50) DEFAULT 'Resolución 2460/2022'::character varying,
    vigencia_desde date DEFAULT CURRENT_DATE,
    vigencia_hasta date,
    activo boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.categoria_vehiculo OWNER TO comparendos_user;

--
-- Name: categoria_vehiculo_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.categoria_vehiculo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categoria_vehiculo_id_seq OWNER TO comparendos_user;

--
-- Name: categoria_vehiculo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.categoria_vehiculo_id_seq OWNED BY public.categoria_vehiculo.id;


--
-- Name: comparendos; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.comparendos (
    id integer NOT NULL,
    numero_comparendo character varying(50) NOT NULL,
    fecha timestamp without time zone NOT NULL,
    placa character varying(10) NOT NULL,
    id_bascula integer,
    evento_pesaje_id integer,
    categoria_id integer,
    infraccion_id integer,
    agente_policia character varying(100),
    codigo_agente character varying(20),
    placa_agente character varying(10),
    unidad_policial character varying(100),
    conductor_cedula character varying(20),
    conductor_nombre character varying(100),
    conductor_licencia character varying(20),
    peso_detectado_kg numeric(8,1),
    peso_limite_kg numeric(8,1),
    exceso_detectado_kg numeric(8,1),
    porcentaje_exceso numeric(5,2),
    valor_multa numeric(12,2),
    valor_con_descuento numeric(12,2),
    descuento_porcentaje numeric(5,2) DEFAULT 50,
    fecha_vencimiento_descuento date,
    fecha_vencimiento_total date,
    estado_comparendo character varying(20) DEFAULT 'PENDIENTE_AGENTE'::character varying,
    fecha_imposicion timestamp without time zone,
    fecha_anulacion timestamp without time zone,
    motivo_anulacion text,
    anulado_por_id integer,
    completado_por_id integer,
    direccion_exacta text,
    observaciones_agente text,
    runt_numero character varying(50),
    runt_estado character varying(20),
    runt_fecha_envio timestamp without time zone,
    runt_fecha_confirmacion timestamp without time zone,
    runt_intentos_envio integer DEFAULT 0,
    created_by_id integer,
    updated_by_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_estado_comparendo CHECK (((estado_comparendo)::text = ANY (ARRAY[('PENDIENTE_AGENTE'::character varying)::text, ('ACTIVO'::character varying)::text, ('ANULADO'::character varying)::text, ('PAGADO'::character varying)::text, ('VENCIDO'::character varying)::text])))
);


ALTER TABLE public.comparendos OWNER TO comparendos_user;

--
-- Name: comparendos_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.comparendos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comparendos_id_seq OWNER TO comparendos_user;

--
-- Name: comparendos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.comparendos_id_seq OWNED BY public.comparendos.id;


--
-- Name: configuracion_notificaciones; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.configuracion_notificaciones (
    id integer NOT NULL,
    correo_destino text NOT NULL,
    umbral_envio integer DEFAULT 65,
    umbral_bloqueo integer DEFAULT 70
);


ALTER TABLE public.configuracion_notificaciones OWNER TO comparendos_user;

--
-- Name: configuracion_notificaciones_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.configuracion_notificaciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.configuracion_notificaciones_id_seq OWNER TO comparendos_user;

--
-- Name: configuracion_notificaciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.configuracion_notificaciones_id_seq OWNED BY public.configuracion_notificaciones.id;


--
-- Name: conteo_registros; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.conteo_registros (
    id integer NOT NULL,
    conteo integer NOT NULL
);


ALTER TABLE public.conteo_registros OWNER TO comparendos_user;

--
-- Name: conteo_registros_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.conteo_registros_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.conteo_registros_id_seq OWNER TO comparendos_user;

--
-- Name: conteo_registros_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.conteo_registros_id_seq OWNED BY public.conteo_registros.id;


--
-- Name: estaciones_control; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.estaciones_control (
    id_estacion integer NOT NULL,
    nombre_estacion character varying(100) NOT NULL,
    ubicacion text NOT NULL,
    activo boolean DEFAULT true,
    latitud double precision,
    longitud double precision,
    tipo_estacion character varying(50) DEFAULT 'CONTROL_PESO'::character varying,
    direccion_flujo character varying(20)
);


ALTER TABLE public.estaciones_control OWNER TO comparendos_user;

--
-- Name: eventos_pesaje; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.eventos_pesaje (
    id integer NOT NULL,
    id_registro_bascam integer,
    placa character varying(10) NOT NULL,
    fecha_pesaje timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    id_estacion integer NOT NULL,
    id_bascula integer,
    peso_bruto_kg numeric(8,1) NOT NULL,
    peso_neto_kg numeric(8,1),
    codigo_bascam character varying(10) NOT NULL,
    categoria_id integer NOT NULL,
    clasificacion_modo character varying(20) DEFAULT 'AUTOMATICA'::character varying,
    clasificacion_justificacion text,
    limite_aplicado_kg numeric(8,1) NOT NULL,
    exceso_kg numeric(8,1) DEFAULT 0,
    tiene_sobrepeso boolean DEFAULT false,
    severidad character varying(20) DEFAULT 'NORMAL'::character varying,
    porcentaje_exceso numeric(5,2) DEFAULT 0,
    foto_evidencia_path text,
    tiquete_numero character varying(50),
    operador_id integer NOT NULL,
    procesado_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    estado_evento character varying(20) DEFAULT 'COMPLETADO'::character varying,
    requiere_retencion boolean DEFAULT false,
    vehiculo_retenido boolean DEFAULT false,
    liberado_en timestamp without time zone,
    liberado_por_id integer,
    observaciones text,
    datos_bascam_raw jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.eventos_pesaje OWNER TO comparendos_user;

--
-- Name: eventos_pesaje_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.eventos_pesaje_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.eventos_pesaje_id_seq OWNER TO comparendos_user;

--
-- Name: eventos_pesaje_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.eventos_pesaje_id_seq OWNED BY public.eventos_pesaje.id;


--
-- Name: evidencias; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.evidencias (
    id integer NOT NULL,
    evento_pesaje_id integer,
    comparendo_id integer,
    tipo_evidencia character varying(30),
    archivo_nombre character varying(255) NOT NULL,
    archivo_path text NOT NULL,
    archivo_url text,
    archivo_size bigint,
    archivo_mime_type character varying(100),
    archivo_hash character varying(64),
    descripcion text,
    tomada_por_id integer,
    fecha_captura timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    activo boolean DEFAULT true
);


ALTER TABLE public.evidencias OWNER TO comparendos_user;

--
-- Name: evidencias_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.evidencias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.evidencias_id_seq OWNER TO comparendos_user;

--
-- Name: evidencias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.evidencias_id_seq OWNED BY public.evidencias.id;


--
-- Name: exclusiones; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.exclusiones (
    id integer NOT NULL,
    placa character varying(10) NOT NULL,
    motivo text NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date,
    activo boolean DEFAULT true
);


ALTER TABLE public.exclusiones OWNER TO comparendos_user;

--
-- Name: exclusiones_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.exclusiones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.exclusiones_id_seq OWNER TO comparendos_user;

--
-- Name: exclusiones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.exclusiones_id_seq OWNED BY public.exclusiones.id;


--
-- Name: historico_pasos; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.historico_pasos (
    id integer NOT NULL,
    placa character varying(10) NOT NULL,
    conteo_pasos integer NOT NULL,
    codigo_tarjeta character varying(50),
    consecutivo_tarjeta character varying(50),
    marca_vehiculo character varying(100),
    usuario character varying(100),
    color_vehiculo character varying(50),
    categoria_vehiculo character varying(50),
    activo boolean DEFAULT true,
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.historico_pasos OWNER TO comparendos_user;

--
-- Name: historico_pasos_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.historico_pasos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.historico_pasos_id_seq OWNER TO comparendos_user;

--
-- Name: historico_pasos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.historico_pasos_id_seq OWNED BY public.historico_pasos.id;


--
-- Name: infracciones; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.infracciones (
    id integer NOT NULL,
    codigo_infraccion character varying(20) NOT NULL,
    descripcion text NOT NULL,
    tipo_infraccion character varying(50),
    severidad character varying(20),
    valor_base numeric(12,2) NOT NULL,
    tipo_calculo character varying(20) DEFAULT 'FIJO'::character varying,
    factor_exceso numeric(12,2) DEFAULT 0,
    unidad_calculo character varying(20) DEFAULT 'UNIDAD'::character varying,
    normativa_referencia character varying(100),
    articulo_referencia character varying(50),
    descuento_pronto_pago numeric(5,2) DEFAULT 50,
    dias_vencimiento_descuento integer DEFAULT 30,
    dias_vencimiento_total integer DEFAULT 90,
    activo boolean DEFAULT true,
    vigencia_desde date DEFAULT CURRENT_DATE,
    vigencia_hasta date,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.infracciones OWNER TO comparendos_user;

--
-- Name: infracciones_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.infracciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.infracciones_id_seq OWNER TO comparendos_user;

--
-- Name: infracciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.infracciones_id_seq OWNED BY public.infracciones.id;


--
-- Name: log_exclusiones; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.log_exclusiones (
    id integer NOT NULL,
    id_exclusion integer NOT NULL,
    fecha_accion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    accion character varying(50) NOT NULL,
    usuario character varying(100) NOT NULL
);


ALTER TABLE public.log_exclusiones OWNER TO comparendos_user;

--
-- Name: log_exclusiones_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.log_exclusiones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_exclusiones_id_seq OWNER TO comparendos_user;

--
-- Name: log_exclusiones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.log_exclusiones_id_seq OWNED BY public.log_exclusiones.id;


--
-- Name: multas; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.multas (
    id integer NOT NULL,
    comparendo_id integer NOT NULL,
    infraccion_id integer NOT NULL,
    numero_multa character varying(50),
    valor_total numeric(12,2) NOT NULL,
    valor_con_descuento numeric(12,2) NOT NULL,
    descuento_porcentaje numeric(5,2) DEFAULT 50,
    fecha_vencimiento_descuento date NOT NULL,
    fecha_vencimiento_total date NOT NULL,
    estado_pago character varying(20) DEFAULT 'PENDIENTE'::character varying,
    fecha_pago timestamp without time zone,
    valor_pagado numeric(12,2),
    metodo_pago character varying(50),
    referencia_pago character varying(100),
    entidad_recaudadora character varying(100),
    observaciones_pago text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_estado_pago CHECK (((estado_pago)::text = ANY (ARRAY[('PENDIENTE'::character varying)::text, ('PAGADO'::character varying)::text, ('VENCIDO'::character varying)::text, ('ANULADO'::character varying)::text])))
);


ALTER TABLE public.multas OWNER TO comparendos_user;

--
-- Name: multas_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.multas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.multas_id_seq OWNER TO comparendos_user;

--
-- Name: multas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.multas_id_seq OWNED BY public.multas.id;


--
-- Name: pasos; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.pasos (
    id integer NOT NULL,
    placa character varying(10) NOT NULL,
    conteo_pasos integer NOT NULL,
    codigo_tarjeta character varying(50),
    consecutivo_tarjeta character varying(50),
    marca_vehiculo character varying(100),
    usuario character varying(100),
    color_vehiculo character varying(50),
    categoria_vehiculo character varying(50),
    activo boolean DEFAULT true,
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.pasos OWNER TO comparendos_user;

--
-- Name: pasos_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.pasos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pasos_id_seq OWNER TO comparendos_user;

--
-- Name: pasos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.pasos_id_seq OWNED BY public.pasos.id;


--
-- Name: peajes_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.peajes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.peajes_id_seq OWNER TO comparendos_user;

--
-- Name: peajes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.peajes_id_seq OWNED BY public.estaciones_control.id_estacion;


--
-- Name: reinicios_mensuales; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.reinicios_mensuales (
    id integer NOT NULL,
    fecha_reinicio date NOT NULL,
    conteo_anterior integer NOT NULL,
    conteo_actual integer NOT NULL
);


ALTER TABLE public.reinicios_mensuales OWNER TO comparendos_user;

--
-- Name: reinicios_mensuales_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.reinicios_mensuales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reinicios_mensuales_id_seq OWNER TO comparendos_user;

--
-- Name: reinicios_mensuales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.reinicios_mensuales_id_seq OWNED BY public.reinicios_mensuales.id;


--
-- Name: turnos; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.turnos (
    id integer NOT NULL,
    operador_id integer NOT NULL,
    id_estacion integer NOT NULL,
    fecha_turno date NOT NULL,
    hora_inicio time without time zone NOT NULL,
    hora_fin time without time zone,
    total_pesajes integer DEFAULT 0,
    total_sobrepesos integer DEFAULT 0,
    total_comparendos integer DEFAULT 0,
    archivo_respaldo_excel text,
    observaciones text,
    estado_turno character varying(20) DEFAULT 'ACTIVO'::character varying,
    cerrado_por_id integer,
    fecha_cierre timestamp without time zone
);


ALTER TABLE public.turnos OWNER TO comparendos_user;

--
-- Name: turnos_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.turnos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.turnos_id_seq OWNER TO comparendos_user;

--
-- Name: turnos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.turnos_id_seq OWNED BY public.turnos.id;


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    password text,
    activo boolean DEFAULT true,
    password_hash character varying(60),
    estacion_asignada integer,
    telefono character varying(20),
    cargo character varying(100),
    fecha_ultimo_acceso timestamp without time zone,
    intentos_fallidos integer DEFAULT 0,
    cuenta_bloqueada boolean DEFAULT false,
    ultimo_cambio_password timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    rol integer,
    CONSTRAINT usuarios_rol_check CHECK ((rol = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7])))
);


ALTER TABLE public.usuarios OWNER TO comparendos_user;

--
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.usuarios_id_seq OWNER TO comparendos_user;

--
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- Name: v_categoria_2s2; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.v_categoria_2s2 (
    id integer
);


ALTER TABLE public.v_categoria_2s2 OWNER TO comparendos_user;

--
-- Name: v_comparendos_completo; Type: VIEW; Schema: public; Owner: comparendos_user
--

CREATE VIEW public.v_comparendos_completo AS
 SELECT c.id,
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
    i.descripcion AS infraccion_descripcion,
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
    c.direccion_exacta,
    c.runt_numero,
    c.runt_estado,
    u_creado.nombre AS creado_por,
    u_completado.nombre AS completado_por,
    c.created_at,
    c.updated_at
   FROM (((((((public.comparendos c
     LEFT JOIN public.eventos_pesaje ep ON ((c.evento_pesaje_id = ep.id)))
     LEFT JOIN public.categoria_vehiculo cv ON ((c.categoria_id = cv.id)))
     LEFT JOIN public.infracciones i ON ((c.infraccion_id = i.id)))
     LEFT JOIN public.multas m ON ((c.id = m.comparendo_id)))
     LEFT JOIN public.estaciones_control ec ON ((ep.id_estacion = ec.id_estacion)))
     LEFT JOIN public.usuarios u_creado ON ((c.created_by_id = u_creado.id)))
     LEFT JOIN public.usuarios u_completado ON ((c.completado_por_id = u_completado.id)));


ALTER TABLE public.v_comparendos_completo OWNER TO comparendos_user;

--
-- Name: vehiculos; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.vehiculos (
    id integer NOT NULL,
    placa character varying(10) NOT NULL,
    marca character varying(100) NOT NULL,
    modelo character varying(50),
    color character varying(50),
    categoria character varying(50),
    activo boolean DEFAULT true,
    codigo_tarjeta character varying(50),
    categoria_id integer,
    empresa_transporte character varying(200),
    numero_interno character varying(50),
    conductor_cedula character varying(20),
    conductor_nombre character varying(100),
    tipo_servicio character varying(50) DEFAULT 'CARGA'::character varying,
    es_oficial boolean DEFAULT false,
    motivo_oficial character varying(100),
    usuario character varying(100),
    color_vehiculo character varying(30),
    conteo_pasos integer DEFAULT 0,
    fecha_ultima_actualizacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_placa_formato CHECK (((placa)::text ~ '^[A-Z]{3}[0-9]{2}[A-Z]$|^[A-Z]{3}[0-9]{3}$'::text))
);


ALTER TABLE public.vehiculos OWNER TO comparendos_user;

--
-- Name: v_eventos_pesaje_completo; Type: VIEW; Schema: public; Owner: comparendos_user
--

CREATE VIEW public.v_eventos_pesaje_completo AS
 SELECT ep.id,
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
    b.nombre AS nombre_bascula,
    u.nombre AS operador_nombre,
    v.empresa_transporte,
    v.numero_interno,
    v.es_oficial
   FROM (((((public.eventos_pesaje ep
     LEFT JOIN public.categoria_vehiculo cv ON ((ep.categoria_id = cv.id)))
     LEFT JOIN public.estaciones_control ec ON ((ep.id_estacion = ec.id_estacion)))
     LEFT JOIN public.basculas b ON ((ep.id_bascula = b.id_bascula)))
     LEFT JOIN public.usuarios u ON ((ep.operador_id = u.id)))
     LEFT JOIN public.vehiculos v ON (((ep.placa)::text = (v.placa)::text)));


ALTER TABLE public.v_eventos_pesaje_completo OWNER TO comparendos_user;

--
-- Name: v_operador_id; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.v_operador_id (
    id integer
);


ALTER TABLE public.v_operador_id OWNER TO comparendos_user;

--
-- Name: vehiculos_hist; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.vehiculos_hist (
    id integer NOT NULL,
    id_vehiculo integer NOT NULL,
    placa character varying(10) NOT NULL,
    marca character varying(100) NOT NULL,
    modelo character varying(50),
    color character varying(50),
    categoria character varying(50),
    activo boolean DEFAULT true,
    fecha_modificacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.vehiculos_hist OWNER TO comparendos_user;

--
-- Name: vehiculos_hist_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.vehiculos_hist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vehiculos_hist_id_seq OWNER TO comparendos_user;

--
-- Name: vehiculos_hist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.vehiculos_hist_id_seq OWNED BY public.vehiculos_hist.id;


--
-- Name: vehiculos_id_seq; Type: SEQUENCE; Schema: public; Owner: comparendos_user
--

CREATE SEQUENCE public.vehiculos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vehiculos_id_seq OWNER TO comparendos_user;

--
-- Name: vehiculos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.vehiculos_id_seq OWNED BY public.vehiculos.id;


--
-- Name: auditoria_sistema id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.auditoria_sistema ALTER COLUMN id SET DEFAULT nextval('public.auditoria_sistema_id_seq'::regclass);


--
-- Name: basculas id_bascula; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.basculas ALTER COLUMN id_bascula SET DEFAULT nextval('public.basculas_id_seq'::regclass);


--
-- Name: categoria_vehiculo id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.categoria_vehiculo ALTER COLUMN id SET DEFAULT nextval('public.categoria_vehiculo_id_seq'::regclass);


--
-- Name: comparendos id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.comparendos ALTER COLUMN id SET DEFAULT nextval('public.comparendos_id_seq'::regclass);


--
-- Name: configuracion_notificaciones id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.configuracion_notificaciones ALTER COLUMN id SET DEFAULT nextval('public.configuracion_notificaciones_id_seq'::regclass);


--
-- Name: conteo_registros id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.conteo_registros ALTER COLUMN id SET DEFAULT nextval('public.conteo_registros_id_seq'::regclass);


--
-- Name: estaciones_control id_estacion; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.estaciones_control ALTER COLUMN id_estacion SET DEFAULT nextval('public.peajes_id_seq'::regclass);


--
-- Name: eventos_pesaje id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.eventos_pesaje ALTER COLUMN id SET DEFAULT nextval('public.eventos_pesaje_id_seq'::regclass);


--
-- Name: evidencias id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.evidencias ALTER COLUMN id SET DEFAULT nextval('public.evidencias_id_seq'::regclass);


--
-- Name: exclusiones id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.exclusiones ALTER COLUMN id SET DEFAULT nextval('public.exclusiones_id_seq'::regclass);


--
-- Name: historico_pasos id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.historico_pasos ALTER COLUMN id SET DEFAULT nextval('public.historico_pasos_id_seq'::regclass);


--
-- Name: infracciones id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.infracciones ALTER COLUMN id SET DEFAULT nextval('public.infracciones_id_seq'::regclass);


--
-- Name: log_exclusiones id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.log_exclusiones ALTER COLUMN id SET DEFAULT nextval('public.log_exclusiones_id_seq'::regclass);


--
-- Name: multas id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.multas ALTER COLUMN id SET DEFAULT nextval('public.multas_id_seq'::regclass);


--
-- Name: pasos id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.pasos ALTER COLUMN id SET DEFAULT nextval('public.pasos_id_seq'::regclass);


--
-- Name: reinicios_mensuales id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.reinicios_mensuales ALTER COLUMN id SET DEFAULT nextval('public.reinicios_mensuales_id_seq'::regclass);


--
-- Name: turnos id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.turnos ALTER COLUMN id SET DEFAULT nextval('public.turnos_id_seq'::regclass);


--
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- Name: vehiculos id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.vehiculos ALTER COLUMN id SET DEFAULT nextval('public.vehiculos_id_seq'::regclass);


--
-- Name: vehiculos_hist id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.vehiculos_hist ALTER COLUMN id SET DEFAULT nextval('public.vehiculos_hist_id_seq'::regclass);


--
-- Data for Name: auditoria_sistema; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.auditoria_sistema (id, tabla_afectada, operacion, registro_id, datos_anteriores, datos_nuevos, usuario_id, ip_origen, user_agent, timestamp_operacion, observaciones) FROM stdin;
\.


--
-- Data for Name: basculas; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.basculas (id_bascula, nombre, activo) FROM stdin;
\.


--
-- Data for Name: categoria_vehiculo; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.categoria_vehiculo (id, codigo_bascam, descripcion_bascam, configuracion_normativa, peso_maximo_kg, tolerancia_kg, norma_referencia, vigencia_desde, vigencia_hasta, activo, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: comparendos; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.comparendos (id, numero_comparendo, fecha, placa, id_bascula, evento_pesaje_id, categoria_id, infraccion_id, agente_policia, codigo_agente, placa_agente, unidad_policial, conductor_cedula, conductor_nombre, conductor_licencia, peso_detectado_kg, peso_limite_kg, exceso_detectado_kg, porcentaje_exceso, valor_multa, valor_con_descuento, descuento_porcentaje, fecha_vencimiento_descuento, fecha_vencimiento_total, estado_comparendo, fecha_imposicion, fecha_anulacion, motivo_anulacion, anulado_por_id, completado_por_id, direccion_exacta, observaciones_agente, runt_numero, runt_estado, runt_fecha_envio, runt_fecha_confirmacion, runt_intentos_envio, created_by_id, updated_by_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: configuracion_notificaciones; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.configuracion_notificaciones (id, correo_destino, umbral_envio, umbral_bloqueo) FROM stdin;
\.


--
-- Data for Name: conteo_registros; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.conteo_registros (id, conteo) FROM stdin;
\.


--
-- Data for Name: estaciones_control; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.estaciones_control (id_estacion, nombre_estacion, ubicacion, activo, latitud, longitud, tipo_estacion, direccion_flujo) FROM stdin;
\.


--
-- Data for Name: eventos_pesaje; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.eventos_pesaje (id, id_registro_bascam, placa, fecha_pesaje, id_estacion, id_bascula, peso_bruto_kg, peso_neto_kg, codigo_bascam, categoria_id, clasificacion_modo, clasificacion_justificacion, limite_aplicado_kg, exceso_kg, tiene_sobrepeso, severidad, porcentaje_exceso, foto_evidencia_path, tiquete_numero, operador_id, procesado_at, estado_evento, requiere_retencion, vehiculo_retenido, liberado_en, liberado_por_id, observaciones, datos_bascam_raw, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: evidencias; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.evidencias (id, evento_pesaje_id, comparendo_id, tipo_evidencia, archivo_nombre, archivo_path, archivo_url, archivo_size, archivo_mime_type, archivo_hash, descripcion, tomada_por_id, fecha_captura, activo) FROM stdin;
\.


--
-- Data for Name: exclusiones; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.exclusiones (id, placa, motivo, fecha_inicio, fecha_fin, activo) FROM stdin;
\.


--
-- Data for Name: historico_pasos; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.historico_pasos (id, placa, conteo_pasos, codigo_tarjeta, consecutivo_tarjeta, marca_vehiculo, usuario, color_vehiculo, categoria_vehiculo, activo, fecha_creacion) FROM stdin;
\.


--
-- Data for Name: infracciones; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.infracciones (id, codigo_infraccion, descripcion, tipo_infraccion, severidad, valor_base, tipo_calculo, factor_exceso, unidad_calculo, normativa_referencia, articulo_referencia, descuento_pronto_pago, dias_vencimiento_descuento, dias_vencimiento_total, activo, vigencia_desde, vigencia_hasta, created_at) FROM stdin;
\.


--
-- Data for Name: log_exclusiones; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.log_exclusiones (id, id_exclusion, fecha_accion, accion, usuario) FROM stdin;
\.


--
-- Data for Name: multas; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.multas (id, comparendo_id, infraccion_id, numero_multa, valor_total, valor_con_descuento, descuento_porcentaje, fecha_vencimiento_descuento, fecha_vencimiento_total, estado_pago, fecha_pago, valor_pagado, metodo_pago, referencia_pago, entidad_recaudadora, observaciones_pago, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: pasos; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.pasos (id, placa, conteo_pasos, codigo_tarjeta, consecutivo_tarjeta, marca_vehiculo, usuario, color_vehiculo, categoria_vehiculo, activo, fecha_creacion) FROM stdin;
\.


--
-- Data for Name: reinicios_mensuales; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.reinicios_mensuales (id, fecha_reinicio, conteo_anterior, conteo_actual) FROM stdin;
\.


--
-- Data for Name: turnos; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.turnos (id, operador_id, id_estacion, fecha_turno, hora_inicio, hora_fin, total_pesajes, total_sobrepesos, total_comparendos, archivo_respaldo_excel, observaciones, estado_turno, cerrado_por_id, fecha_cierre) FROM stdin;
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.usuarios (id, nombre, email, password, activo, password_hash, estacion_asignada, telefono, cargo, fecha_ultimo_acceso, intentos_fallidos, cuenta_bloqueada, ultimo_cambio_password, created_at, updated_at, rol) FROM stdin;
41	Operador Norte Neiva	operador.nn@comparendos.com	\N	t	$2b$10$JdxJuVzuQIKzYsW.9uxSE.05x1rPurXkqHJjONR89ks9vXt3dIUwS	\N	3101234567	Operador Báscula	2025-06-06 15:14:44.323575	0	f	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	2
42	Operador Sur Neiva	operador.sn@comparendos.com	\N	t	$2b$10$14jhcEg3z9IcvZJSfIPUcuOSpzIbfyttJlls9MuAmegiYvWBQx1SC	\N	3101234568	Operador Báscula	2025-06-06 15:14:44.323575	0	f	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	2
43	Operador Norte Flandes	operador.nf@comparendos.com	\N	t	$2b$10$j/EnA2XfZ/B07/jAyMyS8.guEK2/LSNCSn9kigkTHlq1DgGb.0AoG	\N	3101234569	Operador Báscula	2025-06-06 15:14:44.323575	0	f	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	2
44	Operador Sur Flandes	operador.sf@comparendos.com	\N	t	$2b$10$88CyZggv/.E95CJGF8wJ7OrZklCJEPV.3oRsx72CcATBpu1VyvSAq	\N	3101234570	Operador Báscula	2025-06-06 15:14:44.323575	0	f	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	2
45	Oficial de Policía	police@comparendos.com	\N	t	$2b$10$X.3vZVxu6Qx88qOz9iL06uWzZ1z6v2p5j5zQzQzQzQzQzQzQzQzQz	\N	3101234571	Oficial Policía	2025-06-06 15:14:44.323575	0	f	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	3
46	Coordinador ITS	coordinador.its@comparendos.com	\N	t	$2b$10$Sw.Ne/K/84ZBw1.us0k/..WpMwNq4OQfw6GTXZWyWpTswQ0.BFgnW	\N	3101234572	Coordinador ITS	2025-06-06 15:14:44.323575	0	f	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	4
47	Coordinador CCO	coordinador.cco@comparendos.com	\N	t	$2b$10$ylD30TdFk/VDLFoaDKfT5.d4ymtKT2sSTzuRrFWfuAJ5aXEENZRh.	\N	3101234573	Coordinador CCO	2025-06-06 15:14:44.323575	0	f	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	4
48	Regulador ANI	ani@comparendos.com	\N	t	$2b$10$X.3vZVxu6Qx88qOz9iL06uWzZ1z6v2p5j5zQzQzQzQzQzQzQzQzQz	\N	3101234574	Regulador ANI	2025-06-06 15:14:44.323575	0	f	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	5
49	Transportista	transportista@comparendos.com	\N	t	$2b$10$X.3vZVxu6Qx88qOz9iL06uWzZ1z6v2p5j5zQzQzQzQzQzQzQzQzQz	\N	3101234575	Transportista	2025-06-06 15:14:44.323575	0	f	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	2025-06-06 15:14:44.323575	6
\.


--
-- Data for Name: v_categoria_2s2; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.v_categoria_2s2 (id) FROM stdin;
\.


--
-- Data for Name: v_operador_id; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.v_operador_id (id) FROM stdin;
\.


--
-- Data for Name: vehiculos; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.vehiculos (id, placa, marca, modelo, color, categoria, activo, codigo_tarjeta, categoria_id, empresa_transporte, numero_interno, conductor_cedula, conductor_nombre, tipo_servicio, es_oficial, motivo_oficial, usuario, color_vehiculo, conteo_pasos, fecha_ultima_actualizacion, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: vehiculos_hist; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.vehiculos_hist (id, id_vehiculo, placa, marca, modelo, color, categoria, activo, fecha_modificacion) FROM stdin;
\.


--
-- Name: auditoria_sistema_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.auditoria_sistema_id_seq', 1, false);


--
-- Name: basculas_id_bascula_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.basculas_id_bascula_seq', 1, false);


--
-- Name: basculas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.basculas_id_seq', 1, false);


--
-- Name: categoria_vehiculo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.categoria_vehiculo_id_seq', 1, false);


--
-- Name: comparendos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.comparendos_id_seq', 1, false);


--
-- Name: configuracion_notificaciones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.configuracion_notificaciones_id_seq', 1, false);


--
-- Name: conteo_registros_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.conteo_registros_id_seq', 1, false);


--
-- Name: eventos_pesaje_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.eventos_pesaje_id_seq', 1, false);


--
-- Name: evidencias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.evidencias_id_seq', 1, false);


--
-- Name: exclusiones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.exclusiones_id_seq', 1, false);


--
-- Name: historico_pasos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.historico_pasos_id_seq', 1, false);


--
-- Name: infracciones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.infracciones_id_seq', 1, false);


--
-- Name: log_exclusiones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.log_exclusiones_id_seq', 1, false);


--
-- Name: multas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.multas_id_seq', 1, false);


--
-- Name: pasos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.pasos_id_seq', 1, false);


--
-- Name: peajes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.peajes_id_seq', 1, false);


--
-- Name: reinicios_mensuales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.reinicios_mensuales_id_seq', 1, false);


--
-- Name: turnos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.turnos_id_seq', 1, false);


--
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 49, true);


--
-- Name: vehiculos_hist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.vehiculos_hist_id_seq', 1, false);


--
-- Name: vehiculos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.vehiculos_id_seq', 1, false);


--
-- Name: auditoria_sistema auditoria_sistema_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.auditoria_sistema
    ADD CONSTRAINT auditoria_sistema_pkey PRIMARY KEY (id);


--
-- Name: basculas basculas_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.basculas
    ADD CONSTRAINT basculas_pkey PRIMARY KEY (id_bascula);


--
-- Name: categoria_vehiculo categoria_vehiculo_codigo_bascam_key; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.categoria_vehiculo
    ADD CONSTRAINT categoria_vehiculo_codigo_bascam_key UNIQUE (codigo_bascam);


--
-- Name: categoria_vehiculo categoria_vehiculo_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.categoria_vehiculo
    ADD CONSTRAINT categoria_vehiculo_pkey PRIMARY KEY (id);


--
-- Name: comparendos comparendos_numero_comparendo_key; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.comparendos
    ADD CONSTRAINT comparendos_numero_comparendo_key UNIQUE (numero_comparendo);


--
-- Name: comparendos comparendos_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.comparendos
    ADD CONSTRAINT comparendos_pkey PRIMARY KEY (id);


--
-- Name: configuracion_notificaciones configuracion_notificaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.configuracion_notificaciones
    ADD CONSTRAINT configuracion_notificaciones_pkey PRIMARY KEY (id);


--
-- Name: conteo_registros conteo_registros_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.conteo_registros
    ADD CONSTRAINT conteo_registros_pkey PRIMARY KEY (id);


--
-- Name: eventos_pesaje eventos_pesaje_id_registro_bascam_key; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.eventos_pesaje
    ADD CONSTRAINT eventos_pesaje_id_registro_bascam_key UNIQUE (id_registro_bascam);


--
-- Name: eventos_pesaje eventos_pesaje_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.eventos_pesaje
    ADD CONSTRAINT eventos_pesaje_pkey PRIMARY KEY (id);


--
-- Name: eventos_pesaje eventos_pesaje_tiquete_numero_key; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.eventos_pesaje
    ADD CONSTRAINT eventos_pesaje_tiquete_numero_key UNIQUE (tiquete_numero);


--
-- Name: evidencias evidencias_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.evidencias
    ADD CONSTRAINT evidencias_pkey PRIMARY KEY (id);


--
-- Name: exclusiones exclusiones_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.exclusiones
    ADD CONSTRAINT exclusiones_pkey PRIMARY KEY (id);


--
-- Name: historico_pasos historico_pasos_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.historico_pasos
    ADD CONSTRAINT historico_pasos_pkey PRIMARY KEY (id);


--
-- Name: infracciones infracciones_codigo_infraccion_key; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.infracciones
    ADD CONSTRAINT infracciones_codigo_infraccion_key UNIQUE (codigo_infraccion);


--
-- Name: infracciones infracciones_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.infracciones
    ADD CONSTRAINT infracciones_pkey PRIMARY KEY (id);


--
-- Name: log_exclusiones log_exclusiones_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.log_exclusiones
    ADD CONSTRAINT log_exclusiones_pkey PRIMARY KEY (id);


--
-- Name: multas multas_numero_multa_key; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.multas
    ADD CONSTRAINT multas_numero_multa_key UNIQUE (numero_multa);


--
-- Name: multas multas_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.multas
    ADD CONSTRAINT multas_pkey PRIMARY KEY (id);


--
-- Name: pasos pasos_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.pasos
    ADD CONSTRAINT pasos_pkey PRIMARY KEY (id);


--
-- Name: estaciones_control peajes_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.estaciones_control
    ADD CONSTRAINT peajes_pkey PRIMARY KEY (id_estacion);


--
-- Name: reinicios_mensuales reinicios_mensuales_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.reinicios_mensuales
    ADD CONSTRAINT reinicios_mensuales_pkey PRIMARY KEY (id);


--
-- Name: turnos turnos_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.turnos
    ADD CONSTRAINT turnos_pkey PRIMARY KEY (id);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: vehiculos_hist vehiculos_hist_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.vehiculos_hist
    ADD CONSTRAINT vehiculos_hist_pkey PRIMARY KEY (id);


--
-- Name: vehiculos vehiculos_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.vehiculos
    ADD CONSTRAINT vehiculos_pkey PRIMARY KEY (id);


--
-- Name: idx_auditoria_tabla; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_auditoria_tabla ON public.auditoria_sistema USING btree (tabla_afectada);


--
-- Name: idx_auditoria_timestamp; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_auditoria_timestamp ON public.auditoria_sistema USING btree (timestamp_operacion);


--
-- Name: idx_auditoria_usuario; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_auditoria_usuario ON public.auditoria_sistema USING btree (usuario_id);


--
-- Name: idx_categoria_activo; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_categoria_activo ON public.categoria_vehiculo USING btree (activo);


--
-- Name: idx_categoria_codigo; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_categoria_codigo ON public.categoria_vehiculo USING btree (codigo_bascam);


--
-- Name: idx_comparendos_agente; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_comparendos_agente ON public.comparendos USING btree (codigo_agente);


--
-- Name: idx_comparendos_estado; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_comparendos_estado ON public.comparendos USING btree (estado_comparendo);


--
-- Name: idx_comparendos_estado_fecha; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_comparendos_estado_fecha ON public.comparendos USING btree (estado_comparendo, fecha_imposicion);


--
-- Name: idx_comparendos_evento; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_comparendos_evento ON public.comparendos USING btree (evento_pesaje_id);


--
-- Name: idx_comparendos_fecha; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_comparendos_fecha ON public.comparendos USING btree (fecha);


--
-- Name: idx_comparendos_placa; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_comparendos_placa ON public.comparendos USING btree (placa);


--
-- Name: idx_comparendos_runt; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_comparendos_runt ON public.comparendos USING btree (runt_numero);


--
-- Name: idx_estaciones_nombre; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_estaciones_nombre ON public.estaciones_control USING btree (nombre_estacion);


--
-- Name: idx_eventos_pesaje_fecha; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_eventos_pesaje_fecha ON public.eventos_pesaje USING btree (fecha_pesaje);


--
-- Name: idx_eventos_pesaje_placa; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_eventos_pesaje_placa ON public.eventos_pesaje USING btree (placa);


--
-- Name: idx_exclusiones_placa; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_exclusiones_placa ON public.exclusiones USING btree (placa);


--
-- Name: idx_historico_pasos_placa; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_historico_pasos_placa ON public.historico_pasos USING btree (placa);


--
-- Name: idx_multas_comparendo; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_multas_comparendo ON public.multas USING btree (comparendo_id);


--
-- Name: idx_multas_estado; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_multas_estado ON public.multas USING btree (estado_pago);


--
-- Name: idx_multas_vencimiento; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_multas_vencimiento ON public.multas USING btree (fecha_vencimiento_descuento);


--
-- Name: idx_pasos_placa; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_pasos_placa ON public.pasos USING btree (placa);


--
-- Name: idx_usuarios_correo; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_usuarios_correo ON public.usuarios USING btree (email);


--
-- Name: idx_usuarios_email; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_usuarios_email ON public.usuarios USING btree (email);


--
-- Name: idx_vehiculos_placa; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_vehiculos_placa ON public.vehiculos USING btree (placa);


--
-- Name: idx_vehiculos_placa_activo; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_vehiculos_placa_activo ON public.vehiculos USING btree (placa, activo) WHERE (activo = true);


--
-- Name: pasos guardar_en_historico; Type: TRIGGER; Schema: public; Owner: comparendos_user
--

CREATE TRIGGER guardar_en_historico AFTER UPDATE ON public.pasos FOR EACH ROW EXECUTE FUNCTION public.guardar_en_historico();


--
-- Name: auditoria_sistema auditoria_sistema_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.auditoria_sistema
    ADD CONSTRAINT auditoria_sistema_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id);


--
-- Name: comparendos comparendos_anulado_por_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.comparendos
    ADD CONSTRAINT comparendos_anulado_por_id_fkey FOREIGN KEY (anulado_por_id) REFERENCES public.usuarios(id);


--
-- Name: comparendos comparendos_categoria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.comparendos
    ADD CONSTRAINT comparendos_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categoria_vehiculo(id);


--
-- Name: comparendos comparendos_categoria_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.comparendos
    ADD CONSTRAINT comparendos_categoria_id_fkey1 FOREIGN KEY (categoria_id) REFERENCES public.categoria_vehiculo(id);


--
-- Name: comparendos comparendos_completado_por_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.comparendos
    ADD CONSTRAINT comparendos_completado_por_id_fkey FOREIGN KEY (completado_por_id) REFERENCES public.usuarios(id);


--
-- Name: comparendos comparendos_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.comparendos
    ADD CONSTRAINT comparendos_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.usuarios(id);


--
-- Name: comparendos comparendos_id_bascula_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.comparendos
    ADD CONSTRAINT comparendos_id_bascula_fkey FOREIGN KEY (id_bascula) REFERENCES public.basculas(id_bascula);


--
-- Name: comparendos comparendos_infraccion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.comparendos
    ADD CONSTRAINT comparendos_infraccion_id_fkey FOREIGN KEY (infraccion_id) REFERENCES public.infracciones(id);


--
-- Name: comparendos comparendos_infraccion_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.comparendos
    ADD CONSTRAINT comparendos_infraccion_id_fkey1 FOREIGN KEY (infraccion_id) REFERENCES public.infracciones(id);


--
-- Name: comparendos comparendos_updated_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.comparendos
    ADD CONSTRAINT comparendos_updated_by_id_fkey FOREIGN KEY (updated_by_id) REFERENCES public.usuarios(id);


--
-- Name: eventos_pesaje eventos_pesaje_categoria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.eventos_pesaje
    ADD CONSTRAINT eventos_pesaje_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categoria_vehiculo(id);


--
-- Name: eventos_pesaje eventos_pesaje_id_bascula_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.eventos_pesaje
    ADD CONSTRAINT eventos_pesaje_id_bascula_fkey FOREIGN KEY (id_bascula) REFERENCES public.basculas(id_bascula);


--
-- Name: eventos_pesaje eventos_pesaje_liberado_por_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.eventos_pesaje
    ADD CONSTRAINT eventos_pesaje_liberado_por_id_fkey FOREIGN KEY (liberado_por_id) REFERENCES public.usuarios(id);


--
-- Name: eventos_pesaje eventos_pesaje_operador_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.eventos_pesaje
    ADD CONSTRAINT eventos_pesaje_operador_id_fkey FOREIGN KEY (operador_id) REFERENCES public.usuarios(id);


--
-- Name: evidencias evidencias_comparendo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.evidencias
    ADD CONSTRAINT evidencias_comparendo_id_fkey FOREIGN KEY (comparendo_id) REFERENCES public.comparendos(id);


--
-- Name: evidencias evidencias_evento_pesaje_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.evidencias
    ADD CONSTRAINT evidencias_evento_pesaje_id_fkey FOREIGN KEY (evento_pesaje_id) REFERENCES public.eventos_pesaje(id);


--
-- Name: evidencias evidencias_tomada_por_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.evidencias
    ADD CONSTRAINT evidencias_tomada_por_id_fkey FOREIGN KEY (tomada_por_id) REFERENCES public.usuarios(id);


--
-- Name: log_exclusiones log_exclusiones_id_exclusion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.log_exclusiones
    ADD CONSTRAINT log_exclusiones_id_exclusion_fkey FOREIGN KEY (id_exclusion) REFERENCES public.exclusiones(id);


--
-- Name: multas multas_comparendo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.multas
    ADD CONSTRAINT multas_comparendo_id_fkey FOREIGN KEY (comparendo_id) REFERENCES public.comparendos(id);


--
-- Name: multas multas_infraccion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.multas
    ADD CONSTRAINT multas_infraccion_id_fkey FOREIGN KEY (infraccion_id) REFERENCES public.infracciones(id);


--
-- Name: turnos turnos_cerrado_por_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.turnos
    ADD CONSTRAINT turnos_cerrado_por_id_fkey FOREIGN KEY (cerrado_por_id) REFERENCES public.usuarios(id);


--
-- Name: turnos turnos_operador_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.turnos
    ADD CONSTRAINT turnos_operador_id_fkey FOREIGN KEY (operador_id) REFERENCES public.usuarios(id);


--
-- Name: usuarios usuarios_estacion_asignada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_estacion_asignada_fkey FOREIGN KEY (estacion_asignada) REFERENCES public.estaciones_control(id_estacion);


--
-- Name: vehiculos vehiculos_categoria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.vehiculos
    ADD CONSTRAINT vehiculos_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categoria_vehiculo(id);


--
-- Name: vehiculos_hist vehiculos_hist_id_vehiculo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.vehiculos_hist
    ADD CONSTRAINT vehiculos_hist_id_vehiculo_fkey FOREIGN KEY (id_vehiculo) REFERENCES public.vehiculos(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: comparendos_user
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--


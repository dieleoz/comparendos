--
-- PostgreSQL database dump
--

-- Dumped from database version 14.17 (Debian 14.17-1.pgdg120+1)
-- Dumped by pg_dump version 17.0

-- Started on 2025-06-04 15:54:26

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3467 (class 1262 OID 17683)
-- Name: vehiculos_especiales; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE vehiculos_especiales WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


-- Cambiar propietario de la base de datos
ALTER DATABASE comparendos_db OWNER TO comparendos_user;

\connect comparendos_db

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 17759)
-- Name: public; Type: SCHEMA; Schema: -; Owner: comparendos_user
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 17761)
-- Name: guardar_en_historico(); Type: FUNCTION; Schema: public; Owner: vehiculos_user
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


ALTER FUNCTION public.guardar_en_historico() OWNER TO vehiculos_user;

--
-- TOC entry 233 (class 1255 OID 17829)
-- Name: limpiar_conteo_registros(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.limpiar_conteo_registros() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM conteo_registros;
END;
$$;


ALTER FUNCTION public.limpiar_conteo_registros() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 230 (class 1259 OID 25850)
-- Name: basculas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.basculas (
    id_bascula integer NOT NULL,
    nombre character varying(50) NOT NULL,
    ubicacion text NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    latitud double precision,
    longitud double precision
);


ALTER TABLE public.basculas OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 25849)
-- Name: basculas_id_bascula_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.basculas_id_bascula_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.basculas_id_bascula_seq OWNER TO postgres;

--
-- TOC entry 3472 (class 0 OID 0)
-- Dependencies: 229
-- Name: basculas_id_bascula_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.basculas_id_bascula_seq OWNED BY public.basculas.id_bascula;


--
-- TOC entry 228 (class 1259 OID 25841)
-- Name: comparendos; Type: TABLE; Schema: public; Owner: vehiculos_user
--

CREATE TABLE public.comparendos (
    id integer NOT NULL,
    fecha date NOT NULL,
    hora time without time zone NOT NULL,
    numero_ticket character varying(20) NOT NULL,
    placa character varying(10) NOT NULL,
    sobre_peso integer,
    numero_comparendo character varying(50) NOT NULL,
    detalle text,
    pk character varying(20),
    latitud double precision,
    longitud double precision,
    id_bascula integer
);


ALTER TABLE public.comparendos OWNER TO vehiculos_user;

--
-- TOC entry 227 (class 1259 OID 25840)
-- Name: comparendos_id_seq; Type: SEQUENCE; Schema: public; Owner: vehiculos_user
--

CREATE SEQUENCE public.comparendos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comparendos_id_seq OWNER TO vehiculos_user;

--
-- TOC entry 3474 (class 0 OID 0)
-- Dependencies: 227
-- Name: comparendos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vehiculos_user
--

ALTER SEQUENCE public.comparendos_id_seq OWNED BY public.comparendos.id;


--
-- TOC entry 209 (class 1259 OID 17762)
-- Name: configuracion_notificaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.configuracion_notificaciones (
    id integer NOT NULL,
    correo_destino text NOT NULL,
    umbral_envio integer DEFAULT 65,
    umbral_bloqueo integer DEFAULT 70
);


ALTER TABLE public.configuracion_notificaciones OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 17769)
-- Name: configuracion_notificaciones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.configuracion_notificaciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.configuracion_notificaciones_id_seq OWNER TO postgres;

--
-- TOC entry 3476 (class 0 OID 0)
-- Dependencies: 210
-- Name: configuracion_notificaciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.configuracion_notificaciones_id_seq OWNED BY public.configuracion_notificaciones.id;


--
-- TOC entry 211 (class 1259 OID 17770)
-- Name: conteo_registros; Type: TABLE; Schema: public; Owner: vehiculos_user
--

CREATE TABLE public.conteo_registros (
    id integer NOT NULL,
    placa character varying(6),
    tipo_servicio character varying(50),
    categoria character varying(50),
    fecha_registro timestamp without time zone DEFAULT now(),
    fecha_base character varying(50),
    hora_evento character varying(50)
);


ALTER TABLE public.conteo_registros OWNER TO vehiculos_user;

--
-- TOC entry 212 (class 1259 OID 17774)
-- Name: conteo_registros_id_seq; Type: SEQUENCE; Schema: public; Owner: vehiculos_user
--

CREATE SEQUENCE public.conteo_registros_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.conteo_registros_id_seq OWNER TO vehiculos_user;

--
-- TOC entry 3478 (class 0 OID 0)
-- Dependencies: 212
-- Name: conteo_registros_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vehiculos_user
--

ALTER SEQUENCE public.conteo_registros_id_seq OWNED BY public.conteo_registros.id;


--
-- TOC entry 226 (class 1259 OID 25824)
-- Name: exclusiones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exclusiones (
    id integer NOT NULL,
    id_peaje integer,
    placa character varying(6),
    motivo text,
    fecha_exclusion timestamp without time zone DEFAULT now(),
    activo boolean DEFAULT true
);


ALTER TABLE public.exclusiones OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 25823)
-- Name: exclusiones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.exclusiones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exclusiones_id_seq OWNER TO postgres;

--
-- TOC entry 3480 (class 0 OID 0)
-- Dependencies: 225
-- Name: exclusiones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.exclusiones_id_seq OWNED BY public.exclusiones.id;


--
-- TOC entry 213 (class 1259 OID 17775)
-- Name: historico_pasos; Type: TABLE; Schema: public; Owner: vehiculos_user
--

CREATE TABLE public.historico_pasos (
    id integer NOT NULL,
    placa character varying(6),
    codigo_tarjeta character varying(50),
    consecutivo_tarjeta character varying(50),
    marca_vehiculo character varying(50),
    usuario character varying(100),
    color_vehiculo character varying(30),
    categoria_vehiculo character varying(50),
    conteo_pasos integer,
    activo boolean,
    fecha_registro timestamp without time zone DEFAULT now()
);


ALTER TABLE public.historico_pasos OWNER TO vehiculos_user;

--
-- TOC entry 214 (class 1259 OID 17779)
-- Name: historico_pasos_id_seq; Type: SEQUENCE; Schema: public; Owner: vehiculos_user
--

CREATE SEQUENCE public.historico_pasos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.historico_pasos_id_seq OWNER TO vehiculos_user;

--
-- TOC entry 3482 (class 0 OID 0)
-- Dependencies: 214
-- Name: historico_pasos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vehiculos_user
--

ALTER SEQUENCE public.historico_pasos_id_seq OWNED BY public.historico_pasos.id;


--
-- TOC entry 232 (class 1259 OID 25928)
-- Name: log_exclusiones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log_exclusiones (
    id integer NOT NULL,
    placa character varying(6) NOT NULL,
    mes integer NOT NULL,
    anio integer NOT NULL,
    regla_violada text NOT NULL,
    accion character varying(20) NOT NULL,
    usuario character varying(100) NOT NULL,
    fecha timestamp without time zone DEFAULT now(),
    id_peaje integer NOT NULL,
    observaciones text
);


ALTER TABLE public.log_exclusiones OWNER TO postgres;

--
-- TOC entry 3483 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE log_exclusiones; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.log_exclusiones IS 'Registro de trazabilidad de todas las exclusiones automáticas y manuales';


--
-- TOC entry 3484 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN log_exclusiones.regla_violada; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.log_exclusiones.regla_violada IS 'Descripción de la regla que causó la exclusión';


--
-- TOC entry 3485 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN log_exclusiones.accion; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.log_exclusiones.accion IS 'Tipo de acción: AUTOMATICA, MANUAL, REVERSION';


--
-- TOC entry 231 (class 1259 OID 25927)
-- Name: log_exclusiones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_exclusiones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.log_exclusiones_id_seq OWNER TO postgres;

--
-- TOC entry 3487 (class 0 OID 0)
-- Dependencies: 231
-- Name: log_exclusiones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_exclusiones_id_seq OWNED BY public.log_exclusiones.id;


--
-- TOC entry 215 (class 1259 OID 17780)
-- Name: pasos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pasos (
    id integer NOT NULL,
    placa character varying(6),
    fecha_hora timestamp without time zone DEFAULT now(),
    id_peaje integer NOT NULL,
    fecha_paso timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.pasos OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 17784)
-- Name: pasos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pasos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pasos_id_seq OWNER TO postgres;

--
-- TOC entry 3489 (class 0 OID 0)
-- Dependencies: 216
-- Name: pasos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pasos_id_seq OWNED BY public.pasos.id;


--
-- TOC entry 224 (class 1259 OID 25812)
-- Name: peajes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.peajes (
    id_peaje integer NOT NULL,
    nombre_peaje character varying(100) NOT NULL,
    ubicacion character varying(150),
    activo boolean DEFAULT true
);


ALTER TABLE public.peajes OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 25811)
-- Name: peajes_id_peaje_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.peajes_id_peaje_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.peajes_id_peaje_seq OWNER TO postgres;

--
-- TOC entry 3492 (class 0 OID 0)
-- Dependencies: 223
-- Name: peajes_id_peaje_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.peajes_id_peaje_seq OWNED BY public.peajes.id_peaje;


--
-- TOC entry 222 (class 1259 OID 17959)
-- Name: reinicios_mensuales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reinicios_mensuales (
    id integer NOT NULL,
    usuario text NOT NULL,
    fecha timestamp without time zone DEFAULT now(),
    observaciones text,
    mes integer NOT NULL,
    anio integer NOT NULL,
    id_peaje integer NOT NULL
);


ALTER TABLE public.reinicios_mensuales OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 17958)
-- Name: reinicios_mensuales_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reinicios_mensuales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reinicios_mensuales_id_seq OWNER TO postgres;

--
-- TOC entry 3495 (class 0 OID 0)
-- Dependencies: 221
-- Name: reinicios_mensuales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reinicios_mensuales_id_seq OWNED BY public.reinicios_mensuales.id;


--
-- TOC entry 217 (class 1259 OID 17785)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: vehiculos_user
--

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    nombre character varying(100),
    email character varying(100) NOT NULL,
    password_hash text NOT NULL,
    rol integer NOT NULL,
    CONSTRAINT usuarios_rol_check CHECK ((rol = ANY (ARRAY[1, 2, 3, 4])))
);


ALTER TABLE public.usuarios OWNER TO vehiculos_user;

--
-- TOC entry 218 (class 1259 OID 17791)
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: vehiculos_user
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_id_seq OWNER TO vehiculos_user;

--
-- TOC entry 3497 (class 0 OID 0)
-- Dependencies: 218
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vehiculos_user
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- TOC entry 219 (class 1259 OID 17792)
-- Name: vehiculos; Type: TABLE; Schema: public; Owner: vehiculos_user
--

CREATE TABLE public.vehiculos (
    placa character varying(6) NOT NULL,
    codigo_tarjeta character varying(50),
    consecutivo_tarjeta character varying(50),
    marca_vehiculo character varying(50),
    usuario character varying(100),
    color_vehiculo character varying(30),
    categoria_vehiculo character varying(50),
    activo boolean DEFAULT true,
    conteo_pasos integer DEFAULT 0,
    tipo_servicio character varying(50),
    id_peaje integer NOT NULL,
    beneficio_activo boolean DEFAULT true,
    fecha_exclusion timestamp without time zone,
    motivo_exclusion text
);


ALTER TABLE public.vehiculos OWNER TO vehiculos_user;

--
-- TOC entry 3498 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN vehiculos.fecha_exclusion; Type: COMMENT; Schema: public; Owner: vehiculos_user
--

COMMENT ON COLUMN public.vehiculos.fecha_exclusion IS 'Fecha cuando se excluyó el vehículo del beneficio';


--
-- TOC entry 3499 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN vehiculos.motivo_exclusion; Type: COMMENT; Schema: public; Owner: vehiculos_user
--

COMMENT ON COLUMN public.vehiculos.motivo_exclusion IS 'Motivo de la exclusión del beneficio';


--
-- TOC entry 220 (class 1259 OID 17937)
-- Name: vehiculos_hist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehiculos_hist (
    placa character varying(6) NOT NULL,
    codigo_tarjeta character varying(50),
    consecutivo_tarjeta character varying(50),
    marca_vehiculo character varying(50),
    usuario character varying(100),
    color_vehiculo character varying(30),
    categoria_vehiculo character varying(50),
    activo boolean DEFAULT true,
    conteo_pasos integer DEFAULT 0,
    tipo_servicio character varying(50),
    mes integer,
    anio integer,
    fecha_base character varying(50),
    hora_evento time without time zone,
    fecha_registro timestamp without time zone DEFAULT now(),
    id_peaje integer
);


ALTER TABLE public.vehiculos_hist OWNER TO postgres;

--
-- TOC entry 3500 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN vehiculos_hist.mes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.vehiculos_hist.mes IS 'mes del 1 al 12 en numeros';


--
-- TOC entry 3276 (class 2604 OID 25853)
-- Name: basculas id_bascula; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basculas ALTER COLUMN id_bascula SET DEFAULT nextval('public.basculas_id_bascula_seq'::regclass);


--
-- TOC entry 3275 (class 2604 OID 25844)
-- Name: comparendos id; Type: DEFAULT; Schema: public; Owner: vehiculos_user
--

ALTER TABLE ONLY public.comparendos ALTER COLUMN id SET DEFAULT nextval('public.comparendos_id_seq'::regclass);


--
-- TOC entry 3251 (class 2604 OID 17797)
-- Name: configuracion_notificaciones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.configuracion_notificaciones ALTER COLUMN id SET DEFAULT nextval('public.configuracion_notificaciones_id_seq'::regclass);


--
-- TOC entry 3254 (class 2604 OID 17798)
-- Name: conteo_registros id; Type: DEFAULT; Schema: public; Owner: vehiculos_user
--

ALTER TABLE ONLY public.conteo_registros ALTER COLUMN id SET DEFAULT nextval('public.conteo_registros_id_seq'::regclass);


--
-- TOC entry 3272 (class 2604 OID 25827)
-- Name: exclusiones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exclusiones ALTER COLUMN id SET DEFAULT nextval('public.exclusiones_id_seq'::regclass);


--
-- TOC entry 3256 (class 2604 OID 17799)
-- Name: historico_pasos id; Type: DEFAULT; Schema: public; Owner: vehiculos_user
--

ALTER TABLE ONLY public.historico_pasos ALTER COLUMN id SET DEFAULT nextval('public.historico_pasos_id_seq'::regclass);


--
-- TOC entry 3278 (class 2604 OID 25931)
-- Name: log_exclusiones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_exclusiones ALTER COLUMN id SET DEFAULT nextval('public.log_exclusiones_id_seq'::regclass);


--
-- TOC entry 3258 (class 2604 OID 17800)
-- Name: pasos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pasos ALTER COLUMN id SET DEFAULT nextval('public.pasos_id_seq'::regclass);


--
-- TOC entry 3270 (class 2604 OID 25815)
-- Name: peajes id_peaje; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.peajes ALTER COLUMN id_peaje SET DEFAULT nextval('public.peajes_id_peaje_seq'::regclass);


--
-- TOC entry 3268 (class 2604 OID 17962)
-- Name: reinicios_mensuales id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reinicios_mensuales ALTER COLUMN id SET DEFAULT nextval('public.reinicios_mensuales_id_seq'::regclass);


--
-- TOC entry 3261 (class 2604 OID 17801)
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: vehiculos_user
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- TOC entry 3311 (class 2606 OID 25858)
-- Name: basculas basculas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basculas
    ADD CONSTRAINT basculas_pkey PRIMARY KEY (id_bascula);


--
-- TOC entry 3306 (class 2606 OID 25848)
-- Name: comparendos comparendos_pkey; Type: CONSTRAINT; Schema: public; Owner: vehiculos_user
--

ALTER TABLE ONLY public.comparendos
    ADD CONSTRAINT comparendos_pkey PRIMARY KEY (id);


--
-- TOC entry 3282 (class 2606 OID 17803)
-- Name: configuracion_notificaciones configuracion_notificaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.configuracion_notificaciones
    ADD CONSTRAINT configuracion_notificaciones_pkey PRIMARY KEY (id);


--
-- TOC entry 3284 (class 2606 OID 17805)
-- Name: conteo_registros conteo_registros_pkey; Type: CONSTRAINT; Schema: public; Owner: vehiculos_user
--

ALTER TABLE ONLY public.conteo_registros
    ADD CONSTRAINT conteo_registros_pkey PRIMARY KEY (id);


--
-- TOC entry 3303 (class 2606 OID 25832)
-- Name: exclusiones exclusiones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exclusiones
    ADD CONSTRAINT exclusiones_pkey PRIMARY KEY (id);


--
-- TOC entry 3286 (class 2606 OID 17807)
-- Name: historico_pasos historico_pasos_pkey; Type: CONSTRAINT; Schema: public; Owner: vehiculos_user
--

ALTER TABLE ONLY public.historico_pasos
    ADD CONSTRAINT historico_pasos_pkey PRIMARY KEY (id);


--
-- TOC entry 3316 (class 2606 OID 25936)
-- Name: log_exclusiones log_exclusiones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_exclusiones
    ADD CONSTRAINT log_exclusiones_pkey PRIMARY KEY (id);


--
-- TOC entry 3288 (class 2606 OID 17809)
-- Name: pasos pasos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pasos
    ADD CONSTRAINT pasos_pkey PRIMARY KEY (id);


--
-- TOC entry 3301 (class 2606 OID 25818)
-- Name: peajes peajes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.peajes
    ADD CONSTRAINT peajes_pkey PRIMARY KEY (id_peaje);


--
-- TOC entry 3297 (class 2606 OID 17967)
-- Name: reinicios_mensuales reinicios_mensuales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reinicios_mensuales
    ADD CONSTRAINT reinicios_mensuales_pkey PRIMARY KEY (id);


--
-- TOC entry 3299 (class 2606 OID 25924)
-- Name: reinicios_mensuales unique_reinicio_mes_peaje; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reinicios_mensuales
    ADD CONSTRAINT unique_reinicio_mes_peaje UNIQUE (mes, anio, id_peaje);


--
-- TOC entry 3290 (class 2606 OID 17811)
-- Name: usuarios usuarios_email_key; Type: CONSTRAINT; Schema: public; Owner: vehiculos_user
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_email_key UNIQUE (email);


--
-- TOC entry 3292 (class 2606 OID 17813)
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: vehiculos_user
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- TOC entry 3295 (class 2606 OID 25877)
-- Name: vehiculos vehiculos_pk; Type: CONSTRAINT; Schema: public; Owner: vehiculos_user
--

ALTER TABLE ONLY public.vehiculos
    ADD CONSTRAINT vehiculos_pk PRIMARY KEY (placa, id_peaje);


--
-- TOC entry 3307 (class 1259 OID 25916)
-- Name: idx_comparendos_fecha; Type: INDEX; Schema: public; Owner: vehiculos_user
--

CREATE INDEX idx_comparendos_fecha ON public.comparendos USING btree (fecha);


--
-- TOC entry 3308 (class 1259 OID 25917)
-- Name: idx_comparendos_id_bascula; Type: INDEX; Schema: public; Owner: vehiculos_user
--

CREATE INDEX idx_comparendos_id_bascula ON public.comparendos USING btree (id_bascula);


--
-- TOC entry 3309 (class 1259 OID 25915)
-- Name: idx_comparendos_placa; Type: INDEX; Schema: public; Owner: vehiculos_user
--

CREATE INDEX idx_comparendos_placa ON public.comparendos USING btree (placa);


--
-- TOC entry 3304 (class 1259 OID 25865)
-- Name: idx_exclusiones_placa_peaje; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_exclusiones_placa_peaje ON public.exclusiones USING btree (placa, id_peaje);


--
-- TOC entry 3312 (class 1259 OID 25949)
-- Name: idx_log_exclusiones_accion; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_log_exclusiones_accion ON public.log_exclusiones USING btree (accion);


--
-- TOC entry 3313 (class 1259 OID 25948)
-- Name: idx_log_exclusiones_fecha; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_log_exclusiones_fecha ON public.log_exclusiones USING btree (fecha);


--
-- TOC entry 3314 (class 1259 OID 25947)
-- Name: idx_log_exclusiones_placa_peaje; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_log_exclusiones_placa_peaje ON public.log_exclusiones USING btree (placa, id_peaje);


--
-- TOC entry 3293 (class 1259 OID 25837)
-- Name: idx_vehiculos_placa_peaje; Type: INDEX; Schema: public; Owner: vehiculos_user
--

CREATE UNIQUE INDEX idx_vehiculos_placa_peaje ON public.vehiculos USING btree (placa, id_peaje);


--
-- TOC entry 3322 (class 2620 OID 25761)
-- Name: vehiculos trigger_guardar_pasos_historico; Type: TRIGGER; Schema: public; Owner: vehiculos_user
--

CREATE TRIGGER trigger_guardar_pasos_historico BEFORE UPDATE OF conteo_pasos ON public.vehiculos FOR EACH ROW WHEN (((old.conteo_pasos IS DISTINCT FROM new.conteo_pasos) AND (old.conteo_pasos > 0))) EXECUTE FUNCTION public.guardar_en_historico();


--
-- TOC entry 3319 (class 2606 OID 25859)
-- Name: comparendos fk_bascula; Type: FK CONSTRAINT; Schema: public; Owner: vehiculos_user
--

ALTER TABLE ONLY public.comparendos
    ADD CONSTRAINT fk_bascula FOREIGN KEY (id_bascula) REFERENCES public.basculas(id_bascula);


--
-- TOC entry 3320 (class 2606 OID 25937)
-- Name: log_exclusiones fk_log_exclusiones_peaje; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_exclusiones
    ADD CONSTRAINT fk_log_exclusiones_peaje FOREIGN KEY (id_peaje) REFERENCES public.peajes(id_peaje);


--
-- TOC entry 3321 (class 2606 OID 25942)
-- Name: log_exclusiones fk_log_exclusiones_vehiculo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_exclusiones
    ADD CONSTRAINT fk_log_exclusiones_vehiculo FOREIGN KEY (placa, id_peaje) REFERENCES public.vehiculos(placa, id_peaje);


--
-- TOC entry 3318 (class 2606 OID 25918)
-- Name: reinicios_mensuales fk_reinicios_peaje; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reinicios_mensuales
    ADD CONSTRAINT fk_reinicios_peaje FOREIGN KEY (id_peaje) REFERENCES public.peajes(id_peaje);


--
-- TOC entry 3317 (class 2606 OID 25883)
-- Name: pasos pasos_vehiculo_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pasos
    ADD CONSTRAINT pasos_vehiculo_fk FOREIGN KEY (placa, id_peaje) REFERENCES public.vehiculos(placa, id_peaje) ON DELETE CASCADE;


--
-- TOC entry 3468 (class 0 OID 0)
-- Dependencies: 3467
-- Name: DATABASE vehiculos_especiales; Type: ACL; Schema: -; Owner: postgres
--

GRANT CONNECT ON DATABASE vehiculos_especiales TO vehiculos_user;


--
-- TOC entry 3469 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO vehiculos_user;


--
-- TOC entry 3470 (class 0 OID 0)
-- Dependencies: 233
-- Name: FUNCTION limpiar_conteo_registros(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.limpiar_conteo_registros() TO vehiculos_user;


--
-- TOC entry 3471 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE basculas; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.basculas TO vehiculos_user;


--
-- TOC entry 3473 (class 0 OID 0)
-- Dependencies: 229
-- Name: SEQUENCE basculas_id_bascula_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.basculas_id_bascula_seq TO vehiculos_user;


--
-- TOC entry 3475 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE configuracion_notificaciones; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.configuracion_notificaciones TO vehiculos_user;


--
-- TOC entry 3477 (class 0 OID 0)
-- Dependencies: 210
-- Name: SEQUENCE configuracion_notificaciones_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.configuracion_notificaciones_id_seq TO vehiculos_user;


--
-- TOC entry 3479 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE exclusiones; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.exclusiones TO vehiculos_user;


--
-- TOC entry 3481 (class 0 OID 0)
-- Dependencies: 225
-- Name: SEQUENCE exclusiones_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.exclusiones_id_seq TO vehiculos_user;


--
-- TOC entry 3486 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE log_exclusiones; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.log_exclusiones TO vehiculos_user;


--
-- TOC entry 3488 (class 0 OID 0)
-- Dependencies: 215
-- Name: TABLE pasos; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.pasos TO vehiculos_user;


--
-- TOC entry 3490 (class 0 OID 0)
-- Dependencies: 216
-- Name: SEQUENCE pasos_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.pasos_id_seq TO vehiculos_user;


--
-- TOC entry 3491 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE peajes; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.peajes TO vehiculos_user;


--
-- TOC entry 3493 (class 0 OID 0)
-- Dependencies: 223
-- Name: SEQUENCE peajes_id_peaje_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.peajes_id_peaje_seq TO vehiculos_user;


--
-- TOC entry 3494 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE reinicios_mensuales; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.reinicios_mensuales TO vehiculos_user;


--
-- TOC entry 3496 (class 0 OID 0)
-- Dependencies: 221
-- Name: SEQUENCE reinicios_mensuales_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.reinicios_mensuales_id_seq TO vehiculos_user;


--
-- TOC entry 3501 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE vehiculos_hist; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vehiculos_hist TO vehiculos_user;


--
-- TOC entry 2085 (class 826 OID 17760)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO vehiculos_user;


-- Completed on 2025-06-04 15:54:27

--
-- PostgreSQL database dump complete
--


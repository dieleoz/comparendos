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
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: comparendos_user
--

COMMENT ON SCHEMA public IS '';


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
-- Name: basculas; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.basculas (
    id_bascula integer NOT NULL,
    nombre character varying(50) NOT NULL,
    ubicacion text NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    latitud double precision,
    longitud double precision
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
-- Name: basculas_id_bascula_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: comparendos_user
--

ALTER SEQUENCE public.basculas_id_bascula_seq OWNED BY public.basculas.id_bascula;


--
-- Name: comparendos; Type: TABLE; Schema: public; Owner: comparendos_user
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
-- Name: peajes; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.peajes (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    ubicacion text NOT NULL,
    activo boolean DEFAULT true,
    latitud double precision,
    longitud double precision
);


ALTER TABLE public.peajes OWNER TO comparendos_user;

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

ALTER SEQUENCE public.peajes_id_seq OWNED BY public.peajes.id;


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
-- Name: usuarios; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    correo character varying(100) NOT NULL,
    password text NOT NULL,
    rol character varying(50) NOT NULL,
    activo boolean DEFAULT true
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
-- Name: vehiculos; Type: TABLE; Schema: public; Owner: comparendos_user
--

CREATE TABLE public.vehiculos (
    id integer NOT NULL,
    placa character varying(10) NOT NULL,
    marca character varying(100) NOT NULL,
    modelo character varying(50),
    color character varying(50),
    categoria character varying(50),
    activo boolean DEFAULT true
);


ALTER TABLE public.vehiculos OWNER TO comparendos_user;

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
-- Name: basculas id_bascula; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.basculas ALTER COLUMN id_bascula SET DEFAULT nextval('public.basculas_id_bascula_seq'::regclass);


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
-- Name: exclusiones id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.exclusiones ALTER COLUMN id SET DEFAULT nextval('public.exclusiones_id_seq'::regclass);


--
-- Name: historico_pasos id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.historico_pasos ALTER COLUMN id SET DEFAULT nextval('public.historico_pasos_id_seq'::regclass);


--
-- Name: log_exclusiones id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.log_exclusiones ALTER COLUMN id SET DEFAULT nextval('public.log_exclusiones_id_seq'::regclass);


--
-- Name: pasos id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.pasos ALTER COLUMN id SET DEFAULT nextval('public.pasos_id_seq'::regclass);


--
-- Name: peajes id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.peajes ALTER COLUMN id SET DEFAULT nextval('public.peajes_id_seq'::regclass);


--
-- Name: reinicios_mensuales id; Type: DEFAULT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.reinicios_mensuales ALTER COLUMN id SET DEFAULT nextval('public.reinicios_mensuales_id_seq'::regclass);


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
-- Data for Name: basculas; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.basculas (id_bascula, nombre, ubicacion, activo, latitud, longitud) FROM stdin;
\.


--
-- Data for Name: comparendos; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.comparendos (id, fecha, hora, numero_ticket, placa, sobre_peso, numero_comparendo, detalle, pk, latitud, longitud, id_bascula) FROM stdin;
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
-- Data for Name: log_exclusiones; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.log_exclusiones (id, id_exclusion, fecha_accion, accion, usuario) FROM stdin;
\.


--
-- Data for Name: pasos; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.pasos (id, placa, conteo_pasos, codigo_tarjeta, consecutivo_tarjeta, marca_vehiculo, usuario, color_vehiculo, categoria_vehiculo, activo, fecha_creacion) FROM stdin;
\.


--
-- Data for Name: peajes; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.peajes (id, nombre, ubicacion, activo, latitud, longitud) FROM stdin;
\.


--
-- Data for Name: reinicios_mensuales; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.reinicios_mensuales (id, fecha_reinicio, conteo_anterior, conteo_actual) FROM stdin;
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.usuarios (id, nombre, correo, password, rol, activo) FROM stdin;
\.


--
-- Data for Name: vehiculos; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.vehiculos (id, placa, marca, modelo, color, categoria, activo) FROM stdin;
\.


--
-- Data for Name: vehiculos_hist; Type: TABLE DATA; Schema: public; Owner: comparendos_user
--

COPY public.vehiculos_hist (id, id_vehiculo, placa, marca, modelo, color, categoria, activo, fecha_modificacion) FROM stdin;
\.


--
-- Name: basculas_id_bascula_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.basculas_id_bascula_seq', 1, false);


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
-- Name: exclusiones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.exclusiones_id_seq', 1, false);


--
-- Name: historico_pasos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.historico_pasos_id_seq', 1, false);


--
-- Name: log_exclusiones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.log_exclusiones_id_seq', 1, false);


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
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 1, false);


--
-- Name: vehiculos_hist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.vehiculos_hist_id_seq', 1, false);


--
-- Name: vehiculos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: comparendos_user
--

SELECT pg_catalog.setval('public.vehiculos_id_seq', 1, false);


--
-- Name: basculas basculas_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.basculas
    ADD CONSTRAINT basculas_pkey PRIMARY KEY (id_bascula);


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
-- Name: log_exclusiones log_exclusiones_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.log_exclusiones
    ADD CONSTRAINT log_exclusiones_pkey PRIMARY KEY (id);


--
-- Name: pasos pasos_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.pasos
    ADD CONSTRAINT pasos_pkey PRIMARY KEY (id);


--
-- Name: peajes peajes_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.peajes
    ADD CONSTRAINT peajes_pkey PRIMARY KEY (id);


--
-- Name: reinicios_mensuales reinicios_mensuales_pkey; Type: CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.reinicios_mensuales
    ADD CONSTRAINT reinicios_mensuales_pkey PRIMARY KEY (id);


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
-- Name: idx_comparendos_fecha; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_comparendos_fecha ON public.comparendos USING btree (fecha);


--
-- Name: idx_comparendos_placa; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_comparendos_placa ON public.comparendos USING btree (placa);


--
-- Name: idx_exclusiones_placa; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_exclusiones_placa ON public.exclusiones USING btree (placa);


--
-- Name: idx_historico_pasos_placa; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_historico_pasos_placa ON public.historico_pasos USING btree (placa);


--
-- Name: idx_pasos_placa; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_pasos_placa ON public.pasos USING btree (placa);


--
-- Name: idx_usuarios_correo; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_usuarios_correo ON public.usuarios USING btree (correo);


--
-- Name: idx_vehiculos_placa; Type: INDEX; Schema: public; Owner: comparendos_user
--

CREATE INDEX idx_vehiculos_placa ON public.vehiculos USING btree (placa);


--
-- Name: pasos guardar_en_historico; Type: TRIGGER; Schema: public; Owner: comparendos_user
--

CREATE TRIGGER guardar_en_historico AFTER UPDATE ON public.pasos FOR EACH ROW EXECUTE FUNCTION public.guardar_en_historico();


--
-- Name: comparendos comparendos_id_bascula_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.comparendos
    ADD CONSTRAINT comparendos_id_bascula_fkey FOREIGN KEY (id_bascula) REFERENCES public.basculas(id_bascula);


--
-- Name: log_exclusiones log_exclusiones_id_exclusion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: comparendos_user
--

ALTER TABLE ONLY public.log_exclusiones
    ADD CONSTRAINT log_exclusiones_id_exclusion_fkey FOREIGN KEY (id_exclusion) REFERENCES public.exclusiones(id);


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
-- Name: FUNCTION guardar_en_historico(); Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON FUNCTION public.guardar_en_historico() TO vehiculos_user;


--
-- Name: FUNCTION limpiar_conteo_registros(); Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON FUNCTION public.limpiar_conteo_registros() TO vehiculos_user;


--
-- Name: TABLE basculas; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON TABLE public.basculas TO vehiculos_user;


--
-- Name: SEQUENCE basculas_id_bascula_seq; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON SEQUENCE public.basculas_id_bascula_seq TO vehiculos_user;


--
-- Name: TABLE comparendos; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON TABLE public.comparendos TO vehiculos_user;


--
-- Name: SEQUENCE comparendos_id_seq; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON SEQUENCE public.comparendos_id_seq TO vehiculos_user;


--
-- Name: TABLE configuracion_notificaciones; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON TABLE public.configuracion_notificaciones TO vehiculos_user;


--
-- Name: SEQUENCE configuracion_notificaciones_id_seq; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON SEQUENCE public.configuracion_notificaciones_id_seq TO vehiculos_user;


--
-- Name: TABLE conteo_registros; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON TABLE public.conteo_registros TO vehiculos_user;


--
-- Name: SEQUENCE conteo_registros_id_seq; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON SEQUENCE public.conteo_registros_id_seq TO vehiculos_user;


--
-- Name: TABLE exclusiones; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON TABLE public.exclusiones TO vehiculos_user;


--
-- Name: SEQUENCE exclusiones_id_seq; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON SEQUENCE public.exclusiones_id_seq TO vehiculos_user;


--
-- Name: TABLE historico_pasos; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON TABLE public.historico_pasos TO vehiculos_user;


--
-- Name: SEQUENCE historico_pasos_id_seq; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON SEQUENCE public.historico_pasos_id_seq TO vehiculos_user;


--
-- Name: TABLE log_exclusiones; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON TABLE public.log_exclusiones TO vehiculos_user;


--
-- Name: SEQUENCE log_exclusiones_id_seq; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON SEQUENCE public.log_exclusiones_id_seq TO vehiculos_user;


--
-- Name: TABLE pasos; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON TABLE public.pasos TO vehiculos_user;


--
-- Name: SEQUENCE pasos_id_seq; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON SEQUENCE public.pasos_id_seq TO vehiculos_user;


--
-- Name: TABLE peajes; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON TABLE public.peajes TO vehiculos_user;


--
-- Name: SEQUENCE peajes_id_seq; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON SEQUENCE public.peajes_id_seq TO vehiculos_user;


--
-- Name: TABLE reinicios_mensuales; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON TABLE public.reinicios_mensuales TO vehiculos_user;


--
-- Name: SEQUENCE reinicios_mensuales_id_seq; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON SEQUENCE public.reinicios_mensuales_id_seq TO vehiculos_user;


--
-- Name: TABLE usuarios; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON TABLE public.usuarios TO vehiculos_user;


--
-- Name: SEQUENCE usuarios_id_seq; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON SEQUENCE public.usuarios_id_seq TO vehiculos_user;


--
-- Name: TABLE vehiculos; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON TABLE public.vehiculos TO vehiculos_user;


--
-- Name: TABLE vehiculos_hist; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON TABLE public.vehiculos_hist TO vehiculos_user;


--
-- Name: SEQUENCE vehiculos_hist_id_seq; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON SEQUENCE public.vehiculos_hist_id_seq TO vehiculos_user;


--
-- Name: SEQUENCE vehiculos_id_seq; Type: ACL; Schema: public; Owner: comparendos_user
--

GRANT ALL ON SEQUENCE public.vehiculos_id_seq TO vehiculos_user;


--
-- PostgreSQL database dump complete
--


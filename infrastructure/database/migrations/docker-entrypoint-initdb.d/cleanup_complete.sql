-- Eliminar roles y permisos
DROP ROLE IF EXISTS comparendos_user;
DROP ROLE IF EXISTS vehiculos_user;

-- Eliminar todas las tablas y secuencias
DROP SCHEMA IF EXISTS public CASCADE;

-- Crear schema
CREATE SCHEMA public;

-- Crear roles
CREATE ROLE comparendos_user LOGIN PASSWORD 'comparendos_pass';
CREATE ROLE vehiculos_user LOGIN PASSWORD 'vehiculos_pass';

-- Asegurar que el schema public tiene el propietario correcto
ALTER SCHEMA public OWNER TO comparendos_user;

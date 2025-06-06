-- Ajustar roles y permisos
CREATE ROLE IF NOT EXISTS vehiculos_user;
GRANT ALL PRIVILEGES ON DATABASE comparendos_db TO vehiculos_user;

-- Ajustar la tabla comparendos
ALTER TABLE comparendos
ADD COLUMN IF NOT EXISTS id_bascula INTEGER,
ADD CONSTRAINT IF NOT EXISTS fk_comparendos_basculas
FOREIGN KEY (id_bascula) REFERENCES basculas(id);

-- Ajustar permisos en todas las tablas
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO vehiculos_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO vehiculos_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO vehiculos_user;

-- Ajustar permisos específicos
GRANT SELECT, INSERT, UPDATE, DELETE ON comparendos TO vehiculos_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON basculas TO vehiculos_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON vehiculos TO vehiculos_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON pasos TO vehiculos_user;

-- Ajustar permisos en las secuencias
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO vehiculos_user;

-- Ajustar permisos en las funciones
GRANT EXECUTE ON FUNCTION guardar_en_historico() TO vehiculos_user;
GRANT EXECUTE ON FUNCTION limpiar_conteo_registros() TO vehiculos_user;

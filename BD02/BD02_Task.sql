-- =====================================================================
-- TAREA BD02 - Base de datos de un gimnasio (MySQL 8.0)
-- =====================================================================


-- =====================================================================
-- EJERCICIO 1
-- =====================================================================

DROP DATABASE IF EXISTS gym;
CREATE DATABASE gym;
USE gym;

-- ---------------------------------------------------------------------
-- Tabla CLIENT
-- ---------------------------------------------------------------------
CREATE TABLE CLIENT (
    client_id         INT AUTO_INCREMENT,
    first_name        VARCHAR(50)  NOT NULL,
    last_name         VARCHAR(50)  NOT NULL,
    registration_date DATE         NOT NULL,
    email             VARCHAR(100) NOT NULL,
    phone_number      VARCHAR(15)  NOT NULL,
    CONSTRAINT pk_client PRIMARY KEY (client_id),        -- b.1 identificador unico
    CONSTRAINT uq_client_email UNIQUE (email)            -- b.4 email no repetido
);

-- ---------------------------------------------------------------------
-- Tabla EQUIPMENT
-- ---------------------------------------------------------------------
CREATE TABLE EQUIPMENT (
    equipment_id INT AUTO_INCREMENT,
    name         VARCHAR(50) NOT NULL,
    brand        VARCHAR(50) NOT NULL,
    category     VARCHAR(20) NOT NULL,
    availability BOOLEAN     NOT NULL DEFAULT TRUE,              -- b.7 por defecto TRUE
    quantity     INT         NOT NULL,
    CONSTRAINT pk_equipment PRIMARY KEY (equipment_id),          -- b.1 identificador unico
    CONSTRAINT ck_equipment_quantity CHECK (quantity > 0),       -- b.5 cantidad > 0
    CONSTRAINT ck_equipment_category
        CHECK (category IN ('Free Weight', 'Cardio', 'Strength')) -- b.6 valores permitidos
);

-- ---------------------------------------------------------------------
-- Tabla RENT
-- ---------------------------------------------------------------------
CREATE TABLE RENT (
    rent_id      INT AUTO_INCREMENT,
    client_id    INT      NOT NULL,
    equipment_id INT      NOT NULL,
    start_date   DATETIME NOT NULL,
    end_date     DATETIME NULL,                                  -- b.8 unico campo opcional
    CONSTRAINT pk_rent PRIMARY KEY (rent_id),                    -- b.1 identificador unico
    CONSTRAINT fk_rent_client FOREIGN KEY (client_id)
        REFERENCES CLIENT (client_id),                           -- b.2 referencia a CLIENT
    CONSTRAINT fk_rent_equipment FOREIGN KEY (equipment_id)
        REFERENCES EQUIPMENT (equipment_id)                      -- b.3 referencia a EQUIPMENT
);


-- =====================================================================
-- EJERCICIO 2
-- =====================================================================

-- 1. Campo tier con dominio Free, Normal y Premium
ALTER TABLE EQUIPMENT
    ADD COLUMN tier VARCHAR(10) NOT NULL DEFAULT 'Free',
    ADD CONSTRAINT ck_equipment_tier CHECK (tier IN ('Free', 'Normal', 'Premium'));

-- 2. La cantidad debe ser mayor o igual que 3
ALTER TABLE EQUIPMENT
    ADD CONSTRAINT ck_equipment_quantity_min CHECK (quantity >= 3);

-- 3. La fecha de registro debe ser posterior al 13 de marzo de 2026
ALTER TABLE CLIENT
    ADD CONSTRAINT ck_client_registration CHECK (registration_date > '2026-03-13');

-- 4. La hora de inicio del alquiler debe estar entre las 6:00 y las 21:00
ALTER TABLE RENT
    ADD CONSTRAINT ck_rent_start_time
    CHECK (TIME(start_date) BETWEEN '06:00:00' AND '21:00:00');

-- 5. Eliminar la restriccion anterior de cantidad (la del apartado 2)
ALTER TABLE EQUIPMENT
    DROP CHECK ck_equipment_quantity_min;

-- 6. Borrar la columna del telefono de CLIENT
ALTER TABLE CLIENT
    DROP COLUMN phone_number;

-- 7. Dos equipos no pueden tener el mismo nombre
ALTER TABLE EQUIPMENT
    ADD CONSTRAINT uq_equipment_name UNIQUE (name);

-- 8. Clave primaria de RENT = combinacion de los identificadores
--    (se hace en una sola sentencia porque rent_id es AUTO_INCREMENT)
ALTER TABLE RENT
    DROP PRIMARY KEY,
    ADD PRIMARY KEY (rent_id, client_id, equipment_id);

-- 9. Un cliente solo puede tener un equipo en uso a la vez.
--    Un alquiler esta en uso mientras end_date es NULL. El indice guarda
--    client_id solo para los alquileres activos; para los terminados guarda
--    NULL, que puede repetirse. Asi no puede haber dos alquileres activos
--    del mismo cliente.
CREATE UNIQUE INDEX uq_rent_active_client
    ON RENT ((CASE WHEN end_date IS NULL THEN client_id END));

-- 10. Renombrar CLIENT a MEMBER
RENAME TABLE CLIENT TO MEMBER;

-- 11. Eliminar la tabla RENT
DROP TABLE RENT;

-- 12. Crear un usuario y darle SELECT e INSERT sobre EQUIPMENT
--     (la contrasena es de ejemplo)
CREATE USER 'antonio_pastor'@'localhost' IDENTIFIED BY 'Password123!';

GRANT SELECT, INSERT ON gym.EQUIPMENT TO 'antonio_pastor'@'localhost';

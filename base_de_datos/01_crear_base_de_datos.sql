-- =====================================================================
-- Sistema de Biblioteca - Creación de la base de datos y las tablas
-- Autor: Joshua Odin Montoya Flores
-- Motor: MySQL 8.0.16 o superior (necesario para que se apliquen los CHECK)
-- =====================================================================
-- Adaptación del esquema de referencia (Northwind) a una biblioteca.
-- NO se crean las tablas préstamo ni detalle_préstamo (equivalentes a
-- Orders y Order Details), como lo indicó el profesor.
--
--   Employees  -> administrador (hereda de persona; ReportsTo -> id_jefe)
--   Customers  -> lector        (hereda de persona)
--   Products   -> libro
--   Categories -> categoria
--   Suppliers  -> editorial
--   Shippers   -> no aplica (solo sirve para los envíos de Orders)
--
-- Herencia "una tabla por subclase":
--   persona
--     ├── administrador  --> estado_administrador, administrador (jefe)
--     └── lector
--   libro --> editorial, categoria
-- =====================================================================

DROP DATABASE IF EXISTS biblioteca_db;

CREATE DATABASE biblioteca_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE biblioteca_db;

-- ---------------------------------------------------------------------
-- Catálogo de estados del administrador (enum EstadoAdministrador)
-- ---------------------------------------------------------------------
CREATE TABLE estado_administrador (
    id_estado TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre    VARCHAR(20)      NOT NULL,
    PRIMARY KEY (id_estado),
    UNIQUE KEY uq_estado_nombre (nombre)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Persona: datos comunes (clase abstracta Persona)
-- ---------------------------------------------------------------------
CREATE TABLE persona (
    id_persona INT          NOT NULL,            -- PK: id (Integer) del modelo
    curp       CHAR(18)     NOT NULL,
    rfc        VARCHAR(13)  NOT NULL,
    nombre     VARCHAR(50)  NOT NULL,
    apellido   VARCHAR(50)  NOT NULL,
    nacimiento DATE         NOT NULL,
    correo     VARCHAR(80)  NOT NULL,
    telefono   CHAR(10)     NOT NULL,
    url_imagen VARCHAR(255) NULL,                -- opcional: puede no tener imagen
    PRIMARY KEY (id_persona),
    UNIQUE KEY uq_persona_curp (curp),
    CONSTRAINT ck_persona_id       CHECK (id_persona > 0),
    CONSTRAINT ck_persona_curp     CHECK (CHAR_LENGTH(curp) = 18),
    CONSTRAINT ck_persona_rfc      CHECK (CHAR_LENGTH(rfc) BETWEEN 12 AND 13),
    CONSTRAINT ck_persona_telefono CHECK (telefono REGEXP '^[0-9]{10}$')
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Administrador (Employees): hereda de persona.
-- id_jefe es una llave foránea a la misma tabla (equivale a ReportsTo).
-- ---------------------------------------------------------------------
CREATE TABLE administrador (
    id_persona         INT              NOT NULL,        -- PK y FK -> persona
    usuario            VARCHAR(20)      NOT NULL,
    contrasena         VARCHAR(255)     NOT NULL,        -- longitud para guardar un hash
    id_estado          TINYINT UNSIGNED NOT NULL DEFAULT 1,  -- FK -> estado_administrador (1 = ACTIVO)
    rol                VARCHAR(30)      NOT NULL,
    fecha_contratacion DATE             NOT NULL DEFAULT (CURRENT_DATE),
    id_jefe            INT              NULL,            -- FK -> administrador (puede no tener jefe)
    PRIMARY KEY (id_persona),
    UNIQUE KEY uq_administrador_usuario (usuario),
    CONSTRAINT fk_administrador_persona
        FOREIGN KEY (id_persona) REFERENCES persona (id_persona)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_administrador_estado
        FOREIGN KEY (id_estado) REFERENCES estado_administrador (id_estado)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_administrador_jefe
        FOREIGN KEY (id_jefe) REFERENCES administrador (id_persona)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT ck_administrador_usuario CHECK (CHAR_LENGTH(usuario) >= 3)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Lector (Customers): hereda de persona.
-- ---------------------------------------------------------------------
CREATE TABLE lector (
    id_persona        INT           NOT NULL,    -- PK y FK -> persona
    numero_credencial VARCHAR(15)   NOT NULL,
    multa_pendiente   DECIMAL(8,2)  NOT NULL DEFAULT 0.00,
    PRIMARY KEY (id_persona),
    UNIQUE KEY uq_lector_credencial (numero_credencial),
    CONSTRAINT fk_lector_persona
        FOREIGN KEY (id_persona) REFERENCES persona (id_persona)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_lector_multa CHECK (multa_pendiente >= 0)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Categoría (Categories): clasificación de los libros.
-- ---------------------------------------------------------------------
CREATE TABLE categoria (
    id_categoria INT          NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(50)  NOT NULL,
    descripcion  VARCHAR(255) NULL,
    url_imagen   VARCHAR(255) NULL,
    PRIMARY KEY (id_categoria),
    UNIQUE KEY uq_categoria_nombre (nombre)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Editorial (Suppliers): quien provee los libros.
-- ---------------------------------------------------------------------
CREATE TABLE editorial (
    id_editorial    INT          NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(80)  NOT NULL,
    nombre_contacto VARCHAR(60)  NULL,
    cargo_contacto  VARCHAR(40)  NULL,
    direccion       VARCHAR(100) NULL,
    ciudad          VARCHAR(50)  NULL,
    region          VARCHAR(50)  NULL,
    codigo_postal   VARCHAR(10)  NULL,
    pais            VARCHAR(50)  NULL,
    telefono        VARCHAR(20)  NULL,
    sitio_web       VARCHAR(120) NULL,
    url_imagen      VARCHAR(255) NULL,       -- logotipo (ruta relativa de la imagen)
    PRIMARY KEY (id_editorial),
    UNIQUE KEY uq_editorial_nombre (nombre)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Libro (Products): pertenece a una editorial y a una categoría.
-- ---------------------------------------------------------------------
CREATE TABLE libro (
    id_libro               INT           NOT NULL AUTO_INCREMENT,
    titulo                 VARCHAR(120)  NOT NULL,
    autor                  VARCHAR(100)  NOT NULL,
    isbn                   VARCHAR(17)   NULL,
    id_editorial           INT           NOT NULL,   -- FK -> editorial
    id_categoria           INT           NOT NULL,   -- FK -> categoria
    precio                 DECIMAL(8,2)  NOT NULL DEFAULT 0.00,
    ejemplares_disponibles INT           NOT NULL DEFAULT 0,   -- UnitsInStock
    ejemplares_en_pedido   INT           NOT NULL DEFAULT 0,   -- UnitsOnOrder
    nivel_reorden          INT           NOT NULL DEFAULT 0,   -- ReorderLevel
    descontinuado          BOOLEAN       NOT NULL DEFAULT FALSE,
    url_imagen             VARCHAR(255)  NULL,                 -- portada (ruta relativa de la imagen)
    PRIMARY KEY (id_libro),
    UNIQUE KEY uq_libro_isbn (isbn),
    CONSTRAINT fk_libro_editorial
        FOREIGN KEY (id_editorial) REFERENCES editorial (id_editorial)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_libro_categoria
        FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_libro_precio      CHECK (precio >= 0),
    CONSTRAINT ck_libro_disponibles CHECK (ejemplares_disponibles >= 0),
    CONSTRAINT ck_libro_en_pedido   CHECK (ejemplares_en_pedido >= 0),
    CONSTRAINT ck_libro_reorden     CHECK (nivel_reorden >= 0)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Datos del catálogo de estados
-- ---------------------------------------------------------------------
INSERT INTO estado_administrador (nombre) VALUES
    ('ACTIVO'),
    ('BLOQUEADO'),
    ('SUSPENDIDO'),
    ('BAJA');

-- ---------------------------------------------------------------------
-- Verificación de la estructura creada
-- ---------------------------------------------------------------------
SHOW TABLES;
DESCRIBE persona;
DESCRIBE administrador;
DESCRIBE lector;
DESCRIBE categoria;
DESCRIBE editorial;
DESCRIBE libro;
DESCRIBE estado_administrador;

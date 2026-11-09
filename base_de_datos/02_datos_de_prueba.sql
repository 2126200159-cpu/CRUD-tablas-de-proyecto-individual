-- =====================================================================
-- Sistema de Biblioteca - Datos de prueba (opcional)
-- Autor: Joshua Odin Montoya Flores
-- Ejecutar después de 01_crear_base_de_datos.sql
-- =====================================================================
USE biblioteca_db;

-- Primero la persona (tabla padre) y luego su rol (tabla hija)
INSERT INTO persona (id_persona, curp, rfc, nombre, apellido, nacimiento, correo, telefono, url_imagen) VALUES
    (1001, 'MOFJ070212HJCNLSA1', 'MOFJ070212AB1', 'Joshua Odin', 'Montoya Flores', '2007-02-12', 'joshua@correo.com', '3312345678', NULL),
    (1002, 'GARC900505MJCRMRA5', 'GARC900505XY9', 'Carla',       'Garcia Ramos',   '1990-05-05', 'carla@correo.com',  '3311112222', NULL),
    (2001, 'LOPA050315MJCPRNA2', 'LOPA050315CD2', 'Ana',         'Lopez Ruiz',     '2005-03-15', 'ana@correo.com',    '3398765432', NULL);

-- El administrador 1001 no tiene jefe; el 1002 reporta al 1001
INSERT INTO administrador (id_persona, usuario, contrasena, id_estado, rol, fecha_contratacion, id_jefe) VALUES
    (1001, 'joshua_01', '1234', 1, 'Bibliotecario', '2024-01-15', NULL),
    (1002, 'carla_gr',  '5678', 2, 'Supervisor',    '2023-06-01', 1001);

INSERT INTO lector (id_persona, numero_credencial, multa_pendiente) VALUES
    (2001, 'LEC-0001', 15.50);

INSERT INTO categoria (nombre, descripcion) VALUES
    ('Novela',     'Obras de ficción narrativa'),
    ('Ciencia',    'Divulgación y textos científicos'),
    ('Tecnología', 'Computación e ingeniería');

INSERT INTO editorial (nombre, nombre_contacto, cargo_contacto, direccion, ciudad, region, codigo_postal, pais, telefono, sitio_web) VALUES
    ('Editorial Central',  'Luis Perez',  'Ventas',   'Av. Reforma 100', 'Guadalajara', 'Jalisco', '44100', 'México', '3300001111', 'www.editorialcentral.example'),
    ('Ediciones del Sur',  'Marta Gomez', 'Gerente',  'Calle Sur 25',    'Monterrey',   'Nuevo León', '64000', 'México', '8100002222', NULL);

INSERT INTO libro (titulo, autor, isbn, id_editorial, id_categoria, precio, ejemplares_disponibles, ejemplares_en_pedido, nivel_reorden, descontinuado) VALUES
    ('Introducción a la programación', 'A. Ramirez', '978-000-00-0001-1', 1, 3, 350.00, 5, 0, 2, FALSE),
    ('Historias del río',              'M. Torres',  '978-000-00-0002-2', 2, 1, 220.50, 3, 2, 1, FALSE),
    ('Fundamentos de física',          'R. Salinas', NULL,                1, 2, 410.00, 0, 4, 2, TRUE);

-- Consultas de comprobación
SELECT p.id_persona, p.nombre, p.apellido, a.usuario, e.nombre AS estado, a.rol, a.id_jefe
FROM administrador a
JOIN persona p              ON p.id_persona = a.id_persona
JOIN estado_administrador e ON e.id_estado  = a.id_estado;

SELECT p.id_persona, p.nombre, p.apellido, l.numero_credencial, l.multa_pendiente
FROM lector l
JOIN persona p ON p.id_persona = l.id_persona;

SELECT l.id_libro, l.titulo, c.nombre AS categoria, e.nombre AS editorial, l.ejemplares_disponibles
FROM libro l
JOIN categoria c ON c.id_categoria = l.id_categoria
JOIN editorial e ON e.id_editorial = l.id_editorial;

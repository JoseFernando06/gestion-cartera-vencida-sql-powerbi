-- =============================================
-- SCRIPT 02: Inserción de datos
-- Portafolio ficticio: Agrocomercial Sur S.A
-- Período: Junio 2026
-- =============================================

USE CarteraVencida;
GO

-- =============================================
-- CLIENTES (15 del portafolio)
-- =============================================
INSERT INTO Clientes VALUES
(1,  'Distribuidora Vargas Ltda.',   'Correo',       'Normal'),
(2,  'Comercial El Roble SpA',       'Telefono',     'Normal'),
(3,  'Ferretería Muñoz e Hijos',     'Correo',       'Normal'),
(4,  'Agro San Pedro Ltda.',         'Sin contacto', 'Judicial'),
(5,  'Servicios RMH SpA',            'Telefono',     'Normal'),
(6,  'Transportes Pizarro',          'Telefono',     'Normal'),
(7,  'Construmart del Sur Ltda.',    'Sin contacto', 'Judicial'),
(8,  'Agroservicios Bío-Bío',        'Correo',       'Normal'),
(9,  'Inversiones Tapia y Cía.',     'Telefono',     'Normal'),
(10, 'Clínica Veterinaria Renca',    'Correo',       'Normal'),
(11, 'Importadora del Maule',        'Sin contacto', 'Normal'),
(12, 'Repuestos Automotriz JP',      'Telefono',     'Normal'),
(13, 'Catering Central SpA',         'Correo',       'Normal'),
(14, 'Maderera Los Pinos',           'Sin contacto', 'Judicial'),
(15, 'Consultora Nexo Ltda.',        'Correo',       'Normal');
GO

-- =============================================
-- DEUDAS (una partida vencida por cliente)
-- Fecha consulta: 14-06-2026
-- =============================================
INSERT INTO Deudas VALUES
(1,  1,  1250000, '2026-05-27', '2026-06-14'),
(2,  2,  3400000, '2026-04-23', '2026-06-14'),
(3,  3,   780000, '2026-04-09', '2026-06-14'),
(4,  4,  5600000, '2026-03-07', '2026-06-14'),
(5,  5,   920000, '2026-05-09', '2026-06-14'),
(6,  6,  2100000, '2026-05-21', '2026-06-14'),
(7,  7,  6800000, '2026-02-11', '2026-06-14'),
(8,  8,  1450000, '2026-04-16', '2026-06-14'),
(9,  9,  4300000, '2026-04-01', '2026-06-14'),
(10, 10,  550000, '2026-05-31', '2026-06-14'),
(11, 11, 3900000, '2026-03-21', '2026-06-14'),
(12, 12,  670000, '2026-05-17', '2026-06-14'),
(13, 13, 1100000, '2026-04-30', '2026-06-14'),
(14, 14, 7200000, '2026-02-01', '2026-06-14'),
(15, 15,  430000, '2026-05-28', '2026-06-14');
GO

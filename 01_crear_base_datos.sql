-- =============================================
-- PROYECTO: Gestión de Cartera Vencida
-- Autor: José Fernando Vargas Vallejos
-- Ingeniero Comercial | Crédito y Cobranza
-- Período: Junio 2026
-- =============================================
-- SCRIPT 01: Creación de base de datos y tablas
-- =============================================

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'CarteraVencida')
    DROP DATABASE CarteraVencida;
GO

CREATE DATABASE CarteraVencida;
GO

USE CarteraVencida;
GO

-- Tabla 1: Clientes
-- Almacena el maestro de clientes con canal de contacto y zona de cobranza
CREATE TABLE Clientes (
    id_cliente      INT PRIMARY KEY,
    nombre          VARCHAR(100),
    canal_contacto  VARCHAR(20),   -- 'Correo', 'Telefono', 'Sin contacto'
    zona            VARCHAR(20)    -- 'Normal', 'Judicial'
);
GO

-- Tabla 2: Deudas
-- Cada fila es una partida vencida impaga (equivalente a partida abierta en SAP FI-AR)
CREATE TABLE Deudas (
    id_deuda          INT PRIMARY KEY,
    id_cliente        INT,           -- FK → Clientes
    monto_deuda       DECIMAL(12,2),
    fecha_vencimiento DATE,
    fecha_consulta    DATE           -- fecha en que se mide la mora
);
GO

-- Tabla 3: Pagos
-- Registra abonos parciales o totales contra una deuda
CREATE TABLE Pagos (
    id_pago       INT PRIMARY KEY,
    id_deuda      INT,              -- FK → Deudas
    monto_pagado  DECIMAL(12,2),
    fecha_pago    DATE
);
GO

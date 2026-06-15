-- =============================================
-- SCRIPT 03: Consultas analíticas de cartera
-- Gestión de Crédito y Cobranza | Junio 2026
-- Empresa: Agrocomercial Sur S.A.
-- =============================================

USE CarteraVencida;
GO

-- =============================================
-- BLOQUE 1: SELECT + WHERE
-- =============================================

-- 1.1 Cartera completa ordenada por monto mayor a menor
SELECT id_cliente, monto_deuda, fecha_vencimiento
FROM Deudas
ORDER BY monto_deuda DESC;

-- 1.2 Clientes en zona Judicial
SELECT id_cliente, nombre, zona
FROM Clientes
WHERE zona = 'Judicial';

-- 1.3 Clientes sin canal de contacto
SELECT id_cliente, nombre, canal_contacto
FROM Clientes
WHERE canal_contacto = 'Sin contacto';

-- 1.4 Clientes sin contacto Y zona Judicial (casos más críticos)
SELECT id_cliente, nombre, canal_contacto, zona
FROM Clientes
WHERE canal_contacto = 'Sin contacto'
  AND zona = 'Judicial';

-- =============================================
-- BLOQUE 2: GROUP BY + HAVING
-- =============================================

-- 2.1 Deuda total, cantidad y promedio por zona
-- Resultado: Judicial concentra 48% de la deuda con solo 3 clientes
SELECT
    c.zona,
    COUNT(d.id_deuda)    AS cantidad_clientes,
    SUM(d.monto_deuda)   AS deuda_total,
    AVG(d.monto_deuda)   AS deuda_promedio
FROM Deudas d
JOIN Clientes c ON d.id_cliente = c.id_cliente
GROUP BY c.zona
ORDER BY deuda_total DESC;

-- 2.2 Deuda total por canal de contacto
SELECT
    c.canal_contacto,
    COUNT(d.id_deuda)    AS cantidad_clientes,
    SUM(d.monto_deuda)   AS deuda_total
FROM Deudas d
JOIN Clientes c ON d.id_cliente = c.id_cliente
GROUP BY c.canal_contacto
ORDER BY deuda_total DESC;

-- 2.3 HAVING: solo canales con deuda acumulada mayor a $5.000.000
-- Sin contacto concentra 58% de la deuda total del portafolio
SELECT
    c.canal_contacto,
    COUNT(d.id_deuda)    AS cantidad_clientes,
    SUM(d.monto_deuda)   AS deuda_total
FROM Deudas d
JOIN Clientes c ON d.id_cliente = c.id_cliente
GROUP BY c.canal_contacto
HAVING SUM(d.monto_deuda) > 5000000
ORDER BY deuda_total DESC;
Agrega bloque 3: JOINs, CASE WHEN y consulta maestra de cartera

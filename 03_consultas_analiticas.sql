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
-- =============================================
-- BLOQUE 3: JOINs + CASE WHEN
-- =============================================

-- 3.1 Saldo pendiente real por cliente (LEFT JOIN Pagos)
SELECT
    c.nombre,
    c.canal_contacto,
    d.monto_deuda,
    ISNULL(SUM(p.monto_pagado), 0)                   AS total_pagado,
    d.monto_deuda - ISNULL(SUM(p.monto_pagado), 0)  AS saldo_pendiente,
    CASE
        WHEN ISNULL(SUM(p.monto_pagado), 0) = 0
            THEN 'Sin pago'
        WHEN ISNULL(SUM(p.monto_pagado), 0) >= d.monto_deuda
            THEN 'Pagado total'
        ELSE 'Pago parcial'
    END AS estado_pago
FROM Clientes c
INNER JOIN Deudas d ON c.id_cliente = d.id_cliente
LEFT JOIN  Pagos p  ON d.id_deuda   = p.id_deuda
GROUP BY c.nombre, c.canal_contacto, d.monto_deuda
ORDER BY saldo_pendiente DESC;

-- 3.2 Consulta maestra: tramo de mora, provisión IFRS 9 y saldo pendiente
SELECT
    c.nombre,
    c.canal_contacto,
    c.zona,
    d.monto_deuda,
    ISNULL(SUM(p.monto_pagado), 0)                   AS total_pagado,
    d.monto_deuda - ISNULL(SUM(p.monto_pagado), 0)  AS saldo_pendiente,
    DATEDIFF(DAY, d.fecha_vencimiento, d.fecha_consulta) AS dias_mora,
    CASE
        WHEN DATEDIFF(DAY, d.fecha_vencimiento, d.fecha_consulta) <= 30
            THEN '0-30 días (Preventiva)'
        WHEN DATEDIFF(DAY, d.fecha_vencimiento, d.fecha_consulta) <= 60
            THEN '31-60 días (Activa)'
        WHEN DATEDIFF(DAY, d.fecha_vencimiento, d.fecha_consulta) <= 90
            THEN '61-90 días (Extrajudicial)'
        ELSE '+90 días (Judicial/Castigo)'
    END AS tramo_mora,
    CASE
        WHEN DATEDIFF(DAY, d.fecha_vencimiento, d.fecha_consulta) <= 30
            THEN d.monto_deuda * 0.05
        WHEN DATEDIFF(DAY, d.fecha_vencimiento, d.fecha_consulta) <= 60
            THEN d.monto_deuda * 0.25
        WHEN DATEDIFF(DAY, d.fecha_vencimiento, d.fecha_consulta) <= 90
            THEN d.monto_deuda * 0.60
        ELSE d.monto_deuda * 1.00
    END AS provision
FROM Clientes c
INNER JOIN Deudas d ON c.id_cliente = d.id_cliente
LEFT JOIN  Pagos p  ON d.id_deuda   = p.id_deuda
GROUP BY
    c.nombre, c.canal_contacto, c.zona,
    d.monto_deuda, d.fecha_vencimiento, d.fecha_consulta
ORDER BY saldo_pendiente DESC;
-- =============================================
-- BLOQUE 4: FUNCIONES DE VENTANA
-- =============================================

-- 4.1 Ranking de clientes por deuda dentro de cada zona
SELECT
    c.nombre,
    c.zona,
    d.monto_deuda,
    ROW_NUMBER() OVER (
        PARTITION BY c.zona
        ORDER BY d.monto_deuda DESC
    ) AS ranking_en_zona
FROM Clientes c
INNER JOIN Deudas d ON c.id_cliente = d.id_cliente;

-- 4.2 Peor deudor por zona (subconsulta + ROW_NUMBER)
SELECT nombre, zona, monto_deuda
FROM (
    SELECT
        c.nombre,
        c.zona,
        d.monto_deuda,
        ROW_NUMBER() OVER (
            PARTITION BY c.zona
            ORDER BY d.monto_deuda DESC
        ) AS ranking_en_zona
    FROM Clientes c
    INNER JOIN Deudas d ON c.id_cliente = d.id_cliente
) AS subconsulta
WHERE ranking_en_zona = 1;

-- 4.3 Porcentaje del total y acumulado por cliente
SELECT
    c.nombre,
    d.monto_deuda,
    SUM(d.monto_deuda) OVER ()                              AS deuda_total_portafolio,
    CAST(ROUND(d.monto_deuda * 100.0 /
        SUM(d.monto_deuda) OVER (), 1) AS DECIMAL(5,1))    AS pct_del_total,
    SUM(d.monto_deuda) OVER (
        ORDER BY d.monto_deuda DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                       AS acumulado
FROM Clientes c
INNER JOIN Deudas d ON c.id_cliente = d.id_cliente
ORDER BY d.monto_deuda DESC;

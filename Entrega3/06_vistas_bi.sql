USE GD1C2026;
GO

/* ============================================================================
   VISTAS DEL MODELO DE INTELIGENCIA DE NEGOCIOS (BI)
   ============================================================================ */

-- ============================================================================
-- 1. Ticket promedio
-- Valor promedio de venta mensual según rango etario de cliente y canal de venta.
-- ============================================================================
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_01_Ticket_Promedio AS
SELECT 
    t.Tiempo_Anio AS Anio,
    t.Tiempo_Mes AS Mes,
    r.Rango_Etario_Descripcion AS Rango_Etario_Cliente,
    c.Canal_Venta_Nombre AS Canal_Venta,
    CAST(AVG(v.Venta_Importe_Total) AS decimal(18,2)) AS Ticket_Promedio
FROM TP_APROBADO.BI_Fact_Ventas v
JOIN TP_APROBADO.BI_Dim_Tiempo t ON v.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Rango_Etario r ON v.Rango_Etario_Cliente_ID = r.Rango_Etario_ID
JOIN TP_APROBADO.BI_Dim_Canal_Venta c ON v.Canal_Venta_ID = c.Canal_Venta_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Mes, r.Rango_Etario_Descripcion, c.Canal_Venta_Nombre;
GO

-- ============================================================================
-- 2. Distribución de Facturación
-- Porcentaje de facturación correspondiente a cada tipo de servicio para cada 
-- cuatrimestre de cada año.
-- ============================================================================
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_02_Distribucion_Facturacion AS
WITH Totales_Por_Servicio AS (
    SELECT 
        t.Tiempo_Anio,
        t.Tiempo_Cuatrimestre,
        ts.Tipo_Servicio_Nombre,
        SUM(v.Venta_Importe_Total) AS Total_Servicio
    FROM TP_APROBADO.BI_Fact_Ventas v
    JOIN TP_APROBADO.BI_Dim_Tiempo t ON v.Tiempo_ID = t.Tiempo_ID
    JOIN TP_APROBADO.BI_Dim_Tipo_Servicio ts ON v.Tipo_Servicio_ID = ts.Tipo_Servicio_ID
    GROUP BY t.Tiempo_Anio, t.Tiempo_Cuatrimestre, ts.Tipo_Servicio_Nombre
)
SELECT 
    Tiempo_Anio AS Anio,
    Tiempo_Cuatrimestre AS Cuatrimestre,
    Tipo_Servicio_Nombre AS Tipo_Servicio,
    Total_Servicio AS Facturacion_Absoluta,
    CAST((Total_Servicio / NULLIF(SUM(Total_Servicio) OVER (PARTITION BY Tiempo_Anio, Tiempo_Cuatrimestre), 0)) * 100 AS decimal(18,2)) AS Porcentaje_Facturacion
FROM Totales_Por_Servicio;
GO

-- ============================================================================
-- 3. Ranking de solicitudes por temporadas
-- Cantidad de solicitudes realizadas, agrupadas por temporada de cada año 
-- y rango etario del cliente.
-- ============================================================================
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_03_Ranking_Solicitudes_Temporada AS
SELECT 
    t.Tiempo_Anio AS Anio,
    temp.Temporada_Nombre AS Temporada,
    r.Rango_Etario_Descripcion AS Rango_Etario_Cliente,
    COUNT(s.Fact_Solicitud_ID) AS Cantidad_Solicitudes
FROM TP_APROBADO.BI_Fact_Solicitudes s
JOIN TP_APROBADO.BI_Dim_Tiempo t ON s.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Temporada temp ON s.Temporada_ID = temp.Temporada_ID
JOIN TP_APROBADO.BI_Dim_Rango_Etario r ON s.Rango_Etario_Cliente_ID = r.Rango_Etario_ID
GROUP BY t.Tiempo_Anio, temp.Temporada_Nombre, r.Rango_Etario_Descripcion;
GO

-- ============================================================================
-- 4. Anticipación promedio de solicitudes
-- Promedio de días de anticipación con los que el cliente realiza la solicitud.
-- Segmentado por rango etario del cliente y cuatrimestre.
-- ============================================================================
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_04_Anticipacion_Promedio_Solicitudes AS
SELECT 
    t.Tiempo_Anio AS Anio,
    t.Tiempo_Cuatrimestre AS Cuatrimestre,
    r.Rango_Etario_Descripcion AS Rango_Etario_Cliente,
    CAST(AVG(CAST(s.Solicitud_Dias_Anticipacion AS decimal(18,2))) AS decimal(18,2)) AS Anticipacion_Promedio_Dias
FROM TP_APROBADO.BI_Fact_Solicitudes s
JOIN TP_APROBADO.BI_Dim_Tiempo t ON s.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Rango_Etario r ON s.Rango_Etario_Cliente_ID = r.Rango_Etario_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Cuatrimestre, r.Rango_Etario_Descripcion;
GO

-- ============================================================================
-- 5. Tasa de aceptación de propuestas
-- Porcentaje de propuestas aceptadas sobre el total de propuestas emitidas, 
-- calculado por cuatrimestre.
-- ============================================================================
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_05_Tasa_Aceptacion_Propuestas AS
SELECT 
    t.Tiempo_Anio AS Anio,
    t.Tiempo_Cuatrimestre AS Cuatrimestre,
    CAST(
        SUM(CASE WHEN ep.Estado_Propuesta_Nombre LIKE '%Aceptada%' THEN 1.0 ELSE 0.0 END) 
        / NULLIF(COUNT(p.Fact_Propuesta_ID), 0) * 100 
    AS decimal(18,2)) AS Tasa_Aceptacion_Porcentaje
FROM TP_APROBADO.BI_Fact_Propuestas p
JOIN TP_APROBADO.BI_Dim_Tiempo t ON p.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Estado_Propuesta ep ON p.Estado_Propuesta_ID = ep.Estado_Propuesta_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Cuatrimestre;
GO

-- ============================================================================
-- 6. Cotización promedio por temporada
-- Importe promedio de las propuestas emitidas, agrupado por temporada/año.
-- (La temporada del viaje ya fue resuelta en la migración del Fact Table)
-- ============================================================================
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_06_Cotizacion_Promedio_Temporada AS
SELECT 
    t.Tiempo_Anio AS Anio_Emision,
    temp.Temporada_Nombre AS Temporada_Viaje,
    CAST(AVG(p.Propuesta_Importe_Total) AS decimal(18,2)) AS Cotizacion_Promedio
FROM TP_APROBADO.BI_Fact_Propuestas p
JOIN TP_APROBADO.BI_Dim_Tiempo t ON p.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Temporada temp ON p.Temporada_ID = temp.Temporada_ID
GROUP BY t.Tiempo_Anio, temp.Temporada_Nombre;
GO

-- ============================================================================
-- 7. Tiempo promedio de respuesta
-- Tiempo promedio (en días) entre solicitud y emisión de la propuesta. 
-- Segmentado por rango etario del agente y mes.
-- ============================================================================
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_07_Tiempo_Promedio_Respuesta AS
SELECT 
    t.Tiempo_Anio AS Anio_Solicitud,
    t.Tiempo_Mes AS Mes_Solicitud,
    r.Rango_Etario_Descripcion AS Rango_Etario_Agente,
    CAST(AVG(CAST(p.Propuesta_Dias_Respuesta AS decimal(18,2))) AS decimal(18,2)) AS Tiempo_Respuesta_Promedio_Dias
FROM TP_APROBADO.BI_Fact_Propuestas p
JOIN TP_APROBADO.BI_Dim_Tiempo t ON p.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Rango_Etario r ON p.Rango_Etario_Agente_ID = r.Rango_Etario_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Mes, r.Rango_Etario_Descripcion;
GO

-- ============================================================================
-- 8. Desvío de presupuesto
-- Desvío promedio entre el presupuesto estimado y la propuesta generada.
-- (Agrupado a nivel cuatrimestre para consistencia analítica)
-- ============================================================================
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_08_Desvio_Presupuesto AS
SELECT 
    t.Tiempo_Anio AS Anio,
    t.Tiempo_Cuatrimestre AS Cuatrimestre,
    CAST(AVG(p.Propuesta_Desvio_Presupuesto) AS decimal(18,2)) AS Desvio_Presupuesto_Promedio
FROM TP_APROBADO.BI_Fact_Propuestas p
JOIN TP_APROBADO.BI_Dim_Tiempo t ON p.Tiempo_ID = t.Tiempo_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Cuatrimestre;
GO

-- ============================================================================
-- 9. Ranking de aspectos mejor y peor valorados
-- Promedio de puntaje por aspecto evaluado en cada cuatrimestre.
-- ============================================================================
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_09_Ranking_Aspectos_Valorados AS
SELECT 
    t.Tiempo_Anio AS Anio,
    t.Tiempo_Cuatrimestre AS Cuatrimestre,
    a.Aspecto_Nombre,
    CAST(AVG(CAST(e.Encuesta_Puntaje AS decimal(18,2))) AS decimal(18,2)) AS Puntaje_Promedio
FROM TP_APROBADO.BI_Fact_Encuestas e
JOIN TP_APROBADO.BI_Dim_Tiempo t ON e.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Aspecto a ON e.Aspecto_ID = a.Aspecto_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Cuatrimestre, a.Aspecto_Nombre;
GO

-- ============================================================================
-- 10. Satisfacción promedio por agente
-- Puntaje promedio en encuestas, segmentado por rango etario del agente y mes.
-- ============================================================================
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_10_Satisfaccion_Promedio_Agente AS
SELECT 
    t.Tiempo_Anio AS Anio,
    t.Tiempo_Mes AS Mes,
    r.Rango_Etario_Descripcion AS Rango_Etario_Agente,
    CAST(AVG(CAST(e.Encuesta_Puntaje AS decimal(18,2))) AS decimal(18,2)) AS Puntaje_Promedio
FROM TP_APROBADO.BI_Fact_Encuestas e
JOIN TP_APROBADO.BI_Dim_Tiempo t ON e.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Rango_Etario r ON e.Rango_Etario_Agente_ID = r.Rango_Etario_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Mes, r.Rango_Etario_Descripcion;
GO
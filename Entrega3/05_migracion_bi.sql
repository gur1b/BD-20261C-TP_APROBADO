USE GD1C2026;
GO

-- ============================================================================
-- MIGRACION DE DATOS AL MODELO DE BI
-- ============================================================================

-- ############################################################################
--                    STORED PROCEDURES - DIMENSIONES
-- ############################################################################

-- ============================================================================
-- SP: Migrar Dimension Tiempo
-- ============================================================================
-- Extrae todas las combinaciones únicas de año/mes de las tablas transaccionales
-- y las inserta en la dimensión de tiempo.
-- ============================================================================

CREATE PROCEDURE TP_APROBADO.SP_Migrar_Dim_Tiempo
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Dim_Tiempo (Tiempo_Anio, Tiempo_Cuatrimestre, Tiempo_Mes)
    SELECT DISTINCT
        Anio,
        CASE 
            WHEN Mes BETWEEN 1 AND 4 THEN 1
            WHEN Mes BETWEEN 5 AND 8 THEN 2
            ELSE 3
        END AS Cuatrimestre,
        Mes
    FROM (
        SELECT YEAR(Venta_Fecha_Venta) AS Anio, MONTH(Venta_Fecha_Venta) AS Mes
        FROM TP_APROBADO.Venta WHERE Venta_Fecha_Venta IS NOT NULL
        UNION
        SELECT YEAR(Solicitud_Fecha_solicitud), MONTH(Solicitud_Fecha_solicitud)
        FROM TP_APROBADO.Solicitud WHERE Solicitud_Fecha_solicitud IS NOT NULL
        UNION
        SELECT YEAR(Propuesta_Fecha_Emision), MONTH(Propuesta_Fecha_Emision)
        FROM TP_APROBADO.Propuesta WHERE Propuesta_Fecha_Emision IS NOT NULL
        UNION
        SELECT YEAR(Encuesta_Fecha_Encuesta), MONTH(Encuesta_Fecha_Encuesta)
        FROM TP_APROBADO.Encuesta WHERE Encuesta_Fecha_Encuesta IS NOT NULL
    ) AS Fechas
    ORDER BY Anio, Mes;
END;
GO

-- ============================================================================
-- SP: Migrar Dimension Canal de Venta
-- ============================================================================

CREATE PROCEDURE TP_APROBADO.SP_Migrar_Dim_Canal_Venta
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Dim_Canal_Venta (Canal_Venta_Codigo, Canal_Venta_Nombre)
    SELECT Canal_Venta_Codigo, Canal_Venta_Nombre
    FROM TP_APROBADO.Canal_Venta;
END;
GO

-- ============================================================================
-- SP: Migrar Dimension Estado de Propuesta
-- ============================================================================

CREATE PROCEDURE TP_APROBADO.SP_Migrar_Dim_Estado_Propuesta
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Dim_Estado_Propuesta (Estado_Propuesta_Codigo, Estado_Propuesta_Nombre)
    SELECT Estado_Codigo, Estado_Nombre
    FROM TP_APROBADO.Estado;
END;
GO

-- ============================================================================
-- SP: Migrar Dimension Aspecto
-- ============================================================================

CREATE PROCEDURE TP_APROBADO.SP_Migrar_Dim_Aspecto
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Dim_Aspecto (Aspecto_Codigo, Aspecto_Nombre)
    SELECT Aspecto_Codigo, Aspecto_Aspecto
    FROM TP_APROBADO.Aspecto;
END;
GO

-- ############################################################################
--                    STORED PROCEDURES - HECHOS
-- ############################################################################

-- ============================================================================
-- SP: Migrar Fact Ventas
-- ============================================================================
-- Inserta las ventas con sus dimensiones correspondientes.
-- Tipo_Servicio: 1 = Venta Directa (sin propuesta), 2 = Propuesta a Medida
-- ============================================================================

CREATE PROCEDURE TP_APROBADO.SP_Migrar_Fact_Ventas
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Fact_Ventas (
        Tiempo_ID,
        Rango_Etario_Cliente_ID,
        Canal_Venta_ID,
        Tipo_Servicio_ID,
        Venta_Importe_Total,
        Venta_Subtotal,
        Venta_Descuento
    )
    SELECT 
        TP_APROBADO.fn_ObtenerTiempo(v.Venta_Fecha_Venta),
        TP_APROBADO.fn_ObtenerRangoEtario(c.Cliente_Fecha_Nac, v.Venta_Fecha_Venta),
        dc.Canal_Venta_ID,
        CASE WHEN v.Venta_Propuesta IS NULL THEN 1 ELSE 2 END,
        v.Venta_Importe_Total,
        v.Venta_Subtotal,
        v.Venta_Descuento
    FROM TP_APROBADO.Venta v
    JOIN TP_APROBADO.Cliente c 
        ON v.Venta_Cliente_Dni = c.Cliente_Dni 
        AND v.Venta_Cliente_Mail = c.Cliente_Mail
    JOIN TP_APROBADO.BI_Dim_Canal_Venta dc 
        ON v.Venta_Canal_Venta = dc.Canal_Venta_Codigo;
END;
GO

-- ============================================================================
-- SP: Migrar Fact Solicitudes
-- ============================================================================
-- Inserta las solicitudes con días de anticipación calculados.
-- Días anticipación = Fecha_Inicio_Tentativa - Fecha_Solicitud
-- ============================================================================

CREATE PROCEDURE TP_APROBADO.SP_Migrar_Fact_Solicitudes
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Fact_Solicitudes (
        Tiempo_ID,
        Temporada_ID,
        Rango_Etario_Cliente_ID,
        Solicitud_Dias_Anticipacion
    )
    SELECT 
        TP_APROBADO.fn_ObtenerTiempo(s.Solicitud_Fecha_solicitud),
        TP_APROBADO.fn_ObtenerTemporada(s.Solicitud_Fecha_solicitud),
        TP_APROBADO.fn_ObtenerRangoEtario(c.Cliente_Fecha_Nac, s.Solicitud_Fecha_solicitud),
        DATEDIFF(DAY, s.Solicitud_Fecha_solicitud, s.Solicitud_Fecha_Inicio_Tentativa)
    FROM TP_APROBADO.Solicitud s
    JOIN TP_APROBADO.Cliente c 
        ON s.Solicitud_Cliente_Dni = c.Cliente_Dni 
        AND s.Solicitud_Cliente_Mail = c.Cliente_Mail;
END;
GO

-- ============================================================================
-- SP: Migrar Fact Propuestas
-- ============================================================================
-- Inserta las propuestas con métricas calculadas:
--   - Días respuesta = Fecha_Emision - Fecha_Solicitud
--   - Desvío presupuesto = Importe_Propuesta - Presupuesto_Estimado
-- La temporada se calcula según la fecha de inicio del viaje (Propuesta_Fecha_Desde).
-- ============================================================================

CREATE PROCEDURE TP_APROBADO.SP_Migrar_Fact_Propuestas
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Fact_Propuestas (
        Tiempo_ID,
        Temporada_ID,
        Rango_Etario_Agente_ID,
        Estado_Propuesta_ID,
        Propuesta_Importe_Total,
        Propuesta_Dias_Respuesta,
        Propuesta_Desvio_Presupuesto
    )
    SELECT 
        TP_APROBADO.fn_ObtenerTiempo(s.Solicitud_Fecha_solicitud),
        TP_APROBADO.fn_ObtenerTemporada(p.Propuesta_Fecha_Desde),
        TP_APROBADO.fn_ObtenerRangoEtario(a.Agente_Fecha_Nac, p.Propuesta_Fecha_Emision),
        de.Estado_Propuesta_ID,
        p.Propuesta_Importe_Total,
        DATEDIFF(DAY, s.Solicitud_Fecha_solicitud, p.Propuesta_Fecha_Emision),
        p.Propuesta_Importe_Total - s.Solicitud_Presupuesto_Estimado
    FROM TP_APROBADO.Propuesta p
    JOIN TP_APROBADO.Solicitud s 
        ON p.Solicitud_Nro_Solicitud = s.Solicitud_Nro_Solicitud
    JOIN TP_APROBADO.Agente a 
        ON p.Propuesta_Agente = a.Agente_Legajo
    JOIN TP_APROBADO.BI_Dim_Estado_Propuesta de 
        ON p.Propuesta_Estado = de.Estado_Propuesta_Codigo;
END;
GO

-- ============================================================================
-- SP: Migrar Fact Encuestas
-- ============================================================================
-- Inserta los detalles de encuestas (puntajes por aspecto).
-- El agente se obtiene desde la solicitud o venta asociada a la encuesta.
-- ============================================================================

CREATE PROCEDURE TP_APROBADO.SP_Migrar_Fact_Encuestas
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Fact_Encuestas (
        Tiempo_ID,
        Rango_Etario_Agente_ID,
        Aspecto_ID,
        Encuesta_Puntaje
    )
    SELECT 
        TP_APROBADO.fn_ObtenerTiempo(e.Encuesta_Fecha_Encuesta),
        TP_APROBADO.fn_ObtenerRangoEtario(a.Agente_Fecha_Nac, e.Encuesta_Fecha_Encuesta),
        da.Aspecto_ID,
        de.Detalle_Encuesta_Puntaje
    FROM TP_APROBADO.Detalle_Encuesta de
    JOIN TP_APROBADO.Encuesta e 
        ON de.Encuesta_Nro_Encuesta = e.Encuesta_Codigo_Encuesta
    JOIN TP_APROBADO.BI_Dim_Aspecto da 
        ON de.Detalle_Encuesta_Aspecto_Codigo = da.Aspecto_Codigo
    LEFT JOIN TP_APROBADO.Solicitud s 
        ON s.Solicitud_Encuesta = e.Encuesta_Codigo_Encuesta
    LEFT JOIN TP_APROBADO.Venta v 
        ON v.Venta_Encuesta = e.Encuesta_Codigo_Encuesta
    JOIN TP_APROBADO.Agente a 
        ON a.Agente_Legajo = COALESCE(s.Solicitud_Agente, v.Venta_Agente);
END;
GO

-- ############################################################################
--                    STORED PROCEDURE PRINCIPAL
-- ############################################################################

-- ============================================================================
-- SP: Migrar BI (Orquestador)
-- ============================================================================
-- Ejecuta todos los SPs de migración en el orden correcto:
-- 1. Primero las dimensiones (para que existan los IDs)
-- 2. Luego las tablas de hechos (que referencian las dimensiones)
-- ============================================================================

CREATE PROCEDURE TP_APROBADO.SP_Migrar_BI
AS
BEGIN
    PRINT 'Iniciando migración de BI...';
    
    PRINT '1. Migrando dimensión Tiempo...';
    EXEC TP_APROBADO.SP_Migrar_Dim_Tiempo;
    
    PRINT '2. Migrando dimensión Canal de Venta...';
    EXEC TP_APROBADO.SP_Migrar_Dim_Canal_Venta;
    
    PRINT '3. Migrando dimensión Estado de Propuesta...';
    EXEC TP_APROBADO.SP_Migrar_Dim_Estado_Propuesta;
    
    PRINT '4. Migrando dimensión Aspecto...';
    EXEC TP_APROBADO.SP_Migrar_Dim_Aspecto;
    
    PRINT '5. Migrando Fact Ventas...';
    EXEC TP_APROBADO.SP_Migrar_Fact_Ventas;
    
    PRINT '6. Migrando Fact Solicitudes...';
    EXEC TP_APROBADO.SP_Migrar_Fact_Solicitudes;
    
    PRINT '7. Migrando Fact Propuestas...';
    EXEC TP_APROBADO.SP_Migrar_Fact_Propuestas;
    
    PRINT '8. Migrando Fact Encuestas...';
    EXEC TP_APROBADO.SP_Migrar_Fact_Encuestas;
    
    PRINT 'Migración de BI completada.';
END;
GO

-- ============================================================================
-- EJECUCION DE LA MIGRACION
-- ============================================================================

EXEC TP_APROBADO.SP_Migrar_BI;
GO

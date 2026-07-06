/* 
   SCRIPT DE CREACIÓN Y CARGA DEL MODELO DE BI 
*/

USE GD1C2026;
GO

SET NOCOUNT ON;
GO

/* 
   LIMPIEZA DE OBJETOS BI
*/
IF OBJECT_ID('TP_APROBADO.BI_Vista_01_Ticket_Promedio') IS NOT NULL DROP VIEW TP_APROBADO.BI_Vista_01_Ticket_Promedio;
IF OBJECT_ID('TP_APROBADO.BI_Vista_02_Distribucion_Facturacion') IS NOT NULL DROP VIEW TP_APROBADO.BI_Vista_02_Distribucion_Facturacion;
IF OBJECT_ID('TP_APROBADO.BI_Vista_03_Ranking_Solicitudes_Temporada') IS NOT NULL DROP VIEW TP_APROBADO.BI_Vista_03_Ranking_Solicitudes_Temporada;
IF OBJECT_ID('TP_APROBADO.BI_Vista_04_Anticipacion_Promedio_Solicitudes') IS NOT NULL DROP VIEW TP_APROBADO.BI_Vista_04_Anticipacion_Promedio_Solicitudes;
IF OBJECT_ID('TP_APROBADO.BI_Vista_05_Tasa_Aceptacion_Propuestas') IS NOT NULL DROP VIEW TP_APROBADO.BI_Vista_05_Tasa_Aceptacion_Propuestas;
IF OBJECT_ID('TP_APROBADO.BI_Vista_06_Cotizacion_Promedio_Temporada') IS NOT NULL DROP VIEW TP_APROBADO.BI_Vista_06_Cotizacion_Promedio_Temporada;
IF OBJECT_ID('TP_APROBADO.BI_Vista_07_Tiempo_Promedio_Respuesta') IS NOT NULL DROP VIEW TP_APROBADO.BI_Vista_07_Tiempo_Promedio_Respuesta;
IF OBJECT_ID('TP_APROBADO.BI_Vista_08_Desvio_Presupuesto') IS NOT NULL DROP VIEW TP_APROBADO.BI_Vista_08_Desvio_Presupuesto;
IF OBJECT_ID('TP_APROBADO.BI_Vista_09_Ranking_Aspectos_Valorados') IS NOT NULL DROP VIEW TP_APROBADO.BI_Vista_09_Ranking_Aspectos_Valorados;
IF OBJECT_ID('TP_APROBADO.BI_Vista_10_Satisfaccion_Promedio_Agente') IS NOT NULL DROP VIEW TP_APROBADO.BI_Vista_10_Satisfaccion_Promedio_Agente;

IF OBJECT_ID('TP_APROBADO.SP_Migrar_BI') IS NOT NULL DROP PROCEDURE TP_APROBADO.SP_Migrar_BI;
IF OBJECT_ID('TP_APROBADO.SP_Migrar_Dim_Rango_Etario') IS NOT NULL DROP PROCEDURE TP_APROBADO.SP_Migrar_Dim_Rango_Etario;
IF OBJECT_ID('TP_APROBADO.SP_Migrar_Dim_Temporada') IS NOT NULL DROP PROCEDURE TP_APROBADO.SP_Migrar_Dim_Temporada;
IF OBJECT_ID('TP_APROBADO.SP_Migrar_Dim_Tipo_Servicio') IS NOT NULL DROP PROCEDURE TP_APROBADO.SP_Migrar_Dim_Tipo_Servicio;
IF OBJECT_ID('TP_APROBADO.SP_Migrar_Dim_Canal_Venta') IS NOT NULL DROP PROCEDURE TP_APROBADO.SP_Migrar_Dim_Canal_Venta;
IF OBJECT_ID('TP_APROBADO.SP_Migrar_Dim_Estado_Propuesta') IS NOT NULL DROP PROCEDURE TP_APROBADO.SP_Migrar_Dim_Estado_Propuesta;
IF OBJECT_ID('TP_APROBADO.SP_Migrar_Dim_Aspecto') IS NOT NULL DROP PROCEDURE TP_APROBADO.SP_Migrar_Dim_Aspecto;
IF OBJECT_ID('TP_APROBADO.SP_Migrar_Dim_Tiempo') IS NOT NULL DROP PROCEDURE TP_APROBADO.SP_Migrar_Dim_Tiempo;
IF OBJECT_ID('TP_APROBADO.SP_Migrar_Fact_Ventas') IS NOT NULL DROP PROCEDURE TP_APROBADO.SP_Migrar_Fact_Ventas;
IF OBJECT_ID('TP_APROBADO.SP_Migrar_Fact_Solicitudes') IS NOT NULL DROP PROCEDURE TP_APROBADO.SP_Migrar_Fact_Solicitudes;
IF OBJECT_ID('TP_APROBADO.SP_Migrar_Fact_Propuestas') IS NOT NULL DROP PROCEDURE TP_APROBADO.SP_Migrar_Fact_Propuestas;
IF OBJECT_ID('TP_APROBADO.SP_Migrar_Fact_Encuestas') IS NOT NULL DROP PROCEDURE TP_APROBADO.SP_Migrar_Fact_Encuestas;

IF OBJECT_ID('TP_APROBADO.fn_ObtenerTiempo') IS NOT NULL DROP FUNCTION TP_APROBADO.fn_ObtenerTiempo;
IF OBJECT_ID('TP_APROBADO.fn_ObtenerTemporada') IS NOT NULL DROP FUNCTION TP_APROBADO.fn_ObtenerTemporada;
IF OBJECT_ID('TP_APROBADO.fn_ObtenerRangoEtario') IS NOT NULL DROP FUNCTION TP_APROBADO.fn_ObtenerRangoEtario;

IF OBJECT_ID('TP_APROBADO.BI_Fact_Ventas') IS NOT NULL DROP TABLE TP_APROBADO.BI_Fact_Ventas;
IF OBJECT_ID('TP_APROBADO.BI_Fact_Solicitudes') IS NOT NULL DROP TABLE TP_APROBADO.BI_Fact_Solicitudes;
IF OBJECT_ID('TP_APROBADO.BI_Fact_Propuestas') IS NOT NULL DROP TABLE TP_APROBADO.BI_Fact_Propuestas;
IF OBJECT_ID('TP_APROBADO.BI_Fact_Encuestas') IS NOT NULL DROP TABLE TP_APROBADO.BI_Fact_Encuestas;

IF OBJECT_ID('TP_APROBADO.BI_Dim_Tiempo') IS NOT NULL DROP TABLE TP_APROBADO.BI_Dim_Tiempo;
IF OBJECT_ID('TP_APROBADO.BI_Dim_Rango_Etario') IS NOT NULL DROP TABLE TP_APROBADO.BI_Dim_Rango_Etario;
IF OBJECT_ID('TP_APROBADO.BI_Dim_Temporada') IS NOT NULL DROP TABLE TP_APROBADO.BI_Dim_Temporada;
IF OBJECT_ID('TP_APROBADO.BI_Dim_Tipo_Servicio') IS NOT NULL DROP TABLE TP_APROBADO.BI_Dim_Tipo_Servicio;
IF OBJECT_ID('TP_APROBADO.BI_Dim_Canal_Venta') IS NOT NULL DROP TABLE TP_APROBADO.BI_Dim_Canal_Venta;
IF OBJECT_ID('TP_APROBADO.BI_Dim_Estado_Propuesta') IS NOT NULL DROP TABLE TP_APROBADO.BI_Dim_Estado_Propuesta;
IF OBJECT_ID('TP_APROBADO.BI_Dim_Aspecto') IS NOT NULL DROP TABLE TP_APROBADO.BI_Dim_Aspecto;
GO


/*
   CREACIÓN DE TABLAS DIMENSIONALES
*/

-- Tiempo a nivel mes (año / cuatrimestre / mes).
CREATE TABLE TP_APROBADO.BI_Dim_Tiempo (
    Tiempo_ID int IDENTITY(1,1) NOT NULL,
    Tiempo_Anio int NOT NULL,
    Tiempo_Cuatrimestre int NOT NULL,
    Tiempo_Mes int NOT NULL,
    CONSTRAINT PK_BI_Dim_Tiempo PRIMARY KEY (Tiempo_ID),
    CONSTRAINT UQ_BI_Dim_Tiempo UNIQUE (Tiempo_Anio, Tiempo_Mes)
);
GO

-- Rango etario. Los límites permiten clasificar la edad.
CREATE TABLE TP_APROBADO.BI_Dim_Rango_Etario (
    Rango_Etario_ID int IDENTITY(1,1) NOT NULL,
    Rango_Etario_Descripcion nvarchar(100) NOT NULL,
    Rango_Edad_Desde int NULL,
    Rango_Edad_Hasta int NULL,
    CONSTRAINT PK_BI_Dim_Rango_Etario PRIMARY KEY (Rango_Etario_ID)
);
GO

-- Temporada 
CREATE TABLE TP_APROBADO.BI_Dim_Temporada (
    Temporada_ID int IDENTITY(1,1) NOT NULL,
    Temporada_Nombre nvarchar(50) NOT NULL,
    Temporada_Mes_Desde int NOT NULL,
    Temporada_Mes_Hasta int NOT NULL,
    CONSTRAINT PK_BI_Dim_Temporada PRIMARY KEY (Temporada_ID)
);
GO

-- Tipo de servicio (venta directa vs propuesta a medida)
CREATE TABLE TP_APROBADO.BI_Dim_Tipo_Servicio (
    Tipo_Servicio_ID int IDENTITY(1,1) NOT NULL,
    Tipo_Servicio_Nombre nvarchar(50) NOT NULL,
    CONSTRAINT PK_BI_Dim_Tipo_Servicio PRIMARY KEY (Tipo_Servicio_ID)
);
GO

-- Canal de venta. 
CREATE TABLE TP_APROBADO.BI_Dim_Canal_Venta (
    Canal_Venta_ID int IDENTITY(1,1) NOT NULL,
    Canal_Venta_Codigo bigint NOT NULL,
    Canal_Venta_Nombre nvarchar(400) NULL,
    CONSTRAINT PK_BI_Dim_Canal_Venta PRIMARY KEY (Canal_Venta_ID)
);
GO

-- Estado de propuesta. 
CREATE TABLE TP_APROBADO.BI_Dim_Estado_Propuesta (
    Estado_Propuesta_ID int IDENTITY(1,1) NOT NULL,
    Estado_Propuesta_Codigo bigint NOT NULL,
    Estado_Propuesta_Nombre nvarchar(400) NULL,
    CONSTRAINT PK_BI_Dim_Estado_Propuesta PRIMARY KEY (Estado_Propuesta_ID)
);
GO

-- Aspecto evaluado en encuestas
CREATE TABLE TP_APROBADO.BI_Dim_Aspecto (
    Aspecto_ID int IDENTITY(1,1) NOT NULL,
    Aspecto_Codigo smallint NOT NULL,
    Aspecto_Nombre nvarchar(510) NULL,
    CONSTRAINT PK_BI_Dim_Aspecto PRIMARY KEY (Aspecto_ID)
);
GO

-- TABLAS DE HECHOS --------------------------------------------------------------------
-- Agregamos campos SUMARIZADOS y CONTADORES de operaciones

CREATE TABLE TP_APROBADO.BI_Fact_Ventas (
    Fact_Venta_ID int IDENTITY(1,1) NOT NULL,
    Tiempo_ID int NOT NULL,
    Rango_Etario_Cliente_ID int NOT NULL, 
    Canal_Venta_ID int NOT NULL,
    Tipo_Servicio_ID int NOT NULL,
    -- Campos Pre-Calculados Sumarizados
    Venta_Importe_Total_Suma decimal(18,2) NULL,
    Venta_Cantidad_Operaciones int NULL, -- Contador para promedios
    CONSTRAINT PK_BI_Fact_Ventas PRIMARY KEY (Fact_Venta_ID),
    CONSTRAINT FK_BI_Fact_Ventas_Tiempo FOREIGN KEY (Tiempo_ID) REFERENCES TP_APROBADO.BI_Dim_Tiempo (Tiempo_ID),
    CONSTRAINT FK_BI_Fact_Ventas_Rango_Etario FOREIGN KEY (Rango_Etario_Cliente_ID) REFERENCES TP_APROBADO.BI_Dim_Rango_Etario (Rango_Etario_ID),
    CONSTRAINT FK_BI_Fact_Ventas_Canal FOREIGN KEY (Canal_Venta_ID) REFERENCES TP_APROBADO.BI_Dim_Canal_Venta (Canal_Venta_ID),
    CONSTRAINT FK_BI_Fact_Ventas_Tipo_Servicio FOREIGN KEY (Tipo_Servicio_ID) REFERENCES TP_APROBADO.BI_Dim_Tipo_Servicio (Tipo_Servicio_ID)
);
GO

CREATE TABLE TP_APROBADO.BI_Fact_Solicitudes (
    Fact_Solicitud_ID int IDENTITY(1,1) NOT NULL,
    Tiempo_ID int NOT NULL,
    Temporada_ID int NOT NULL,
    Rango_Etario_Cliente_ID int NOT NULL,
    -- Campos Pre-Calculados Sumarizados
    Solicitud_Dias_Anticipacion_Suma int NULL,
    Solicitud_Cantidad int NULL, -- Contador
    CONSTRAINT PK_BI_Fact_Solicitudes PRIMARY KEY (Fact_Solicitud_ID),
    CONSTRAINT FK_BI_Fact_Solicitudes_Tiempo FOREIGN KEY (Tiempo_ID) REFERENCES TP_APROBADO.BI_Dim_Tiempo (Tiempo_ID),
    CONSTRAINT FK_BI_Fact_Solicitudes_Temporada FOREIGN KEY (Temporada_ID) REFERENCES TP_APROBADO.BI_Dim_Temporada (Temporada_ID),
    CONSTRAINT FK_BI_Fact_Solicitudes_Rango_Etario FOREIGN KEY (Rango_Etario_Cliente_ID) REFERENCES TP_APROBADO.BI_Dim_Rango_Etario (Rango_Etario_ID)
);
GO
 
CREATE TABLE TP_APROBADO.BI_Fact_Propuestas (
    Fact_Propuesta_ID int IDENTITY(1,1) NOT NULL,
    Tiempo_Solicitud_ID int NOT NULL,
    Tiempo_Emision_ID int NOT NULL,
    Tiempo_Inicio_Viaje_ID int NOT NULL,
    Temporada_ID int NOT NULL,
    Rango_Etario_Agente_ID int NOT NULL,
    Estado_Propuesta_ID int NOT NULL,
    -- Campos Pre-Calculados Sumarizados
    Propuesta_Importe_Total_Suma decimal(18,2) NULL,
    Propuesta_Dias_Respuesta_Suma int NULL,
    Propuesta_Desvio_Presupuesto_Suma decimal(18,2) NULL,
    Propuesta_Cantidad int NULL, -- Contador
    CONSTRAINT PK_BI_Fact_Propuestas PRIMARY KEY (Fact_Propuesta_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Tiempo_Solicitud FOREIGN KEY (Tiempo_Solicitud_ID) REFERENCES TP_APROBADO.BI_Dim_Tiempo (Tiempo_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Tiempo_Emision FOREIGN KEY (Tiempo_Emision_ID) REFERENCES TP_APROBADO.BI_Dim_Tiempo (Tiempo_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Tiempo_Inicio_Viaje FOREIGN KEY (Tiempo_Inicio_Viaje_ID) REFERENCES TP_APROBADO.BI_Dim_Tiempo (Tiempo_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Temporada FOREIGN KEY (Temporada_ID) REFERENCES TP_APROBADO.BI_Dim_Temporada (Temporada_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Rango_Etario FOREIGN KEY (Rango_Etario_Agente_ID) REFERENCES TP_APROBADO.BI_Dim_Rango_Etario (Rango_Etario_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Estado FOREIGN KEY (Estado_Propuesta_ID) REFERENCES TP_APROBADO.BI_Dim_Estado_Propuesta (Estado_Propuesta_ID)
);
GO

CREATE TABLE TP_APROBADO.BI_Fact_Encuestas (
    Fact_Encuesta_ID int IDENTITY(1,1) NOT NULL,
    Tiempo_ID int NOT NULL,
    Rango_Etario_Agente_ID int NOT NULL,
    Aspecto_ID int NOT NULL,
    -- Campos Pre-Calculados Sumarizados
    Encuesta_Puntaje_Suma int NULL,
    Encuesta_Cantidad int NULL, -- Contador 
    CONSTRAINT PK_BI_Fact_Encuestas PRIMARY KEY (Fact_Encuesta_ID),
    CONSTRAINT FK_BI_Fact_Encuestas_Tiempo FOREIGN KEY (Tiempo_ID) REFERENCES TP_APROBADO.BI_Dim_Tiempo (Tiempo_ID),
    CONSTRAINT FK_BI_Fact_Encuestas_Rango_Etario FOREIGN KEY (Rango_Etario_Agente_ID) REFERENCES TP_APROBADO.BI_Dim_Rango_Etario (Rango_Etario_ID),
    CONSTRAINT FK_BI_Fact_Encuestas_Aspecto FOREIGN KEY (Aspecto_ID) REFERENCES TP_APROBADO.BI_Dim_Aspecto (Aspecto_ID)
);
GO


/* 
   FUNCIONES AUXILIARES
*/
CREATE OR ALTER FUNCTION TP_APROBADO.fn_ObtenerTiempo (@fecha date)
RETURNS int
AS
BEGIN
    DECLARE @id int;
    SELECT @id = Tiempo_ID
    FROM TP_APROBADO.BI_Dim_Tiempo
    WHERE Tiempo_Anio = YEAR(@fecha) AND Tiempo_Mes = MONTH(@fecha);
    RETURN ISNULL(@id, -1); -- Evita nulos en la tabla de hechos
END;
GO

CREATE OR ALTER FUNCTION TP_APROBADO.fn_ObtenerTemporada (@fecha date)
RETURNS int
AS
BEGIN
    DECLARE @mes int = MONTH(@fecha);
    DECLARE @id int;
    SELECT @id = Temporada_ID
    FROM TP_APROBADO.BI_Dim_Temporada
    WHERE @mes BETWEEN Temporada_Mes_Desde AND Temporada_Mes_Hasta;
    RETURN ISNULL(@id, -1);
END;
GO

CREATE OR ALTER FUNCTION TP_APROBADO.fn_ObtenerRangoEtario (@fecha_nacimiento date, @fecha_referencia date)
RETURNS int
AS
BEGIN
    DECLARE @edad int;
    DECLARE @id int;
    SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, @fecha_referencia)
              - CASE WHEN MONTH(@fecha_nacimiento) > MONTH(@fecha_referencia)
                       OR (MONTH(@fecha_nacimiento) = MONTH(@fecha_referencia)
                           AND DAY(@fecha_nacimiento) > DAY(@fecha_referencia))
                     THEN 1 ELSE 0 END;
    SELECT @id = Rango_Etario_ID
    FROM TP_APROBADO.BI_Dim_Rango_Etario
    WHERE @edad > ISNULL(Rango_Edad_Desde, -1)
      AND @edad <= ISNULL(Rango_Edad_Hasta, 999);
    RETURN ISNULL(@id, 1); 
END;
GO


/*
   PROCEDURES DE MIGRACIÓN DIMENSIONAL
*/

CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Dim_Rango_Etario
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Dim_Rango_Etario (Rango_Etario_Descripcion, Rango_Edad_Desde, Rango_Edad_Hasta)
    VALUES ('Menores de 25 años inclusive', NULL, 25),
           ('Entre 25 y 35 años inclusive', 25, 35),
           ('Entre 35 y 50 años inclusive', 35, 50),
           ('Mayores de 50 años', 50, NULL);
END;
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Dim_Temporada
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Dim_Temporada (Temporada_Nombre, Temporada_Mes_Desde, Temporada_Mes_Hasta)
    VALUES ('Verano', 1, 3), ('Otoño', 4, 6), ('Invierno', 7, 9), ('Primavera', 10, 12);
END;
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Dim_Tipo_Servicio
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Dim_Tipo_Servicio (Tipo_Servicio_Nombre)
    VALUES ('Venta Directa'), ('Propuesta a Medida');
END;
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Dim_Canal_Venta
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Dim_Canal_Venta (Canal_Venta_Codigo, Canal_Venta_Nombre)
    SELECT Canal_Venta_Codigo, Canal_Venta_Nombre FROM TP_APROBADO.Canal_Venta;
END;
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Dim_Estado_Propuesta
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Dim_Estado_Propuesta (Estado_Propuesta_Codigo, Estado_Propuesta_Nombre)
    SELECT Estado_Codigo, Estado_Nombre FROM TP_APROBADO.Estado;
END;
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Dim_Aspecto
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Dim_Aspecto (Aspecto_Codigo, Aspecto_Nombre)
    SELECT Aspecto_Codigo, Aspecto_Aspecto FROM TP_APROBADO.Aspecto;
END;
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Dim_Tiempo
AS
BEGIN
    -- Capturamos todos los años y meses posibles de las tablas principales
    WITH Fechas AS (
        SELECT Venta_Fecha_Venta AS Fch FROM TP_APROBADO.Venta WHERE Venta_Fecha_Venta IS NOT NULL
        UNION SELECT Solicitud_Fecha_solicitud FROM TP_APROBADO.Solicitud WHERE Solicitud_Fecha_solicitud IS NOT NULL
        UNION SELECT Propuesta_Fecha_Emision FROM TP_APROBADO.Propuesta WHERE Propuesta_Fecha_Emision IS NOT NULL
        UNION SELECT Propuesta_Fecha_Desde FROM TP_APROBADO.Propuesta WHERE Propuesta_Fecha_Desde IS NOT NULL
        UNION SELECT Encuesta_Fecha_Encuesta FROM TP_APROBADO.Encuesta WHERE Encuesta_Fecha_Encuesta IS NOT NULL
    )
    INSERT INTO TP_APROBADO.BI_Dim_Tiempo (Tiempo_Anio, Tiempo_Cuatrimestre, Tiempo_Mes)
    SELECT DISTINCT
        YEAR(Fch),
        CASE 
            WHEN MONTH(Fch) BETWEEN 1 AND 4 THEN 1
            WHEN MONTH(Fch) BETWEEN 5 AND 8 THEN 2
            ELSE 3
        END,
        MONTH(Fch)
    FROM Fechas
    WHERE NOT EXISTS (
        SELECT 1 FROM TP_APROBADO.BI_Dim_Tiempo t 
        WHERE t.Tiempo_Anio = YEAR(Fch) AND t.Tiempo_Mes = MONTH(Fch)
    );
    
    -- Agregamos un registro "comodín" por si hay fechas nulas inevitables
    IF NOT EXISTS (SELECT 1 FROM TP_APROBADO.BI_Dim_Tiempo WHERE Tiempo_Anio = 1900)
    BEGIN
        INSERT INTO TP_APROBADO.BI_Dim_Tiempo (Tiempo_Anio, Tiempo_Cuatrimestre, Tiempo_Mes) VALUES (1900, 1, 1);
    END
END;
GO

/*
   PROCEDURES DE MIGRACIÓN DE HECHOS (CON AGRUPACIÓN)
*/

CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Fact_Ventas
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Fact_Ventas (
        Tiempo_ID, Rango_Etario_Cliente_ID, Canal_Venta_ID, Tipo_Servicio_ID,
        Venta_Importe_Total_Suma, Venta_Cantidad_Operaciones)
    SELECT
        TP_APROBADO.fn_ObtenerTiempo(v.Venta_Fecha_Venta) AS Tiempo_ID,
        TP_APROBADO.fn_ObtenerRangoEtario(c.Cliente_Fecha_Nac, v.Venta_Fecha_Venta) AS Rango_Etario_Cliente_ID,
        dc.Canal_Venta_ID,
        CASE WHEN v.Venta_Propuesta IS NULL THEN 1 ELSE 2 END AS Tipo_Servicio_ID,
        -- CAMPOS SUMARIZADOS
        SUM(v.Venta_Importe_Total) AS Venta_Importe_Total_Suma,
        COUNT(v.Venta_Nro_Venta) AS Venta_Cantidad_Operaciones
    FROM TP_APROBADO.Venta v
    LEFT JOIN TP_APROBADO.Cliente c
        ON v.Venta_Cliente_Dni = c.Cliente_Dni AND v.Venta_Cliente_Mail = c.Cliente_Mail
    JOIN TP_APROBADO.BI_Dim_Canal_Venta dc
        ON v.Venta_Canal_Venta = dc.Canal_Venta_Codigo
    WHERE v.Venta_Fecha_Venta IS NOT NULL
    -- AGRUPAMOS
    GROUP BY 
        TP_APROBADO.fn_ObtenerTiempo(v.Venta_Fecha_Venta),
        TP_APROBADO.fn_ObtenerRangoEtario(c.Cliente_Fecha_Nac, v.Venta_Fecha_Venta),
        dc.Canal_Venta_ID,
        CASE WHEN v.Venta_Propuesta IS NULL THEN 1 ELSE 2 END;
END;
GO


CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Fact_Solicitudes
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Fact_Solicitudes (
        Tiempo_ID, Temporada_ID, Rango_Etario_Cliente_ID, 
        Solicitud_Dias_Anticipacion_Suma, Solicitud_Cantidad)
    SELECT
        TP_APROBADO.fn_ObtenerTiempo(s.Solicitud_Fecha_solicitud) AS Tiempo_ID,
        TP_APROBADO.fn_ObtenerTemporada(s.Solicitud_Fecha_solicitud) AS Temporada_ID,
        TP_APROBADO.fn_ObtenerRangoEtario(c.Cliente_Fecha_Nac, s.Solicitud_Fecha_solicitud) AS Rango_Etario_Cliente_ID,
        -- CAMPOS SUMARIZADOS
        SUM(DATEDIFF(DAY, s.Solicitud_Fecha_solicitud, s.Solicitud_Fecha_Inicio_Tentativa)) AS Solicitud_Dias_Anticipacion_Suma,
        COUNT(s.Solicitud_Nro_Solicitud) AS Solicitud_Cantidad
    FROM TP_APROBADO.Solicitud s
    LEFT JOIN TP_APROBADO.Cliente c
        ON s.Solicitud_Cliente_Dni = c.Cliente_Dni AND s.Solicitud_Cliente_Mail = c.Cliente_Mail
    WHERE s.Solicitud_Fecha_solicitud IS NOT NULL
    -- AGRUPAMOS
    GROUP BY 
        TP_APROBADO.fn_ObtenerTiempo(s.Solicitud_Fecha_solicitud),
        TP_APROBADO.fn_ObtenerTemporada(s.Solicitud_Fecha_solicitud),
        TP_APROBADO.fn_ObtenerRangoEtario(c.Cliente_Fecha_Nac, s.Solicitud_Fecha_solicitud);
END;
GO


CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Fact_Propuestas
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Fact_Propuestas (
        Tiempo_Solicitud_ID, Tiempo_Emision_ID, Tiempo_Inicio_Viaje_ID, Temporada_ID, 
        Rango_Etario_Agente_ID, Estado_Propuesta_ID, 
        Propuesta_Importe_Total_Suma, Propuesta_Dias_Respuesta_Suma, Propuesta_Desvio_Presupuesto_Suma, Propuesta_Cantidad)
    SELECT
        TP_APROBADO.fn_ObtenerTiempo(s.Solicitud_Fecha_solicitud) AS Tiempo_Solicitud_ID,
        TP_APROBADO.fn_ObtenerTiempo(p.Propuesta_Fecha_Emision) AS Tiempo_Emision_ID,
        TP_APROBADO.fn_ObtenerTiempo(p.Propuesta_Fecha_Desde) AS Tiempo_Inicio_Viaje_ID,
        TP_APROBADO.fn_ObtenerTemporada(p.Propuesta_Fecha_Desde) AS Temporada_ID,
        TP_APROBADO.fn_ObtenerRangoEtario(a.Agente_Fecha_Nac, p.Propuesta_Fecha_Emision) AS Rango_Etario_Agente_ID,
        de.Estado_Propuesta_ID,
        -- CAMPOS SUMARIZADOS
        SUM(p.Propuesta_Importe_Total) AS Propuesta_Importe_Total_Suma,
        SUM(DATEDIFF(DAY, s.Solicitud_Fecha_solicitud, p.Propuesta_Fecha_Emision)) AS Propuesta_Dias_Respuesta_Suma,
        SUM(p.Propuesta_Importe_Total - s.Solicitud_Presupuesto_Estimado) AS Propuesta_Desvio_Presupuesto_Suma,
        COUNT(p.Propuesta_Nro_Propuesta) AS Propuesta_Cantidad
    FROM TP_APROBADO.Propuesta p
    JOIN TP_APROBADO.Solicitud s
        ON p.Solicitud_Nro_Solicitud = s.Solicitud_Nro_Solicitud
    LEFT JOIN TP_APROBADO.Agente a
        ON p.Propuesta_Agente = a.Agente_Legajo
    JOIN TP_APROBADO.BI_Dim_Estado_Propuesta de
        ON p.Propuesta_Estado = de.Estado_Propuesta_Codigo
    WHERE s.Solicitud_Fecha_solicitud IS NOT NULL
      AND p.Propuesta_Fecha_Emision IS NOT NULL
      AND p.Propuesta_Fecha_Desde IS NOT NULL
    -- AGRUPAMOS
    GROUP BY
        TP_APROBADO.fn_ObtenerTiempo(s.Solicitud_Fecha_solicitud),
        TP_APROBADO.fn_ObtenerTiempo(p.Propuesta_Fecha_Emision),
        TP_APROBADO.fn_ObtenerTiempo(p.Propuesta_Fecha_Desde),
        TP_APROBADO.fn_ObtenerTemporada(p.Propuesta_Fecha_Desde),
        TP_APROBADO.fn_ObtenerRangoEtario(a.Agente_Fecha_Nac, p.Propuesta_Fecha_Emision),
        de.Estado_Propuesta_ID;
END;
GO


CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Fact_Encuestas
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Fact_Encuestas (
        Tiempo_ID, Rango_Etario_Agente_ID, Aspecto_ID, 
        Encuesta_Puntaje_Suma, Encuesta_Cantidad)
    SELECT
        TP_APROBADO.fn_ObtenerTiempo(e.Encuesta_Fecha_Encuesta) AS Tiempo_ID,
        TP_APROBADO.fn_ObtenerRangoEtario(a.Agente_Fecha_Nac, e.Encuesta_Fecha_Encuesta) AS Rango_Etario_Agente_ID,
        da.Aspecto_ID,
        -- CAMPOS SUMARIZADOS
        SUM(de.Detalle_Encuesta_Puntaje) AS Encuesta_Puntaje_Suma,
        COUNT(de.Encuesta_Nro_Encuesta) AS Encuesta_Cantidad
    FROM TP_APROBADO.Detalle_Encuesta de
    JOIN TP_APROBADO.Encuesta e
        ON de.Encuesta_Nro_Encuesta = e.Encuesta_Codigo_Encuesta
    JOIN TP_APROBADO.BI_Dim_Aspecto da
        ON de.Detalle_Encuesta_Aspecto_Codigo = da.Aspecto_Codigo
    LEFT JOIN TP_APROBADO.Agente a
        ON a.Agente_Legajo = e.Encuesta_Agente
    WHERE e.Encuesta_Fecha_Encuesta IS NOT NULL
    -- AGRUPAMOS
    GROUP BY
        TP_APROBADO.fn_ObtenerTiempo(e.Encuesta_Fecha_Encuesta),
        TP_APROBADO.fn_ObtenerRangoEtario(a.Agente_Fecha_Nac, e.Encuesta_Fecha_Encuesta),
        da.Aspecto_ID;
END;
GO


-- PROCEDURE ORQUESTADOR ---------------------------------------------------------------
CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_BI
AS
BEGIN
    EXEC TP_APROBADO.SP_Migrar_Dim_Rango_Etario;
    EXEC TP_APROBADO.SP_Migrar_Dim_Temporada;
    EXEC TP_APROBADO.SP_Migrar_Dim_Tipo_Servicio;
    EXEC TP_APROBADO.SP_Migrar_Dim_Canal_Venta;
    EXEC TP_APROBADO.SP_Migrar_Dim_Estado_Propuesta;
    EXEC TP_APROBADO.SP_Migrar_Dim_Aspecto;
    EXEC TP_APROBADO.SP_Migrar_Dim_Tiempo;

    EXEC TP_APROBADO.SP_Migrar_Fact_Ventas;
    EXEC TP_APROBADO.SP_Migrar_Fact_Solicitudes;
    EXEC TP_APROBADO.SP_Migrar_Fact_Propuestas;
    EXEC TP_APROBADO.SP_Migrar_Fact_Encuestas;
END;
GO


/* 
   EJECUCIÓN DE LA MIGRACIÓN BI
*/
EXEC TP_APROBADO.SP_Migrar_BI;
GO


/* 
   VISTAS 
*/

-- VISTA 1. Ticket promedio.
-- CÁLCULO: SUMA(Importes) / SUMA(Cantidad_Operaciones)
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_01_Ticket_Promedio AS
SELECT
    t.Tiempo_Anio AS Anio, 
    t.Tiempo_Mes AS Mes,
    r.Rango_Etario_Descripcion AS Rango_Etario_Cliente,
    c.Canal_Venta_Nombre AS Canal_Venta,
    CAST(SUM(v.Venta_Importe_Total_Suma) / NULLIF(SUM(v.Venta_Cantidad_Operaciones), 0) AS decimal(18,2)) AS Ticket_Promedio
FROM TP_APROBADO.BI_Fact_Ventas v
JOIN TP_APROBADO.BI_Dim_Tiempo t ON v.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Rango_Etario r ON v.Rango_Etario_Cliente_ID = r.Rango_Etario_ID
JOIN TP_APROBADO.BI_Dim_Canal_Venta c ON v.Canal_Venta_ID = c.Canal_Venta_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Mes, r.Rango_Etario_Descripcion, c.Canal_Venta_Nombre;
GO

-- VISTA 2. Distribución de facturación.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_02_Distribucion_Facturacion AS
WITH Totales AS (
    SELECT 
        t.Tiempo_Anio, 
        t.Tiempo_Cuatrimestre, 
        ts.Tipo_Servicio_Nombre,
        SUM(v.Venta_Importe_Total_Suma) AS Total_Servicio
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
FROM Totales;
GO

-- VISTA 3. Ranking de solicitudes por temporada.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_03_Ranking_Solicitudes_Temporada AS
SELECT
    t.Tiempo_Anio AS Anio, 
    temp.Temporada_Nombre AS Temporada,
    r.Rango_Etario_Descripcion AS Rango_Etario_Cliente,
    SUM(s.Solicitud_Cantidad) AS Cantidad_Solicitudes
FROM TP_APROBADO.BI_Fact_Solicitudes s
JOIN TP_APROBADO.BI_Dim_Tiempo t ON s.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Temporada temp ON s.Temporada_ID = temp.Temporada_ID
JOIN TP_APROBADO.BI_Dim_Rango_Etario r ON s.Rango_Etario_Cliente_ID = r.Rango_Etario_ID
GROUP BY t.Tiempo_Anio, temp.Temporada_Nombre, r.Rango_Etario_Descripcion;
GO

-- VISTA 4. Anticipación promedio de solicitudes.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_04_Anticipacion_Promedio_Solicitudes AS
SELECT
    t.Tiempo_Anio AS Anio, 
    t.Tiempo_Cuatrimestre AS Cuatrimestre,
    r.Rango_Etario_Descripcion AS Rango_Etario_Cliente,
    CAST(CAST(SUM(s.Solicitud_Dias_Anticipacion_Suma) AS decimal(18,2)) / NULLIF(SUM(s.Solicitud_Cantidad), 0) AS decimal(18,2)) AS Anticipacion_Promedio_Dias
FROM TP_APROBADO.BI_Fact_Solicitudes s
JOIN TP_APROBADO.BI_Dim_Tiempo t ON s.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Rango_Etario r ON s.Rango_Etario_Cliente_ID = r.Rango_Etario_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Cuatrimestre, r.Rango_Etario_Descripcion;
GO

-- VISTA 5. Tasa de aceptación de propuestas.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_05_Tasa_Aceptacion_Propuestas AS
SELECT
    t.Tiempo_Anio AS Anio,
    t.Tiempo_Cuatrimestre AS Cuatrimestre,
    CAST((SUM(CASE WHEN ep.Estado_Propuesta_Nombre LIKE '%Aceptad%' THEN p.Propuesta_Cantidad ELSE 0 END) * 100.0) 
         / NULLIF(SUM(p.Propuesta_Cantidad), 0) AS decimal(18,2)) AS Tasa_Aceptacion_Porcentaje
FROM TP_APROBADO.BI_Fact_Propuestas p
JOIN TP_APROBADO.BI_Dim_Tiempo t ON p.Tiempo_Emision_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Estado_Propuesta ep ON p.Estado_Propuesta_ID = ep.Estado_Propuesta_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Cuatrimestre;
GO

-- VISTA 6. Cotización promedio por temporada.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_06_Cotizacion_Promedio_Temporada AS
SELECT
    t.Tiempo_Anio AS Anio,
    temp.Temporada_Nombre AS Temporada_Viaje,
    CAST(SUM(p.Propuesta_Importe_Total_Suma) / NULLIF(SUM(p.Propuesta_Cantidad), 0) AS decimal(18,2)) AS Cotizacion_Promedio
FROM TP_APROBADO.BI_Fact_Propuestas p
JOIN TP_APROBADO.BI_Dim_Tiempo t ON p.Tiempo_Inicio_Viaje_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Temporada temp ON p.Temporada_ID = temp.Temporada_ID
GROUP BY t.Tiempo_Anio, temp.Temporada_Nombre;
GO

-- VISTA 7. Tiempo promedio de respuesta.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_07_Tiempo_Promedio_Respuesta AS
SELECT
    t.Tiempo_Anio AS Anio, 
    t.Tiempo_Mes AS Mes,
    r.Rango_Etario_Descripcion AS Rango_Etario_Agente,
    CAST(CAST(SUM(p.Propuesta_Dias_Respuesta_Suma) AS decimal(18,2)) / NULLIF(SUM(p.Propuesta_Cantidad), 0) AS decimal(18,2)) AS Tiempo_Respuesta_Promedio_Dias
FROM TP_APROBADO.BI_Fact_Propuestas p
JOIN TP_APROBADO.BI_Dim_Tiempo t ON p.Tiempo_Solicitud_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Rango_Etario r ON p.Rango_Etario_Agente_ID = r.Rango_Etario_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Mes, r.Rango_Etario_Descripcion;
GO

-- VISTA 8. Desvío de presupuesto.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_08_Desvio_Presupuesto AS
SELECT
    t.Tiempo_Anio AS Anio, 
    t.Tiempo_Cuatrimestre AS Cuatrimestre,
    CAST(SUM(p.Propuesta_Desvio_Presupuesto_Suma) / NULLIF(SUM(p.Propuesta_Cantidad), 0) AS decimal(18,2)) AS Desvio_Presupuesto_Promedio
FROM TP_APROBADO.BI_Fact_Propuestas p
JOIN TP_APROBADO.BI_Dim_Tiempo t ON p.Tiempo_Solicitud_ID = t.Tiempo_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Cuatrimestre;
GO

-- VISTA 9. Ranking de aspectos mejor y peor valorados.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_09_Ranking_Aspectos_Valorados AS
SELECT
    t.Tiempo_Anio AS Anio, 
    t.Tiempo_Cuatrimestre AS Cuatrimestre,
    a.Aspecto_Nombre,
    CAST(CAST(SUM(e.Encuesta_Puntaje_Suma) AS decimal(18,2)) / NULLIF(SUM(e.Encuesta_Cantidad), 0) AS decimal(18,2)) AS Puntaje_Promedio
FROM TP_APROBADO.BI_Fact_Encuestas e
JOIN TP_APROBADO.BI_Dim_Tiempo t ON e.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Aspecto a ON e.Aspecto_ID = a.Aspecto_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Cuatrimestre, a.Aspecto_Nombre;
GO

-- VISTA 10. Satisfacción promedio por agente.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_10_Satisfaccion_Promedio_Agente AS
SELECT
    t.Tiempo_Anio AS Anio, 
    t.Tiempo_Mes AS Mes,
    r.Rango_Etario_Descripcion AS Rango_Etario_Agente,
    CAST(CAST(SUM(e.Encuesta_Puntaje_Suma) AS decimal(18,2)) / NULLIF(SUM(e.Encuesta_Cantidad), 0) AS decimal(18,2)) AS Puntaje_Promedio
FROM TP_APROBADO.BI_Fact_Encuestas e
JOIN TP_APROBADO.BI_Dim_Tiempo t ON e.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Rango_Etario r ON e.Rango_Etario_Agente_ID = r.Rango_Etario_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Mes, r.Rango_Etario_Descripcion;
GO
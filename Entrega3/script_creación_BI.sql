/* ============================================================================
   SCRIPT DE CREACIÓN Y CARGA DEL MODELO DE BI
   ============================================================================ */

USE GD1C2026;
GO

SET NOCOUNT ON;
GO

/* ============================================================================
   LIMPIEZA: vistas, procedures, funciones, hechos, dimensiones
   ============================================================================ */
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


/* ============================================================================
   CREACIÓN DE TABLAS DIMENSIONALES
   ============================================================================ */

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

-- Ventas -> importe, subtotal, descuento. Vistas 1 y 2.
CREATE TABLE TP_APROBADO.BI_Fact_Ventas (
    Fact_Venta_ID int IDENTITY(1,1) NOT NULL,
    Tiempo_ID int NOT NULL,
    Rango_Etario_Cliente_ID int NULL,
    Canal_Venta_ID int NOT NULL,
    Tipo_Servicio_ID int NOT NULL,
    Venta_Importe_Total decimal(18,2) NULL,
    Venta_Subtotal decimal(18,2) NULL,
    Venta_Descuento decimal(18,2) NULL,
    CONSTRAINT PK_BI_Fact_Ventas PRIMARY KEY (Fact_Venta_ID),
    CONSTRAINT FK_BI_Fact_Ventas_Tiempo FOREIGN KEY (Tiempo_ID) REFERENCES TP_APROBADO.BI_Dim_Tiempo (Tiempo_ID),
    CONSTRAINT FK_BI_Fact_Ventas_Rango_Etario FOREIGN KEY (Rango_Etario_Cliente_ID) REFERENCES TP_APROBADO.BI_Dim_Rango_Etario (Rango_Etario_ID),
    CONSTRAINT FK_BI_Fact_Ventas_Canal FOREIGN KEY (Canal_Venta_ID) REFERENCES TP_APROBADO.BI_Dim_Canal_Venta (Canal_Venta_ID),
    CONSTRAINT FK_BI_Fact_Ventas_Tipo_Servicio FOREIGN KEY (Tipo_Servicio_ID) REFERENCES TP_APROBADO.BI_Dim_Tipo_Servicio (Tipo_Servicio_ID)
);
GO

-- Solicitudes -> días de anticipación. Vistas 3 y 4.
CREATE TABLE TP_APROBADO.BI_Fact_Solicitudes (
    Fact_Solicitud_ID int IDENTITY(1,1) NOT NULL,
    Tiempo_ID int NOT NULL,
    Temporada_ID int NOT NULL,
    Rango_Etario_Cliente_ID int NULL,
    Solicitud_Dias_Anticipacion int NULL,
    CONSTRAINT PK_BI_Fact_Solicitudes PRIMARY KEY (Fact_Solicitud_ID),
    CONSTRAINT FK_BI_Fact_Solicitudes_Tiempo FOREIGN KEY (Tiempo_ID) REFERENCES TP_APROBADO.BI_Dim_Tiempo (Tiempo_ID),
    CONSTRAINT FK_BI_Fact_Solicitudes_Temporada FOREIGN KEY (Temporada_ID) REFERENCES TP_APROBADO.BI_Dim_Temporada (Temporada_ID),
    CONSTRAINT FK_BI_Fact_Solicitudes_Rango_Etario FOREIGN KEY (Rango_Etario_Cliente_ID) REFERENCES TP_APROBADO.BI_Dim_Rango_Etario (Rango_Etario_ID)
);
GO

-- Propuestas -> importe, días de respuesta, desvío de presupuesto. Vistas 5 a 8.
CREATE TABLE TP_APROBADO.BI_Fact_Propuestas (
    Fact_Propuesta_ID int IDENTITY(1,1) NOT NULL,
    Tiempo_Solicitud_ID int NOT NULL,
    Tiempo_Emision_ID int NOT NULL,
    Tiempo_Inicio_Viaje_ID int NOT NULL,
    Temporada_ID int NOT NULL,
    Rango_Etario_Agente_ID int NULL,
    Estado_Propuesta_ID int NOT NULL,
    Propuesta_Importe_Total decimal(18,2) NULL,
    Propuesta_Dias_Respuesta int NULL,
    Propuesta_Desvio_Presupuesto decimal(18,2) NULL,
    CONSTRAINT PK_BI_Fact_Propuestas PRIMARY KEY (Fact_Propuesta_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Tiempo_Solicitud FOREIGN KEY (Tiempo_Solicitud_ID) REFERENCES TP_APROBADO.BI_Dim_Tiempo (Tiempo_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Tiempo_Emision FOREIGN KEY (Tiempo_Emision_ID) REFERENCES TP_APROBADO.BI_Dim_Tiempo (Tiempo_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Tiempo_Inicio_Viaje FOREIGN KEY (Tiempo_Inicio_Viaje_ID) REFERENCES TP_APROBADO.BI_Dim_Tiempo (Tiempo_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Temporada FOREIGN KEY (Temporada_ID) REFERENCES TP_APROBADO.BI_Dim_Temporada (Temporada_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Rango_Etario FOREIGN KEY (Rango_Etario_Agente_ID) REFERENCES TP_APROBADO.BI_Dim_Rango_Etario (Rango_Etario_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Estado FOREIGN KEY (Estado_Propuesta_ID) REFERENCES TP_APROBADO.BI_Dim_Estado_Propuesta (Estado_Propuesta_ID)
);
GO

-- Encuestas, puntaje por aspecto -> puntaje. Vistas 9 y 10.
CREATE TABLE TP_APROBADO.BI_Fact_Encuestas (
    Fact_Encuesta_ID int IDENTITY(1,1) NOT NULL,
    Tiempo_ID int NOT NULL,
    Rango_Etario_Agente_ID int NULL,
    Aspecto_ID int NOT NULL,
    Encuesta_Puntaje int NULL,
    CONSTRAINT PK_BI_Fact_Encuestas PRIMARY KEY (Fact_Encuesta_ID),
    CONSTRAINT FK_BI_Fact_Encuestas_Tiempo FOREIGN KEY (Tiempo_ID) REFERENCES TP_APROBADO.BI_Dim_Tiempo (Tiempo_ID),
    CONSTRAINT FK_BI_Fact_Encuestas_Rango_Etario FOREIGN KEY (Rango_Etario_Agente_ID) REFERENCES TP_APROBADO.BI_Dim_Rango_Etario (Rango_Etario_ID),
    CONSTRAINT FK_BI_Fact_Encuestas_Aspecto FOREIGN KEY (Aspecto_ID) REFERENCES TP_APROBADO.BI_Dim_Aspecto (Aspecto_ID)
);
GO


/* ============================================================================
   FUNCIONES AUXILIARES
   ============================================================================ */

-- Devuelve el Tiempo_ID (a nivel mes) correspondiente a una fecha.
CREATE OR ALTER FUNCTION TP_APROBADO.fn_ObtenerTiempo (@fecha date)
RETURNS int
AS
BEGIN
    DECLARE @id int;
    SELECT @id = Tiempo_ID
    FROM TP_APROBADO.BI_Dim_Tiempo
    WHERE Tiempo_Anio = YEAR(@fecha) AND Tiempo_Mes = MONTH(@fecha);
    RETURN @id;
END;
GO

-- Devuelve el Temporada_ID correspondiente al mes de una fecha.
CREATE OR ALTER FUNCTION TP_APROBADO.fn_ObtenerTemporada (@fecha date)
RETURNS int
AS
BEGIN
    DECLARE @mes int = MONTH(@fecha);
    DECLARE @id int;
    SELECT @id = Temporada_ID
    FROM TP_APROBADO.BI_Dim_Temporada
    WHERE @mes BETWEEN Temporada_Mes_Desde AND Temporada_Mes_Hasta;
    RETURN @id;
END;
GO

-- Calcula la edad a una fecha de referencia y devuelve el Rango_Etario_ID.
-- Si la fecha de nacimiento es NULL, la edad queda NULL y devuelve NULL.
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
    RETURN @id;
END;
GO


/* ============================================================================
   PROCEDURES DE MIGRACIÓN
   ============================================================================ */

-- DIMENSIONES ESTÁTICAS (valores fijos del enunciado) -----------------------

CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Dim_Rango_Etario
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Dim_Rango_Etario (Rango_Etario_Descripcion, Rango_Edad_Desde, Rango_Edad_Hasta)
    VALUES ('Menores de 25 años', NULL, 25),
           ('Entre 25 y 35 años', 25, 35),
           ('Entre 35 y 50 años', 35, 50),
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

-- DIMENSIONES DERIVADAS DEL MODELO TRANSACCIONAL ----------------------------

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

-- Tiempo: combinaciones únicas de año/mes de todas las fechas que usan los hechos.
CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Dim_Tiempo
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Dim_Tiempo (Tiempo_Anio, Tiempo_Cuatrimestre, Tiempo_Mes)
    SELECT DISTINCT
        YEAR(v.Venta_Fecha_Venta),
        CASE 
            WHEN MONTH(v.Venta_Fecha_Venta) BETWEEN 1 AND 4 THEN 1
            WHEN MONTH(v.Venta_Fecha_Venta) BETWEEN 5 AND 8 THEN 2
            ELSE 3
        END,
        MONTH(v.Venta_Fecha_Venta)
    FROM TP_APROBADO.Venta v
    WHERE v.Venta_Fecha_Venta IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM TP_APROBADO.BI_Dim_Tiempo t
          WHERE t.Tiempo_Anio = YEAR(v.Venta_Fecha_Venta)
            AND t.Tiempo_Mes = MONTH(v.Venta_Fecha_Venta)
      );

    INSERT INTO TP_APROBADO.BI_Dim_Tiempo (Tiempo_Anio, Tiempo_Cuatrimestre, Tiempo_Mes)
    SELECT DISTINCT
        YEAR(s.Solicitud_Fecha_solicitud),
        CASE 
            WHEN MONTH(s.Solicitud_Fecha_solicitud) BETWEEN 1 AND 4 THEN 1
            WHEN MONTH(s.Solicitud_Fecha_solicitud) BETWEEN 5 AND 8 THEN 2
            ELSE 3
        END,
        MONTH(s.Solicitud_Fecha_solicitud)
    FROM TP_APROBADO.Solicitud s
    WHERE s.Solicitud_Fecha_solicitud IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM TP_APROBADO.BI_Dim_Tiempo t
          WHERE t.Tiempo_Anio = YEAR(s.Solicitud_Fecha_solicitud)
            AND t.Tiempo_Mes = MONTH(s.Solicitud_Fecha_solicitud)
      );

    INSERT INTO TP_APROBADO.BI_Dim_Tiempo (Tiempo_Anio, Tiempo_Cuatrimestre, Tiempo_Mes)
    SELECT DISTINCT
        YEAR(p.Propuesta_Fecha_Emision),
        CASE 
            WHEN MONTH(p.Propuesta_Fecha_Emision) BETWEEN 1 AND 4 THEN 1
            WHEN MONTH(p.Propuesta_Fecha_Emision) BETWEEN 5 AND 8 THEN 2
            ELSE 3
        END,
        MONTH(p.Propuesta_Fecha_Emision)
    FROM TP_APROBADO.Propuesta p
    WHERE p.Propuesta_Fecha_Emision IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM TP_APROBADO.BI_Dim_Tiempo t
          WHERE t.Tiempo_Anio = YEAR(p.Propuesta_Fecha_Emision)
            AND t.Tiempo_Mes = MONTH(p.Propuesta_Fecha_Emision)
      );

    INSERT INTO TP_APROBADO.BI_Dim_Tiempo (Tiempo_Anio, Tiempo_Cuatrimestre, Tiempo_Mes)
    SELECT DISTINCT
        YEAR(p.Propuesta_Fecha_Desde),
        CASE 
            WHEN MONTH(p.Propuesta_Fecha_Desde) BETWEEN 1 AND 4 THEN 1
            WHEN MONTH(p.Propuesta_Fecha_Desde) BETWEEN 5 AND 8 THEN 2
            ELSE 3
        END,
        MONTH(p.Propuesta_Fecha_Desde)
    FROM TP_APROBADO.Propuesta p
    WHERE p.Propuesta_Fecha_Desde IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM TP_APROBADO.BI_Dim_Tiempo t
          WHERE t.Tiempo_Anio = YEAR(p.Propuesta_Fecha_Desde)
            AND t.Tiempo_Mes = MONTH(p.Propuesta_Fecha_Desde)
      );

    INSERT INTO TP_APROBADO.BI_Dim_Tiempo (Tiempo_Anio, Tiempo_Cuatrimestre, Tiempo_Mes)
    SELECT DISTINCT
        YEAR(e.Encuesta_Fecha_Encuesta),
        CASE 
            WHEN MONTH(e.Encuesta_Fecha_Encuesta) BETWEEN 1 AND 4 THEN 1
            WHEN MONTH(e.Encuesta_Fecha_Encuesta) BETWEEN 5 AND 8 THEN 2
            ELSE 3
        END,
        MONTH(e.Encuesta_Fecha_Encuesta)
    FROM TP_APROBADO.Encuesta e
    WHERE e.Encuesta_Fecha_Encuesta IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM TP_APROBADO.BI_Dim_Tiempo t
          WHERE t.Tiempo_Anio = YEAR(e.Encuesta_Fecha_Encuesta)
            AND t.Tiempo_Mes = MONTH(e.Encuesta_Fecha_Encuesta)
      );
END;
GO

-- HECHOS --------------------------------------------------------------------

-- Ventas. Tipo de servicio: 1 = directa (sin propuesta), 2 = a medida (con propuesta).
-- Se filtran ventas sin fecha (Tiempo es obligatorio). Cliente por LEFT JOIN: si falta,
-- el rango etario queda NULL (FK opcional).
CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Fact_Ventas
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Fact_Ventas (
        Tiempo_ID, Rango_Etario_Cliente_ID, Canal_Venta_ID, Tipo_Servicio_ID,
        Venta_Importe_Total, Venta_Subtotal, Venta_Descuento)
    SELECT
        TP_APROBADO.fn_ObtenerTiempo(v.Venta_Fecha_Venta),
        TP_APROBADO.fn_ObtenerRangoEtario(c.Cliente_Fecha_Nac, v.Venta_Fecha_Venta),
        dc.Canal_Venta_ID,
        CASE WHEN v.Venta_Propuesta IS NULL THEN 1 ELSE 2 END,
        v.Venta_Importe_Total, v.Venta_Subtotal, v.Venta_Descuento
    FROM TP_APROBADO.Venta v
    LEFT JOIN TP_APROBADO.Cliente c
        ON v.Venta_Cliente_Dni = c.Cliente_Dni AND v.Venta_Cliente_Mail = c.Cliente_Mail
    JOIN TP_APROBADO.BI_Dim_Canal_Venta dc
        ON v.Venta_Canal_Venta = dc.Canal_Venta_Codigo
    WHERE v.Venta_Fecha_Venta IS NOT NULL;
END;
GO

-- Solicitudes. Días de anticipación = inicio tentativo - fecha de solicitud.
-- Se filtran solicitudes sin fecha (Tiempo y Temporada son obligatorios).
CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Fact_Solicitudes
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Fact_Solicitudes (
        Tiempo_ID, Temporada_ID, Rango_Etario_Cliente_ID, Solicitud_Dias_Anticipacion)
    SELECT
        TP_APROBADO.fn_ObtenerTiempo(s.Solicitud_Fecha_solicitud),
        TP_APROBADO.fn_ObtenerTemporada(s.Solicitud_Fecha_solicitud),
        TP_APROBADO.fn_ObtenerRangoEtario(c.Cliente_Fecha_Nac, s.Solicitud_Fecha_solicitud),
        DATEDIFF(DAY, s.Solicitud_Fecha_solicitud, s.Solicitud_Fecha_Inicio_Tentativa)
    FROM TP_APROBADO.Solicitud s
    LEFT JOIN TP_APROBADO.Cliente c
        ON s.Solicitud_Cliente_Dni = c.Cliente_Dni AND s.Solicitud_Cliente_Mail = c.Cliente_Mail
    WHERE s.Solicitud_Fecha_solicitud IS NOT NULL;
END;
GO

-- Propuestas. Días de respuesta = emisión - solicitud. Desvío = importe - presupuesto estimado.
-- Tiempo según fecha de solicitud; temporada según inicio del viaje. Se filtran filas sin
-- esas fechas (FK obligatorias). Agente por LEFT JOIN (rango etario opcional).
CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Fact_Propuestas
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Fact_Propuestas (Tiempo_Solicitud_ID, Tiempo_Emision_ID, Tiempo_Inicio_Viaje_ID,
        Temporada_ID, Rango_Etario_Agente_ID, Estado_Propuesta_ID, Propuesta_Importe_Total, Propuesta_Dias_Respuesta,
        Propuesta_Desvio_Presupuesto
    )
    SELECT
        TP_APROBADO.fn_ObtenerTiempo(s.Solicitud_Fecha_solicitud),
        TP_APROBADO.fn_ObtenerTiempo(p.Propuesta_Fecha_Emision),
        TP_APROBADO.fn_ObtenerTiempo(p.Propuesta_Fecha_Desde),
        TP_APROBADO.fn_ObtenerTemporada(p.Propuesta_Fecha_Desde),
        TP_APROBADO.fn_ObtenerRangoEtario(a.Agente_Fecha_Nac, p.Propuesta_Fecha_Emision),
        de.Estado_Propuesta_ID,
        p.Propuesta_Importe_Total,
        DATEDIFF(DAY, s.Solicitud_Fecha_solicitud, p.Propuesta_Fecha_Emision),
        p.Propuesta_Importe_Total - s.Solicitud_Presupuesto_Estimado
    FROM TP_APROBADO.Propuesta p
    JOIN TP_APROBADO.Solicitud s
        ON p.Solicitud_Nro_Solicitud = s.Solicitud_Nro_Solicitud
    LEFT JOIN TP_APROBADO.Agente a
        ON p.Propuesta_Agente = a.Agente_Legajo
    JOIN TP_APROBADO.BI_Dim_Estado_Propuesta de
        ON p.Propuesta_Estado = de.Estado_Propuesta_Codigo
    WHERE s.Solicitud_Fecha_solicitud IS NOT NULL
      AND p.Propuesta_Fecha_Emision IS NOT NULL
      AND p.Propuesta_Fecha_Desde IS NOT NULL;
END;
GO
-- Encuestas. El agente sale directo de la tabla Encuesta (columna Encuesta_Agente del
-- modelo relacional), por LEFT JOIN a Agente: si no resolviera, el rango etario queda
-- NULL (FK opcional). Se filtran encuestas sin fecha.
CREATE OR ALTER PROCEDURE TP_APROBADO.SP_Migrar_Fact_Encuestas
AS
BEGIN
    INSERT INTO TP_APROBADO.BI_Fact_Encuestas (
        Tiempo_ID, Rango_Etario_Agente_ID, Aspecto_ID, Encuesta_Puntaje)
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
    LEFT JOIN TP_APROBADO.Agente a
        ON a.Agente_Legajo = e.Encuesta_Agente
    WHERE e.Encuesta_Fecha_Encuesta IS NOT NULL;
END;
GO

-- PROCEDURE ORQUESTADOR ---------------------------------------------------------------
-- Carga primero todas las dimensiones (para que existan los IDs) y luego los hechos.
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


/* ============================================================================
   EJECUCIÓN DE LA MIGRACIÓN
   ============================================================================ */
EXEC TP_APROBADO.SP_Migrar_BI;
GO


/* ============================================================================
   VISTAS
   ============================================================================ */

--VISTA 1. Ticket promedio: venta promedio mensual por rango etario de cliente y canal.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_01_Ticket_Promedio AS
SELECT
    t.Tiempo_Anio AS Anio, t.Tiempo_Mes AS Mes,
    r.Rango_Etario_Descripcion AS Rango_Etario_Cliente,
    c.Canal_Venta_Nombre AS Canal_Venta,
    CAST(AVG(v.Venta_Importe_Total) AS decimal(18,2)) AS Ticket_Promedio
FROM TP_APROBADO.BI_Fact_Ventas v
JOIN TP_APROBADO.BI_Dim_Tiempo t ON v.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Rango_Etario r ON v.Rango_Etario_Cliente_ID = r.Rango_Etario_ID
JOIN TP_APROBADO.BI_Dim_Canal_Venta c ON v.Canal_Venta_ID = c.Canal_Venta_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Mes, r.Rango_Etario_Descripcion, c.Canal_Venta_Nombre;
GO

-- VISTA 2. Distribución de facturación: % por tipo de servicio, por cuatrimestre/año.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_02_Distribucion_Facturacion AS
WITH Totales AS (
    SELECT t.Tiempo_Anio, t.Tiempo_Cuatrimestre, ts.Tipo_Servicio_Nombre,
           SUM(v.Venta_Importe_Total) AS Total_Servicio
    FROM TP_APROBADO.BI_Fact_Ventas v
    JOIN TP_APROBADO.BI_Dim_Tiempo t ON v.Tiempo_ID = t.Tiempo_ID
    JOIN TP_APROBADO.BI_Dim_Tipo_Servicio ts ON v.Tipo_Servicio_ID = ts.Tipo_Servicio_ID
    GROUP BY t.Tiempo_Anio, t.Tiempo_Cuatrimestre, ts.Tipo_Servicio_Nombre
)
SELECT
    Tiempo_Anio AS Anio, Tiempo_Cuatrimestre AS Cuatrimestre,
    Tipo_Servicio_Nombre AS Tipo_Servicio,
    Total_Servicio AS Facturacion_Absoluta,
    CAST(Total_Servicio / NULLIF(SUM(Total_Servicio) OVER (PARTITION BY Tiempo_Anio, Tiempo_Cuatrimestre), 0) * 100 AS decimal(18,2)) AS Porcentaje_Facturacion
FROM Totales;
GO

-- VISTA 3. Ranking de solicitudes por temporada/año y rango etario de cliente.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_03_Ranking_Solicitudes_Temporada AS
SELECT
    t.Tiempo_Anio AS Anio, temp.Temporada_Nombre AS Temporada,
    r.Rango_Etario_Descripcion AS Rango_Etario_Cliente,
    COUNT(s.Fact_Solicitud_ID) AS Cantidad_Solicitudes
FROM TP_APROBADO.BI_Fact_Solicitudes s
JOIN TP_APROBADO.BI_Dim_Tiempo t ON s.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Temporada temp ON s.Temporada_ID = temp.Temporada_ID
JOIN TP_APROBADO.BI_Dim_Rango_Etario r ON s.Rango_Etario_Cliente_ID = r.Rango_Etario_ID
GROUP BY t.Tiempo_Anio, temp.Temporada_Nombre, r.Rango_Etario_Descripcion;
GO

-- VISTA 4. Anticipación promedio de solicitudes por cuatrimestre y rango etario de cliente.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_04_Anticipacion_Promedio_Solicitudes AS
SELECT
    t.Tiempo_Anio AS Anio, t.Tiempo_Cuatrimestre AS Cuatrimestre,
    r.Rango_Etario_Descripcion AS Rango_Etario_Cliente,
    CAST(AVG(CAST(s.Solicitud_Dias_Anticipacion AS decimal(18,2))) AS decimal(18,2)) AS Anticipacion_Promedio_Dias
FROM TP_APROBADO.BI_Fact_Solicitudes s
JOIN TP_APROBADO.BI_Dim_Tiempo t ON s.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Rango_Etario r ON s.Rango_Etario_Cliente_ID = r.Rango_Etario_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Cuatrimestre, r.Rango_Etario_Descripcion;
GO

-- VISTA 5. Tasa de aceptación de propuestas por cuatrimestre.
-- Se identifica la propuesta aceptada por el NOMBRE del estado (dato de negocio),
-- no por el código (que es una clave subrogada sin significado fijo).
-- VERIFICAR el texto exacto del estado en la tabla Estado y ajustar el patrón si difiere.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_05_Tasa_Aceptacion_Propuestas AS
SELECT
    t.Tiempo_Anio AS Anio,
    t.Tiempo_Cuatrimestre AS Cuatrimestre,
    CAST(SUM(CASE WHEN ep.Estado_Propuesta_Nombre LIKE '%Aceptad%' THEN 1.0 ELSE 0.0 END)
         / NULLIF(COUNT(p.Fact_Propuesta_ID), 0) * 100 AS decimal(18,2)) AS Tasa_Aceptacion_Porcentaje
FROM TP_APROBADO.BI_Fact_Propuestas p
JOIN TP_APROBADO.BI_Dim_Tiempo t 
    ON p.Tiempo_Emision_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Estado_Propuesta ep 
    ON p.Estado_Propuesta_ID = ep.Estado_Propuesta_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Cuatrimestre;
GO

-- VISTA 6. Cotización promedio por temporada del viaje / año de solicitud.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_06_Cotizacion_Promedio_Temporada AS
SELECT
    t.Tiempo_Anio AS Anio,
    temp.Temporada_Nombre AS Temporada_Viaje,
    CAST(AVG(p.Propuesta_Importe_Total) AS decimal(18,2)) AS Cotizacion_Promedio
FROM TP_APROBADO.BI_Fact_Propuestas p
JOIN TP_APROBADO.BI_Dim_Tiempo t 
    ON p.Tiempo_Inicio_Viaje_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Temporada temp 
    ON p.Temporada_ID = temp.Temporada_ID
GROUP BY t.Tiempo_Anio, temp.Temporada_Nombre;
GO

-- VISTA 7. Tiempo promedio de respuesta por mes (de la solicitud) y rango etario de agente.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_07_Tiempo_Promedio_Respuesta AS
SELECT
    t.Tiempo_Anio AS Anio, t.Tiempo_Mes AS Mes,
    r.Rango_Etario_Descripcion AS Rango_Etario_Agente,
    CAST(AVG(CAST(p.Propuesta_Dias_Respuesta AS decimal(18,2))) AS decimal(18,2)) AS Tiempo_Respuesta_Promedio_Dias
FROM TP_APROBADO.BI_Fact_Propuestas p
JOIN TP_APROBADO.BI_Dim_Tiempo t 
    ON p.Tiempo_Solicitud_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Rango_Etario r 
    ON p.Rango_Etario_Agente_ID = r.Rango_Etario_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Mes, r.Rango_Etario_Descripcion;
GO

-- VISTA 8. Desvío promedio de presupuesto por cuatrimestre.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_08_Desvio_Presupuesto AS
SELECT
    t.Tiempo_Anio AS Anio, t.Tiempo_Cuatrimestre AS Cuatrimestre,
    CAST(AVG(p.Propuesta_Desvio_Presupuesto) AS decimal(18,2)) AS Desvio_Presupuesto_Promedio
FROM TP_APROBADO.BI_Fact_Propuestas p
JOIN TP_APROBADO.BI_Dim_Tiempo t 
    ON p.Tiempo_Solicitud_ID = t.Tiempo_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Cuatrimestre;
GO

-- VISTA 9. Ranking de aspectos: puntaje promedio por aspecto y cuatrimestre.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_09_Ranking_Aspectos_Valorados AS
SELECT
    t.Tiempo_Anio AS Anio, t.Tiempo_Cuatrimestre AS Cuatrimestre,
    a.Aspecto_Nombre,
    CAST(AVG(CAST(e.Encuesta_Puntaje AS decimal(18,2))) AS decimal(18,2)) AS Puntaje_Promedio
FROM TP_APROBADO.BI_Fact_Encuestas e
JOIN TP_APROBADO.BI_Dim_Tiempo t ON e.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Aspecto a ON e.Aspecto_ID = a.Aspecto_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Cuatrimestre, a.Aspecto_Nombre;
GO

-- VISTA 10. Satisfacción promedio por agente: puntaje promedio por mes y rango etario de agente.
CREATE OR ALTER VIEW TP_APROBADO.BI_Vista_10_Satisfaccion_Promedio_Agente AS
SELECT
    t.Tiempo_Anio AS Anio, t.Tiempo_Mes AS Mes,
    r.Rango_Etario_Descripcion AS Rango_Etario_Agente,
    CAST(AVG(CAST(e.Encuesta_Puntaje AS decimal(18,2))) AS decimal(18,2)) AS Puntaje_Promedio
FROM TP_APROBADO.BI_Fact_Encuestas e
JOIN TP_APROBADO.BI_Dim_Tiempo t ON e.Tiempo_ID = t.Tiempo_ID
JOIN TP_APROBADO.BI_Dim_Rango_Etario r ON e.Rango_Etario_Agente_ID = r.Rango_Etario_ID
GROUP BY t.Tiempo_Anio, t.Tiempo_Mes, r.Rango_Etario_Descripcion;
GO

USE GD1C2026;
GO

-- ============================================================================
-- MODELO DE INTELIGENCIA DE NEGOCIOS (BI)
-- ============================================================================

-- ############################################################################
--                          TABLAS DIMENSIONALES
-- ############################################################################

-- ============================================================================
-- DIMENSION: TIEMPO
-- ============================================================================
-- Permite agrupar por año, cuatrimestre y mes.
-- Se genera a partir de las fechas existentes en el modelo transaccional.
-- ============================================================================

CREATE TABLE TP_APROBADO.BI_Dim_Tiempo (
    Tiempo_ID int IDENTITY(1,1) NOT NULL,
    Tiempo_Anio int NOT NULL,
    Tiempo_Cuatrimestre int NOT NULL,
    Tiempo_Mes int NOT NULL,
    CONSTRAINT PK_BI_Dim_Tiempo PRIMARY KEY (Tiempo_ID),
    CONSTRAINT UQ_BI_Dim_Tiempo UNIQUE (Tiempo_Anio, Tiempo_Mes)
);
GO

-- ============================================================================
-- DIMENSION: RANGO ETARIO
-- ============================================================================
-- Categoriza las edades en rangos predefinidos.
-- Se usa tanto para clientes como para agentes (filtrando según corresponda).
-- Rangos definidos en el enunciado:
--   Clientes: ≤25, 25-35, 35-50, >50
--   Agentes:  25-35, 35-50, >50
-- ============================================================================

CREATE TABLE TP_APROBADO.BI_Dim_Rango_Etario (
    Rango_Etario_ID int IDENTITY(1,1) NOT NULL,
    Rango_Etario_Descripcion nvarchar(100) NOT NULL,
    Rango_Edad_Desde int NULL,
    Rango_Edad_Hasta int NULL,
    CONSTRAINT PK_BI_Dim_Rango_Etario PRIMARY KEY (Rango_Etario_ID)
);
GO

INSERT INTO TP_APROBADO.BI_Dim_Rango_Etario (Rango_Etario_Descripcion, Rango_Edad_Desde, Rango_Edad_Hasta)
VALUES 
    ('Menores de 25 años', NULL, 25),
    ('Entre 25 y 35 años', 25, 35),
    ('Entre 35 y 50 años', 35, 50),
    ('Mayores de 50 años', 50, NULL);
GO

-- ============================================================================
-- DIMENSION: TEMPORADA
-- ============================================================================
-- Agrupa los meses en temporadas según el enunciado:
--   Verano (Enero - Marzo), Otoño (Abril - Junio),
--   Invierno (Julio - Septiembre), Primavera (Octubre - Diciembre)
-- ============================================================================

CREATE TABLE TP_APROBADO.BI_Dim_Temporada (
    Temporada_ID int IDENTITY(1,1) NOT NULL,
    Temporada_Nombre nvarchar(50) NOT NULL,
    Temporada_Mes_Desde int NOT NULL,
    Temporada_Mes_Hasta int NOT NULL,
    CONSTRAINT PK_BI_Dim_Temporada PRIMARY KEY (Temporada_ID)
);
GO

INSERT INTO TP_APROBADO.BI_Dim_Temporada (Temporada_Nombre, Temporada_Mes_Desde, Temporada_Mes_Hasta)
VALUES 
    ('Verano', 1, 3),
    ('Otoño', 4, 6),
    ('Invierno', 7, 9),
    ('Primavera', 10, 12);
GO

-- ============================================================================
-- DIMENSION: TIPO DE SERVICIO
-- ============================================================================
-- Diferencia entre ventas directas y propuestas a medida.
-- ============================================================================

CREATE TABLE TP_APROBADO.BI_Dim_Tipo_Servicio (
    Tipo_Servicio_ID int IDENTITY(1,1) NOT NULL,
    Tipo_Servicio_Nombre nvarchar(50) NOT NULL,
    CONSTRAINT PK_BI_Dim_Tipo_Servicio PRIMARY KEY (Tipo_Servicio_ID)
);
GO

INSERT INTO TP_APROBADO.BI_Dim_Tipo_Servicio (Tipo_Servicio_Nombre)
VALUES 
    ('Venta Directa'),
    ('Propuesta a Medida');
GO

-- ============================================================================
-- DIMENSION: CANAL DE VENTA
-- ============================================================================
-- Se migra desde la tabla Canal_Venta del modelo transaccional.
-- ============================================================================

CREATE TABLE TP_APROBADO.BI_Dim_Canal_Venta (
    Canal_Venta_ID int IDENTITY(1,1) NOT NULL,
    Canal_Venta_Codigo bigint NOT NULL,
    Canal_Venta_Nombre nvarchar(400) NULL,
    CONSTRAINT PK_BI_Dim_Canal_Venta PRIMARY KEY (Canal_Venta_ID)
);
GO

-- ============================================================================
-- DIMENSION: ESTADO DE PROPUESTA
-- ============================================================================
-- Se migra desde la tabla Estado del modelo transaccional.
-- ============================================================================

CREATE TABLE TP_APROBADO.BI_Dim_Estado_Propuesta (
    Estado_Propuesta_ID int IDENTITY(1,1) NOT NULL,
    Estado_Propuesta_Codigo bigint NOT NULL,
    Estado_Propuesta_Nombre nvarchar(400) NULL,
    CONSTRAINT PK_BI_Dim_Estado_Propuesta PRIMARY KEY (Estado_Propuesta_ID)
);
GO

-- ============================================================================
-- DIMENSION: ASPECTO (ENCUESTA)
-- ============================================================================
-- Se migra desde la tabla Aspecto del modelo transaccional.
-- Usado para analizar valoraciones por aspecto evaluado.
-- ============================================================================

CREATE TABLE TP_APROBADO.BI_Dim_Aspecto (
    Aspecto_ID int IDENTITY(1,1) NOT NULL,
    Aspecto_Codigo smallint NOT NULL,
    Aspecto_Nombre nvarchar(510) NULL,
    CONSTRAINT PK_BI_Dim_Aspecto PRIMARY KEY (Aspecto_ID)
);
GO

-- ############################################################################
--                          TABLAS DE HECHOS
-- ############################################################################

-- ============================================================================
-- FACT: VENTAS
-- ============================================================================
-- Registra las ventas realizadas.
-- Métricas: importe total, subtotal, descuento.
-- Usado en vistas: 1 (Ticket promedio), 2 (Distribución facturación).
-- ============================================================================

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

-- ============================================================================
-- FACT: SOLICITUDES
-- ============================================================================
-- Registra las solicitudes de cotización realizadas por clientes.
-- Métricas: cantidad, días de anticipación.
-- Usado en vistas: 3 (Ranking solicitudes), 4 (Anticipación promedio).
-- ============================================================================

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

-- ============================================================================
-- FACT: PROPUESTAS
-- ============================================================================
-- Registra las propuestas emitidas a partir de solicitudes.
-- Métricas: importe, días de respuesta, desvío de presupuesto.
-- Usado en vistas: 5 (Tasa aceptación), 6 (Cotización promedio), 
--                  7 (Tiempo respuesta), 8 (Desvío presupuesto).
-- ============================================================================

CREATE TABLE TP_APROBADO.BI_Fact_Propuestas (
    Fact_Propuesta_ID int IDENTITY(1,1) NOT NULL,
    Tiempo_ID int NOT NULL,
    Temporada_ID int NOT NULL,
    Rango_Etario_Agente_ID int NULL,
    Estado_Propuesta_ID int NOT NULL,
    Propuesta_Importe_Total decimal(18,2) NULL,
    Propuesta_Dias_Respuesta int NULL,
    Propuesta_Desvio_Presupuesto decimal(18,2) NULL,
    CONSTRAINT PK_BI_Fact_Propuestas PRIMARY KEY (Fact_Propuesta_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Tiempo FOREIGN KEY (Tiempo_ID) REFERENCES TP_APROBADO.BI_Dim_Tiempo (Tiempo_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Temporada FOREIGN KEY (Temporada_ID) REFERENCES TP_APROBADO.BI_Dim_Temporada (Temporada_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Rango_Etario FOREIGN KEY (Rango_Etario_Agente_ID) REFERENCES TP_APROBADO.BI_Dim_Rango_Etario (Rango_Etario_ID),
    CONSTRAINT FK_BI_Fact_Propuestas_Estado FOREIGN KEY (Estado_Propuesta_ID) REFERENCES TP_APROBADO.BI_Dim_Estado_Propuesta (Estado_Propuesta_ID)
);
GO

-- ============================================================================
-- FACT: ENCUESTAS
-- ============================================================================
-- Registra las valoraciones de encuestas de satisfacción.
-- Métricas: puntaje por aspecto.
-- Usado en vistas: 9 (Ranking aspectos), 10 (Satisfacción por agente).
-- ============================================================================

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

-- ############################################################################
--                          FUNCIONES AUXILIARES
-- ############################################################################

-- ============================================================================
-- FUNCION: Obtener ID de Rango Etario
-- ============================================================================
-- Calcula la edad de una persona a una fecha de referencia y retorna el ID
-- del rango etario correspondiente en la dimensión.
--
-- Parámetros:
--   @fecha_nacimiento: Fecha de nacimiento de la persona
--   @fecha_referencia: Fecha a la cual calcular la edad (ej: fecha de venta)
-- Retorna: Rango_Etario_ID correspondiente
-- ============================================================================

CREATE FUNCTION TP_APROBADO.fn_ObtenerRangoEtario(
    @fecha_nacimiento date,
    @fecha_referencia date
)
RETURNS int
AS
BEGIN
    DECLARE @edad int;
    DECLARE @rango_id int;
    
    SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, @fecha_referencia)
                - CASE 
                    WHEN MONTH(@fecha_nacimiento) > MONTH(@fecha_referencia) 
                         OR (MONTH(@fecha_nacimiento) = MONTH(@fecha_referencia) 
                             AND DAY(@fecha_nacimiento) > DAY(@fecha_referencia))
                    THEN 1 
                    ELSE 0 
                  END;
    
    SELECT @rango_id = Rango_Etario_ID
    FROM TP_APROBADO.BI_Dim_Rango_Etario
    WHERE (@edad > ISNULL(Rango_Edad_Desde, -1))
      AND (@edad <= ISNULL(Rango_Edad_Hasta, 999));
    
    RETURN @rango_id;
END;
GO

-- ============================================================================
-- FUNCION: Obtener ID de Temporada
-- ============================================================================
-- A partir de una fecha, retorna el ID de la temporada correspondiente.
--
-- Parámetros:
--   @fecha: Fecha a evaluar
-- Retorna: Temporada_ID correspondiente
-- ============================================================================

CREATE FUNCTION TP_APROBADO.fn_ObtenerTemporada(
    @fecha date
)
RETURNS int
AS
BEGIN
    DECLARE @mes int = MONTH(@fecha);
    DECLARE @temporada_id int;
    
    SELECT @temporada_id = Temporada_ID
    FROM TP_APROBADO.BI_Dim_Temporada
    WHERE @mes BETWEEN Temporada_Mes_Desde AND Temporada_Mes_Hasta;
    
    RETURN @temporada_id;
END;
GO

-- ============================================================================
-- FUNCION: Obtener ID de Tiempo
-- ============================================================================
-- A partir de una fecha, retorna el ID de la dimensión tiempo correspondiente.
-- Si no existe, retorna NULL (debe poblarse previamente la dimensión).
--
-- Parámetros:
--   @fecha: Fecha a buscar
-- Retorna: Tiempo_ID correspondiente
-- ============================================================================

CREATE FUNCTION TP_APROBADO.fn_ObtenerTiempo(
    @fecha date
)
RETURNS int
AS
BEGIN
    DECLARE @tiempo_id int;
    
    SELECT @tiempo_id = Tiempo_ID
    FROM TP_APROBADO.BI_Dim_Tiempo
    WHERE Tiempo_Anio = YEAR(@fecha)
      AND Tiempo_Mes = MONTH(@fecha);
    
    RETURN @tiempo_id;
END;
GO

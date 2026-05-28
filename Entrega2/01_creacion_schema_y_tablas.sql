USE GD1C2026;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'TP_APROBADO'
)
BEGIN
    EXEC('CREATE SCHEMA TP_APROBADO');
END
GO

-- ============================================================================
-- 1. TABLAS MAESTRAS / INDEPENDIENTES (Nivel 1)
-- ============================================================================

CREATE TABLE TP_APROBADO.Alianza (
    Alianza_Codigo bigint NOT NULL,
    Alianza_Nombre nvarchar(400) NULL,
    CONSTRAINT PK_Alianza PRIMARY KEY (Alianza_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Aspecto (
    Aspecto_Codigo smallint NOT NULL,
    Aspecto_Aspecto nvarchar(510) NULL,
    CONSTRAINT PK_Aspecto PRIMARY KEY (Aspecto_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Canal_Venta (
    Canal_Venta_Codigo bigint NOT NULL,
    Canal_Venta_Nombre nvarchar(400) NULL,
    CONSTRAINT PK_Canal_Venta PRIMARY KEY (Canal_Venta_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Estado (
    Estado_Codigo bigint NOT NULL,
    Estado_Nombre nvarchar(400) NULL,
    Estado_Descripcion nvarchar(400) NULL,
    CONSTRAINT PK_Estado PRIMARY KEY (Estado_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Habitacion (
    Habitacion_Codigo bigint NOT NULL,
    Habitacion_Nombre nvarchar(510) NULL,
    Habitacion_Descripcion nvarchar(510) NULL,
    Habitacion_Precio_Noche decimal(18,2) NULL,
    Habitacion_Precio decimal(18,2) NULL,
    Habitacion_Cantidad int NULL,
    CONSTRAINT PK_Habitacion PRIMARY KEY (Habitacion_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Localidad (
    Localidad_Codigo bigint NOT NULL,
    Localidad_Nombre nvarchar(400) NULL,
    CONSTRAINT PK_Localidad PRIMARY KEY (Localidad_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Medio_Pago (
    Medio_Pago_Codigo bigint NOT NULL,
    Medio_Pago_Nombre nvarchar(400) NULL,
    CONSTRAINT PK_Medio_Pago PRIMARY KEY (Medio_Pago_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Pais (
    Pais_Codigo bigint NOT NULL,
    Pais_Nombre nvarchar(400) NULL,
    Pais_Capital nvarchar(510) NULL,
    CONSTRAINT PK_Pais PRIMARY KEY (Pais_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Proveedor (
    Proveedor_Codigo bigint NOT NULL,
    Proveedor_Nombre nvarchar(255) NULL,
    Proveedor_Mail nvarchar(255) NULL,
    Proveedor_Telefono nvarchar(255) NULL,
    CONSTRAINT PK_Proveedor PRIMARY KEY (Proveedor_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Provincia (
    Provincia_Codigo bigint NOT NULL,
    Provincia_Nombre nvarchar(400) NULL,
    CONSTRAINT PK_Provincia PRIMARY KEY (Provincia_Codigo)
);

-- ============================================================================
-- 2. TABLAS CON DEPENDENCIAS SIMPLES (Nivel 2)
-- ============================================================================

CREATE TABLE TP_APROBADO.Aerolinea (
    Aerolinea_Codigo nvarchar(255) NOT NULL,
    Aerolinea_Nombre nvarchar(510) NULL,
    Aerolinea_Pais nvarchar(510) NULL,
    Aerolinea_Alianza bigint NULL,
    CONSTRAINT PK_Aerolinea PRIMARY KEY (Aerolinea_Codigo),
    CONSTRAINT FK_Aerolinea_Alianza FOREIGN KEY (Aerolinea_Alianza) REFERENCES TP_APROBADO.Alianza (Alianza_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Ciudad (
    Ciudad_Codigo bigint NOT NULL,
    Ciudad_Nombre nvarchar(400) NULL,
    Ciudad_es_capital bit NULL, -- Representación de bool en SQL Server
    CONSTRAINT PK_Ciudad PRIMARY KEY (Ciudad_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Cliente (
    Cliente_Dni nvarchar(510) NOT NULL,
    Cliente_Mail nvarchar(510) NOT NULL,
    Cliente_Nombre nvarchar(510) NULL,
    Cliente_Apellido nvarchar(510) NULL,
    Cliente_Tel nvarchar(510) NULL,
    Cliente_Direccion nvarchar(510) NULL,
    Cliente_Fecha_Nac date NULL,
    Cliente_Localidad nvarchar(510) NULL,
    Cliente_Provincia nvarchar(510) NULL,
    CONSTRAINT PK_Cliente PRIMARY KEY (Cliente_Dni, Cliente_Mail)
);
GO



CREATE TABLE TP_APROBADO.Encuesta (
    Encuesta_Codigo_Encuesta bigint NOT NULL,
    Encuesta_Fecha_Encuesta date NULL,
    Encuesta_Comentarios varchar(max) NULL,
    CONSTRAINT PK_Encuesta PRIMARY KEY (Encuesta_Codigo_Encuesta)
);
GO



CREATE TABLE TP_APROBADO.Excursion (
    Excursion_Codigo bigint NOT NULL,
    Proveedor_Codigo bigint NULL,
    Excursion_Nombre nvarchar(510) NULL,
    Excursion_Descripcion nvarchar(510) NULL,
    Excursion_Horario int NULL,
    Excursion_Duracion int NULL,
    Excursion_Precio decimal(18,2) NULL,
    CONSTRAINT PK_Excursion PRIMARY KEY (Excursion_Codigo),
    CONSTRAINT FK_Excursion_Proveedor FOREIGN KEY (Proveedor_Codigo) REFERENCES TP_APROBADO.Proveedor (Proveedor_Codigo)
);

-- ============================================================================
-- 3. TABLAS CON DEPENDENCIAS INTERMEDIAS (Nivel 3)
-- ============================================================================

CREATE TABLE TP_APROBADO.Aeropuerto (
    Aeropuerto_Codigo bigint NOT NULL,
    Aeropuerto_Descripcion nvarchar(400) NULL,
    Aeropuerto_Ciudad nvarchar(510) NULL,
    Aeropuerto_Pais nvarchar(510) NULL,
    CONSTRAINT PK_Aeropuerto PRIMARY KEY (Aeropuerto_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Agencia (
    Agencia_Nro_Agencia bigint NOT NULL,
    Agencia_Direccion nvarchar(510) NULL,
    Agencia_Telefono nvarchar(510) NULL,
    Agencia_Mail nvarchar(510) NULL,
    Agencia_Provincia nvarchar(510) NULL,
    Agencia_Localidad nvarchar(510) NULL,
    CONSTRAINT PK_Agencia PRIMARY KEY (Agencia_Nro_Agencia)
);
GO



CREATE TABLE TP_APROBADO.Detalle_Encuesta (
    Encuesta_Nro_Encuesta bigint NOT NULL,
    Detalle_Encuesta_Puntaje int NULL,
    Detalle_Encuesta_Aspecto_Codigo smallint NOT NULL,
    CONSTRAINT PK_Detalle_Encuesta PRIMARY KEY (Encuesta_Nro_Encuesta, Detalle_Encuesta_Aspecto_Codigo),
    CONSTRAINT FK_Detalle_Encuesta_Encuesta FOREIGN KEY (Encuesta_Nro_Encuesta) REFERENCES TP_APROBADO.Encuesta (Encuesta_Codigo_Encuesta),
    CONSTRAINT FK_Detalle_Encuesta_Aspecto FOREIGN KEY (Detalle_Encuesta_Aspecto_Codigo) REFERENCES TP_APROBADO.Aspecto (Aspecto_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Hospedaje (
    Hospedaje_Codigo bigint NOT NULL,
    Hospedaje_Ciudad nvarchar(510) NULL,
    Hospedaje_Pais nvarchar(510) NULL,
    Hospedaje_Nombre nvarchar(510) NULL,
    Hospedaje_Direccion nvarchar(510) NULL,
    Hospedaje_Incluye_Desayuno bit NULL,
    Hospedaje_Check_In nvarchar(1000) NULL,
    Hospedaje_Check_Out nvarchar(1000) NULL,
    Hospedaje_Precio_Total decimal(18,2) NULL,
    Hospedaje_Habitacion bigint NULL,
    Hospedaje_Cantidad_Habitaciones int NULL,
    CONSTRAINT PK_Hospedaje PRIMARY KEY (Hospedaje_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Vuelo (
    Vuelo_Codigo bigint NOT NULL,
    Vuelo_Fecha_Salida date NULL,
    Vuelo_Horario_Salida nvarchar(50),
    Vuelo_Fecha_Llegada date NULL,
    Vuelo_Horario_Llegada nvarchar(50),
    Vuelo_Duracion int NULL,
    Vuelo_Precio decimal(18,2) NULL,
    Vuelo_Incluye_Carry bit NULL,
    Vuelo_Incluye_Valija bit NULL,
    Vuelo_Aeropuerto_Salida bigint NULL,
    Vuelo_Aeropuerto_Llegada bigint NULL,
    Vuelo_Aerolinea_Codigo bigint NULL,
    CONSTRAINT PK_Vuelo PRIMARY KEY (Vuelo_Codigo),
    CONSTRAINT FK_Vuelo_Aeropuerto_Salida FOREIGN KEY (Vuelo_Aeropuerto_Salida) REFERENCES TP_APROBADO.Aeropuerto (Aeropuerto_Codigo),
    CONSTRAINT FK_Vuelo_Aeropuerto_Llegada FOREIGN KEY (Vuelo_Aeropuerto_Llegada) REFERENCES TP_APROBADO.Aeropuerto (Aeropuerto_Codigo)
);

-- ============================================================================
-- 4. TABLAS ESTRUCTURALES COMPLEJAS Y DOCUMENTOS (Nivel 4)
-- ============================================================================

CREATE TABLE TP_APROBADO.Agente (
    Agente_Legajo bigint NOT NULL,
    Agencia_Nro_Agencia bigint NULL,
    Agente_Nombre nvarchar(510) NULL,
    Agente_Apellido nvarchar(510) NULL,
    Agente_Fecha_Nac date NULL,
    Agente_Telefono nvarchar(510) NULL,
    Agente_Mail nvarchar(510) NULL,
    Agente_Direccion nvarchar(510) NULL,
    Agente_Provincia nvarchar(510) NULL,
    Agente_Localidad nvarchar(510) NULL,
    CONSTRAINT PK_Agente PRIMARY KEY (Agente_Legajo),
    CONSTRAINT FK_Agente_Agencia FOREIGN KEY (Agencia_Nro_Agencia) REFERENCES TP_APROBADO.Agencia (Agencia_Nro_Agencia)
);
GO



CREATE TABLE TP_APROBADO.Solicitud (
    Solicitud_Nro_Solicitud bigint NOT NULL,
    Solicitud_Fecha_solicitud date NULL,
    Solicitud_Fecha_Inicio_Tentativa date NULL,
    Solicitud_Fecha_Fin_tentativa date NULL,
    Solicitud_Cant_Pax int NULL,
    Solicitud_Observaciones nvarchar(max) NULL,
    Solicitud_Presupuesto_Estimado decimal(18,2) NULL,
    Solicitud_Cliente_Dni nvarchar(255) NULL,
    Solicitud_Cliente_Mail nvarchar(255) NULL,
    Solicitud_Agente bigint NULL,
    Solicitud_Encuesta bigint NULL,
    CONSTRAINT PK_Solicitud PRIMARY KEY (Solicitud_Nro_Solicitud),
    CONSTRAINT FK_Solicitud_Agente FOREIGN KEY (Solicitud_Agente) REFERENCES TP_APROBADO.Agente (Agente_Legajo),
    CONSTRAINT FK_Solicitud_Encuesta FOREIGN KEY (Solicitud_Encuesta) REFERENCES TP_APROBADO.Encuesta (Encuesta_Codigo_Encuesta)
);
GO



CREATE TABLE TP_APROBADO.Detalle_Solicitud (
    Detalle_Solicitud_Codigo bigint NOT NULL,
    Detalle_Solicitud_Nro_Solicitud bigint NULL,
    Detalle_Solicitud_Ciudad nvarchar(255) NULL,
    Detalle_Solicitud_Cant_Dias_Aprox int NULL,
    Detalle_Solicitud_Observaciones nvarchar(max) NULL,
    CONSTRAINT PK_Detalle_Solicitud PRIMARY KEY (Detalle_Solicitud_Codigo),
    CONSTRAINT FK_Detalle_Solicitud_Solicitud FOREIGN KEY (Detalle_Solicitud_Nro_Solicitud) REFERENCES TP_APROBADO.Solicitud (Solicitud_Nro_Solicitud)
);
GO



CREATE TABLE TP_APROBADO.Propuesta (
    Propuesta_Nro_Propuesta bigint NOT NULL,
    Solicitud_Nro_Solicitud bigint NULL,
    Propuesta_Fecha_Emision date NULL,
    Propuesta_Vigencia_Hasta date NULL,
    Propuesta_Fecha_Desde date NULL,
    Propuesta_Fecha_Hasta date NULL,
    Propuesta_Subtotal decimal(18,2) NULL,
    Propuesta_Descuento decimal(18,2) NULL,
    Propuesta_Importe_Total decimal(18,2) NULL,
    Propuesta_Estado nvarchar(255) NULL,
    Propuesta_Agente bigint NULL,
    CONSTRAINT PK_Propuesta PRIMARY KEY (Propuesta_Nro_Propuesta),
    CONSTRAINT FK_Propuesta_Solicitud FOREIGN KEY (Solicitud_Nro_Solicitud) REFERENCES TP_APROBADO.Solicitud (Solicitud_Nro_Solicitud),
    CONSTRAINT FK_Propuesta_Agente FOREIGN KEY (Propuesta_Agente) REFERENCES TP_APROBADO.Agente (Agente_Legajo)
);
GO



CREATE TABLE TP_APROBADO.Detalle_Propuesta_Hospedaje (
    Detalle_Propuesta_Hospedaje_Codigo bigint NOT NULL,
    Propuesta_Nro_Propuesta bigint NULL,
    Detalle_Propuesta_Hospedaje_Habitacion_Codigo bigint NULL,
    Detalle_Propuesta_Hospedaje_Fecha_Desde date NULL,
    Detalle_Propuesta_Hospedaje_Fecha_Hasta date NULL,
    Detalle_Propuesta_Hospedaje_Cant int NULL,
    Detalle_Propuesta_Hospedaje_Precio decimal(18,2) NULL,
    Detalle_Propuesta_Hospedaje_Subtotal decimal(18,2) NULL,
    CONSTRAINT PK_Detalle_Propuesta_Hospedaje PRIMARY KEY (Detalle_Propuesta_Hospedaje_Codigo),
    CONSTRAINT FK_Detalle_Propuesta_Hospedaje_Propuesta FOREIGN KEY (Propuesta_Nro_Propuesta) REFERENCES TP_APROBADO.Propuesta (Propuesta_Nro_Propuesta),
    CONSTRAINT FK_Detalle_Propuesta_Hospedaje_Habitacion FOREIGN KEY (Detalle_Propuesta_Hospedaje_Habitacion_Codigo) REFERENCES TP_APROBADO.Habitacion (Habitacion_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Detalle_Propuesta_Vuelo (
    Detalle_Propuesta_Vuelo_Cod bigint NOT NULL,
    Detalle_Propuesta_Nro_Propuesta bigint NULL,
    Detalle_Propuesta_Vuelo_Cant_Pasajes int NULL,
    Detalle_Propuesta_Vuelo_Precio decimal(18,2) NULL,
    Detalle_Propuesta_Vuelo_Subtotal decimal(18,2) NULL,
    CONSTRAINT PK_Detalle_Propuesta_Vuelo PRIMARY KEY (Detalle_Propuesta_Vuelo_Cod),
    CONSTRAINT FK_Detalle_Propuesta_Vuelo_Propuesta FOREIGN KEY (Detalle_Propuesta_Nro_Propuesta) REFERENCES TP_APROBADO.Propuesta (Propuesta_Nro_Propuesta)
);
GO



CREATE TABLE TP_APROBADO.Venta (
    Venta_Nro_Venta bigint NOT NULL,
    Venta_Fecha_Venta date NULL,
    Venta_Canal_Venta varchar(50) NULL,
    Venta_Medio_Pago varchar(50) NULL,
    Venta_Subtotal decimal(18,2) NULL,
    Venta_Descuento decimal(18,2) NULL,
    Venta_Importe_Total decimal(18,2) NULL,
    Venta_Agente bigint NULL,
    Venta_Cliente_Dni nvarchar(510) NULL,
    Venta_Cliente_Mail nvarchar(510) NULL,
    Venta_Propuesta bigint NULL,
    Venta_Encuesta bigint NULL,
    CONSTRAINT PK_Venta PRIMARY KEY (Venta_Nro_Venta),
    CONSTRAINT FK_Venta_Agente FOREIGN KEY (Venta_Agente) REFERENCES TP_APROBADO.Agente (Agente_Legajo),
    CONSTRAINT FK_Venta_Propuesta FOREIGN KEY (Venta_Propuesta) REFERENCES TP_APROBADO.Propuesta (Propuesta_Nro_Propuesta)
);
GO



CREATE TABLE TP_APROBADO.Detalle_Venta_Excursion (
    Detalle_Venta_Excursion_Cod bigint NOT NULL,
    Venta_Nro_Venta bigint NULL,
    Excursion_Codigo bigint NULL,
    Detalle_Venta_Excursion_Fecha_Reserva date NULL,
    Detalle_Venta_Excursion_Cant int NULL,
    Detalle_Venta_Excursion_Precio_Unitario decimal(18,2) NULL,
    Detalle_Venta_Excursion_Subtotal decimal(18,2) NULL,
    Detalle_Venta_Excursion_Cod_Reserva varchar(255) NULL,
    CONSTRAINT PK_Detalle_Venta_Excursion PRIMARY KEY (Detalle_Venta_Excursion_Cod),
    CONSTRAINT FK_Detalle_Venta_Excursion_Venta FOREIGN KEY (Venta_Nro_Venta) REFERENCES TP_APROBADO.Venta (Venta_Nro_Venta),
    CONSTRAINT FK_Detalle_Venta_Excursion_Excursion FOREIGN KEY (Excursion_Codigo) REFERENCES TP_APROBADO.Excursion (Excursion_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Detalle_Venta_Hospedaje (
    Detalle_Venta_Hospedaje_Cod bigint NOT NULL,
    Detalle_Venta_Hospedaje_Fecha_Desde date NULL,
    Detalle_Venta_Hospedaje_Fecha_Hasta date NULL,
    Detalle_Venta_Hospedaje_Cantidad int NULL,
    Detalle_Venta_Hospedaje_Precio_Unitario decimal(18,2) NULL,
    Detalle_Venta_Hospedaje_Subtotal decimal(18,2) NULL,
    Detalle_Venta_Hospedaje_Cod_Reserva varchar(255) NULL,
    Habitacion_Codigo bigint NULL,
    Detalle_Venta_Nro_Venta bigint NULL,
    CONSTRAINT PK_Detalle_Venta_Hospedaje PRIMARY KEY (Detalle_Venta_Hospedaje_Cod),
    CONSTRAINT FK_Detalle_Venta_Hospedaje_Venta FOREIGN KEY (Detalle_Venta_Nro_Venta) REFERENCES TP_APROBADO.Venta (Venta_Nro_Venta),
    CONSTRAINT FK_Detalle_Venta_Hospedaje_Habitacion FOREIGN KEY (Habitacion_Codigo) REFERENCES TP_APROBADO.Habitacion (Habitacion_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Detalle_Venta_Vuelo (
    Detalle_Venta_Vuelo_Cod bigint NOT NULL,
    Detalle_Venta_Vuelo_Cantidad_Pasajes int NULL,
    Detalle_Venta_Vuelo_Preco_Unitano decimal(18,2) NULL,
    Detalle_Venta_Vuelo_Subtotal decimal(18,2) NULL,
    Detalle_Venta_Vuelo_Cod_Reserva varchar(255) NULL,
    Detalle_Venta_Nro_Venta bigint NULL,
    Detalle_Venta_Vuelo_Codigo bigint NULL,
    CONSTRAINT PK_Detalle_Venta_Vuelo PRIMARY KEY (Detalle_Venta_Vuelo_Cod),
    CONSTRAINT FK_Detalle_Venta_Vuelo_Venta FOREIGN KEY (Detalle_Venta_Nro_Venta) REFERENCES TP_APROBADO.Venta (Venta_Nro_Venta),
    CONSTRAINT FK_Detalle_Venta_Vuelo_Vuelo FOREIGN KEY (Detalle_Venta_Vuelo_Codigo) REFERENCES TP_APROBADO.Vuelo (Vuelo_Codigo)
);
GO

/* Verificacion final */
SELECT 
    s.name AS Esquema,
    t.name AS Tabla
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'TP_APROBADO'
ORDER BY t.name;
GO

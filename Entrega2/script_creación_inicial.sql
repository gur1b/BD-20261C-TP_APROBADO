/* 
============================================================================
TP GESTIÓN DE DATOS - SCRIPT DE CREACIÓN INICIAL
Esquema: TP_APROBADO  |  Motor: SQL Server 2022
============================================================================ 
 */

USE GD1C2026;
GO

SET NOCOUNT ON;
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


CREATE TABLE TP_APROBADO.Aerolinea (
    Aerolinea_Codigo nvarchar(255) NOT NULL,
    Aerolinea_Nombre nvarchar(510) NULL,
    Aerolinea_Pais bigint NULL,
    Aerolinea_Alianza bigint NULL,
    CONSTRAINT PK_Aerolinea PRIMARY KEY (Aerolinea_Codigo),
    CONSTRAINT FK_Aerolinea_Alianza FOREIGN KEY (Aerolinea_Alianza) REFERENCES TP_APROBADO.Alianza (Alianza_Codigo),
    CONSTRAINT FK_Aerolinea_Pais FOREIGN KEY (Aerolinea_Pais) REFERENCES TP_APROBADO.Pais (Pais_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Ciudad (
    Ciudad_Codigo bigint NOT NULL,
    Ciudad_Nombre nvarchar(400) NULL,
    Ciudad_es_capital bit NULL,
    Ciudad_Pais bigint NULL,
    CONSTRAINT PK_Ciudad PRIMARY KEY (Ciudad_Codigo),
    CONSTRAINT FK_Ciudad_Pais FOREIGN KEY (Ciudad_Pais) REFERENCES TP_APROBADO.Pais (Pais_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Cliente (
    Cliente_Dni nvarchar(255) NOT NULL,
    Cliente_Mail nvarchar(255) NOT NULL,
    Cliente_Nombre nvarchar(255) NULL,
    Cliente_Apellido nvarchar(255) NULL,
    Cliente_Tel nvarchar(255) NULL,
    Cliente_Direccion nvarchar(255) NULL,
    Cliente_Fecha_Nac date NULL,
    Cliente_Localidad bigint NULL,
    Cliente_Provincia bigint NULL,
    CONSTRAINT PK_Cliente PRIMARY KEY (Cliente_Dni, Cliente_Mail),
    CONSTRAINT FK_Cliente_Localidad FOREIGN KEY (Cliente_Localidad) REFERENCES TP_APROBADO.Localidad (Localidad_Codigo),
    CONSTRAINT FK_Cliente_Provincia FOREIGN KEY (Cliente_Provincia) REFERENCES TP_APROBADO.Provincia (Provincia_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Encuesta (
    Encuesta_Codigo_Encuesta bigint NOT NULL,
    Encuesta_Fecha_Encuesta date NULL,
    Encuesta_Comentarios nvarchar(max) NULL,
    CONSTRAINT PK_Encuesta PRIMARY KEY (Encuesta_Codigo_Encuesta)
);
GO



CREATE TABLE TP_APROBADO.Excursion (
    Excursion_Codigo bigint NOT NULL,
    Proveedor_Codigo bigint NULL,
    Excursion_Nombre nvarchar(255) NULL,
    Excursion_Descripcion nvarchar(max) NULL,
    Excursion_Horario nvarchar(50) NULL,
    Excursion_Duracion int NULL,
    Excursion_Precio decimal(18,2) NULL,
    CONSTRAINT PK_Excursion PRIMARY KEY (Excursion_Codigo),
    CONSTRAINT FK_Excursion_Proveedor FOREIGN KEY (Proveedor_Codigo) REFERENCES TP_APROBADO.Proveedor (Proveedor_Codigo)
);


CREATE TABLE TP_APROBADO.Aeropuerto (
    Aeropuerto_Codigo nvarchar(10) NOT NULL,
    Aeropuerto_Descripcion nvarchar(400) NULL,
    Aeropuerto_Ciudad bigint NULL,
    Aeropuerto_Pais bigint NULL,
    CONSTRAINT PK_Aeropuerto PRIMARY KEY (Aeropuerto_Codigo),
    CONSTRAINT FK_Aeropuerto_Ciudad FOREIGN KEY (Aeropuerto_Ciudad) REFERENCES TP_APROBADO.Ciudad (Ciudad_Codigo),
    CONSTRAINT FK_Aeropuerto_Pais FOREIGN KEY (Aeropuerto_Pais) REFERENCES TP_APROBADO.Pais (Pais_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Agencia (
    Agencia_Nro_Agencia bigint NOT NULL,
    Agencia_Direccion nvarchar(255) NULL,
    Agencia_Telefono nvarchar(255) NULL,
    Agencia_Mail nvarchar(255) NULL,
    Agencia_Provincia bigint NULL,
    Agencia_Localidad bigint NULL,
    CONSTRAINT PK_Agencia PRIMARY KEY (Agencia_Nro_Agencia),
    CONSTRAINT FK_Agencia_Provincia FOREIGN KEY (Agencia_Provincia) REFERENCES TP_APROBADO.Provincia (Provincia_Codigo),
    CONSTRAINT FK_Agencia_Localidad FOREIGN KEY (Agencia_Localidad) REFERENCES TP_APROBADO.Localidad (Localidad_Codigo)
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
    Hospedaje_Ciudad bigint NULL,
    Hospedaje_Pais bigint NULL,
    Hospedaje_Nombre nvarchar(255) NULL,
    Hospedaje_Direccion nvarchar(255) NULL,
    Hospedaje_Incluye_Desayuno bit NULL,
    Hospedaje_Check_In nvarchar(50) NULL,
    Hospedaje_Check_Out nvarchar(50) NULL,
    CONSTRAINT PK_Hospedaje PRIMARY KEY (Hospedaje_Codigo),
    CONSTRAINT FK_Hospedaje_Ciudad FOREIGN KEY (Hospedaje_Ciudad) REFERENCES TP_APROBADO.Ciudad (Ciudad_Codigo),
    CONSTRAINT FK_Hospedaje_Pais FOREIGN KEY (Hospedaje_Pais) REFERENCES TP_APROBADO.Pais (Pais_Codigo)
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
    Vuelo_Aeropuerto_Salida nvarchar(10) NULL,
    Vuelo_Aeropuerto_Llegada nvarchar(10) NULL,
    Vuelo_Aerolinea_Codigo nvarchar(255) NULL,
    CONSTRAINT PK_Vuelo PRIMARY KEY (Vuelo_Codigo),
    CONSTRAINT FK_Vuelo_Aeropuerto_Salida FOREIGN KEY (Vuelo_Aeropuerto_Salida) REFERENCES TP_APROBADO.Aeropuerto (Aeropuerto_Codigo),
    CONSTRAINT FK_Vuelo_Aeropuerto_Llegada FOREIGN KEY (Vuelo_Aeropuerto_Llegada) REFERENCES TP_APROBADO.Aeropuerto (Aeropuerto_Codigo),
    CONSTRAINT FK_Vuelo_Aerolinea FOREIGN KEY (Vuelo_Aerolinea_Codigo) REFERENCES TP_APROBADO.Aerolinea (Aerolinea_Codigo)
);


CREATE TABLE TP_APROBADO.Habitacion (
    Habitacion_Codigo bigint NOT NULL,
    Habitacion_Nombre nvarchar(510) NULL,
    Habitacion_Descripcion nvarchar(max) NULL,
    Habitacion_Precio_Noche decimal(18,2) NULL,
    Habitacion_Precio decimal(18,2) NULL,
    Habitacion_Cantidad int NULL,
    Habitacion_Hospedaje bigint NULL,
    CONSTRAINT PK_Habitacion PRIMARY KEY (Habitacion_Codigo),
    CONSTRAINT FK_Habitacion_Hospedaje FOREIGN KEY (Habitacion_Hospedaje) REFERENCES TP_APROBADO.Hospedaje (Hospedaje_Codigo)
);
GO     



CREATE TABLE TP_APROBADO.Agente (
    Agente_Legajo bigint NOT NULL,
    Agencia_Nro_Agencia bigint NULL,
    Agente_Nombre nvarchar(255) NULL,
    Agente_Apellido nvarchar(255) NULL,
    Agente_DNI nvarchar(255) NULL,
    Agente_Fecha_Nac date NULL,
    Agente_Telefono nvarchar(255) NULL,
    Agente_Mail nvarchar(255) NULL,
    Agente_Direccion nvarchar(255) NULL,
    Agente_Provincia bigint NULL,
    Agente_Localidad bigint NULL,
    CONSTRAINT PK_Agente PRIMARY KEY (Agente_Legajo),
    CONSTRAINT FK_Agente_Agencia FOREIGN KEY (Agencia_Nro_Agencia) REFERENCES TP_APROBADO.Agencia (Agencia_Nro_Agencia),
    CONSTRAINT FK_Agente_Provincia FOREIGN KEY (Agente_Provincia) REFERENCES TP_APROBADO.Provincia (Provincia_Codigo),
    CONSTRAINT FK_Agente_Localidad FOREIGN KEY (Agente_Localidad) REFERENCES TP_APROBADO.Localidad (Localidad_Codigo)
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
    CONSTRAINT FK_Solicitud_Encuesta FOREIGN KEY (Solicitud_Encuesta) REFERENCES TP_APROBADO.Encuesta (Encuesta_Codigo_Encuesta),
    CONSTRAINT FK_Solicitud_Cliente FOREIGN KEY (Solicitud_Cliente_Dni, Solicitud_Cliente_Mail) REFERENCES TP_APROBADO.Cliente (Cliente_Dni, Cliente_Mail)
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
    Propuesta_Estado bigint NULL,
    Propuesta_Agente bigint NULL,
    CONSTRAINT PK_Propuesta PRIMARY KEY (Propuesta_Nro_Propuesta),
    CONSTRAINT FK_Propuesta_Solicitud FOREIGN KEY (Solicitud_Nro_Solicitud) REFERENCES TP_APROBADO.Solicitud (Solicitud_Nro_Solicitud),
    CONSTRAINT FK_Propuesta_Agente FOREIGN KEY (Propuesta_Agente) REFERENCES TP_APROBADO.Agente (Agente_Legajo),
    CONSTRAINT FK_Propuesta_Estado FOREIGN KEY (Propuesta_Estado) REFERENCES TP_APROBADO.Estado (Estado_Codigo)
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
    Detalle_Propuesta_Codigo_Vuelo bigint NULL, 
    CONSTRAINT PK_Detalle_Propuesta_Vuelo PRIMARY KEY (Detalle_Propuesta_Vuelo_Cod),
    CONSTRAINT FK_Detalle_Propuesta_Vuelo_Propuesta FOREIGN KEY (Detalle_Propuesta_Nro_Propuesta) REFERENCES TP_APROBADO.Propuesta (Propuesta_Nro_Propuesta),
    CONSTRAINT FK_Detalle_Propuesta_Vuelo_Vuelo FOREIGN KEY (Detalle_Propuesta_Codigo_Vuelo) REFERENCES TP_APROBADO.Vuelo (Vuelo_Codigo)
);
GO



CREATE TABLE TP_APROBADO.Venta (
    Venta_Nro_Venta bigint NOT NULL,
    Venta_Fecha_Venta date NULL,
    Venta_Canal_Venta bigint NULL,
    Venta_Medio_Pago bigint NULL,
    Venta_Subtotal decimal(18,2) NULL,
    Venta_Descuento decimal(18,2) NULL,
    Venta_Importe_Total decimal(18,2) NULL,
    Venta_Agente bigint NULL,
    Venta_Cliente_Dni nvarchar(255) NULL,
    Venta_Cliente_Mail nvarchar(255) NULL,
    Venta_Propuesta bigint NULL,
    Venta_Encuesta bigint NULL,
    CONSTRAINT PK_Venta PRIMARY KEY (Venta_Nro_Venta),
    CONSTRAINT FK_Venta_Agente FOREIGN KEY (Venta_Agente) REFERENCES TP_APROBADO.Agente (Agente_Legajo),
    CONSTRAINT FK_Venta_Propuesta FOREIGN KEY (Venta_Propuesta) REFERENCES TP_APROBADO.Propuesta (Propuesta_Nro_Propuesta),
    CONSTRAINT FK_Venta_Cliente FOREIGN KEY (Venta_Cliente_Dni, Venta_Cliente_Mail) REFERENCES TP_APROBADO.Cliente (Cliente_Dni, Cliente_Mail),
    CONSTRAINT FK_Venta_Canal_Venta FOREIGN KEY (Venta_Canal_Venta) REFERENCES TP_APROBADO.Canal_Venta (Canal_Venta_Codigo),
    CONSTRAINT FK_Venta_Medio_Pago FOREIGN KEY (Venta_Medio_Pago) REFERENCES TP_APROBADO.Medio_Pago (Medio_Pago_Codigo)

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
    Detalle_Venta_Excursion_Cod_Reserva nvarchar(255) NULL,
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
    Detalle_Venta_Hospedaje_Cod_Reserva nvarchar(255) NULL,
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
    Detalle_Venta_Vuelo_Precio_Unitario decimal(18,2) NULL,
    Detalle_Venta_Vuelo_Subtotal decimal(18,2) NULL,
    Detalle_Venta_Vuelo_Cod_Reserva nvarchar(255) NULL,
    Detalle_Venta_Nro_Venta bigint NULL,
    Detalle_Venta_Vuelo_Codigo bigint NULL,
    CONSTRAINT PK_Detalle_Venta_Vuelo PRIMARY KEY (Detalle_Venta_Vuelo_Cod),
    CONSTRAINT FK_Detalle_Venta_Vuelo_Venta FOREIGN KEY (Detalle_Venta_Nro_Venta) REFERENCES TP_APROBADO.Venta (Venta_Nro_Venta),
    CONSTRAINT FK_Detalle_Venta_Vuelo_Vuelo FOREIGN KEY (Detalle_Venta_Vuelo_Codigo) REFERENCES TP_APROBADO.Vuelo (Vuelo_Codigo)
);
GO


CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Alianza
AS
BEGIN
    INSERT INTO TP_APROBADO.Alianza (Alianza_Codigo, Alianza_Nombre)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Aerolinea_Alianza
    FROM (SELECT DISTINCT Aerolinea_Alianza FROM gd_esquema.Maestra WHERE Aerolinea_Alianza IS NOT NULL) D;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Aspecto
AS
BEGIN
    INSERT INTO TP_APROBADO.Aspecto (Aspecto_Codigo, Aspecto_Aspecto)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Aspecto_Aspecto
    FROM (SELECT DISTINCT Aspecto_Aspecto FROM gd_esquema.Maestra WHERE Aspecto_Aspecto IS NOT NULL) D;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Canal_Venta
AS
BEGIN
    INSERT INTO TP_APROBADO.Canal_Venta (Canal_Venta_Codigo, Canal_Venta_Nombre)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Venta_Canal_Venta
    FROM (SELECT DISTINCT Venta_Canal_Venta FROM gd_esquema.Maestra WHERE Venta_Canal_Venta IS NOT NULL) D;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Medio_Pago
AS
BEGIN
    INSERT INTO TP_APROBADO.Medio_Pago (Medio_Pago_Codigo, Medio_Pago_Nombre)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Venta_Medio_Pago
    FROM (SELECT DISTINCT Venta_Medio_Pago FROM gd_esquema.Maestra WHERE Venta_Medio_Pago IS NOT NULL) D;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Estado
AS
BEGIN
    INSERT INTO TP_APROBADO.Estado (Estado_Codigo, Estado_Nombre, Estado_Descripcion)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Propuesta_Estado, NULL
    FROM (SELECT DISTINCT Propuesta_Estado FROM gd_esquema.Maestra WHERE Propuesta_Estado IS NOT NULL) D;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Provincia
AS
BEGIN
    INSERT INTO TP_APROBADO.Provincia (Provincia_Codigo, Provincia_Nombre)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Provincia_Nombre
    FROM (
        SELECT Agencia_Provincia AS Provincia_Nombre FROM gd_esquema.Maestra WHERE Agencia_Provincia IS NOT NULL
        UNION SELECT Agente_Provincia  FROM gd_esquema.Maestra WHERE Agente_Provincia  IS NOT NULL
        UNION SELECT Cliente_Provincia FROM gd_esquema.Maestra WHERE Cliente_Provincia IS NOT NULL
    ) D;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Localidad
AS
BEGIN
    INSERT INTO TP_APROBADO.Localidad (Localidad_Codigo, Localidad_Nombre)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Localidad_Nombre
    FROM (
        SELECT Agencia_Localidad AS Localidad_Nombre FROM gd_esquema.Maestra WHERE Agencia_Localidad IS NOT NULL
        UNION SELECT Agente_Localidad  FROM gd_esquema.Maestra WHERE Agente_Localidad  IS NOT NULL
        UNION SELECT Cliente_Localidad FROM gd_esquema.Maestra WHERE Cliente_Localidad IS NOT NULL
    ) D;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Pais
AS
BEGIN
    INSERT INTO TP_APROBADO.Pais (Pais_Codigo, Pais_Nombre, Pais_Capital)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Pais_Nombre, NULL
    FROM (
        SELECT Aeropuerto_Salida_Pais  AS Pais_Nombre FROM gd_esquema.Maestra WHERE Aeropuerto_Salida_Pais  IS NOT NULL
        UNION SELECT Aeropuerto_Llegada_Pais FROM gd_esquema.Maestra WHERE Aeropuerto_Llegada_Pais IS NOT NULL
        UNION SELECT Aerolinea_Pais          FROM gd_esquema.Maestra WHERE Aerolinea_Pais          IS NOT NULL
        UNION SELECT Hospedaje_Pais          FROM gd_esquema.Maestra WHERE Hospedaje_Pais          IS NOT NULL
    ) D;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Proveedor
AS
BEGIN
    INSERT INTO TP_APROBADO.Proveedor (Proveedor_Codigo, Proveedor_Nombre, Proveedor_Mail, Proveedor_Telefono)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Proveedor_Nombre, Proveedor_Mail, Proveedor_Telefono
    FROM (SELECT DISTINCT Proveedor_Nombre, Proveedor_Mail, Proveedor_Telefono
          FROM gd_esquema.Maestra WHERE Proveedor_Nombre IS NOT NULL) D;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Ciudad
AS
BEGIN
    WITH Pares AS (
        SELECT Aeropuerto_Salida_Ciudad  AS Ciudad_Nombre, Aeropuerto_Salida_Pais  AS Pais_Nombre FROM gd_esquema.Maestra WHERE Aeropuerto_Salida_Ciudad  IS NOT NULL
        UNION SELECT Aeropuerto_Llegada_Ciudad, Aeropuerto_Llegada_Pais FROM gd_esquema.Maestra WHERE Aeropuerto_Llegada_Ciudad IS NOT NULL
        UNION SELECT Hospedaje_Ciudad,          Hospedaje_Pais          FROM gd_esquema.Maestra WHERE Hospedaje_Ciudad          IS NOT NULL
    ),
    Dedup AS (
        SELECT Ciudad_Nombre, Pais_Nombre,
               ROW_NUMBER() OVER (PARTITION BY Ciudad_Nombre
                                  ORDER BY CASE WHEN Pais_Nombre IS NULL THEN 1 ELSE 0 END) AS rn
        FROM Pares
    )
    INSERT INTO TP_APROBADO.Ciudad (Ciudad_Codigo, Ciudad_Nombre, Ciudad_es_capital, Ciudad_Pais)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), D.Ciudad_Nombre, NULL, P.Pais_Codigo
    FROM Dedup D
    LEFT JOIN TP_APROBADO.Pais P ON P.Pais_Nombre = D.Pais_Nombre
    WHERE D.rn = 1;
END
GO


CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Aerolinea
AS
BEGIN
    WITH Dedup AS (
        SELECT Aerolinea_Codigo, Aerolinea_Nombre, Aerolinea_Pais, Aerolinea_Alianza,
               ROW_NUMBER() OVER (PARTITION BY Aerolinea_Codigo
                                  ORDER BY CASE WHEN Aerolinea_Nombre IS NULL THEN 1 ELSE 0 END) AS rn
        FROM gd_esquema.Maestra
        WHERE Aerolinea_Codigo IS NOT NULL
    )
    INSERT INTO TP_APROBADO.Aerolinea (Aerolinea_Codigo, Aerolinea_Nombre, Aerolinea_Pais, Aerolinea_Alianza)
    SELECT D.Aerolinea_Codigo, D.Aerolinea_Nombre, P.Pais_Codigo, A.Alianza_Codigo
    FROM Dedup D
    LEFT JOIN TP_APROBADO.Pais    P ON P.Pais_Nombre    = D.Aerolinea_Pais
    LEFT JOIN TP_APROBADO.Alianza A ON A.Alianza_Nombre = D.Aerolinea_Alianza
    WHERE D.rn = 1;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Aeropuerto
AS
BEGIN
    WITH Aero AS (
        SELECT Aeropuerto_Salida_Codigo AS Cod, Aeropuerto_Salida_Descripcion AS Descr,
               Aeropuerto_Salida_Ciudad  AS Ciud, Aeropuerto_Salida_Pais        AS Pa
        FROM gd_esquema.Maestra WHERE Aeropuerto_Salida_Codigo IS NOT NULL
        UNION ALL
        SELECT Aeropuerto_Llegada_Codigo, Aeropuerto_Llegada_Descripcion,
               Aeropuerto_Llegada_Ciudad,  Aeropuerto_Llegada_Pais
        FROM gd_esquema.Maestra WHERE Aeropuerto_Llegada_Codigo IS NOT NULL
    ),
    Dedup AS (
        SELECT Cod, Descr, Ciud, Pa,
               ROW_NUMBER() OVER (PARTITION BY Cod ORDER BY CASE WHEN Descr IS NULL THEN 1 ELSE 0 END) AS rn
        FROM Aero
    )
    INSERT INTO TP_APROBADO.Aeropuerto (Aeropuerto_Codigo, Aeropuerto_Descripcion, Aeropuerto_Ciudad, Aeropuerto_Pais)
    SELECT D.Cod, D.Descr, C.Ciudad_Codigo, P.Pais_Codigo
    FROM Dedup D
    LEFT JOIN TP_APROBADO.Ciudad C ON C.Ciudad_Nombre = D.Ciud
    LEFT JOIN TP_APROBADO.Pais   P ON P.Pais_Nombre   = D.Pa
    WHERE D.rn = 1;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Agencia
AS
BEGIN
    WITH Dedup AS (
        SELECT Agencia_Nro_Agencia, Agencia_Direccion, Agencia_Telefono, Agencia_Mail,
               Agencia_Provincia, Agencia_Localidad,
               ROW_NUMBER() OVER (PARTITION BY Agencia_Nro_Agencia
                                  ORDER BY CASE WHEN Agencia_Direccion IS NULL THEN 1 ELSE 0 END) AS rn
        FROM gd_esquema.Maestra
        WHERE Agencia_Nro_Agencia IS NOT NULL
    )
    INSERT INTO TP_APROBADO.Agencia (Agencia_Nro_Agencia, Agencia_Direccion, Agencia_Telefono,
                                     Agencia_Mail, Agencia_Provincia, Agencia_Localidad)
    SELECT D.Agencia_Nro_Agencia, D.Agencia_Direccion, D.Agencia_Telefono, D.Agencia_Mail,
           PR.Provincia_Codigo, LO.Localidad_Codigo
    FROM Dedup D
    LEFT JOIN TP_APROBADO.Provincia PR ON PR.Provincia_Nombre = D.Agencia_Provincia
    LEFT JOIN TP_APROBADO.Localidad LO ON LO.Localidad_Nombre = D.Agencia_Localidad
    WHERE D.rn = 1;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Cliente
AS
BEGIN
    WITH Dedup AS (
        SELECT Cliente_Dni, Cliente_Mail, Cliente_Nombre, Cliente_Apellido, Cliente_Tel,
               Cliente_Direccion, Cliente_Fecha_Nac, Cliente_Localidad, Cliente_Provincia,
               ROW_NUMBER() OVER (PARTITION BY Cliente_Dni, Cliente_Mail
                                  ORDER BY CASE WHEN Cliente_Nombre IS NULL THEN 1 ELSE 0 END) AS rn
        FROM gd_esquema.Maestra
        WHERE Cliente_Dni IS NOT NULL AND Cliente_Mail IS NOT NULL
    )
    INSERT INTO TP_APROBADO.Cliente (Cliente_Dni, Cliente_Mail, Cliente_Nombre, Cliente_Apellido,
                                     Cliente_Tel, Cliente_Direccion, Cliente_Fecha_Nac,
                                     Cliente_Localidad, Cliente_Provincia)
    SELECT D.Cliente_Dni, D.Cliente_Mail, D.Cliente_Nombre, D.Cliente_Apellido, D.Cliente_Tel,
           D.Cliente_Direccion, D.Cliente_Fecha_Nac, LO.Localidad_Codigo, PR.Provincia_Codigo
    FROM Dedup D
    LEFT JOIN TP_APROBADO.Localidad LO ON LO.Localidad_Nombre = D.Cliente_Localidad
    LEFT JOIN TP_APROBADO.Provincia PR ON PR.Provincia_Nombre = D.Cliente_Provincia
    WHERE D.rn = 1;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Encuesta
AS
BEGIN
    WITH Dedup AS (
        SELECT Encuesta_Codigo_Encuesta, Encuesta_Fecha_Encuesta, Encuesta_Comentarios,
               ROW_NUMBER() OVER (PARTITION BY Encuesta_Codigo_Encuesta
                                  ORDER BY CASE WHEN Encuesta_Fecha_Encuesta IS NULL THEN 1 ELSE 0 END) AS rn
        FROM gd_esquema.Maestra
        WHERE Encuesta_Codigo_Encuesta IS NOT NULL
    )
    INSERT INTO TP_APROBADO.Encuesta (Encuesta_Codigo_Encuesta, Encuesta_Fecha_Encuesta, Encuesta_Comentarios)
    SELECT Encuesta_Codigo_Encuesta, Encuesta_Fecha_Encuesta, Encuesta_Comentarios
    FROM Dedup WHERE rn = 1;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Excursion
AS
BEGIN
    WITH Dist AS (
        SELECT DISTINCT Excursion_Nombre, Excursion_Descripcion, Excursion_Horario,
               Excursion_Duracion, Excursion_Precio,
               Proveedor_Nombre, Proveedor_Mail, Proveedor_Telefono
        FROM gd_esquema.Maestra
        WHERE Excursion_Nombre IS NOT NULL
    )
    INSERT INTO TP_APROBADO.Excursion (Excursion_Codigo, Proveedor_Codigo, Excursion_Nombre,
                                       Excursion_Descripcion, Excursion_Horario,
                                       Excursion_Duracion, Excursion_Precio)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), P.Proveedor_Codigo, D.Excursion_Nombre,
           D.Excursion_Descripcion, D.Excursion_Horario, D.Excursion_Duracion, D.Excursion_Precio
    FROM Dist D
    LEFT JOIN TP_APROBADO.Proveedor P
        ON P.Proveedor_Nombre = D.Proveedor_Nombre
       AND ISNULL(P.Proveedor_Mail, '')     = ISNULL(D.Proveedor_Mail, '')
       AND ISNULL(P.Proveedor_Telefono, '') = ISNULL(D.Proveedor_Telefono, '');
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Hospedaje
AS
BEGIN
    WITH Dedup AS (
        SELECT Hospedaje_Nombre, Hospedaje_Direccion, Hospedaje_Incluye_Desayuno,
               Hospedaje_Check_In, Hospedaje_Check_Out, Hospedaje_Ciudad, Hospedaje_Pais,
               ROW_NUMBER() OVER (PARTITION BY Hospedaje_Nombre, Hospedaje_Direccion,
                                               Hospedaje_Incluye_Desayuno, Hospedaje_Check_In, Hospedaje_Check_Out
                                  ORDER BY (SELECT NULL)) AS rn
        FROM gd_esquema.Maestra
        WHERE Hospedaje_Nombre IS NOT NULL
    )
    INSERT INTO TP_APROBADO.Hospedaje (Hospedaje_Codigo, Hospedaje_Ciudad, Hospedaje_Pais, Hospedaje_Nombre,
                                       Hospedaje_Direccion, Hospedaje_Incluye_Desayuno, Hospedaje_Check_In, Hospedaje_Check_Out)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), C.Ciudad_Codigo, P.Pais_Codigo, D.Hospedaje_Nombre,
           D.Hospedaje_Direccion, D.Hospedaje_Incluye_Desayuno, D.Hospedaje_Check_In, D.Hospedaje_Check_Out
    FROM Dedup D
    LEFT JOIN TP_APROBADO.Ciudad C ON C.Ciudad_Nombre = D.Hospedaje_Ciudad
    LEFT JOIN TP_APROBADO.Pais   P ON P.Pais_Nombre   = D.Hospedaje_Pais
    WHERE D.rn = 1;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Agente
AS
BEGIN
    WITH Dedup AS (
        SELECT Agente_Legajo, Agencia_Nro_Agencia, Agente_Nombre, Agente_Apellido, Agente_Dni, Agente_Fecha_Nac,
               Agente_Telefono, Agente_Mail, Agente_Direccion, Agente_Provincia, Agente_Localidad,
               ROW_NUMBER() OVER (PARTITION BY Agente_Legajo
                                  ORDER BY CASE WHEN Agente_Nombre IS NULL THEN 1 ELSE 0 END,
                                           CASE WHEN Agencia_Nro_Agencia IS NULL THEN 1 ELSE 0 END) AS rn
        FROM gd_esquema.Maestra
        WHERE Agente_Legajo IS NOT NULL
    )
    INSERT INTO TP_APROBADO.Agente (Agente_Legajo, Agencia_Nro_Agencia, Agente_Nombre, Agente_Apellido, Agente_DNI,
                                    Agente_Fecha_Nac, Agente_Telefono, Agente_Mail, Agente_Direccion,
                                    Agente_Provincia, Agente_Localidad)
    SELECT D.Agente_Legajo, D.Agencia_Nro_Agencia, D.Agente_Nombre, D.Agente_Apellido, D.Agente_Dni, D.Agente_Fecha_Nac,
           D.Agente_Telefono, D.Agente_Mail, D.Agente_Direccion, PR.Provincia_Codigo, LO.Localidad_Codigo
    FROM Dedup D
    LEFT JOIN TP_APROBADO.Provincia PR ON PR.Provincia_Nombre = D.Agente_Provincia
    LEFT JOIN TP_APROBADO.Localidad LO ON LO.Localidad_Nombre = D.Agente_Localidad
    WHERE D.rn = 1;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Habitacion
AS
BEGIN
    WITH Dist AS (
        SELECT DISTINCT
            Hospedaje_Nombre, Hospedaje_Direccion, Hospedaje_Incluye_Desayuno, Hospedaje_Check_In, Hospedaje_Check_Out,
            Habitacion_Nombre, Habitacion_Descripcion, Habitacion_Precio_Noche
        FROM gd_esquema.Maestra
        WHERE Habitacion_Nombre IS NOT NULL AND Hospedaje_Nombre IS NOT NULL
    )
    INSERT INTO TP_APROBADO.Habitacion (Habitacion_Codigo, Habitacion_Nombre, Habitacion_Descripcion,
                                        Habitacion_Precio_Noche, Habitacion_Precio, Habitacion_Cantidad, Habitacion_Hospedaje)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
           D.Habitacion_Nombre, D.Habitacion_Descripcion, D.Habitacion_Precio_Noche, NULL, NULL, H.Hospedaje_Codigo
    FROM Dist D
    JOIN TP_APROBADO.Hospedaje H
        ON ISNULL(H.Hospedaje_Nombre, N'@N@')    = ISNULL(D.Hospedaje_Nombre, N'@N@')
       AND ISNULL(H.Hospedaje_Direccion, N'@N@') = ISNULL(D.Hospedaje_Direccion, N'@N@')
       AND ISNULL(CAST(H.Hospedaje_Incluye_Desayuno AS int), -1) = ISNULL(CAST(D.Hospedaje_Incluye_Desayuno AS int), -1)
       AND ISNULL(H.Hospedaje_Check_In, N'@N@')  = ISNULL(D.Hospedaje_Check_In, N'@N@')
       AND ISNULL(H.Hospedaje_Check_Out, N'@N@') = ISNULL(D.Hospedaje_Check_Out, N'@N@');
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Vuelo
AS
BEGIN
    WITH Dist AS (
        SELECT DISTINCT
            Aerolinea_Codigo, Aeropuerto_Salida_Codigo, Aeropuerto_Llegada_Codigo,
            Vuelo_Fecha_Salida, Vuelo_Horario_Salida, Vuelo_Fecha_Llegada, Vuelo_Horario_Llegada,
            Vuelo_Duracion, Vuelo_Precio, Vuelo_Incluye_Carry, Vuelo_Incluye_Valija
        FROM gd_esquema.Maestra
        WHERE Aeropuerto_Salida_Codigo IS NOT NULL
    )
    INSERT INTO TP_APROBADO.Vuelo (
        Vuelo_Codigo, Vuelo_Fecha_Salida, Vuelo_Horario_Salida, Vuelo_Fecha_Llegada,
        Vuelo_Horario_Llegada, Vuelo_Duracion, Vuelo_Precio, Vuelo_Incluye_Carry,
        Vuelo_Incluye_Valija, Vuelo_Aeropuerto_Salida, Vuelo_Aeropuerto_Llegada, Vuelo_Aerolinea_Codigo)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
           Vuelo_Fecha_Salida, Vuelo_Horario_Salida, Vuelo_Fecha_Llegada, Vuelo_Horario_Llegada,
           Vuelo_Duracion, Vuelo_Precio, Vuelo_Incluye_Carry, Vuelo_Incluye_Valija,
           Aeropuerto_Salida_Codigo, Aeropuerto_Llegada_Codigo, Aerolinea_Codigo
    FROM Dist;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Detalle_Encuesta
AS
BEGIN
    WITH Dedup AS (
        SELECT M.Encuesta_Codigo_Encuesta AS Enc, A.Aspecto_Codigo AS Asp, M.Detalle_Encuesta_Puntaje AS Punt,
               ROW_NUMBER() OVER (PARTITION BY M.Encuesta_Codigo_Encuesta, A.Aspecto_Codigo ORDER BY (SELECT NULL)) AS rn
        FROM gd_esquema.Maestra M
        JOIN TP_APROBADO.Aspecto A ON A.Aspecto_Aspecto = M.Aspecto_Aspecto
        WHERE M.Encuesta_Codigo_Encuesta IS NOT NULL AND M.Aspecto_Aspecto IS NOT NULL
    )
    INSERT INTO TP_APROBADO.Detalle_Encuesta (Encuesta_Nro_Encuesta, Detalle_Encuesta_Puntaje, Detalle_Encuesta_Aspecto_Codigo)
    SELECT Enc, Punt, Asp FROM Dedup WHERE rn = 1;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Solicitud
AS
BEGIN
    WITH Dedup AS (
        SELECT Solicitud_Nro_Solicitud, Solicitud_Fecha_Solicitud, Solicitud_Fecha_Inicio_Tentativa,
               Solicitud_Fecha_Fin_Tentativa, Solicitud_Cant_Pax, Solicitud_Observaciones,
               Solicitud_Presupuesto_Estimado, Cliente_Dni, Cliente_Mail, Agente_Legajo, Encuesta_Codigo_Encuesta,
               ROW_NUMBER() OVER (PARTITION BY Solicitud_Nro_Solicitud
                                  ORDER BY CASE WHEN Solicitud_Fecha_Solicitud IS NULL THEN 1 ELSE 0 END) AS rn
        FROM gd_esquema.Maestra
        WHERE Solicitud_Nro_Solicitud IS NOT NULL
    )
    INSERT INTO TP_APROBADO.Solicitud (
        Solicitud_Nro_Solicitud, Solicitud_Fecha_solicitud, Solicitud_Fecha_Inicio_Tentativa,
        Solicitud_Fecha_Fin_tentativa, Solicitud_Cant_Pax, Solicitud_Observaciones,
        Solicitud_Presupuesto_Estimado, Solicitud_Cliente_Dni, Solicitud_Cliente_Mail,
        Solicitud_Agente, Solicitud_Encuesta)
    SELECT Solicitud_Nro_Solicitud, Solicitud_Fecha_Solicitud, Solicitud_Fecha_Inicio_Tentativa,
           Solicitud_Fecha_Fin_Tentativa, Solicitud_Cant_Pax, Solicitud_Observaciones,
           Solicitud_Presupuesto_Estimado, Cliente_Dni, Cliente_Mail, Agente_Legajo, Encuesta_Codigo_Encuesta
    FROM Dedup WHERE rn = 1;
END
GO


CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Detalle_Solicitud
AS
BEGIN
    WITH Dist AS (
        SELECT DISTINCT Solicitud_Nro_Solicitud, Detalle_Solicitud_Ciudad,
               Detalle_Solicitud_Cant_Dias_Aprox, Detalle_Solicitud_Observaciones
        FROM gd_esquema.Maestra
        WHERE Solicitud_Nro_Solicitud IS NOT NULL AND Detalle_Solicitud_Ciudad IS NOT NULL
    )
    INSERT INTO TP_APROBADO.Detalle_Solicitud (
        Detalle_Solicitud_Codigo, Detalle_Solicitud_Nro_Solicitud, Detalle_Solicitud_Ciudad,
        Detalle_Solicitud_Cant_Dias_Aprox, Detalle_Solicitud_Observaciones)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Solicitud_Nro_Solicitud, Detalle_Solicitud_Ciudad,
           Detalle_Solicitud_Cant_Dias_Aprox, Detalle_Solicitud_Observaciones
    FROM Dist;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Propuesta
AS
BEGIN
    WITH Dedup AS (
        SELECT Propuesta_Nro_Propuesta, Solicitud_Nro_Solicitud, Propuesta_Fecha_Emision,
               Propuesta_Vigencia_Hasta, Propuesta_Fecha_Desde, Propuesta_Fecha_Hasta,
               Propuesta_Subtotal, Propuesta_Descuento, Propuesta_Importe_Total, Propuesta_Estado, Agente_Legajo,
               ROW_NUMBER() OVER (PARTITION BY Propuesta_Nro_Propuesta
                                  ORDER BY CASE WHEN Propuesta_Fecha_Emision IS NULL THEN 1 ELSE 0 END) AS rn
        FROM gd_esquema.Maestra
        WHERE Propuesta_Nro_Propuesta IS NOT NULL
    )
    INSERT INTO TP_APROBADO.Propuesta (
        Propuesta_Nro_Propuesta, Solicitud_Nro_Solicitud, Propuesta_Fecha_Emision, Propuesta_Vigencia_Hasta,
        Propuesta_Fecha_Desde, Propuesta_Fecha_Hasta, Propuesta_Subtotal, Propuesta_Descuento,
        Propuesta_Importe_Total, Propuesta_Estado, Propuesta_Agente)
    SELECT D.Propuesta_Nro_Propuesta, D.Solicitud_Nro_Solicitud, D.Propuesta_Fecha_Emision, D.Propuesta_Vigencia_Hasta,
           D.Propuesta_Fecha_Desde, D.Propuesta_Fecha_Hasta, D.Propuesta_Subtotal, D.Propuesta_Descuento,
           D.Propuesta_Importe_Total, E.Estado_Codigo, D.Agente_Legajo
    FROM Dedup D
    LEFT JOIN TP_APROBADO.Estado E ON E.Estado_Nombre = D.Propuesta_Estado
    WHERE D.rn = 1;
END
GO



CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Venta
AS
BEGIN
    WITH Dedup AS (
        SELECT Venta_Nro_Venta, Venta_Fecha_Venta, Venta_Canal_Venta, Venta_Medio_Pago,
               Venta_Subtotal, Venta_Descuento, Venta_Importe_Total, Agente_Legajo,
               Cliente_Dni, Cliente_Mail, Propuesta_Nro_Propuesta, Encuesta_Codigo_Encuesta,
               ROW_NUMBER() OVER (PARTITION BY Venta_Nro_Venta
                                  ORDER BY CASE WHEN Venta_Fecha_Venta IS NULL THEN 1 ELSE 0 END) AS rn
        FROM gd_esquema.Maestra
        WHERE Venta_Nro_Venta IS NOT NULL
    )
    INSERT INTO TP_APROBADO.Venta (
        Venta_Nro_Venta, Venta_Fecha_Venta, Venta_Canal_Venta, Venta_Medio_Pago, Venta_Subtotal,
        Venta_Descuento, Venta_Importe_Total, Venta_Agente, Venta_Cliente_Dni, Venta_Cliente_Mail,
        Venta_Propuesta, Venta_Encuesta)
    SELECT D.Venta_Nro_Venta, D.Venta_Fecha_Venta, CV.Canal_Venta_Codigo, MP.Medio_Pago_Codigo, D.Venta_Subtotal,
           D.Venta_Descuento, D.Venta_Importe_Total, D.Agente_Legajo, D.Cliente_Dni, D.Cliente_Mail,
           D.Propuesta_Nro_Propuesta, D.Encuesta_Codigo_Encuesta
    FROM Dedup D
    LEFT JOIN TP_APROBADO.Canal_Venta CV ON CV.Canal_Venta_Nombre = D.Venta_Canal_Venta
    LEFT JOIN TP_APROBADO.Medio_Pago  MP ON MP.Medio_Pago_Nombre  = D.Venta_Medio_Pago
    WHERE D.rn = 1;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Detalle_Propuesta_Vuelo
AS
BEGIN
    WITH Lineas AS (
        SELECT DISTINCT
            M.Propuesta_Nro_Propuesta, M.Detalle_Propuesta_Vuelo_Cant_Pasajes,
            M.Detalle_Propuesta_Vuelo_Precio, M.Detalle_Propuesta_Vuelo_Subtotal, V.Vuelo_Codigo
        FROM gd_esquema.Maestra M
        JOIN TP_APROBADO.Vuelo V
            ON ISNULL(V.Vuelo_Aerolinea_Codigo,  N'@N@')       = ISNULL(M.Aerolinea_Codigo,          N'@N@')
           AND ISNULL(V.Vuelo_Aeropuerto_Salida, N'@N@')       = ISNULL(M.Aeropuerto_Salida_Codigo,  N'@N@')
           AND ISNULL(V.Vuelo_Aeropuerto_Llegada,N'@N@')       = ISNULL(M.Aeropuerto_Llegada_Codigo, N'@N@')
           AND ISNULL(V.Vuelo_Fecha_Salida,  '19000101')       = ISNULL(M.Vuelo_Fecha_Salida,  '19000101')
           AND ISNULL(V.Vuelo_Horario_Salida,   N'@N@')        = ISNULL(M.Vuelo_Horario_Salida,     N'@N@')
           AND ISNULL(V.Vuelo_Fecha_Llegada, '19000101')       = ISNULL(M.Vuelo_Fecha_Llegada, '19000101')
           AND ISNULL(V.Vuelo_Horario_Llegada,  N'@N@')        = ISNULL(M.Vuelo_Horario_Llegada,    N'@N@')
           AND ISNULL(V.Vuelo_Duracion, -1)                    = ISNULL(M.Vuelo_Duracion, -1)
           AND ISNULL(V.Vuelo_Precio, -1)                      = ISNULL(M.Vuelo_Precio, -1)
           AND ISNULL(CAST(V.Vuelo_Incluye_Carry  AS int), -1) = ISNULL(CAST(M.Vuelo_Incluye_Carry  AS int), -1)
           AND ISNULL(CAST(V.Vuelo_Incluye_Valija AS int), -1) = ISNULL(CAST(M.Vuelo_Incluye_Valija AS int), -1)
        WHERE M.Propuesta_Nro_Propuesta IS NOT NULL
          AND M.Aeropuerto_Salida_Codigo IS NOT NULL
          AND (M.Detalle_Propuesta_Vuelo_Cant_Pasajes IS NOT NULL
            OR M.Detalle_Propuesta_Vuelo_Precio        IS NOT NULL
            OR M.Detalle_Propuesta_Vuelo_Subtotal      IS NOT NULL)
    )
    INSERT INTO TP_APROBADO.Detalle_Propuesta_Vuelo (
        Detalle_Propuesta_Vuelo_Cod, Detalle_Propuesta_Nro_Propuesta, Detalle_Propuesta_Vuelo_Cant_Pasajes,
        Detalle_Propuesta_Vuelo_Precio, Detalle_Propuesta_Vuelo_Subtotal, Detalle_Propuesta_Codigo_Vuelo)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Propuesta_Nro_Propuesta,
           Detalle_Propuesta_Vuelo_Cant_Pasajes, Detalle_Propuesta_Vuelo_Precio,
           Detalle_Propuesta_Vuelo_Subtotal, Vuelo_Codigo
    FROM Lineas;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Detalle_Propuesta_Hospedaje
AS
BEGIN
    WITH Lineas AS (
        SELECT DISTINCT
            M.Propuesta_Nro_Propuesta, M.Detalle_Propuesta_Hospedaje_Fecha_Desde,
            M.Detalle_Propuesta_Hospedaje_Fecha_Hasta, M.Detalle_Propuesta_Hospedaje_Cant,
            M.Detalle_Propuesta_Hospedaje_Precio, M.Detalle_Propuesta_Hospedaje_Subtotal, HAB.Habitacion_Codigo
        FROM gd_esquema.Maestra M
        JOIN TP_APROBADO.Hospedaje H
            ON ISNULL(H.Hospedaje_Nombre, N'@N@')    = ISNULL(M.Hospedaje_Nombre, N'@N@')
           AND ISNULL(H.Hospedaje_Direccion, N'@N@') = ISNULL(M.Hospedaje_Direccion, N'@N@')
           AND ISNULL(CAST(H.Hospedaje_Incluye_Desayuno AS int), -1) = ISNULL(CAST(M.Hospedaje_Incluye_Desayuno AS int), -1)
           AND ISNULL(H.Hospedaje_Check_In, N'@N@')  = ISNULL(M.Hospedaje_Check_In, N'@N@')
           AND ISNULL(H.Hospedaje_Check_Out, N'@N@') = ISNULL(M.Hospedaje_Check_Out, N'@N@')
        JOIN TP_APROBADO.Habitacion HAB
            ON HAB.Habitacion_Hospedaje = H.Hospedaje_Codigo
           AND ISNULL(HAB.Habitacion_Nombre, N'@N@') = ISNULL(M.Habitacion_Nombre, N'@N@')
           AND ISNULL(HAB.Habitacion_Precio_Noche, -1) = ISNULL(M.Habitacion_Precio_Noche, -1)
           AND ISNULL(CAST(HAB.Habitacion_Descripcion AS nvarchar(max)), N'@N@')
             = ISNULL(CAST(M.Habitacion_Descripcion AS nvarchar(max)), N'@N@')
        WHERE M.Propuesta_Nro_Propuesta IS NOT NULL
          AND M.Habitacion_Nombre IS NOT NULL AND M.Hospedaje_Nombre IS NOT NULL
          AND (M.Detalle_Propuesta_Hospedaje_Cant        IS NOT NULL
            OR M.Detalle_Propuesta_Hospedaje_Fecha_Desde IS NOT NULL
            OR M.Detalle_Propuesta_Hospedaje_Subtotal    IS NOT NULL)
    )
    INSERT INTO TP_APROBADO.Detalle_Propuesta_Hospedaje (
        Detalle_Propuesta_Hospedaje_Codigo, Propuesta_Nro_Propuesta,
        Detalle_Propuesta_Hospedaje_Habitacion_Codigo, Detalle_Propuesta_Hospedaje_Fecha_Desde,
        Detalle_Propuesta_Hospedaje_Fecha_Hasta, Detalle_Propuesta_Hospedaje_Cant,
        Detalle_Propuesta_Hospedaje_Precio, Detalle_Propuesta_Hospedaje_Subtotal)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Propuesta_Nro_Propuesta, Habitacion_Codigo,
           Detalle_Propuesta_Hospedaje_Fecha_Desde, Detalle_Propuesta_Hospedaje_Fecha_Hasta,
           Detalle_Propuesta_Hospedaje_Cant, Detalle_Propuesta_Hospedaje_Precio, Detalle_Propuesta_Hospedaje_Subtotal
    FROM Lineas;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Detalle_Venta_Vuelo
AS
BEGIN
    WITH Lineas AS (
        SELECT DISTINCT
            M.Venta_Nro_Venta, M.Detalle_Venta_Vuelo_Cantidad_Pasajes,
            M.Detalle_Venta_Vuelo_Precio_Unitario, M.Detalle_Venta_Vuelo_Subtotal,
            M.Detalle_Venta_Vuelo_Cod_Reserva, V.Vuelo_Codigo
        FROM gd_esquema.Maestra M
        JOIN TP_APROBADO.Vuelo V
            ON ISNULL(V.Vuelo_Aerolinea_Codigo,  N'@N@')       = ISNULL(M.Aerolinea_Codigo,          N'@N@')
           AND ISNULL(V.Vuelo_Aeropuerto_Salida, N'@N@')       = ISNULL(M.Aeropuerto_Salida_Codigo,  N'@N@')
           AND ISNULL(V.Vuelo_Aeropuerto_Llegada,N'@N@')       = ISNULL(M.Aeropuerto_Llegada_Codigo, N'@N@')
           AND ISNULL(V.Vuelo_Fecha_Salida,  '19000101')       = ISNULL(M.Vuelo_Fecha_Salida,  '19000101')
           AND ISNULL(V.Vuelo_Horario_Salida,   N'@N@')        = ISNULL(M.Vuelo_Horario_Salida,     N'@N@')
           AND ISNULL(V.Vuelo_Fecha_Llegada, '19000101')       = ISNULL(M.Vuelo_Fecha_Llegada, '19000101')
           AND ISNULL(V.Vuelo_Horario_Llegada,  N'@N@')        = ISNULL(M.Vuelo_Horario_Llegada,    N'@N@')
           AND ISNULL(V.Vuelo_Duracion, -1)                    = ISNULL(M.Vuelo_Duracion, -1)
           AND ISNULL(V.Vuelo_Precio, -1)                      = ISNULL(M.Vuelo_Precio, -1)
           AND ISNULL(CAST(V.Vuelo_Incluye_Carry  AS int), -1) = ISNULL(CAST(M.Vuelo_Incluye_Carry  AS int), -1)
           AND ISNULL(CAST(V.Vuelo_Incluye_Valija AS int), -1) = ISNULL(CAST(M.Vuelo_Incluye_Valija AS int), -1)
        WHERE M.Venta_Nro_Venta IS NOT NULL
          AND M.Aeropuerto_Salida_Codigo IS NOT NULL
          AND (M.Detalle_Venta_Vuelo_Cantidad_Pasajes IS NOT NULL
            OR M.Detalle_Venta_Vuelo_Cod_Reserva       IS NOT NULL
            OR M.Detalle_Venta_Vuelo_Precio_Unitario   IS NOT NULL)
    )
    INSERT INTO TP_APROBADO.Detalle_Venta_Vuelo (
        Detalle_Venta_Vuelo_Cod, Detalle_Venta_Vuelo_Cantidad_Pasajes, Detalle_Venta_Vuelo_Precio_Unitario,
        Detalle_Venta_Vuelo_Subtotal, Detalle_Venta_Vuelo_Cod_Reserva, Detalle_Venta_Nro_Venta, Detalle_Venta_Vuelo_Codigo)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Detalle_Venta_Vuelo_Cantidad_Pasajes,
           Detalle_Venta_Vuelo_Precio_Unitario, Detalle_Venta_Vuelo_Subtotal,
           Detalle_Venta_Vuelo_Cod_Reserva, Venta_Nro_Venta, Vuelo_Codigo
    FROM Lineas;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Detalle_Venta_Hospedaje
AS
BEGIN
    WITH Lineas AS (
        SELECT DISTINCT
            M.Venta_Nro_Venta, M.Detalle_Venta_Hospedaje_Fecha_Desde, M.Detalle_Venta_Hospedaje_Fecha_Hasta,
            M.Detalle_Venta_Hospedaje_Cantidad, M.Detalle_Venta_Hospedaje_Precio_Unitario,
            M.Detalle_Venta_Hospedaje_Subtotal, M.Detalle_Venta_Hospedaje_Cod_Reserva, HAB.Habitacion_Codigo
        FROM gd_esquema.Maestra M
        JOIN TP_APROBADO.Hospedaje H
            ON ISNULL(H.Hospedaje_Nombre, N'@N@')    = ISNULL(M.Hospedaje_Nombre, N'@N@')
           AND ISNULL(H.Hospedaje_Direccion, N'@N@') = ISNULL(M.Hospedaje_Direccion, N'@N@')
           AND ISNULL(CAST(H.Hospedaje_Incluye_Desayuno AS int), -1) = ISNULL(CAST(M.Hospedaje_Incluye_Desayuno AS int), -1)
           AND ISNULL(H.Hospedaje_Check_In, N'@N@')  = ISNULL(M.Hospedaje_Check_In, N'@N@')
           AND ISNULL(H.Hospedaje_Check_Out, N'@N@') = ISNULL(M.Hospedaje_Check_Out, N'@N@')
        JOIN TP_APROBADO.Habitacion HAB
            ON HAB.Habitacion_Hospedaje = H.Hospedaje_Codigo
           AND ISNULL(HAB.Habitacion_Nombre, N'@N@') = ISNULL(M.Habitacion_Nombre, N'@N@')
           AND ISNULL(HAB.Habitacion_Precio_Noche, -1) = ISNULL(M.Habitacion_Precio_Noche, -1)
           AND ISNULL(CAST(HAB.Habitacion_Descripcion AS nvarchar(max)), N'@N@')
             = ISNULL(CAST(M.Habitacion_Descripcion AS nvarchar(max)), N'@N@')
        WHERE M.Venta_Nro_Venta IS NOT NULL
          AND M.Habitacion_Nombre IS NOT NULL AND M.Hospedaje_Nombre IS NOT NULL
          AND (M.Detalle_Venta_Hospedaje_Cantidad   IS NOT NULL
            OR M.Detalle_Venta_Hospedaje_Cod_Reserva IS NOT NULL
            OR M.Detalle_Venta_Hospedaje_Fecha_Desde IS NOT NULL)
    )
    INSERT INTO TP_APROBADO.Detalle_Venta_Hospedaje (
        Detalle_Venta_Hospedaje_Cod, Detalle_Venta_Hospedaje_Fecha_Desde, Detalle_Venta_Hospedaje_Fecha_Hasta,
        Detalle_Venta_Hospedaje_Cantidad, Detalle_Venta_Hospedaje_Precio_Unitario, Detalle_Venta_Hospedaje_Subtotal,
        Detalle_Venta_Hospedaje_Cod_Reserva, Habitacion_Codigo, Detalle_Venta_Nro_Venta)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Detalle_Venta_Hospedaje_Fecha_Desde,
           Detalle_Venta_Hospedaje_Fecha_Hasta, Detalle_Venta_Hospedaje_Cantidad,
           Detalle_Venta_Hospedaje_Precio_Unitario, Detalle_Venta_Hospedaje_Subtotal,
           Detalle_Venta_Hospedaje_Cod_Reserva, Habitacion_Codigo, Venta_Nro_Venta
    FROM Lineas;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Detalle_Venta_Excursion
AS
BEGIN
    WITH Lineas AS (
        SELECT DISTINCT
            M.Venta_Nro_Venta, M.Detalle_Venta_Excursion_Fecha_Reserva, M.Detalle_Venta_Excursion_Cant,
            M.Detalle_Venta_Excursion_Precio_Unitario, M.Detalle_Venta_Excursion_Subtotal,
            M.Detalle_Venta_Excursion_Cod_Reserva, E.Excursion_Codigo
        FROM gd_esquema.Maestra M
        CROSS APPLY (
            SELECT TOP 1 X.Excursion_Codigo
            FROM TP_APROBADO.Excursion X
            WHERE ISNULL(X.Excursion_Nombre, N'@N@')   = ISNULL(M.Excursion_Nombre, N'@N@')
              AND ISNULL(X.Excursion_Horario, N'@N@')  = ISNULL(M.Excursion_Horario, N'@N@')
              AND ISNULL(X.Excursion_Duracion, -1)     = ISNULL(M.Excursion_Duracion, -1)
              AND ISNULL(X.Excursion_Precio, -1)       = ISNULL(M.Excursion_Precio, -1)
              AND ISNULL(CAST(X.Excursion_Descripcion AS nvarchar(max)), N'@N@')
                = ISNULL(CAST(M.Excursion_Descripcion AS nvarchar(max)), N'@N@')
            ORDER BY X.Excursion_Codigo
        ) E
        WHERE M.Venta_Nro_Venta IS NOT NULL
          AND M.Excursion_Nombre IS NOT NULL
          AND (M.Detalle_Venta_Excursion_Cant          IS NOT NULL
            OR M.Detalle_Venta_Excursion_Cod_Reserva   IS NOT NULL
            OR M.Detalle_Venta_Excursion_Fecha_Reserva IS NOT NULL)
    )
    INSERT INTO TP_APROBADO.Detalle_Venta_Excursion (
        Detalle_Venta_Excursion_Cod, Venta_Nro_Venta, Excursion_Codigo,
        Detalle_Venta_Excursion_Fecha_Reserva, Detalle_Venta_Excursion_Cant,
        Detalle_Venta_Excursion_Precio_Unitario, Detalle_Venta_Excursion_Subtotal, Detalle_Venta_Excursion_Cod_Reserva)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Venta_Nro_Venta, Excursion_Codigo,
           Detalle_Venta_Excursion_Fecha_Reserva, Detalle_Venta_Excursion_Cant,
           Detalle_Venta_Excursion_Precio_Unitario, Detalle_Venta_Excursion_Subtotal, Detalle_Venta_Excursion_Cod_Reserva
    FROM Lineas;
END
GO


CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Limpiar
AS
BEGIN
    DELETE FROM TP_APROBADO.Detalle_Venta_Vuelo;
    DELETE FROM TP_APROBADO.Detalle_Venta_Hospedaje;
    DELETE FROM TP_APROBADO.Detalle_Venta_Excursion;
    DELETE FROM TP_APROBADO.Detalle_Propuesta_Vuelo;
    DELETE FROM TP_APROBADO.Detalle_Propuesta_Hospedaje;
    DELETE FROM TP_APROBADO.Detalle_Solicitud;
    DELETE FROM TP_APROBADO.Detalle_Encuesta;
    DELETE FROM TP_APROBADO.Venta;
    DELETE FROM TP_APROBADO.Propuesta;
    DELETE FROM TP_APROBADO.Solicitud;
    DELETE FROM TP_APROBADO.Vuelo;
    DELETE FROM TP_APROBADO.Habitacion;
    DELETE FROM TP_APROBADO.Hospedaje;
    DELETE FROM TP_APROBADO.Agente;
    DELETE FROM TP_APROBADO.Excursion;
    DELETE FROM TP_APROBADO.Encuesta;
    DELETE FROM TP_APROBADO.Cliente;
    DELETE FROM TP_APROBADO.Aeropuerto;
    DELETE FROM TP_APROBADO.Aerolinea;
    DELETE FROM TP_APROBADO.Agencia;
    DELETE FROM TP_APROBADO.Ciudad;
    DELETE FROM TP_APROBADO.Proveedor;
    DELETE FROM TP_APROBADO.Pais;
    DELETE FROM TP_APROBADO.Localidad;
    DELETE FROM TP_APROBADO.Provincia;
    DELETE FROM TP_APROBADO.Estado;
    DELETE FROM TP_APROBADO.Medio_Pago;
    DELETE FROM TP_APROBADO.Canal_Venta;
    DELETE FROM TP_APROBADO.Aspecto;
    DELETE FROM TP_APROBADO.Alianza;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Nivel_1
AS
BEGIN
    EXEC TP_APROBADO.Migrar_Alianza;
    EXEC TP_APROBADO.Migrar_Aspecto;
    EXEC TP_APROBADO.Migrar_Canal_Venta;
    EXEC TP_APROBADO.Migrar_Medio_Pago;
    EXEC TP_APROBADO.Migrar_Estado;
    EXEC TP_APROBADO.Migrar_Provincia;
    EXEC TP_APROBADO.Migrar_Localidad;
    EXEC TP_APROBADO.Migrar_Pais;
    EXEC TP_APROBADO.Migrar_Proveedor;
    EXEC TP_APROBADO.Migrar_Ciudad;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Nivel_2
AS
BEGIN
    EXEC TP_APROBADO.Migrar_Aerolinea;
    EXEC TP_APROBADO.Migrar_Aeropuerto;
    EXEC TP_APROBADO.Migrar_Agencia;
    EXEC TP_APROBADO.Migrar_Cliente;
    EXEC TP_APROBADO.Migrar_Encuesta;
    EXEC TP_APROBADO.Migrar_Excursion;
    EXEC TP_APROBADO.Migrar_Hospedaje;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Nivel_3
AS
BEGIN
    EXEC TP_APROBADO.Migrar_Agente;
    EXEC TP_APROBADO.Migrar_Habitacion;
    EXEC TP_APROBADO.Migrar_Vuelo;
    EXEC TP_APROBADO.Migrar_Detalle_Encuesta;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Nivel_4
AS
BEGIN
    EXEC TP_APROBADO.Migrar_Solicitud;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Nivel_5
AS
BEGIN
    EXEC TP_APROBADO.Migrar_Detalle_Solicitud;
    EXEC TP_APROBADO.Migrar_Propuesta;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Nivel_6
AS
BEGIN
    EXEC TP_APROBADO.Migrar_Venta;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Nivel_7
AS
BEGIN
    EXEC TP_APROBADO.Migrar_Detalle_Propuesta_Vuelo;
    EXEC TP_APROBADO.Migrar_Detalle_Propuesta_Hospedaje;
    EXEC TP_APROBADO.Migrar_Detalle_Venta_Vuelo;
    EXEC TP_APROBADO.Migrar_Detalle_Venta_Hospedaje;
    EXEC TP_APROBADO.Migrar_Detalle_Venta_Excursion;
END
GO

EXEC TP_APROBADO.Migrar_Limpiar;
EXEC TP_APROBADO.Migrar_Nivel_1;
EXEC TP_APROBADO.Migrar_Nivel_2;
EXEC TP_APROBADO.Migrar_Nivel_3;
EXEC TP_APROBADO.Migrar_Nivel_4;
EXEC TP_APROBADO.Migrar_Nivel_5;
EXEC TP_APROBADO.Migrar_Nivel_6;
EXEC TP_APROBADO.Migrar_Nivel_7;
GO

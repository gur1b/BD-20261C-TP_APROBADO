/*NIVEL 1:*/

CREATE PROCEDURE TP_APROBADO.Migrar_Alianza
AS
BEGIN
    INSERT INTO TP_APROBADO.Alianza (
        Alianza_Codigo,
        Alianza_Nombre
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY Aerolinea_Alianza) AS Alianza_Codigo,
        Aerolinea_Alianza
    FROM (
        SELECT DISTINCT Aerolinea_Alianza
        FROM gd_esquema.Maestra
        WHERE Aerolinea_Alianza IS NOT NULL
    ) M;
END
GO

CREATE PROCEDURE TP_APROBADO.Migrar_Aspecto
AS
BEGIN
    INSERT INTO TP_APROBADO.Aspecto (
        Aspecto_Codigo,
        Aspecto_Aspecto
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY Aspecto_Aspecto) AS Aspecto_Codigo,
        Aspecto_Aspecto
    FROM (
        SELECT DISTINCT Aspecto_Aspecto
        FROM gd_esquema.Maestra
        WHERE Aspecto_Aspecto IS NOT NULL
    ) M;
END
GO

CREATE PROCEDURE TP_APROBADO.Migrar_Canal_Venta
AS
BEGIN
    INSERT INTO TP_APROBADO.Canal_Venta (
        Canal_Venta_Codigo,
        Canal_Venta_Nombre
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY Venta_Canal_Venta) AS Canal_Venta_Codigo,
        Venta_Canal_Venta
    FROM (
        SELECT DISTINCT Venta_Canal_Venta
        FROM gd_esquema.Maestra
        WHERE Venta_Canal_Venta IS NOT NULL
    ) M;
END
GO

CREATE PROCEDURE TP_APROBADO.Migrar_Medio_Pago
AS
BEGIN
    INSERT INTO TP_APROBADO.Medio_Pago (
        Medio_Pago_Codigo,
        Medio_Pago_Nombre
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY Venta_Medio_Pago) AS Medio_Pago_Codigo,
        Venta_Medio_Pago
    FROM (
        SELECT DISTINCT Venta_Medio_Pago
        FROM gd_esquema.Maestra
        WHERE Venta_Medio_Pago IS NOT NULL
    ) M;
END
GO

CREATE PROCEDURE TP_APROBADO.Migrar_Proveedor
AS
BEGIN
    INSERT INTO TP_APROBADO.Proveedor (
        Proveedor_Codigo,
        Proveedor_Nombre,
        Proveedor_Mail,
        Proveedor_Telefono
    )
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY Proveedor_Nombre, Proveedor_Mail, Proveedor_Telefono
        ) AS Proveedor_Codigo,
        Proveedor_Nombre,
        Proveedor_Mail,
        Proveedor_Telefono
    FROM (
        SELECT DISTINCT
            Proveedor_Nombre,
            Proveedor_Mail,
            Proveedor_Telefono
        FROM gd_esquema.Maestra
        WHERE Proveedor_Nombre IS NOT NULL
    ) M;
END
GO

CREATE PROCEDURE TP_APROBADO.Migrar_Estado
AS
BEGIN
    INSERT INTO TP_APROBADO.Estado (
        Estado_Codigo,
        Estado_Nombre,
        Estado_Descripcion
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY Propuesta_Estado) AS Estado_Codigo,
        Propuesta_Estado,
        NULL
    FROM (
        SELECT DISTINCT Propuesta_Estado
        FROM gd_esquema.Maestra
        WHERE Propuesta_Estado IS NOT NULL
    ) M;
END
GO

CREATE PROCEDURE TP_APROBADO.Migrar_Habitacion
AS
BEGIN
    INSERT INTO TP_APROBADO.Habitacion (
        Habitacion_Codigo,
        Habitacion_Nombre,
        Habitacion_Descripcion,
        Habitacion_Precio_Noche,
        Habitacion_Precio,
        Habitacion_Cantidad
    )
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY Habitacion_Nombre, Habitacion_Descripcion, Habitacion_Precio_Noche
        ) AS Habitacion_Codigo,
        Habitacion_Nombre,
        Habitacion_Descripcion,
        Habitacion_Precio_Noche,
        NULL,
        NULL
    FROM (
        SELECT DISTINCT
            Habitacion_Nombre,
            Habitacion_Descripcion,
            Habitacion_Precio_Noche
        FROM gd_esquema.Maestra
        WHERE Habitacion_Nombre IS NOT NULL
    ) M;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Provincia
AS
BEGIN
    INSERT INTO TP_APROBADO.Provincia (
        Provincia_Codigo,
        Provincia_Nombre
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY Provincia_Nombre) AS Provincia_Codigo,
        Provincia_Nombre
    FROM (
        SELECT DISTINCT Agencia_Provincia AS Provincia_Nombre
        FROM gd_esquema.Maestra
        WHERE Agencia_Provincia IS NOT NULL

        UNION

        SELECT DISTINCT Agente_Provincia
        FROM gd_esquema.Maestra
        WHERE Agente_Provincia IS NOT NULL

        UNION

        SELECT DISTINCT Cliente_Provincia
        FROM gd_esquema.Maestra
        WHERE Cliente_Provincia IS NOT NULL
    ) M;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Localidad
AS
BEGIN
    INSERT INTO TP_APROBADO.Localidad (
        Localidad_Codigo,
        Localidad_Nombre
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY Localidad_Nombre) AS Localidad_Codigo,
        Localidad_Nombre
    FROM (
        SELECT DISTINCT Agencia_Localidad AS Localidad_Nombre
        FROM gd_esquema.Maestra
        WHERE Agencia_Localidad IS NOT NULL

        UNION

        SELECT DISTINCT Agente_Localidad
        FROM gd_esquema.Maestra
        WHERE Agente_Localidad IS NOT NULL

        UNION

        SELECT DISTINCT Cliente_Localidad
        FROM gd_esquema.Maestra
        WHERE Cliente_Localidad IS NOT NULL
    ) M;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Pais
AS
BEGIN
    INSERT INTO TP_APROBADO.Pais (
        Pais_Codigo,
        Pais_Nombre,
        Pais_Capital
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY Pais_Nombre) AS Pais_Codigo,
        Pais_Nombre,
        NULL AS Pais_Capital
    FROM (
        SELECT DISTINCT Aeropuerto_Salida_Pais AS Pais_Nombre
        FROM gd_esquema.Maestra
        WHERE Aeropuerto_Salida_Pais IS NOT NULL

        UNION

        SELECT DISTINCT Aeropuerto_Llegada_Pais
        FROM gd_esquema.Maestra
        WHERE Aeropuerto_Llegada_Pais IS NOT NULL

        UNION

        SELECT DISTINCT Aerolinea_Pais
        FROM gd_esquema.Maestra
        WHERE Aerolinea_Pais IS NOT NULL

        UNION

        SELECT DISTINCT Hospedaje_Pais
        FROM gd_esquema.Maestra
        WHERE Hospedaje_Pais IS NOT NULL
    ) M;
END
GO

/*NIVEL 2:*/

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Aerolinea
AS
BEGIN
    INSERT INTO TP_APROBADO.Aerolinea (
        Aerolinea_Codigo,
        Aerolinea_Nombre,
        Aerolinea_Pais,
        Aerolinea_Alianza
    )
    SELECT DISTINCT
        M.Aerolinea_Codigo,
        M.Aerolinea_Nombre,
        M.Aerolinea_Pais,
        A.Alianza_Codigo
    FROM gd_esquema.Maestra M
    LEFT JOIN TP_APROBADO.Alianza A
        ON A.Alianza_Nombre = M.Aerolinea_Alianza
    WHERE M.Aerolinea_Codigo IS NOT NULL;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Ciudad
AS
BEGIN
    INSERT INTO TP_APROBADO.Ciudad (
        Ciudad_Codigo,
        Ciudad_Nombre,
        Ciudad_es_capital
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY Ciudad_Nombre) AS Ciudad_Codigo,
        Ciudad_Nombre,
        NULL AS Ciudad_es_capital
    FROM (
        SELECT DISTINCT Aeropuerto_Salida_Ciudad AS Ciudad_Nombre
        FROM gd_esquema.Maestra
        WHERE Aeropuerto_Salida_Ciudad IS NOT NULL

        UNION

        SELECT DISTINCT Aeropuerto_Llegada_Ciudad
        FROM gd_esquema.Maestra
        WHERE Aeropuerto_Llegada_Ciudad IS NOT NULL

        UNION

        SELECT DISTINCT Hospedaje_Ciudad
        FROM gd_esquema.Maestra
        WHERE Hospedaje_Ciudad IS NOT NULL
    ) C;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Cliente
AS
BEGIN
    INSERT INTO TP_APROBADO.Cliente (
        Cliente_Dni,
        Cliente_Mail,
        Cliente_Nombre,
        Cliente_Apellido,
        Cliente_Tel,
        Cliente_Direccion,
        Cliente_Fecha_Nac,
        Cliente_Localidad,
        Cliente_Provincia
    )
    SELECT DISTINCT
        Cliente_Dni,
        Cliente_Mail,
        Cliente_Nombre,
        Cliente_Apellido,
        Cliente_Tel,
        Cliente_Direccion,
        Cliente_Fecha_Nac,
        Cliente_Localidad,
        Cliente_Provincia
    FROM gd_esquema.Maestra
    WHERE Cliente_Dni IS NOT NULL
      AND Cliente_Mail IS NOT NULL;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Encuesta
AS
BEGIN
    INSERT INTO TP_APROBADO.Encuesta (
        Encuesta_Codigo_Encuesta,
        Encuesta_Fecha_Encuesta,
        Encuesta_Comentarios
    )
    SELECT DISTINCT
        Encuesta_Codigo_Encuesta,
        Encuesta_Fecha_Encuesta,
        Encuesta_Comentarios
    FROM gd_esquema.Maestra
    WHERE Encuesta_Codigo_Encuesta IS NOT NULL;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Excursion
AS
BEGIN
    INSERT INTO TP_APROBADO.Excursion (
        Excursion_Codigo,
        Proveedor_Codigo,
        Excursion_Nombre,
        Excursion_Descripcion,
        Excursion_Horario,
        Excursion_Duracion,
        Excursion_Precio
    )
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY 
                M.Excursion_Nombre,
                M.Excursion_Descripcion,
                M.Excursion_Horario,
                M.Excursion_Duracion,
                M.Excursion_Precio
        ) AS Excursion_Codigo,
        P.Proveedor_Codigo,
        M.Excursion_Nombre,
        M.Excursion_Descripcion,
        TRY_CAST(M.Excursion_Horario AS int),
        M.Excursion_Duracion,
        M.Excursion_Precio
    FROM (
        SELECT DISTINCT
            Excursion_Nombre,
            Excursion_Descripcion,
            Excursion_Horario,
            Excursion_Duracion,
            Excursion_Precio,
            Proveedor_Nombre,
            Proveedor_Mail,
            Proveedor_Telefono
        FROM gd_esquema.Maestra
        WHERE Excursion_Nombre IS NOT NULL
    ) M
    LEFT JOIN TP_APROBADO.Proveedor P
        ON P.Proveedor_Nombre = M.Proveedor_Nombre
       AND ISNULL(P.Proveedor_Mail, '') = ISNULL(M.Proveedor_Mail, '')
       AND ISNULL(P.Proveedor_Telefono, '') = ISNULL(M.Proveedor_Telefono, '');
END
GO


CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Nivel_1
AS
BEGIN
    EXEC TP_APROBADO.Migrar_Alianza;
    EXEC TP_APROBADO.Migrar_Aspecto;
    EXEC TP_APROBADO.Migrar_Canal_Venta;
    EXEC TP_APROBADO.Migrar_Estado;
    EXEC TP_APROBADO.Migrar_Habitacion;
    EXEC TP_APROBADO.Migrar_Localidad;
    EXEC TP_APROBADO.Migrar_Medio_Pago;
    EXEC TP_APROBADO.Migrar_Pais;
    EXEC TP_APROBADO.Migrar_Proveedor;
    EXEC TP_APROBADO.Migrar_Provincia;
END
GO

CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Nivel_2
AS
BEGIN
    EXEC TP_APROBADO.Migrar_Aerolinea;
    EXEC TP_APROBADO.Migrar_Ciudad;
    EXEC TP_APROBADO.Migrar_Cliente;
    EXEC TP_APROBADO.Migrar_Encuesta;
    EXEC TP_APROBADO.Migrar_Excursion;
END
GO

EXEC TP_APROBADO.Migrar_Nivel_1;
EXEC TP_APROBADO.Migrar_Nivel_2;
GO

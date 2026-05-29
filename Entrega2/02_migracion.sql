/* ============================================================================
   TP GESTIÓN DE DATOS - MIGRACIÓN AL MODELO TRANSACCIONAL
   Esquema destino: TP_APROBADO
   Prerrequisito: ejecutar antes 01_creacion_schema_y_tablas.sql

   Versión adaptada al 01 actualizado, que ahora:
   - Referencia las lookups por FK (Canal_Venta, Medio_Pago, Estado, Ciudad,
     Pais, Provincia, Localidad) en vez de guardar texto.
   - Modela Habitacion -> Hospedaje (FK Habitacion_Hospedaje); Hospedaje ya no
     apunta a una habitación ni tiene Precio_Total / Cantidad_Habitaciones.

   ----------------------------------------------------------------------------
   CORRECCIONES CRÍTICAS (se mantienen de la versión anterior)
   ----------------------------------------------------------------------------
   1. Cliente / Aerolinea / Encuesta: dedup PK-safe (ROW_NUMBER/PARTITION BY)
      en vez de SELECT DISTINCT sobre todas las columnas -> evita violar la PK
      si una misma clave aparece con datos distintos.
   2. Excursion_Horario: se inserta como texto (antes un TRY_CAST a int lo anulaba).
   3. Dedup PK-safe también en Agencia, Agente, Solicitud, Propuesta, Venta.
   4. Todos los SP son CREATE OR ALTER + SP Migrar_Limpiar para re-ejecutar sin error.

   ----------------------------------------------------------------------------
   RESOLUCIÓN DE FK A LOOKUPS
   ----------------------------------------------------------------------------
   La maestra trae el texto (nombre de ciudad/país/provincia/localidad/canal/etc).
   Cada SP resuelve ese texto al código de la lookup con LEFT JOIN por nombre
   (LEFT para no perder filas si el texto es NULL). Las lookups se cargan con
   nombres distintos, así que el match es 1:1.

   RESOLUCIÓN DE FK A ENTIDADES DE CLAVE SUSTITUTA (Vuelo, Habitacion, Excursion)
   ----------------------------------------------------------------------------
   Los detalles reconstruyen la FK joineando la fila de maestra contra el padre
   por su conjunto natural completo de atributos, NULL-safe con ISNULL + centinela
   (texto N'@N@', fecha '19000101', numérico -1, bit casteado a int). Es 1:1 porque
   el padre se dedup por exactamente esos atributos.

   SUPUESTOS (ver PENDIENTES_2da_iteracion.md):
   - Hospedaje se identifica por (Nombre, Direccion, Incluye_Desayuno, Check_In,
     Check_Out); Ciudad/País se toman de una fila representante. Habitacion y los
     detalles enganchan al hospedaje por ese mismo conjunto.
   - Encuesta -> Venta en filas de venta y -> Solicitud en filas de solicitud.
   ============================================================================ */

USE GD1C2026;
GO

SET NOCOUNT ON;
GO


/* ============================================================================
   NIVEL 1 - SIN DEPENDENCIAS (lookups y entidades base con código sustituto)
   ============================================================================ */

-- Alianzas distintas; código sustituto.
CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Alianza
AS
BEGIN
    INSERT INTO TP_APROBADO.Alianza (Alianza_Codigo, Alianza_Nombre)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Aerolinea_Alianza
    FROM (SELECT DISTINCT Aerolinea_Alianza FROM gd_esquema.Maestra WHERE Aerolinea_Alianza IS NOT NULL) D;
END
GO

-- Aspectos evaluables distintos; código sustituto (smallint).
CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Aspecto
AS
BEGIN
    INSERT INTO TP_APROBADO.Aspecto (Aspecto_Codigo, Aspecto_Aspecto)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Aspecto_Aspecto
    FROM (SELECT DISTINCT Aspecto_Aspecto FROM gd_esquema.Maestra WHERE Aspecto_Aspecto IS NOT NULL) D;
END
GO

-- Canales de venta distintos; código sustituto (referenciado por Venta).
CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Canal_Venta
AS
BEGIN
    INSERT INTO TP_APROBADO.Canal_Venta (Canal_Venta_Codigo, Canal_Venta_Nombre)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Venta_Canal_Venta
    FROM (SELECT DISTINCT Venta_Canal_Venta FROM gd_esquema.Maestra WHERE Venta_Canal_Venta IS NOT NULL) D;
END
GO

-- Medios de pago distintos; código sustituto (referenciado por Venta).
CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Medio_Pago
AS
BEGIN
    INSERT INTO TP_APROBADO.Medio_Pago (Medio_Pago_Codigo, Medio_Pago_Nombre)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Venta_Medio_Pago
    FROM (SELECT DISTINCT Venta_Medio_Pago FROM gd_esquema.Maestra WHERE Venta_Medio_Pago IS NOT NULL) D;
END
GO

-- Estados de propuesta distintos; código sustituto (referenciado por Propuesta).
CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Estado
AS
BEGIN
    INSERT INTO TP_APROBADO.Estado (Estado_Codigo, Estado_Nombre, Estado_Descripcion)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Propuesta_Estado, NULL
    FROM (SELECT DISTINCT Propuesta_Estado FROM gd_esquema.Maestra WHERE Propuesta_Estado IS NOT NULL) D;
END
GO

-- Provincias distintas (union de los 3 orígenes); código sustituto.
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

-- Localidades distintas (union de los 3 orígenes); código sustituto.
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

-- Países distintos (union de los orígenes); código sustituto. Pais_Capital sin origen -> NULL.
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

-- Proveedores distintos; código sustituto.
CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Proveedor
AS
BEGIN
    INSERT INTO TP_APROBADO.Proveedor (Proveedor_Codigo, Proveedor_Nombre, Proveedor_Mail, Proveedor_Telefono)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), Proveedor_Nombre, Proveedor_Mail, Proveedor_Telefono
    FROM (SELECT DISTINCT Proveedor_Nombre, Proveedor_Mail, Proveedor_Telefono
          FROM gd_esquema.Maestra WHERE Proveedor_Nombre IS NOT NULL) D;
END
GO

-- Ciudades distintas; código sustituto. Ciudad_es_capital sin origen -> NULL.
-- Ciudad_Pais: la maestra no trae un país por ciudad de forma directa, pero sí trae el
-- par (ciudad, país) en aeropuertos y hospedaje. Se toma ese país y se resuelve a código;
-- si una ciudad aparece con más de un país (inconsistencia), se queda con uno (dedup PK-safe).
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


/* ============================================================================
   NIVEL 2 - DEPENDEN DE NIVEL 1
   ============================================================================ */

-- Aerolíneas: PK = Aerolinea_Codigo (dedup PK-safe). Pais y Alianza vienen como
-- texto en la maestra -> se resuelven a código.
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

-- Aeropuertos: PK = Aeropuerto_Codigo (union salida+llegada, dedup PK-safe).
-- Ciudad y País vienen como texto -> se resuelven a código.
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

-- Agencias: PK = Agencia_Nro_Agencia (dedup PK-safe). Provincia/Localidad -> código.
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

-- Clientes: PK = (Cliente_Dni, Cliente_Mail) (dedup PK-safe). Localidad/Provincia -> código.
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

-- Encuestas: PK = Encuesta_Codigo_Encuesta (dedup PK-safe).
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

-- Excursiones distintas; código sustituto. Horario como texto. Proveedor -> código.
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

-- Hospedajes: sin clave natural. Se identifica por (Nombre, Direccion, Incluye_Desayuno,
-- Check_In, Check_Out) con dedup PK-safe; Ciudad/País se toman de la fila representante y
-- se resuelven a código. Habitacion y los detalles enganchan por ese mismo conjunto.
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


/* ============================================================================
   NIVEL 3 - DEPENDEN DE NIVEL 2
   ============================================================================ */

-- Agentes: PK = Agente_Legajo (dedup PK-safe). Provincia/Localidad -> código.
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

-- Habitaciones por hospedaje; código sustituto. Dedup por (hospedaje + atributos de
-- habitación). El hospedaje se resuelve matcheando su conjunto identificatorio (NULL-safe).
-- Habitacion_Precio y Habitacion_Cantidad no tienen origen -> NULL.
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

-- Vuelos: sin clave natural. Clave = conjunto completo de atributos del vuelo.
-- Las FK (aeropuertos nvarchar, aerolínea nvarchar) ya están como código en la maestra.
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

-- Detalle de encuesta: PK = (Encuesta, Aspecto). Aspecto -> código. Dedup por la PK.
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


/* ============================================================================
   NIVEL 4 - SOLICITUD (depende de Agente, Cliente, Encuesta)
   ============================================================================ */

-- Solicitudes: PK = Solicitud_Nro_Solicitud (dedup PK-safe). Cliente_Dni/Mail quedan
-- como texto (FK compuesta a Cliente).
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


/* ============================================================================
   NIVEL 5 - DETALLE_SOLICITUD y PROPUESTA (Propuesta antes que Venta)
   ============================================================================ */

-- Detalle de solicitud (ciudades por solicitud); código sustituto.
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

-- Propuestas: PK = Propuesta_Nro_Propuesta (dedup PK-safe, representante con fecha de
-- emisión no nula). Estado -> código.
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


/* ============================================================================
   NIVEL 6 - VENTA (depende de Propuesta)
   ============================================================================ */

-- Ventas: PK = Venta_Nro_Venta (dedup PK-safe). Canal/Medio -> código.
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


/* ============================================================================
   NIVEL 7 - DETALLES DE PROPUESTA Y VENTA
   FK a Vuelo: join por la identidad completa del vuelo (NULL-safe).
   FK a Habitacion: join al Hospedaje (por su identidad) y luego a la Habitacion de
   ese hospedaje (por sus atributos), para no confundir habitaciones de hoteles distintos.
   ============================================================================ */

-- Detalle de vuelos de PROPUESTA.
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

-- Detalle de hospedajes de PROPUESTA. Engancha la habitación del hospedaje correcto.
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

-- Detalle de vuelos de VENTA.
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

-- Detalle de hospedajes de VENTA. Engancha la habitación del hospedaje correcto.
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

-- Detalle de excursiones de VENTA. La excursión se identifica por sus atributos (APPLY TOP 1
-- porque la excursión se dedup junto con el proveedor).
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


/* ============================================================================
   LIMPIEZA Y ORQUESTACIÓN
   ============================================================================ */

-- Borra hijo -> padre (respeta las nuevas FKs: Habitacion antes que Hospedaje, etc.).
-- En base limpia no afecta nada; permite re-ejecutar la migración.
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

-- Nivel 1: lookups y bases sin dependencias.
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

-- Nivel 2: dependen de Nivel 1.
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

-- Nivel 3: dependen de Nivel 2 (Habitacion DESPUÉS de Hospedaje).
CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Nivel_3
AS
BEGIN
    EXEC TP_APROBADO.Migrar_Agente;
    EXEC TP_APROBADO.Migrar_Habitacion;
    EXEC TP_APROBADO.Migrar_Vuelo;
    EXEC TP_APROBADO.Migrar_Detalle_Encuesta;
END
GO

-- Nivel 4: Solicitud.
CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Nivel_4
AS
BEGIN
    EXEC TP_APROBADO.Migrar_Solicitud;
END
GO

-- Nivel 5: Detalle_Solicitud y Propuesta.
CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Nivel_5
AS
BEGIN
    EXEC TP_APROBADO.Migrar_Detalle_Solicitud;
    EXEC TP_APROBADO.Migrar_Propuesta;
END
GO

-- Nivel 6: Venta (depende de Propuesta).
CREATE OR ALTER PROCEDURE TP_APROBADO.Migrar_Nivel_6
AS
BEGIN
    EXEC TP_APROBADO.Migrar_Venta;
END
GO

-- Nivel 7: detalles de propuesta y venta.
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


/* ============================================================================
   EJECUCIÓN DE LA MIGRACIÓN
   ============================================================================ */
EXEC TP_APROBADO.Migrar_Limpiar;
EXEC TP_APROBADO.Migrar_Nivel_1;
EXEC TP_APROBADO.Migrar_Nivel_2;
EXEC TP_APROBADO.Migrar_Nivel_3;
EXEC TP_APROBADO.Migrar_Nivel_4;
EXEC TP_APROBADO.Migrar_Nivel_5;
EXEC TP_APROBADO.Migrar_Nivel_6;
EXEC TP_APROBADO.Migrar_Nivel_7;
GO

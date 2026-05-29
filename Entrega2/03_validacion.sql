/* ============================================================================
   TP GESTIÓN DE DATOS - VALIDACIÓN / RECONCILIACIÓN DE LA MIGRACIÓN
   Esquema: TP_APROBADO

   IMPORTANTE: este script se ejecuta DESPUÉS de correr 01 (creación) y 02
   (migración). Lee la maestra y las tablas ya migradas y las compara; no
   modifica ningún dato (solo SELECTs + tablas temporales).

   Por qué no compara "total maestra" vs "total migrado":
   la maestra está desnormalizada (una fila por línea de venta/propuesta/etc.),
   así que cada tabla destino tiene su propio "esperado" = cantidad de entidades
   DISTINTAS en la maestra, calculado con la MISMA lógica de dedup que usó la
   migración. Si Esperado = Migrado, esa tabla está OK.

   Contenido:
   - PARTE A: análisis de la maestra (cuántas filas y cómo se reparten por área).
   - PARTE B: tabla comparativa Esperado (maestra) vs Migrado (destino) por tabla.
   - PARTE C: chequeo de que los textos de la maestra resolvieron a su FK (deben dar 0).
   ============================================================================ */

USE GD1C2026;
GO

SET NOCOUNT ON;
GO


/* ============================================================================
   PARTE A - ANÁLISIS DE LA TABLA MAESTRA
   Total de filas y cuántas filas "alimentan" cada área (cabecera no nula).
   Las áreas se solapan: una misma fila puede tener venta + vuelo + cliente, etc.
   ============================================================================ */
SELECT 'Filas totales en la maestra' AS Metrica, COUNT(*) AS Cantidad FROM gd_esquema.Maestra
UNION ALL SELECT 'Filas con Agencia',   COUNT(*) FROM gd_esquema.Maestra WHERE Agencia_Nro_Agencia      IS NOT NULL
UNION ALL SELECT 'Filas con Agente',    COUNT(*) FROM gd_esquema.Maestra WHERE Agente_Legajo            IS NOT NULL
UNION ALL SELECT 'Filas con Cliente',   COUNT(*) FROM gd_esquema.Maestra WHERE Cliente_Dni              IS NOT NULL
UNION ALL SELECT 'Filas con Solicitud', COUNT(*) FROM gd_esquema.Maestra WHERE Solicitud_Nro_Solicitud  IS NOT NULL
UNION ALL SELECT 'Filas con Propuesta', COUNT(*) FROM gd_esquema.Maestra WHERE Propuesta_Nro_Propuesta  IS NOT NULL
UNION ALL SELECT 'Filas con Venta',     COUNT(*) FROM gd_esquema.Maestra WHERE Venta_Nro_Venta          IS NOT NULL
UNION ALL SELECT 'Filas con Encuesta',  COUNT(*) FROM gd_esquema.Maestra WHERE Encuesta_Codigo_Encuesta IS NOT NULL
UNION ALL SELECT 'Filas con Vuelo',     COUNT(*) FROM gd_esquema.Maestra WHERE Aeropuerto_Salida_Codigo IS NOT NULL
UNION ALL SELECT 'Filas con Hospedaje', COUNT(*) FROM gd_esquema.Maestra WHERE Hospedaje_Nombre         IS NOT NULL
UNION ALL SELECT 'Filas con Excursion', COUNT(*) FROM gd_esquema.Maestra WHERE Excursion_Nombre         IS NOT NULL
ORDER BY Cantidad DESC;


/* ============================================================================
   PARTE B - COMPARATIVA ESPERADO (maestra) vs MIGRADO (destino)
   ============================================================================ */
IF OBJECT_ID('tempdb..#Recon') IS NOT NULL DROP TABLE #Recon;
CREATE TABLE #Recon (Orden int, Tabla nvarchar(60), Esperado int, Migrado int);

-- NIVEL 1 ---------------------------------------------------------------------
INSERT #Recon SELECT 1, 'Alianza',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Aerolinea_Alianza FROM gd_esquema.Maestra WHERE Aerolinea_Alianza IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Alianza);

INSERT #Recon SELECT 2, 'Aspecto',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Aspecto_Aspecto FROM gd_esquema.Maestra WHERE Aspecto_Aspecto IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Aspecto);

INSERT #Recon SELECT 3, 'Canal_Venta',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Venta_Canal_Venta FROM gd_esquema.Maestra WHERE Venta_Canal_Venta IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Canal_Venta);

INSERT #Recon SELECT 4, 'Medio_Pago',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Venta_Medio_Pago FROM gd_esquema.Maestra WHERE Venta_Medio_Pago IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Medio_Pago);

INSERT #Recon SELECT 5, 'Estado',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Propuesta_Estado FROM gd_esquema.Maestra WHERE Propuesta_Estado IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Estado);

INSERT #Recon SELECT 6, 'Provincia',
    (SELECT COUNT(*) FROM (
        SELECT Agencia_Provincia AS n FROM gd_esquema.Maestra WHERE Agencia_Provincia IS NOT NULL
        UNION SELECT Agente_Provincia  FROM gd_esquema.Maestra WHERE Agente_Provincia  IS NOT NULL
        UNION SELECT Cliente_Provincia FROM gd_esquema.Maestra WHERE Cliente_Provincia IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Provincia);

INSERT #Recon SELECT 7, 'Localidad',
    (SELECT COUNT(*) FROM (
        SELECT Agencia_Localidad AS n FROM gd_esquema.Maestra WHERE Agencia_Localidad IS NOT NULL
        UNION SELECT Agente_Localidad  FROM gd_esquema.Maestra WHERE Agente_Localidad  IS NOT NULL
        UNION SELECT Cliente_Localidad FROM gd_esquema.Maestra WHERE Cliente_Localidad IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Localidad);

INSERT #Recon SELECT 8, 'Pais',
    (SELECT COUNT(*) FROM (
        SELECT Aeropuerto_Salida_Pais AS n FROM gd_esquema.Maestra WHERE Aeropuerto_Salida_Pais IS NOT NULL
        UNION SELECT Aeropuerto_Llegada_Pais FROM gd_esquema.Maestra WHERE Aeropuerto_Llegada_Pais IS NOT NULL
        UNION SELECT Aerolinea_Pais          FROM gd_esquema.Maestra WHERE Aerolinea_Pais          IS NOT NULL
        UNION SELECT Hospedaje_Pais          FROM gd_esquema.Maestra WHERE Hospedaje_Pais          IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Pais);

INSERT #Recon SELECT 9, 'Proveedor',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Proveedor_Nombre, Proveedor_Mail, Proveedor_Telefono
                           FROM gd_esquema.Maestra WHERE Proveedor_Nombre IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Proveedor);

-- Ciudad: la migración dedup por nombre de ciudad -> esperado = ciudades distintas.
INSERT #Recon SELECT 10, 'Ciudad',
    (SELECT COUNT(*) FROM (
        SELECT Aeropuerto_Salida_Ciudad AS n FROM gd_esquema.Maestra WHERE Aeropuerto_Salida_Ciudad IS NOT NULL
        UNION SELECT Aeropuerto_Llegada_Ciudad FROM gd_esquema.Maestra WHERE Aeropuerto_Llegada_Ciudad IS NOT NULL
        UNION SELECT Hospedaje_Ciudad          FROM gd_esquema.Maestra WHERE Hospedaje_Ciudad          IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Ciudad);

-- NIVEL 2 ---------------------------------------------------------------------
INSERT #Recon SELECT 11, 'Aerolinea',
    (SELECT COUNT(DISTINCT Aerolinea_Codigo) FROM gd_esquema.Maestra WHERE Aerolinea_Codigo IS NOT NULL),
    (SELECT COUNT(*) FROM TP_APROBADO.Aerolinea);

INSERT #Recon SELECT 12, 'Aeropuerto',
    (SELECT COUNT(*) FROM (
        SELECT Aeropuerto_Salida_Codigo AS c FROM gd_esquema.Maestra WHERE Aeropuerto_Salida_Codigo IS NOT NULL
        UNION SELECT Aeropuerto_Llegada_Codigo FROM gd_esquema.Maestra WHERE Aeropuerto_Llegada_Codigo IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Aeropuerto);

INSERT #Recon SELECT 13, 'Agencia',
    (SELECT COUNT(DISTINCT Agencia_Nro_Agencia) FROM gd_esquema.Maestra WHERE Agencia_Nro_Agencia IS NOT NULL),
    (SELECT COUNT(*) FROM TP_APROBADO.Agencia);

INSERT #Recon SELECT 14, 'Cliente',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Cliente_Dni, Cliente_Mail FROM gd_esquema.Maestra
                           WHERE Cliente_Dni IS NOT NULL AND Cliente_Mail IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Cliente);

INSERT #Recon SELECT 15, 'Encuesta',
    (SELECT COUNT(DISTINCT Encuesta_Codigo_Encuesta) FROM gd_esquema.Maestra WHERE Encuesta_Codigo_Encuesta IS NOT NULL),
    (SELECT COUNT(*) FROM TP_APROBADO.Encuesta);

INSERT #Recon SELECT 16, 'Excursion',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Excursion_Nombre, Excursion_Descripcion, Excursion_Horario,
                                  Excursion_Duracion, Excursion_Precio, Proveedor_Nombre, Proveedor_Mail, Proveedor_Telefono
                           FROM gd_esquema.Maestra WHERE Excursion_Nombre IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Excursion);

INSERT #Recon SELECT 17, 'Hospedaje',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Hospedaje_Nombre, Hospedaje_Direccion, Hospedaje_Incluye_Desayuno,
                                  Hospedaje_Check_In, Hospedaje_Check_Out
                           FROM gd_esquema.Maestra WHERE Hospedaje_Nombre IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Hospedaje);

-- NIVEL 3 ---------------------------------------------------------------------
INSERT #Recon SELECT 18, 'Agente',
    (SELECT COUNT(DISTINCT Agente_Legajo) FROM gd_esquema.Maestra WHERE Agente_Legajo IS NOT NULL),
    (SELECT COUNT(*) FROM TP_APROBADO.Agente);

INSERT #Recon SELECT 19, 'Habitacion',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Hospedaje_Nombre, Hospedaje_Direccion, Hospedaje_Incluye_Desayuno,
                                  Hospedaje_Check_In, Hospedaje_Check_Out,
                                  Habitacion_Nombre, Habitacion_Descripcion, Habitacion_Precio_Noche
                           FROM gd_esquema.Maestra
                           WHERE Habitacion_Nombre IS NOT NULL AND Hospedaje_Nombre IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Habitacion);

INSERT #Recon SELECT 20, 'Vuelo',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Aerolinea_Codigo, Aeropuerto_Salida_Codigo, Aeropuerto_Llegada_Codigo,
                                  Vuelo_Fecha_Salida, Vuelo_Horario_Salida, Vuelo_Fecha_Llegada, Vuelo_Horario_Llegada,
                                  Vuelo_Duracion, Vuelo_Precio, Vuelo_Incluye_Carry, Vuelo_Incluye_Valija
                           FROM gd_esquema.Maestra WHERE Aeropuerto_Salida_Codigo IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Vuelo);

INSERT #Recon SELECT 21, 'Detalle_Encuesta',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Encuesta_Codigo_Encuesta, Aspecto_Aspecto FROM gd_esquema.Maestra
                           WHERE Encuesta_Codigo_Encuesta IS NOT NULL AND Aspecto_Aspecto IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Detalle_Encuesta);

-- NIVEL 4 ---------------------------------------------------------------------
INSERT #Recon SELECT 22, 'Solicitud',
    (SELECT COUNT(DISTINCT Solicitud_Nro_Solicitud) FROM gd_esquema.Maestra WHERE Solicitud_Nro_Solicitud IS NOT NULL),
    (SELECT COUNT(*) FROM TP_APROBADO.Solicitud);

-- NIVEL 5 ---------------------------------------------------------------------
INSERT #Recon SELECT 23, 'Detalle_Solicitud',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Solicitud_Nro_Solicitud, Detalle_Solicitud_Ciudad,
                                  Detalle_Solicitud_Cant_Dias_Aprox, Detalle_Solicitud_Observaciones
                           FROM gd_esquema.Maestra
                           WHERE Solicitud_Nro_Solicitud IS NOT NULL AND Detalle_Solicitud_Ciudad IS NOT NULL) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Detalle_Solicitud);

INSERT #Recon SELECT 24, 'Propuesta',
    (SELECT COUNT(DISTINCT Propuesta_Nro_Propuesta) FROM gd_esquema.Maestra WHERE Propuesta_Nro_Propuesta IS NOT NULL),
    (SELECT COUNT(*) FROM TP_APROBADO.Propuesta);

-- NIVEL 6 ---------------------------------------------------------------------
INSERT #Recon SELECT 25, 'Venta',
    (SELECT COUNT(DISTINCT Venta_Nro_Venta) FROM gd_esquema.Maestra WHERE Venta_Nro_Venta IS NOT NULL),
    (SELECT COUNT(*) FROM TP_APROBADO.Venta);

-- NIVEL 7 (detalles) ----------------------------------------------------------
-- El esperado replica el DISTINCT del SP, incluyendo los atributos que identifican
-- al padre de clave sustituta (vuelo/habitación/excursión), porque ese atributo
-- determina 1:1 el código generado.
INSERT #Recon SELECT 26, 'Detalle_Propuesta_Vuelo',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Propuesta_Nro_Propuesta, Detalle_Propuesta_Vuelo_Cant_Pasajes,
                                  Detalle_Propuesta_Vuelo_Precio, Detalle_Propuesta_Vuelo_Subtotal,
                                  Aerolinea_Codigo, Aeropuerto_Salida_Codigo, Aeropuerto_Llegada_Codigo,
                                  Vuelo_Fecha_Salida, Vuelo_Horario_Salida, Vuelo_Fecha_Llegada, Vuelo_Horario_Llegada,
                                  Vuelo_Duracion, Vuelo_Precio, Vuelo_Incluye_Carry, Vuelo_Incluye_Valija
                           FROM gd_esquema.Maestra
                           WHERE Propuesta_Nro_Propuesta IS NOT NULL AND Aeropuerto_Salida_Codigo IS NOT NULL
                             AND (Detalle_Propuesta_Vuelo_Cant_Pasajes IS NOT NULL
                               OR Detalle_Propuesta_Vuelo_Precio        IS NOT NULL
                               OR Detalle_Propuesta_Vuelo_Subtotal      IS NOT NULL)) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Detalle_Propuesta_Vuelo);

INSERT #Recon SELECT 27, 'Detalle_Propuesta_Hospedaje',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Propuesta_Nro_Propuesta, Detalle_Propuesta_Hospedaje_Fecha_Desde,
                                  Detalle_Propuesta_Hospedaje_Fecha_Hasta, Detalle_Propuesta_Hospedaje_Cant,
                                  Detalle_Propuesta_Hospedaje_Precio, Detalle_Propuesta_Hospedaje_Subtotal,
                                  Hospedaje_Nombre, Hospedaje_Direccion, Hospedaje_Incluye_Desayuno,
                                  Hospedaje_Check_In, Hospedaje_Check_Out,
                                  Habitacion_Nombre, Habitacion_Descripcion, Habitacion_Precio_Noche
                           FROM gd_esquema.Maestra
                           WHERE Propuesta_Nro_Propuesta IS NOT NULL
                             AND Habitacion_Nombre IS NOT NULL AND Hospedaje_Nombre IS NOT NULL
                             AND (Detalle_Propuesta_Hospedaje_Cant        IS NOT NULL
                               OR Detalle_Propuesta_Hospedaje_Fecha_Desde IS NOT NULL
                               OR Detalle_Propuesta_Hospedaje_Subtotal    IS NOT NULL)) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Detalle_Propuesta_Hospedaje);

INSERT #Recon SELECT 28, 'Detalle_Venta_Vuelo',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Venta_Nro_Venta, Detalle_Venta_Vuelo_Cantidad_Pasajes,
                                  Detalle_Venta_Vuelo_Precio_Unitario, Detalle_Venta_Vuelo_Subtotal,
                                  Detalle_Venta_Vuelo_Cod_Reserva,
                                  Aerolinea_Codigo, Aeropuerto_Salida_Codigo, Aeropuerto_Llegada_Codigo,
                                  Vuelo_Fecha_Salida, Vuelo_Horario_Salida, Vuelo_Fecha_Llegada, Vuelo_Horario_Llegada,
                                  Vuelo_Duracion, Vuelo_Precio, Vuelo_Incluye_Carry, Vuelo_Incluye_Valija
                           FROM gd_esquema.Maestra
                           WHERE Venta_Nro_Venta IS NOT NULL AND Aeropuerto_Salida_Codigo IS NOT NULL
                             AND (Detalle_Venta_Vuelo_Cantidad_Pasajes IS NOT NULL
                               OR Detalle_Venta_Vuelo_Cod_Reserva       IS NOT NULL
                               OR Detalle_Venta_Vuelo_Precio_Unitario   IS NOT NULL)) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Detalle_Venta_Vuelo);

INSERT #Recon SELECT 29, 'Detalle_Venta_Hospedaje',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Venta_Nro_Venta, Detalle_Venta_Hospedaje_Fecha_Desde,
                                  Detalle_Venta_Hospedaje_Fecha_Hasta, Detalle_Venta_Hospedaje_Cantidad,
                                  Detalle_Venta_Hospedaje_Precio_Unitario, Detalle_Venta_Hospedaje_Subtotal,
                                  Detalle_Venta_Hospedaje_Cod_Reserva,
                                  Hospedaje_Nombre, Hospedaje_Direccion, Hospedaje_Incluye_Desayuno,
                                  Hospedaje_Check_In, Hospedaje_Check_Out,
                                  Habitacion_Nombre, Habitacion_Descripcion, Habitacion_Precio_Noche
                           FROM gd_esquema.Maestra
                           WHERE Venta_Nro_Venta IS NOT NULL
                             AND Habitacion_Nombre IS NOT NULL AND Hospedaje_Nombre IS NOT NULL
                             AND (Detalle_Venta_Hospedaje_Cantidad   IS NOT NULL
                               OR Detalle_Venta_Hospedaje_Cod_Reserva IS NOT NULL
                               OR Detalle_Venta_Hospedaje_Fecha_Desde IS NOT NULL)) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Detalle_Venta_Hospedaje);

INSERT #Recon SELECT 30, 'Detalle_Venta_Excursion',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Venta_Nro_Venta, Detalle_Venta_Excursion_Fecha_Reserva,
                                  Detalle_Venta_Excursion_Cant, Detalle_Venta_Excursion_Precio_Unitario,
                                  Detalle_Venta_Excursion_Subtotal, Detalle_Venta_Excursion_Cod_Reserva,
                                  Excursion_Nombre, Excursion_Descripcion, Excursion_Horario,
                                  Excursion_Duracion, Excursion_Precio
                           FROM gd_esquema.Maestra
                           WHERE Venta_Nro_Venta IS NOT NULL AND Excursion_Nombre IS NOT NULL
                             AND (Detalle_Venta_Excursion_Cant          IS NOT NULL
                               OR Detalle_Venta_Excursion_Cod_Reserva   IS NOT NULL
                               OR Detalle_Venta_Excursion_Fecha_Reserva IS NOT NULL)) z),
    (SELECT COUNT(*) FROM TP_APROBADO.Detalle_Venta_Excursion);

-- Resultado de la reconciliación.
SELECT Orden, Tabla, Esperado, Migrado,
       (Migrado - Esperado) AS Diferencia,
       CASE WHEN Migrado = Esperado THEN 'OK' ELSE '** REVISAR **' END AS Estado
FROM #Recon
ORDER BY Orden;

-- Resumen: cuántas tablas quedaron OK y cuántas para revisar.
SELECT
    SUM(CASE WHEN Migrado = Esperado THEN 1 ELSE 0 END) AS Tablas_OK,
    SUM(CASE WHEN Migrado <> Esperado THEN 1 ELSE 0 END) AS Tablas_a_revisar,
    COUNT(*) AS Total_tablas
FROM #Recon;

DROP TABLE #Recon;


/* ============================================================================
   PARTE C - RESOLUCIÓN DE FKs A LOOKUPS
   Cuenta, para cada texto de la maestra, cuántos valores distintos NO encontraron
   su código en la lookup. Todo debería dar 0; si algo da > 0, hay un valor que no
   resolvió (típicamente diferencia de tipeo, espacios o mayúsculas).
   ============================================================================ */
SELECT 'Venta.Canal_Venta -> Canal_Venta' AS Resolucion,
    (SELECT COUNT(*) FROM (SELECT DISTINCT Venta_Canal_Venta v FROM gd_esquema.Maestra WHERE Venta_Canal_Venta IS NOT NULL) s
     WHERE NOT EXISTS (SELECT 1 FROM TP_APROBADO.Canal_Venta c WHERE c.Canal_Venta_Nombre = s.v)) AS Textos_sin_resolver
UNION ALL SELECT 'Venta.Medio_Pago -> Medio_Pago',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Venta_Medio_Pago v FROM gd_esquema.Maestra WHERE Venta_Medio_Pago IS NOT NULL) s
     WHERE NOT EXISTS (SELECT 1 FROM TP_APROBADO.Medio_Pago c WHERE c.Medio_Pago_Nombre = s.v))
UNION ALL SELECT 'Propuesta.Estado -> Estado',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Propuesta_Estado v FROM gd_esquema.Maestra WHERE Propuesta_Estado IS NOT NULL) s
     WHERE NOT EXISTS (SELECT 1 FROM TP_APROBADO.Estado c WHERE c.Estado_Nombre = s.v))
UNION ALL SELECT 'Aerolinea.Pais -> Pais',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Aerolinea_Pais v FROM gd_esquema.Maestra WHERE Aerolinea_Pais IS NOT NULL) s
     WHERE NOT EXISTS (SELECT 1 FROM TP_APROBADO.Pais c WHERE c.Pais_Nombre = s.v))
UNION ALL SELECT 'Cliente.Provincia -> Provincia',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Cliente_Provincia v FROM gd_esquema.Maestra WHERE Cliente_Provincia IS NOT NULL) s
     WHERE NOT EXISTS (SELECT 1 FROM TP_APROBADO.Provincia c WHERE c.Provincia_Nombre = s.v))
UNION ALL SELECT 'Cliente.Localidad -> Localidad',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Cliente_Localidad v FROM gd_esquema.Maestra WHERE Cliente_Localidad IS NOT NULL) s
     WHERE NOT EXISTS (SELECT 1 FROM TP_APROBADO.Localidad c WHERE c.Localidad_Nombre = s.v))
UNION ALL SELECT 'Hospedaje.Ciudad -> Ciudad',
    (SELECT COUNT(*) FROM (SELECT DISTINCT Hospedaje_Ciudad v FROM gd_esquema.Maestra WHERE Hospedaje_Ciudad IS NOT NULL) s
     WHERE NOT EXISTS (SELECT 1 FROM TP_APROBADO.Ciudad c WHERE c.Ciudad_Nombre = s.v));
GO

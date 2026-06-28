USE GD1C2026;
GO

/* 
============================================================================
 ELIMINAR TODO LO CREADO EN EL SCHEMA TP_APROBADO
 No toca gd_esquema.Maestra.
 Borra FKs, vistas, procedimientos, tablas y funciones del schema del grupo.
 ============================================================================ 
*/

DECLARE @sql NVARCHAR(MAX);

/* 1. Borrar foreign keys del schema */
SET @sql = N'';

SELECT @sql += N'
ALTER TABLE '
    + QUOTENAME(SCHEMA_NAME(t.schema_id)) + N'.' + QUOTENAME(t.name)
    + N' DROP CONSTRAINT ' + QUOTENAME(fk.name) + N';'
FROM sys.foreign_keys fk
JOIN sys.tables t
    ON fk.parent_object_id = t.object_id
WHERE SCHEMA_NAME(t.schema_id) = 'TP_APROBADO';

EXEC sp_executesql @sql;
GO

/* 2. Borrar vistas del schema */
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += N'
DROP VIEW ' + QUOTENAME(s.name) + N'.' + QUOTENAME(v.name) + N';'
FROM sys.views v
JOIN sys.schemas s
    ON v.schema_id = s.schema_id
WHERE s.name = 'TP_APROBADO';

EXEC sp_executesql @sql;
GO

/* 3. Borrar stored procedures del schema */
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += N'
DROP PROCEDURE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(p.name) + N';'
FROM sys.procedures p
JOIN sys.schemas s
    ON p.schema_id = s.schema_id
WHERE s.name = 'TP_APROBADO';

EXEC sp_executesql @sql;
GO

/* 4. Borrar funciones del schema */
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += N'
DROP FUNCTION ' + QUOTENAME(s.name) + N'.' + QUOTENAME(o.name) + N';'
FROM sys.objects o
JOIN sys.schemas s
    ON o.schema_id = s.schema_id
WHERE s.name = 'TP_APROBADO'
  AND o.type IN ('FN', 'IF', 'TF');

EXEC sp_executesql @sql;
GO

/* 5. Borrar tablas del schema */
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += N'
DROP TABLE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) + N';'
FROM sys.tables t
JOIN sys.schemas s
    ON t.schema_id = s.schema_id
WHERE s.name = 'TP_APROBADO';

EXEC sp_executesql @sql;
GO

/* 6. Opcional: borrar el schema si quedó vacío */
IF EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'TP_APROBADO'
)
AND NOT EXISTS (
    SELECT 1
    FROM sys.objects o
    JOIN sys.schemas s ON o.schema_id = s.schema_id
    WHERE s.name = 'TP_APROBADO'
)
BEGIN
    EXEC('DROP SCHEMA TP_APROBADO');
END
GO

/* Verificacion final */
SELECT 
    s.name AS Esquema,
    o.name AS Objeto,
    o.type_desc AS Tipo
FROM sys.objects o
JOIN sys.schemas s
    ON o.schema_id = s.schema_id
WHERE s.name = 'TP_APROBADO'
ORDER BY o.type_desc, o.name;
GO

/* PIXEL STUDIO | Demostracion de seguridad a nivel de base.
   Crea un usuario de PRUEBA SIN LOGIN, no una cuenta de acceso real.
   Ejecutar con cuenta autorizada para administrar roles y permisos.
*/
USE PixelStudio;
GO
IF DATABASE_PRINCIPAL_ID(N'rol_pixelstudio_consulta') IS NULL
    CREATE ROLE rol_pixelstudio_consulta AUTHORIZATION dbo;
GO
IF DATABASE_PRINCIPAL_ID(N'usuario_pixelstudio_demo') IS NULL
    CREATE USER usuario_pixelstudio_demo WITHOUT LOGIN;
GO
IF NOT EXISTS (
    SELECT 1 FROM sys.database_role_members rm
    JOIN sys.database_principals r ON r.principal_id=rm.role_principal_id
    JOIN sys.database_principals u ON u.principal_id=rm.member_principal_id
    WHERE r.name=N'rol_pixelstudio_consulta' AND u.name=N'usuario_pixelstudio_demo'
)
    ALTER ROLE rol_pixelstudio_consulta ADD MEMBER usuario_pixelstudio_demo;
GO
GRANT SELECT ON SCHEMA::dbo TO rol_pixelstudio_consulta;
GO
/* Prueba de permisos: SELECT permitido; no realizamos UPDATE/DELETE real. */
EXECUTE AS USER=N'usuario_pixelstudio_demo';
SELECT USER_NAME() AS usuario_actual, COUNT(*) AS total_clientes FROM dbo.Clientes;
SELECT HAS_PERMS_BY_NAME(N'dbo.Clientes',N'OBJECT',N'SELECT') AS permiso_select,
       HAS_PERMS_BY_NAME(N'dbo.Clientes',N'OBJECT',N'UPDATE') AS permiso_update;
REVERT;
GO
SELECT r.name AS rol, u.name AS usuario
FROM sys.database_role_members AS m
JOIN sys.database_principals AS r ON r.principal_id=m.role_principal_id
JOIN sys.database_principals AS u ON u.principal_id=m.member_principal_id
WHERE r.name=N'rol_pixelstudio_consulta';
GO

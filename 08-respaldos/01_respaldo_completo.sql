/* PIXEL STUDIO - RESPALDO COMPLETO
   SQL Server 2022. Ejecutar como administrador de una instancia de práctica.
   Requiere permisos BACKUP DATABASE y escritura en carpeta de backups para
   la cuenta de SERVICIO de SQL Server, no solo para usuario de Windows.
   Genera nombre unico y verifica backup. NO RESTAURA NI ELIMINA DATOS.
*/
USE PixelStudio;
GO
CREATE OR ALTER PROCEDURE dbo.usp_RespaldarPixelStudio
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @dir NVARCHAR(4000) = CONVERT(NVARCHAR(4000), SERVERPROPERTY('InstanceDefaultBackupPath'));
    IF @dir IS NULL OR LEN(@dir)=0
        THROW 51001, 'No se encontro ruta predeterminada de respaldos; revisa configuracion del servidor.', 1;

    -- Evitar colisiones entre ejecuciones muy cercanas
    DECLARE @stamp VARCHAR(30) = CONVERT(VARCHAR(8), SYSDATETIME(),112) + '_'
        + REPLACE(CONVERT(VARCHAR(8), SYSDATETIME(),108), ':', '');
    DECLARE @ruta NVARCHAR(4000) = @dir
       + CASE WHEN RIGHT(@dir,1) IN ('\','/') THEN N'' ELSE N'\' END
       + N'PixelStudio_' + @stamp + N'_' + LEFT(CONVERT(NVARCHAR(36), NEWID()),8) + N'.bak';
    DECLARE @q NVARCHAR(MAX);
    SET @q = N'BACKUP DATABASE [PixelStudio] TO DISK = N'''
       + REPLACE(@ruta,'''','''''')
       + N''' WITH COPY_ONLY, INIT, CHECKSUM, STATS = 10;';
    EXEC sys.sp_executesql @q;

    SET @q = N'RESTORE VERIFYONLY FROM DISK = N'''
       + REPLACE(@ruta,'''','''''') + N''' WITH CHECKSUM;';
    EXEC sys.sp_executesql @q;
    SELECT @ruta AS archivo_respaldo, N'RESTORE VERIFYONLY completado' AS resultado;
END;
GO
-- Ejecutar una sola vez para generar evidencia
EXEC dbo.usp_RespaldarPixelStudio;
GO
-- Mostrar historial de respaldos registrados en msdb
SELECT TOP (10) bs.database_name, bs.backup_start_date, bs.backup_finish_date,
       bmf.physical_device_name AS archivo,
       CASE bs.[type] WHEN 'D' THEN 'Completo' ELSE bs.[type] END AS tipo
FROM msdb.dbo.backupset bs
JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id=bmf.media_set_id
WHERE bs.database_name = N'PixelStudio'
ORDER BY bs.backup_finish_date DESC;
GO

/* Solo consulta registros; no modifica datos ni restaura. */
SELECT TOP(10)
  bs.database_name,
  bs.backup_finish_date,
  bs.backup_size / 1048576.0 AS tamano_mb,
  bs.has_backup_checksums,
  bmf.physical_device_name
FROM msdb.dbo.backupset AS bs
JOIN msdb.dbo.backupmediafamily AS bmf ON bs.media_set_id=bmf.media_set_id
WHERE bs.database_name=N'PixelStudio' AND bs.[type]='D'
ORDER BY bs.backup_finish_date DESC;
GO

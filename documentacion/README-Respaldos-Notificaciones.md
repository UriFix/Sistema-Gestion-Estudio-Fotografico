# Pixel Studio — Respaldos y notificaciones

## 1. Respaldo manual verificado
1. Conectarse a la instancia de práctica en SSMS, como usuario con permisos de respaldo.
2. Ejecutar `08-respaldos/01_respaldo_completo.sql` una sola vez. Crea `dbo.usp_RespaldarPixelStudio`, genera respaldo con `CHECKSUM` y ejecuta `RESTORE VERIFYONLY`.
3. Revisar `archivo_respaldo` y los resultados del historial `msdb`.
4. Ejecutar `08-respaldos/02_verificar_respaldo.sql` y guardar captura.

**Importante:** la ruta predeterminada de backups pertenece al servidor SQL; SQL Server debe tener permiso de escritura allí. No ejecutar RESTORE sobre PixelStudio. `VERIFYONLY` no sustituye una restauración de prueba en otra base/instancia.

## 2. Job diario
1. Asegurar que SQL Server Agent esté activo.
2. Ejecutar `06-jobs/02_job_respaldo_diario.sql` **una vez**.
3. En SSMS, SQL Server Agent > Jobs > `JOB_PixelStudio_RespaldoDiario` > Start Job at Step.
4. Revisar View History, ejecutar nuevamente `02_verificar_respaldo.sql` y tomar evidencia.
5. El horario de ejemplo es 23:30 hora local **del servidor**, con el servicio encendido. La ejecución automática deberá comprobarse después.

## 3. Notificación por correo (configuración manual, NO automática)
1. SSMS > Management > Database Mail > clic derecho > Configure Database Mail.
2. Configurar perfil `PixelStudioMail` con datos SMTP reales de un proveedor/cuenta autorizados. No guardar contraseñas en Git.
3. Probar el correo desde Database Mail > Send Test E-Mail; confirmar recepción efectiva.
4. SQL Server Agent > Properties > Alert System > Enable mail profile > Database Mail > `PixelStudioMail`; reiniciar solo **SQL Server Agent**.
5. SQL Server Agent > Operators > New Operator; nombrar `OperadorPixelStudio` y asignar un correo real al que puedas acceder.
6. SQL Server Agent > Jobs > `JOB_PixelStudio_RespaldoDiario` > Properties > Notifications > E-mail `OperadorPixelStudio` > When the job fails.
7. Ejecutar `08-respaldos/03_verificar_correo.sql` para revisar estado de la cola y log de errores.
8. Para evidenciar la notificación de falla, utilizar únicamente un Job de prueba aislado y una falla controlada; no dañar ni alterar PixelStudio. Capturar correo recibido.

## 4. Evidencias sugeridas
- Captura de backup finalizado + ruta de archivo `.bak`.
- Captura `RESTORE VERIFYONLY` y `has_backup_checksums = 1`.
- Historial de ejecución exitosa del Job.
- Captura del perfil de Database Mail (ocultando secretos).
- Captura de la notificación recibida (ocultando direcciones personales si se publica).

## 5. Límites de esta implementación
- `COPY_ONLY` es una copia completa independiente; no construye cadena de respaldos diferenciales.
- Los backups almacenados en un solo disco no sustituyen una estrategia externa de recuperación.
- No se implementa limpieza automática de `.bak` antiguos: requiere política de retención definida.
- Para una entrega sólida, probar RESTORE en una base distinta y documentarlo (en entorno de práctica).

Referencias oficiales: https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/backup-overview-sql-server y https://learn.microsoft.com/en-us/sql/relational-databases/database-mail/configure-database-mail

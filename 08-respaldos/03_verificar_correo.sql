/* Ejecutar DESPUES de configurar Database Mail y enviar un correo de prueba.
   El hecho de aparecer en la cola no garantiza entrega en el inbox. */
SELECT TOP(20) sent_date, recipients, subject, sent_status, last_mod_date
FROM msdb.dbo.sysmail_allitems
ORDER BY mailitem_id DESC;
SELECT TOP(20) log_date, event_type, description
FROM msdb.dbo.sysmail_event_log
ORDER BY log_date DESC;
GO

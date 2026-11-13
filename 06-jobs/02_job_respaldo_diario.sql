/* PIXEL STUDIO - JOB AUTOMATICO DE BACKUP
   REQUISITOS: SQL Server Agent activo y procedimiento
   PixelStudio.dbo.usp_RespaldarPixelStudio creado.
   No modifica otros Jobs; si ya existe el nombre, detiene el script.
   Horario de ejemplo 23:30 hora local del servidor.
*/
USE msdb;
GO
IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name=N'JOB_PixelStudio_RespaldoDiario')
    THROW 51002, 'El Job ya existe; revisalo en SQL Server Agent antes de recrearlo.', 1;
GO
DECLARE @job_id UNIQUEIDENTIFIER;
EXEC dbo.sp_add_job
    @job_name=N'JOB_PixelStudio_RespaldoDiario',
    @enabled=1,
    @description=N'Respaldo completo COPY_ONLY y verificacion de PixelStudio',
    @job_id=@job_id OUTPUT;
EXEC dbo.sp_add_jobstep
    @job_id=@job_id,
    @step_name=N'CrearYVerificarRespaldo',
    @subsystem=N'TSQL',
    @database_name=N'PixelStudio',
    @command=N'EXEC dbo.usp_RespaldarPixelStudio;',
    @on_success_action=1,
    @on_fail_action=2;
EXEC dbo.sp_add_schedule
    @schedule_name=N'Horario_PixelStudio_Respaldo_2330',
    @enabled=1,
    @freq_type=4,
    @freq_interval=1,
    @active_start_time=233000;
EXEC dbo.sp_attach_schedule
    @job_id=@job_id,
    @schedule_name=N'Horario_PixelStudio_Respaldo_2330';
EXEC dbo.sp_add_jobserver @job_id=@job_id;
GO
SELECT name, enabled FROM msdb.dbo.sysjobs
WHERE name=N'JOB_PixelStudio_RespaldoDiario';
GO

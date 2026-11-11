# Pixel Studio | Job de mantenimiento

## Lo que se implementó en SSMS

- Job: `JOB_PixelStudio_Mantenimiento`
- Paso: `RegistrarEjecucion`
- Base de datos: `PixelStudio`
- Tarea: insertar una fila en `dbo.BitacoraJobs`
- Programación propuesta: diaria, a las 23:00

## Verificación

La ejecución manual finalizó con éxito y produjo un registro en `BitacoraJobs`. Para verificar:

```sql
USE PixelStudio;
GO
SELECT TOP (10) id_ejecucion, nombre_job, fecha_ejecucion, resultado
FROM dbo.BitacoraJobs
ORDER BY fecha_ejecucion DESC;
```

La ejecución manual exitosa no demuestra todavía que la **programación automática** funcione. Verificar el historial luego de las 23:00, cuando SQL Server Agent siga encendido.

## Exportar el Job real al repositorio (IMPORTANTE)

1. SSMS > SQL Server Agent > Jobs.
2. Clic derecho en `JOB_PixelStudio_Mantenimiento`.
3. `Script Job as` > `CREATE To` > `File`.
4. Guardar en `06-jobs/01_job_mantenimiento.sql`.
5. **No ejecutar ese script en el mismo servidor** sin revisar: el Job ya existe y podría generar errores/duplicados.

Esto conserva la definición real del Job y su programación, en vez de limitarse a documentar un INSERT.

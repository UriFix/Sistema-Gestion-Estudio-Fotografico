/* PIXEL STUDIO | Indices adicionales.
   Ejecutar sobre la base PixelStudio. Se puede repetir sin duplicar estos indices.
   Los beneficios reales dependen de las consultas y el volumen de datos.
*/
USE PixelStudio;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Reservaciones_Cliente_Fecha' AND object_id=OBJECT_ID(N'dbo.Reservaciones'))
    CREATE NONCLUSTERED INDEX IX_Reservaciones_Cliente_Fecha
    ON dbo.Reservaciones(id_cliente, fecha_reservacion)
    INCLUDE (id_paquete, estado, precio_pactado);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Sesiones_Fotografo_Inicio' AND object_id=OBJECT_ID(N'dbo.Sesiones'))
    CREATE NONCLUSTERED INDEX IX_Sesiones_Fotografo_Inicio
    ON dbo.Sesiones(id_empleado, fecha_inicio)
    INCLUDE (fecha_fin, estado);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Pagos_Reservacion_Estado' AND object_id=OBJECT_ID(N'dbo.Pagos'))
    CREATE NONCLUSTERED INDEX IX_Pagos_Reservacion_Estado
    ON dbo.Pagos(id_reservacion, estado)
    INCLUDE (monto, fecha_pago);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Fotografias_Sesion' AND object_id=OBJECT_ID(N'dbo.Fotografias'))
    CREATE NONCLUSTERED INDEX IX_Fotografias_Sesion
    ON dbo.Fotografias(id_sesion)
    INCLUDE (estado, fecha_captura);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_AsignacionesEquipo_Equipo' AND object_id=OBJECT_ID(N'dbo.AsignacionesEquipo'))
    CREATE NONCLUSTERED INDEX IX_AsignacionesEquipo_Equipo
    ON dbo.AsignacionesEquipo(id_equipo, id_sesion);
GO
SELECT t.name AS tabla, i.name AS indice, i.type_desc
FROM sys.indexes AS i
JOIN sys.tables AS t ON t.object_id=i.object_id
WHERE i.name IN (N'IX_Reservaciones_Cliente_Fecha',N'IX_Sesiones_Fotografo_Inicio',N'IX_Pagos_Reservacion_Estado',N'IX_Fotografias_Sesion',N'IX_AsignacionesEquipo_Equipo')
ORDER BY t.name, i.name;
GO

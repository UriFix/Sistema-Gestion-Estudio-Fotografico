/* PIXEL STUDIO | 05 | Pruebas verificables
   Ejecutar DESPUES de 01_triggers.sql y 02_vistas.sql.
   Las pruebas negativas deben fallar con un error controlado 5200x.
   No crea ni borra datos permanentes. */
USE PixelStudio;
GO
SET NOCOUNT ON;

PRINT '=== Objetos instalados ===';
SELECT 'TRIGGER' AS tipo, name FROM sys.triggers
WHERE parent_class = 1 AND name IN (
 'trg_DetalleEntrega_MismaSesion','trg_AsignacionesEquipo_Disponibilidad',
 'trg_Sesiones_ValidarAgenda','trg_Pagos_NoExcederTotal')
UNION ALL
SELECT 'VISTA', name FROM sys.views WHERE name IN (
 'vw_EstadoCuentaReservaciones','vw_AgendaFotografos',
 'vw_InventarioEquipos','vw_ResumenEntregas')
ORDER BY tipo, name;

PRINT '=== Vistas: datos del negocio ===';
SELECT TOP (10) * FROM dbo.vw_EstadoCuentaReservaciones ORDER BY id_reservacion;
SELECT TOP (10) * FROM dbo.vw_AgendaFotografos ORDER BY fecha_inicio;
SELECT TOP (10) * FROM dbo.vw_InventarioEquipos ORDER BY id_equipo;
SELECT TOP (10) * FROM dbo.vw_ResumenEntregas ORDER BY id_entrega;

/* Prueba negativa 1: pago superior al precio pactado. Esperado: 52007.
   Al fallar el AFTER trigger, SQL Server revierte ese INSERT. */
DECLARE @res INT = (SELECT MIN(id_reservacion) FROM dbo.Reservaciones);
IF @res IS NOT NULL
BEGIN
    BEGIN TRY
        INSERT INTO dbo.Pagos (id_reservacion, monto, metodo_pago, estado)
        VALUES (@res, 99999999.99, 'Efectivo', 'Aplicado');
        PRINT 'ERROR DE PRUEBA: el pago incorrecto fue aceptado.';
    END TRY
    BEGIN CATCH
        PRINT CONCAT('Prueba pago rechazada como se esperaba. Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE());
    END CATCH;
END
ELSE PRINT 'Sin reservaciones: se omite prueba de pago.';

/* Prueba negativa 2: entrega con fotografia de OTRA sesion. Esperado: 52001. */
DECLARE @entrega INT, @foto INT;
SELECT TOP (1) @entrega = e.id_entrega, @foto = f.id_fotografia
FROM dbo.Entregas AS e
CROSS JOIN dbo.Fotografias AS f
WHERE e.id_sesion <> f.id_sesion
AND NOT EXISTS (
  SELECT 1 FROM dbo.DetalleEntrega AS d
  WHERE d.id_entrega = e.id_entrega AND d.id_fotografia = f.id_fotografia
)
ORDER BY e.id_entrega, f.id_fotografia;
IF @entrega IS NOT NULL
BEGIN
    BEGIN TRY
        INSERT INTO dbo.DetalleEntrega(id_entrega,id_fotografia) VALUES(@entrega,@foto);
        PRINT 'ERROR DE PRUEBA: el detalle incorrecto fue aceptado.';
    END TRY
    BEGIN CATCH
        PRINT CONCAT('Prueba foto ajena rechazada como se esperaba. Error ',ERROR_NUMBER(),': ',ERROR_MESSAGE());
    END CATCH;
END
ELSE PRINT 'No hay entrega/foto de distintas sesiones: prueba omitida.';

PRINT '=== Conteo final (las pruebas negativas no deben agregar registros) ===';
SELECT (SELECT COUNT(*) FROM dbo.Pagos) AS pagos,
       (SELECT COUNT(*) FROM dbo.DetalleEntrega) AS detalles_entrega;
GO

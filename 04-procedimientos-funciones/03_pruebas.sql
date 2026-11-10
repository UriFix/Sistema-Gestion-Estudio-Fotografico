/* PIXEL STUDIO | Pruebas no destructivas (lectura)
   Corre primero los scripts 01 y 02; requiere datos de prueba previos.
   Estas consultas NO insertan ni modifican datos.
*/
USE PixelStudio;
GO
PRINT 'Comprobación de objetos:';
SELECT o.name AS objeto, o.type_desc
FROM sys.objects AS o
WHERE o.name IN
('fn_SaldoReservacion','fn_ResumenReservacion',
 'sp_CrearReservacion','sp_ProgramarSesion','sp_RegistrarPago')
ORDER BY o.name;
GO
DECLARE @id INT = (SELECT MIN(id_reservacion) FROM dbo.Reservaciones);
IF @id IS NULL
    PRINT 'No hay reservaciones; primero ejecuta los datos de prueba.';
ELSE
BEGIN
    SELECT @id AS id_reservacion,
           dbo.fn_SaldoReservacion(@id) AS saldo_escalar;
    SELECT * FROM dbo.fn_ResumenReservacion(@id);
END;
GO
/* PRUEBA CONTROLADA DE ESCRITURA (opcional):
   Ejecuta un SP en una base de prueba con datos de prueba, no en producción.
   Ejemplo para un cliente/paquete existentes; la fecha es sólo académica:

DECLARE @nueva INT;
EXEC dbo.sp_CrearReservacion
 @id_cliente = 1, @id_paquete = 1,
 @fecha_reservacion = '2026-11-20', @hora_reservacion = '13:00',
 @observaciones = N'Reservación de práctica',
 @id_reservacion = @nueva OUTPUT;
SELECT @nueva AS nueva_reservacion;

Para probar el agendamiento, usa una reservación sin sesión asignada
 y un Empleado cuyo puesto sea 'Fotografo' y activo=1.
 NOTA: los SP controlan sus propias transacciones; NO los consideres
 automáticamente reversibles envolviéndolos en un BEGIN TRAN externo.
*/

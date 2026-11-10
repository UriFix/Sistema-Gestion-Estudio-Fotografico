/* PIXEL STUDIO | DEMOSTRACION CRUD
   Requiere ejecutar 01_datos_prueba.sql primero.
   Los cambios de este laboratorio se revierten con ROLLBACK.
*/
USE PixelStudio;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

-- READ: consultar los clientes existentes.
SELECT id_cliente,nombre,apellido_paterno,telefono,correo
FROM dbo.Clientes
ORDER BY id_cliente;
GO

-- CREATE, READ, UPDATE, DELETE sin alterar el contenido definitivo.
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @nuevoCliente INT;

    -- CREATE
    INSERT INTO dbo.Clientes(nombre,apellido_paterno,telefono,correo)
    VALUES(N'Cliente',N'Demostracion','2229990000',N'crud.demostracion@example.com');
    SET @nuevoCliente = CONVERT(INT,SCOPE_IDENTITY());

    -- READ: verificar que se insertó.
    SELECT 'Despues de INSERT' AS paso,*
    FROM dbo.Clientes WHERE id_cliente=@nuevoCliente;

    -- UPDATE: modificar únicamente el registro creado en esta transacción.
    UPDATE dbo.Clientes
    SET telefono='2229991111'
    WHERE id_cliente=@nuevoCliente;

    SELECT 'Despues de UPDATE' AS paso,*
    FROM dbo.Clientes WHERE id_cliente=@nuevoCliente;

    -- DELETE: borrar únicamente el registro temporal, que no tiene dependientes.
    DELETE FROM dbo.Clientes WHERE id_cliente=@nuevoCliente;
    SELECT 'Despues de DELETE' AS paso,COUNT(*) AS registros
    FROM dbo.Clientes WHERE id_cliente=@nuevoCliente;

    -- ROLLBACK: protege la base de práctica y permite repetir el ejercicio.
    ROLLBACK TRANSACTION;
    PRINT N'CRUD ejecutado. Cambios revertidos con ROLLBACK.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- Ejemplo seguro de consulta de reservaciones con sus claves foráneas.
SELECT id_reservacion,id_cliente,id_paquete,estado,precio_pactado
FROM dbo.Reservaciones ORDER BY id_reservacion;
GO

/* PIXEL STUDIO | Procedimientos almacenados | SQL Server 2022
   Para prácticas: todos los procedimientos manejan errores con THROW.
   Los procedimientos son la vía recomendada para estas operaciones; un INSERT
   directo con permisos amplios podría saltarse sus reglas de negocio.
*/
USE PixelStudio;
GO

/* SP 1: crear reservación y capturar precio vigente del paquete.
   Cualquier precio posterior del catálogo no altera el precio pactado. */
CREATE OR ALTER PROCEDURE dbo.sp_CrearReservacion
    @id_cliente INT,
    @id_paquete INT,
    @fecha_reservacion DATE,
    @hora_reservacion TIME(0),
    @observaciones NVARCHAR(250) = NULL,
    @id_reservacion INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @id_reservacion = NULL;
    DECLARE @precio DECIMAL(10,2);

    BEGIN TRY
        BEGIN TRAN;
        IF NOT EXISTS (SELECT 1 FROM dbo.Clientes WHERE id_cliente = @id_cliente)
            THROW 51001, 'El cliente no existe.', 1;
        SELECT @precio = precio FROM dbo.Paquetes
        WHERE id_paquete = @id_paquete AND activo = 1;
        IF @precio IS NULL
            THROW 51002, 'El paquete no existe o está inactivo.', 1;
        IF @fecha_reservacion IS NULL OR @hora_reservacion IS NULL
            THROW 51003, 'La fecha y la hora son obligatorias.', 1;

        INSERT INTO dbo.Reservaciones
            (id_cliente, id_paquete, fecha_reservacion, hora_reservacion,
             precio_pactado, estado, observaciones)
        VALUES (@id_cliente, @id_paquete, @fecha_reservacion,
                @hora_reservacion, @precio, 'Pendiente', @observaciones);
        SET @id_reservacion = CONVERT(INT,SCOPE_IDENTITY());
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* SP 2: agendar sesión evitando cruces de fotógrafo, incluso ante
   dos solicitudes concurrentes que usen este mismo procedimiento.
   Se usa un candado exclusivo de aplicación POR FOTÓGRAFO; la sesión
   permite intervalos consecutivos [inicio,fin) sin considerarlos choque.
*/
CREATE OR ALTER PROCEDURE dbo.sp_ProgramarSesion
    @id_reservacion INT,
    @id_empleado INT,
    @fecha_inicio DATETIME2(0),
    @fecha_fin DATETIME2(0),
    @id_sesion INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @id_sesion = NULL;
    DECLARE @lockResult INT, @lockName NVARCHAR(255);

    BEGIN TRY
        BEGIN TRAN;
        IF @fecha_inicio IS NULL OR @fecha_fin IS NULL OR @fecha_fin <= @fecha_inicio
            THROW 51010, 'El fin debe ser posterior al inicio.', 1;
        IF NOT EXISTS (
            SELECT 1 FROM dbo.Reservaciones
            WHERE id_reservacion = @id_reservacion
              AND estado IN ('Pendiente','Confirmada'))
            THROW 51011, 'Reservación inexistente o con estado no permitido.', 1;
        IF NOT EXISTS (
            SELECT 1 FROM dbo.Empleados
            WHERE id_empleado = @id_empleado
              AND puesto = 'Fotografo' AND activo = 1)
            THROW 51012, 'Empleado inexistente o no es fotógrafo activo.', 1;
        IF EXISTS (SELECT 1 FROM dbo.Sesiones WHERE id_reservacion = @id_reservacion)
            THROW 51013, 'La reservación ya tiene una sesión.', 1;

        SET @lockName = CONCAT(N'PixelStudio:Fotografo:', @id_empleado);
        EXEC @lockResult = sys.sp_getapplock
             @Resource = @lockName,
             @LockMode = 'Exclusive', @LockOwner = 'Transaction',
             @LockTimeout = 10000;
        IF @lockResult < 0
            THROW 51014, 'No fue posible obtener el bloqueo del fotógrafo.', 1;

        IF EXISTS (
            SELECT 1 FROM dbo.Sesiones WITH (UPDLOCK, HOLDLOCK)
            WHERE id_empleado = @id_empleado
              AND estado <> 'Cancelada'
              AND @fecha_inicio < fecha_fin
              AND fecha_inicio < @fecha_fin)
            THROW 51015, 'El fotógrafo tiene otra sesión en ese horario.', 1;

        INSERT INTO dbo.Sesiones
            (id_reservacion, id_empleado, fecha_inicio, fecha_fin, estado)
        VALUES (@id_reservacion, @id_empleado, @fecha_inicio,
                @fecha_fin, 'Programada');
        SET @id_sesion = CONVERT(INT,SCOPE_IDENTITY());
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* SP 3: registrar pago sin exceder precio pactado.
   El bloqueo POR RESERVACIÓN protege el saldo si varias transacciones
   de pago llaman al procedimiento al mismo tiempo. */
CREATE OR ALTER PROCEDURE dbo.sp_RegistrarPago
    @id_reservacion INT,
    @monto DECIMAL(10,2),
    @metodo_pago VARCHAR(20),
    @id_pago INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @id_pago = NULL;
    DECLARE @lockResult INT, @lockName NVARCHAR(255), @precio DECIMAL(10,2), @pagado DECIMAL(12,2);

    BEGIN TRY
        BEGIN TRAN;
        IF @monto IS NULL OR @monto <= 0
            THROW 51020, 'El monto debe ser positivo.', 1;
        IF @metodo_pago IS NULL OR @metodo_pago NOT IN ('Efectivo','Transferencia','Tarjeta')
            THROW 51021, 'Método de pago inválido.', 1;

        SET @lockName = CONCAT(N'PixelStudio:Pago:', @id_reservacion);
        EXEC @lockResult = sys.sp_getapplock
             @Resource = @lockName,
             @LockMode = 'Exclusive', @LockOwner = 'Transaction',
             @LockTimeout = 10000;
        IF @lockResult < 0
            THROW 51022, 'No fue posible obtener el bloqueo de pagos.', 1;

        SELECT @precio = precio_pactado
        FROM dbo.Reservaciones WITH (UPDLOCK, HOLDLOCK)
        WHERE id_reservacion = @id_reservacion
          AND estado <> 'Cancelada';
        IF @precio IS NULL
            THROW 51023, 'La reservación no existe o fue cancelada.', 1;

        SELECT @pagado = COALESCE(SUM(CAST(monto AS DECIMAL(12,2))),0)
        FROM dbo.Pagos
        WHERE id_reservacion = @id_reservacion AND estado = 'Aplicado';
        IF @pagado + @monto > @precio
            THROW 51024, 'El pago supera el saldo pendiente.', 1;

        INSERT INTO dbo.Pagos(id_reservacion, monto, metodo_pago, estado)
        VALUES (@id_reservacion, @monto, @metodo_pago, 'Aplicado');
        SET @id_pago = CONVERT(INT,SCOPE_IDENTITY());
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO
PRINT 'Procedimientos creados/actualizados.';
GO

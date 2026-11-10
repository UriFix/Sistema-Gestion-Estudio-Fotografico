/* PIXEL STUDIO | 03-crud/01_datos_prueba.sql
   Compatible con 02-tablas/01_crear_bd_tablas.sql (SQL Server).
   Ejecutar una sola vez en una base de practica limpia.
   La marca evita volver a cargar el lote por accidente.
*/
USE PixelStudio;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
IF EXISTS (SELECT 1 FROM dbo.Clientes WHERE correo = N'ana.torres.pixelstudio@example.com')
BEGIN
    PRINT N'Los datos de demostracion ya parecen estar cargados. No se insertaron duplicados.';
END
ELSE
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @clienteAna INT, @clienteLuis INT, @clienteSofia INT;
        DECLARE @servGraduacion INT, @servBoda INT, @servRetrato INT;
        DECLARE @paqBasico INT, @paqPremium INT, @paqBoda INT, @paqRetrato INT;
        DECLARE @empPedro INT, @empElena INT, @empEditor INT;
        DECLARE @camCanon INT, @camSony INT, @flash INT;
        DECLARE @resAna INT, @resLuis INT, @resSofia INT;
        DECLARE @sesAna INT, @sesLuis INT, @sesSofia INT;
        DECLARE @foto1 INT, @foto2 INT, @foto3 INT, @entregaAna INT;

        INSERT INTO dbo.Clientes (nombre,apellido_paterno,apellido_materno,telefono,correo)
        VALUES (N'Ana',N'Torres',N'Lopez','2221001001',N'ana.torres.pixelstudio@example.com');
        SET @clienteAna = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Clientes (nombre,apellido_paterno,telefono,correo)
        VALUES (N'Luis',N'Ramirez','2221001002',N'luis.ramirez.pixelstudio@example.com');
        SET @clienteLuis = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Clientes (nombre,apellido_paterno,apellido_materno,telefono,correo)
        VALUES (N'Sofia',N'Mendez',N'Garcia','2221001003',N'sofia.mendez.pixelstudio@example.com');
        SET @clienteSofia = CONVERT(INT,SCOPE_IDENTITY());

        INSERT INTO dbo.Servicios (nombre,descripcion) VALUES (N'Graduacion',N'Fotografia de graduacion');
        SET @servGraduacion = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Servicios (nombre,descripcion) VALUES (N'Bodas',N'Cobertura de bodas');
        SET @servBoda = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Servicios (nombre,descripcion) VALUES (N'Retratos',N'Sesiones de retrato');
        SET @servRetrato = CONVERT(INT,SCOPE_IDENTITY());

        INSERT INTO dbo.Paquetes (id_servicio,nombre,descripcion,precio)
        VALUES (@servGraduacion,N'Basico',N'10 fotografias editadas',1200.00);
        SET @paqBasico = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Paquetes (id_servicio,nombre,descripcion,precio)
        VALUES (@servGraduacion,N'Premium',N'25 fotografias y album',2500.00);
        SET @paqPremium = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Paquetes (id_servicio,nombre,descripcion,precio)
        VALUES (@servBoda,N'Esencial',N'Cobertura de ceremonia',8000.00);
        SET @paqBoda = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Paquetes (id_servicio,nombre,descripcion,precio)
        VALUES (@servRetrato,N'Individual',N'8 retratos editados',950.00);
        SET @paqRetrato = CONVERT(INT,SCOPE_IDENTITY());

        INSERT INTO dbo.Empleados(nombre,apellido_paterno,telefono,puesto,fecha_contratacion)
        VALUES(N'Pedro',N'Gomez','2222002001','Fotografo','2025-02-10');
        SET @empPedro = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Empleados(nombre,apellido_paterno,telefono,puesto,fecha_contratacion)
        VALUES(N'Elena',N'Ruiz','2222002002','Fotografo','2025-03-05');
        SET @empElena = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Empleados(nombre,apellido_paterno,telefono,puesto,fecha_contratacion)
        VALUES(N'Marco',N'Salas','2222002003','Editor','2025-04-01');
        SET @empEditor = CONVERT(INT,SCOPE_IDENTITY());

        INSERT INTO dbo.Equipos(nombre,numero_serie,tipo)
        VALUES(N'Canon EOS R6',N'PS-DEMO-CAN-001','Camara');
        SET @camCanon = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Equipos(nombre,numero_serie,tipo)
        VALUES(N'Sony A7 IV',N'PS-DEMO-SON-001','Camara');
        SET @camSony = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Equipos(nombre,numero_serie,tipo)
        VALUES(N'Flash Godox V1',N'PS-DEMO-FLA-001','Flash');
        SET @flash = CONVERT(INT,SCOPE_IDENTITY());

        INSERT INTO dbo.Reservaciones(id_cliente,id_paquete,fecha_reservacion,hora_reservacion,precio_pactado,estado,observaciones)
        VALUES (@clienteAna,@paqPremium,'2026-11-14','10:00',2500.00,'Confirmada',N'Fotos de graduacion');
        SET @resAna = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Reservaciones(id_cliente,id_paquete,fecha_reservacion,hora_reservacion,precio_pactado,estado)
        VALUES (@clienteLuis,@paqBoda,'2026-11-15','12:00',8000.00,'Confirmada');
        SET @resLuis = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Reservaciones(id_cliente,id_paquete,fecha_reservacion,hora_reservacion,precio_pactado,estado)
        VALUES (@clienteSofia,@paqRetrato,'2026-11-14','12:00',950.00,'Confirmada');
        SET @resSofia = CONVERT(INT,SCOPE_IDENTITY());

        INSERT INTO dbo.Sesiones(id_reservacion,id_empleado,fecha_inicio,fecha_fin)
        VALUES (@resAna,@empPedro,'2026-11-14T10:00:00','2026-11-14T12:00:00');
        SET @sesAna = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Sesiones(id_reservacion,id_empleado,fecha_inicio,fecha_fin)
        VALUES (@resLuis,@empElena,'2026-11-15T12:00:00','2026-11-15T16:00:00');
        SET @sesLuis = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Sesiones(id_reservacion,id_empleado,fecha_inicio,fecha_fin)
        VALUES (@resSofia,@empPedro,'2026-11-14T12:00:00','2026-11-14T13:00:00');
        SET @sesSofia = CONVERT(INT,SCOPE_IDENTITY());

        INSERT INTO dbo.Pagos(id_reservacion,monto,metodo_pago)
        VALUES (@resAna,500.00,'Transferencia'),(@resLuis,2000.00,'Efectivo'),(@resSofia,950.00,'Tarjeta');

        INSERT INTO dbo.AsignacionesEquipo(id_sesion,id_equipo)
        VALUES (@sesAna,@camCanon),(@sesAna,@flash),(@sesLuis,@camSony),(@sesSofia,@camCanon);

        INSERT INTO dbo.Fotografias(id_sesion,nombre_archivo,ruta_archivo,fecha_captura,estado)
        VALUES(@sesAna,N'graduacion_001.jpg',N'/demo/graduacion_001.jpg','2026-11-14T10:30:00','Seleccionada');
        SET @foto1 = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Fotografias(id_sesion,nombre_archivo,ruta_archivo,fecha_captura,estado)
        VALUES(@sesAna,N'graduacion_002.jpg',N'/demo/graduacion_002.jpg','2026-11-14T10:40:00','Editada');
        SET @foto2 = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.Fotografias(id_sesion,nombre_archivo,ruta_archivo,fecha_captura,estado)
        VALUES(@sesLuis,N'boda_001.jpg',N'/demo/boda_001.jpg','2026-11-15T13:00:00','Original');
        SET @foto3 = CONVERT(INT,SCOPE_IDENTITY());

        INSERT INTO dbo.Entregas(id_sesion,fecha_entrega,metodo_entrega,estado)
        VALUES(@sesAna,'2026-11-18T16:00:00','Digital','Pendiente');
        SET @entregaAna = CONVERT(INT,SCOPE_IDENTITY());
        INSERT INTO dbo.DetalleEntrega(id_entrega,id_fotografia)
        VALUES(@entregaAna,@foto1),(@entregaAna,@foto2);

        COMMIT TRANSACTION;
        PRINT N'Datos de demostracion insertados correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
SELECT N'Clientes' AS tabla,COUNT(*) AS total FROM dbo.Clientes
UNION ALL SELECT N'Servicios',COUNT(*) FROM dbo.Servicios
UNION ALL SELECT N'Paquetes',COUNT(*) FROM dbo.Paquetes
UNION ALL SELECT N'Empleados',COUNT(*) FROM dbo.Empleados
UNION ALL SELECT N'Equipos',COUNT(*) FROM dbo.Equipos
UNION ALL SELECT N'Reservaciones',COUNT(*) FROM dbo.Reservaciones
UNION ALL SELECT N'Sesiones',COUNT(*) FROM dbo.Sesiones
UNION ALL SELECT N'Pagos',COUNT(*) FROM dbo.Pagos
UNION ALL SELECT N'AsignacionesEquipo',COUNT(*) FROM dbo.AsignacionesEquipo
UNION ALL SELECT N'Fotografias',COUNT(*) FROM dbo.Fotografias
UNION ALL SELECT N'Entregas',COUNT(*) FROM dbo.Entregas
UNION ALL SELECT N'DetalleEntrega',COUNT(*) FROM dbo.DetalleEntrega;
GO

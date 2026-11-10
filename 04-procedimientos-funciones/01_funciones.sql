/* PIXEL STUDIO | Funciones | SQL Server 2022
   Requiere: dbo.Reservaciones, dbo.Pagos, dbo.Clientes, dbo.Paquetes.
   Ejecutar sobre la base PixelStudio después de 01_crear_bd_tablas.sql.
*/
USE PixelStudio;
GO

/* Función escalar: saldo de una reservación.
   No incluye pagos reembolsados, solo pagos Aplicados. */
CREATE OR ALTER FUNCTION dbo.fn_SaldoReservacion (@id_reservacion INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @saldo DECIMAL(12,2);
    SELECT @saldo = CAST(r.precio_pactado AS DECIMAL(12,2))
                    - COALESCE((SELECT SUM(CAST(p.monto AS DECIMAL(12,2)))
                                FROM dbo.Pagos AS p
                                WHERE p.id_reservacion = r.id_reservacion
                                  AND p.estado = 'Aplicado'), 0)
    FROM dbo.Reservaciones AS r
    WHERE r.id_reservacion = @id_reservacion;
    RETURN @saldo; -- NULL si la reservación no existe.
END;
GO

/* Función de tabla en línea: resumen por reservación. */
CREATE OR ALTER FUNCTION dbo.fn_ResumenReservacion (@id_reservacion INT)
RETURNS TABLE
AS
RETURN
(
    SELECT r.id_reservacion,
           CONCAT(c.nombre, N' ', c.apellido_paterno) AS cliente,
           pa.nombre AS paquete,
           r.fecha_reservacion,
           r.hora_reservacion,
           r.estado,
           r.precio_pactado,
           COALESCE(x.total_pagado, CONVERT(DECIMAL(12,2),0)) AS total_pagado,
           CAST(r.precio_pactado AS DECIMAL(12,2))
                - COALESCE(x.total_pagado, CONVERT(DECIMAL(12,2),0)) AS saldo
    FROM dbo.Reservaciones AS r
    JOIN dbo.Clientes AS c ON c.id_cliente = r.id_cliente
    JOIN dbo.Paquetes AS pa ON pa.id_paquete = r.id_paquete
    OUTER APPLY (
        SELECT SUM(CAST(p.monto AS DECIMAL(12,2))) AS total_pagado
        FROM dbo.Pagos AS p
        WHERE p.id_reservacion = r.id_reservacion AND p.estado = 'Aplicado'
    ) AS x
    WHERE r.id_reservacion = @id_reservacion
);
GO
PRINT 'Funciones creadas/actualizadas.';

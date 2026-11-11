/* PIXEL STUDIO | 05 | Vistas | SQL Server 2022
   Las vistas simplifican reportes sin duplicar informacion almacenada.
*/
USE PixelStudio;
GO

/* VISTA 1: Estado de cuenta por reservacion (evita duplicar pagos por JOIN). */
CREATE OR ALTER VIEW dbo.vw_EstadoCuentaReservaciones
AS
SELECT r.id_reservacion,
       CONCAT(c.nombre, N' ', c.apellido_paterno) AS cliente,
       sv.nombre AS servicio,
       p.nombre AS paquete,
       r.fecha_reservacion,
       r.estado AS estado_reservacion,
       r.precio_pactado,
       COALESCE(x.total_pagado, CAST(0 AS DECIMAL(19,2))) AS total_pagado,
       CAST(r.precio_pactado - COALESCE(x.total_pagado, 0) AS DECIMAL(19,2)) AS saldo_pendiente
FROM dbo.Reservaciones AS r
JOIN dbo.Clientes AS c ON c.id_cliente = r.id_cliente
JOIN dbo.Paquetes AS p ON p.id_paquete = r.id_paquete
JOIN dbo.Servicios AS sv ON sv.id_servicio = p.id_servicio
LEFT JOIN (
    SELECT id_reservacion, SUM(CAST(monto AS DECIMAL(19,2))) AS total_pagado
    FROM dbo.Pagos WHERE estado = 'Aplicado'
    GROUP BY id_reservacion
) AS x ON x.id_reservacion = r.id_reservacion;
GO

/* VISTA 2: Agenda con fotografo y datos de cliente. */
CREATE OR ALTER VIEW dbo.vw_AgendaFotografos
AS
SELECT s.id_sesion, s.fecha_inicio, s.fecha_fin,
       s.estado AS estado_sesion,
       e.id_empleado AS id_fotografo,
       CONCAT(e.nombre, N' ', e.apellido_paterno) AS fotografo,
       r.id_reservacion,
       CONCAT(c.nombre, N' ', c.apellido_paterno) AS cliente,
       p.nombre AS paquete
FROM dbo.Sesiones AS s
JOIN dbo.Empleados AS e ON e.id_empleado = s.id_empleado
JOIN dbo.Reservaciones AS r ON r.id_reservacion = s.id_reservacion
JOIN dbo.Clientes AS c ON c.id_cliente = r.id_cliente
JOIN dbo.Paquetes AS p ON p.id_paquete = r.id_paquete;
GO

/* VISTA 3: Inventario y numero de sesiones en las que se utilizo cada equipo. */
CREATE OR ALTER VIEW dbo.vw_InventarioEquipos
AS
SELECT eq.id_equipo, eq.nombre, eq.numero_serie, eq.tipo, eq.estado,
       COUNT(ae.id_asignacion) AS total_asignaciones
FROM dbo.Equipos AS eq
LEFT JOIN dbo.AsignacionesEquipo AS ae ON ae.id_equipo = eq.id_equipo
GROUP BY eq.id_equipo, eq.nombre, eq.numero_serie, eq.tipo, eq.estado;
GO

/* VISTA 4: Entregas y numero de fotografias incluidas. */
CREATE OR ALTER VIEW dbo.vw_ResumenEntregas
AS
SELECT en.id_entrega, en.id_sesion, en.fecha_entrega,
       en.metodo_entrega, en.estado,
       COUNT(de.id_detalle) AS total_fotografias
FROM dbo.Entregas AS en
LEFT JOIN dbo.DetalleEntrega AS de ON de.id_entrega = en.id_entrega
GROUP BY en.id_entrega, en.id_sesion, en.fecha_entrega,
         en.metodo_entrega, en.estado;
GO

SELECT name FROM sys.views WHERE name LIKE 'vw_%' ORDER BY name;
GO

/* PIXEL STUDIO | SELECT y JOIN
   Requiere ejecutar 01_datos_prueba.sql primero.
*/
USE PixelStudio;
GO

-- 1. INNER JOIN: cada reservación y su cliente, paquete y servicio.
SELECT r.id_reservacion,
       CONCAT(c.nombre,N' ',c.apellido_paterno) AS cliente,
       sv.nombre AS servicio,
       p.nombre AS paquete,
       r.fecha_reservacion,r.hora_reservacion,
       r.precio_pactado,r.estado
FROM dbo.Reservaciones AS r
INNER JOIN dbo.Clientes AS c ON c.id_cliente=r.id_cliente
INNER JOIN dbo.Paquetes AS p ON p.id_paquete=r.id_paquete
INNER JOIN dbo.Servicios AS sv ON sv.id_servicio=p.id_servicio
ORDER BY r.fecha_reservacion,r.hora_reservacion;
GO

-- 2. LEFT JOIN: clientes incluidos aunque no tengan reservaciones.
SELECT c.id_cliente,CONCAT(c.nombre,N' ',c.apellido_paterno) AS cliente,
       COUNT(r.id_reservacion) AS cantidad_reservaciones
FROM dbo.Clientes AS c
LEFT JOIN dbo.Reservaciones AS r ON r.id_cliente=c.id_cliente
GROUP BY c.id_cliente,c.nombre,c.apellido_paterno
ORDER BY c.id_cliente;
GO

-- 3. JOIN y SUM: total pagado y saldo pendiente por reservación.
SELECT r.id_reservacion,
       r.precio_pactado,
       COALESCE(SUM(CASE WHEN pg.estado='Aplicado' THEN pg.monto ELSE 0 END),0) AS total_pagado,
       r.precio_pactado - COALESCE(SUM(CASE WHEN pg.estado='Aplicado' THEN pg.monto ELSE 0 END),0) AS saldo_pendiente
FROM dbo.Reservaciones AS r
LEFT JOIN dbo.Pagos AS pg ON pg.id_reservacion=r.id_reservacion
GROUP BY r.id_reservacion,r.precio_pactado
ORDER BY r.id_reservacion;
GO

-- 4. Fotógrafos y sus horarios de sesiones.
SELECT s.id_sesion,
       CONCAT(e.nombre,N' ',e.apellido_paterno) AS fotografo,
       s.fecha_inicio,s.fecha_fin,s.estado
FROM dbo.Sesiones AS s
INNER JOIN dbo.Empleados AS e ON e.id_empleado=s.id_empleado
ORDER BY s.fecha_inicio;
GO

-- 5. Equipos asignados a cada sesión (tabla intermedia).
SELECT s.id_sesion,eq.nombre AS equipo,eq.numero_serie,
       s.fecha_inicio,s.fecha_fin
FROM dbo.AsignacionesEquipo AS ae
INNER JOIN dbo.Sesiones AS s ON s.id_sesion=ae.id_sesion
INNER JOIN dbo.Equipos AS eq ON eq.id_equipo=ae.id_equipo
ORDER BY s.id_sesion,eq.nombre;
GO

-- 6. Fotografías incluidas en las entregas.
SELECT en.id_entrega,en.estado AS estado_entrega,
       f.nombre_archivo,f.estado AS estado_fotografia
FROM dbo.DetalleEntrega AS de
INNER JOIN dbo.Entregas AS en ON en.id_entrega=de.id_entrega
INNER JOIN dbo.Fotografias AS f ON f.id_fotografia=de.id_fotografia
ORDER BY en.id_entrega,f.nombre_archivo;
GO

/* PIXEL STUDIO | 05 | Triggers | SQL Server 2022
   Requiere las 12 tablas del archivo 02-tablas/01_crear_bd_tablas.sql.
   Ejecutar una vez DESPUES de cargar datos de prueba y los SP.
   CREATE OR ALTER permite volver a ejecutar este archivo sin duplicar triggers.
*/
USE PixelStudio;
GO

/* TRIGGER 1: Cada fotografia incluida en una entrega debe pertenecer
   a la MISMA sesion que la entrega. Soporta INSERT/UPDATE multirregistro. */
CREATE OR ALTER TRIGGER dbo.trg_DetalleEntrega_MismaSesion
ON dbo.DetalleEntrega
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN dbo.Entregas AS e ON e.id_entrega = i.id_entrega
        JOIN dbo.Fotografias AS f ON f.id_fotografia = i.id_fotografia
        WHERE e.id_sesion <> f.id_sesion
    )
        THROW 52001, 'La fotografia no pertenece a la sesion de la entrega.', 1;
END;
GO

/* TRIGGER 2: Evita asignar equipos en mantenimiento/baja, o el mismo
   equipo a sesiones no canceladas con intervalos que se superponen.
   La PK/UNIQUE existente ya evita asignar el mismo equipo dos veces
   a UNA misma sesion. */
CREATE OR ALTER TRIGGER dbo.trg_AsignacionesEquipo_Disponibilidad
ON dbo.AsignacionesEquipo
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted AS i
        JOIN dbo.Equipos AS eq ON eq.id_equipo = i.id_equipo
        WHERE eq.estado <> 'Disponible'
    )
        THROW 52002, 'Solo pueden asignarse equipos disponibles.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN dbo.Sesiones AS nueva ON nueva.id_sesion = i.id_sesion
        JOIN dbo.AsignacionesEquipo AS otra WITH (UPDLOCK, HOLDLOCK)
          ON otra.id_equipo = i.id_equipo AND otra.id_asignacion <> i.id_asignacion
        JOIN dbo.Sesiones AS existente ON existente.id_sesion = otra.id_sesion
        WHERE nueva.estado <> 'Cancelada'
          AND existente.estado <> 'Cancelada'
          AND nueva.fecha_inicio < existente.fecha_fin
          AND existente.fecha_inicio < nueva.fecha_fin
    )
        THROW 52003, 'El equipo ya esta asignado a otra sesion en ese horario.', 1;
END;
GO

/* TRIGGER 3: Validacion defensiva si alguien crea/edita sesiones
   directamente, en vez de usar sp_ProgramarSesion.
   Tambien rechaza sesiones con fotografos inactivos o no fotografos. */
CREATE OR ALTER TRIGGER dbo.trg_Sesiones_ValidarAgenda
ON dbo.Sesiones
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted AS i
        JOIN dbo.Empleados AS emp ON emp.id_empleado = i.id_empleado
        WHERE emp.activo <> 1 OR emp.puesto <> 'Fotografo'
    )
        THROW 52004, 'La sesion requiere un fotografo activo.', 1;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN dbo.Sesiones AS s WITH (UPDLOCK, HOLDLOCK)
          ON s.id_empleado = i.id_empleado AND s.id_sesion <> i.id_sesion
        WHERE i.estado <> 'Cancelada'
          AND s.estado <> 'Cancelada'
          AND i.fecha_inicio < s.fecha_fin
          AND s.fecha_inicio < i.fecha_fin
    )
        THROW 52005, 'El fotografo tiene otra sesion en ese horario.', 1;

    /* Mover una sesion puede causar choques en asignaciones ya existentes. */
    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN dbo.AsignacionesEquipo AS ae ON ae.id_sesion = i.id_sesion
        JOIN dbo.AsignacionesEquipo AS ae2 WITH (UPDLOCK, HOLDLOCK)
          ON ae2.id_equipo = ae.id_equipo AND ae2.id_sesion <> i.id_sesion
        JOIN dbo.Sesiones AS s2 ON s2.id_sesion = ae2.id_sesion
        WHERE i.estado <> 'Cancelada' AND s2.estado <> 'Cancelada'
          AND i.fecha_inicio < s2.fecha_fin AND s2.fecha_inicio < i.fecha_fin
    )
        THROW 52006, 'El nuevo horario entra en conflicto con un equipo asignado.', 1;
END;
GO

/* TRIGGER 4: Rechaza pagos aplicados cuyo total supere el monto pactado.
   Considera UPDATE y operaciones de varias filas.
   El SP sp_RegistrarPago sigue siendo la via recomendada para pagos
   porque incorpora bloqueo transaccional por reservacion. */
CREATE OR ALTER TRIGGER dbo.trg_Pagos_NoExcederTotal
ON dbo.Pagos
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM (SELECT DISTINCT id_reservacion FROM inserted) AS afectadas
        JOIN dbo.Reservaciones AS r ON r.id_reservacion = afectadas.id_reservacion
        OUTER APPLY (
            SELECT COALESCE(SUM(CAST(p.monto AS DECIMAL(19,2))),0) AS pagado
            FROM dbo.Pagos AS p
            WHERE p.id_reservacion = afectadas.id_reservacion
              AND p.estado = 'Aplicado'
        ) AS totales
        WHERE totales.pagado > r.precio_pactado
    )
        THROW 52007, 'La suma de pagos aplicados supera el precio pactado.', 1;
END;
GO

SELECT name, is_disabled FROM sys.triggers
WHERE parent_class = 1 AND name LIKE 'trg_%'
ORDER BY name;
GO

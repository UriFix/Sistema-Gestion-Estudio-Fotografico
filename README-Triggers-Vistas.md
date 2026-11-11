# Pixel Studio — Fase 5: Triggers y Vistas

## Objetivo

Cubrir el apartado **5. Construcción de Disparadores y Vistas (10 puntos)** de la rúbrica de Bases de Datos.

## Requisitos previos

- Base `PixelStudio` con las **12 tablas** y los datos de prueba.
- Preferiblemente, haber ejecutado los procedimientos y funciones de la fase 4.
- Permisos `CREATE/ALTER TRIGGER` y `CREATE/ALTER VIEW`.

## Orden de ejecución en SSMS

1. `05-triggers-vistas/01_triggers.sql`: crea **4 triggers** (`CREATE OR ALTER`).
2. `05-triggers-vistas/02_vistas.sql`: crea **4 vistas** (`CREATE OR ALTER`).
3. `05-triggers-vistas/03_pruebas.sql`: muestra los **8 objetos**, consulta las vistas y prueba el rechazo de un pago excesivo y una fotografía de otra sesión.

> La prueba negativa genera mensajes de error controlados que son **esperados**; la instrucción inválida se revierte. Las consultas finales muestran el estado de la base de datos.

## Qué aprender

- **Trigger:** se ejecuta automáticamente al insertar o actualizar filas en una tabla. Las tablas lógicas `inserted` y `deleted` permiten identificar cambios. Un trigger debe contemplar operaciones de múltiples filas, no asumir que solo se inserta una.
- **Vista:** es una consulta guardada, útil para simplificar reportes y reutilizar `JOIN`, `GROUP BY` y `SUM`.
- **Validación de pertenencia:** una foto de la sesión A no debe incorporarse a una entrega de la sesión B.
- **Disponibilidad:** un recurso en mantenimiento no puede asignarse, y el mismo equipo no puede usarse en sesiones superpuestas.

## Limitaciones y precauciones

- El trigger `trg_Sesiones_ValidarAgenda` es **defensa adicional** para cambios directos, pero el procedimiento `sp_ProgramarSesion` sigue siendo la forma recomendada de programar: su bloqueo por fotógrafo maneja mejor la concurrencia. Los triggers no sustituyen una estrategia completa de permisos y serialización de transacciones.
- `trg_Pagos_NoExcederTotal` revisa cambios en pagos. Cambiar directamente el `precio_pactado` de una reservación o alterar registros relacionados puede requerir controles extra.
- Si se cambia el estado de un equipo a mantenimiento después de asignarlo, el trigger de asignaciones **no** se dispara; esa operación requiere una regla adicional del negocio.
- Para una solución productiva se necesitan pruebas concurrentes reales, no solo ejecución secuencial en una conexión.
- **No uses `DROP TABLE` ni ejecutes nuevamente el script de creación inicial** si ya hay datos que quieres conservar.

## Evidencia para el reporte

Captura en SSMS: (1) listado de triggers; (2) listado de vistas; (3) resultado de `vw_EstadoCuentaReservaciones`; (4) mensaje controlado al intentar un pago excesivo; (5) mensaje de error al asociar fotografía de otra sesión. En el reporte explica **por qué** cada regla existe.

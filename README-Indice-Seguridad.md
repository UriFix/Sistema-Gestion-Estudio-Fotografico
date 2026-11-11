# Pixel Studio | Índices, permisos y usuarios

## Orden

1. Ejecutar `07-seguridad-indices/01_indices.sql` en SSMS.
2. Ejecutar `07-seguridad-indices/02_roles_usuarios.sql`.
3. Guardar capturas del listado de cinco índices y de los resultados de permisos.
4. Exportar el Job real siguiendo `06-jobs/README-Jobs.md`.

## Conceptos

- **Índice no agrupado**: estructura auxiliar para acelerar determinadas búsquedas. Tiene coste de espacio y mantenimiento; con pocos registros quizá el optimizador prefiera recorrer la tabla.
- **INCLUDE**: agrega columnas no clave al nivel hoja del índice para reducir lecturas adicionales en consultas.
- **Rol**: agrupa permisos.
- **Usuario sin LOGIN**: permite demostrar permisos dentro de la base, pero no sirve para conectarse a SQL Server por sí solo.
- **Principio de mínimo privilegio**: este rol tiene SELECT sobre dbo, sin INSERT, UPDATE ni DELETE concedidos expresamente.

## Precauciones

- Usar exclusivamente la base de práctica `PixelStudio`.
- No guardar contraseñas, claves ni credenciales en GitHub.
- `GRANT SELECT ON SCHEMA::dbo` permite leer todas las tablas y vistas bajo `dbo`, incluidas las que se creen después: para producción convendría restringirlo a vistas concretas.
- La seguridad depende también de otros permisos que puedan heredarse; este usuario de ejemplo es nuevo y solo pertenece al rol de demostración.

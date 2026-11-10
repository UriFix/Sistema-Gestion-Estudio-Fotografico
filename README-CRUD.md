# Pixel Studio — CRUD y consultas

Compatible con `02-tablas/01_crear_bd_tablas.sql` en SQL Server 2022.

## Orden de ejecución en SSMS

1. Confirma que existe la base `PixelStudio` y sus 12 tablas.
2. Ejecuta `03-crud/01_datos_prueba.sql`. Usa datos totalmente ficticios.
3. Ejecuta `03-crud/02_operaciones_crud.sql` para practicar INSERT, SELECT, UPDATE y DELETE. La demostración revierte sus cambios con `ROLLBACK`, por lo que puedes repetirla.
4. Ejecuta `03-crud/03_consultas_join.sql` para practicar INNER JOIN, LEFT JOIN, COUNT, SUM y GROUP BY.

## Qué aprender

- Las claves primarias `IDENTITY` las genera SQL Server. Usamos `SCOPE_IDENTITY()` para recuperar cada identificador recién insertado en vez de suponer que empieza en 1.
- Las claves foráneas requieren que existan los registros padre antes de insertar los hijos.
- Los ejemplos CRUD incluyen `WHERE` para no modificar o eliminar toda una tabla accidentalmente.
- `ROLLBACK` revierte modificaciones de datos de la transacción; el contador de `IDENTITY` puede seguir aumentando.
- Los scripts de esta etapa **no** implementan todavía prevención de empalmes, validación de rol de fotógrafo ni pertenencia de foto a entrega; esas son tareas pendientes de triggers y procedimientos.

## Seguridad

No ejecutes estos ejemplos en bases con datos reales. Si ya tienes información en `PixelStudio`, utiliza una instancia/base de prácticas separada antes de insertar los datos de ejemplo. El script de datos se protege contra una repetición simple por correo marcador, pero no es un proceso de migración completo.

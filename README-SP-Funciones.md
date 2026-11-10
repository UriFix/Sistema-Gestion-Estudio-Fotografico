# Pixel Studio — Procedimientos almacenados y funciones

## Orden de ejecución (SSMS)

1. Selecciona la instancia donde creaste `PixelStudio`.
2. Abre y ejecuta `04-procedimientos-funciones/01_funciones.sql`.
3. Abre y ejecuta `04-procedimientos-funciones/02_procedimientos.sql`.
4. Ejecuta `04-procedimientos-funciones/03_pruebas.sql`.
5. Espera cinco objetos en la primera consulta de prueba (dos funciones, tres procedimientos).

## Objetos

- `fn_SaldoReservacion(id)`: saldo, sin contar pagos reembolsados; `NULL` si no existe reservación.
- `fn_ResumenReservacion(id)`: resultado tabular con cliente, paquete, precio, pagos y saldo.
- `sp_CrearReservacion`: valida cliente y paquete, y congela precio pactado; devuelve ID por parámetro `OUTPUT`.
- `sp_ProgramarSesion`: fotógrafo activo y sin solapamiento; valida fechas y utiliza `sp_getapplock` para serializar agendamiento del mismo fotógrafo.
- `sp_RegistrarPago`: confirma método y monto; impide rebasar el precio pactado y serializa pagos de una misma reservación.

## Conceptos importantes

Los procedimientos almacenados se ejecutan con `EXEC`; las funciones escalares se usan en expresiones `SELECT`, y las funciones tabulares en `FROM`. `OUTPUT` permite devolver el ID generado. `TRY...CATCH`, `THROW` y transacciones protegen cambios.

**Límites actuales:** son reglas para las operaciones realizadas a través de estos procedimientos; alguien con permisos para modificar tablas directamente puede saltarse dichas validaciones. En las próximas fases estableceremos permisos y triggers para controles transversales. Tampoco se comprueba aún la disponibilidad de equipos ni la coherencia entre fotografías y entregas.

**No ejecutes nuevamente** el archivo de creación de tablas: ya se ejecutó. Estos scripts usan `CREATE OR ALTER` y pueden volver a ejecutarse para actualizar las definiciones.

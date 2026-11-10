# Pixel Studio — Normalización (1FN, 2FN y 3FN)

## Caso inicial: registro sin normalizar

Supongamos una hoja donde cada fila almacena:

`id_reservacion, cliente_nombre, cliente_telefono, paquete_nombre, servicio_nombre, precio_paquete, equipos_usados ("Canon, flash, lente"), fotografias_entregadas ("foto1.jpg, foto2.jpg")`.

Problemas: hay campos con listas; los datos del cliente se repiten en cada reserva; modificar el teléfono requeriría cambiar muchas filas; los datos de paquetes se duplican; el control de equipos y fotos resulta difícil.

## 1FN: primera forma normal

Cada atributo contiene un solo valor del dominio, sin listas de equipos ni fotografías en una misma celda. Las asignaciones de equipos y los detalles de entrega se representan mediante filas separadas en `ASIGNACIONES_EQUIPO` y `DETALLE_ENTREGA`. Todas las tablas tienen claves primarias.

## 2FN: segunda forma normal

Además de 1FN, cada atributo no clave debe depender de **toda** la clave candidata relevante; no debe existir dependencia parcial de una clave compuesta.

Ejemplo hipotético de tabla incorrecta con clave `(id_sesion, id_equipo)`:

| id_sesion | id_equipo | nombre_equipo | fecha_inicio_sesion |
|---|---|---|---|
| 1 | 10 | Canon R | 2026-11-14 10:00 |

`nombre_equipo` depende solo de `id_equipo` y `fecha_inicio_sesion` depende solo de `id_sesion`. Separamos los datos en `EQUIPOS`, `SESIONES` y `ASIGNACIONES_EQUIPO` (que guarda únicamente la relación).

**Nota:** Si una tabla tiene clave primaria simple, no puede tener dependencias parciales respecto a esa clave; aun así debe cumplir la 1FN.

## 3FN: tercera forma normal

Además de 2FN, evitamos dependencias transitivas de atributos no clave respecto de una clave.

En una tabla de reservaciones incorrecta podríamos tener: `id_reservacion -> id_paquete -> nombre_paquete, precio, id_servicio -> nombre_servicio`. Los datos propios del paquete no deben repetirse en cada reservación. Los ubicamos en `PAQUETES`, y los del servicio en `SERVICIOS`.

De forma análoga, `id_reservacion -> id_cliente -> nombre_cliente, telefono` motiva guardar la información de contacto en `CLIENTES`.

## Decisiones y matices

- `RESERVACIONES.fecha_reservacion` y `hora_reservacion` representan **la fecha y hora solicitadas/contratadas**, mientras `SESIONES.fecha_inicio` y `fecha_fin` representan la **planificación efectiva**. Mantener ambas solo tiene sentido si documentamos y usamos esa diferencia.
- `PAQUETES.precio` representa el precio vigente del catálogo. Para preservar importes históricos cuando cambien los precios, conviene agregar `precio_pactado` a `RESERVACIONES` (es un hecho del contrato y no necesariamente duplicación indebida).
- Normalizar no equivale a prohibir todos los datos aparentemente repetidos: una copia histórica del precio pactado tiene justificación de negocio.
- La 3FN del diseño se justifica por las dependencias funcionales asumidas; debe revisarse si las reglas del negocio cambian.

## Evidencia del proyecto

El esquema físico y sus restricciones están en `02-tablas/01_crear_bd_tablas.sql`. Las consultas CRUD y validaciones se documentarán en fases posteriores.

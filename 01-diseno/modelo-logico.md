
# Pixel Studio — Modelo lógico

## Objetivo
Diseñar una base de datos relacional para gestionar
clientes, reservaciones, servicios y recursos de
un estudio fotográfico.

## Entidad: Clientes
- id_cliente (PK)
- nombre
- apellido_paterno
- apellido_materno
- telefono
- correo
- fecha_registro

## Entidad: Paquetes
- id_paquete (PK)
- id_servicio (FK)
- nombre
- precio

## Entidad: Reservaciones
- id_reservacion (PK)
- id_cliente (FK)
- id_paquete (FK)
- fecha_reservacion
- hora_reservacion
- estado
- observaciones

## Relaciones
- Clientes 1:N Reservaciones
- Paquetes 1:N Reservaciones
- Servicios 1:N Paquetes

## Reglas de negocio preliminares
1. Toda reservacion pertenece a un cliente.
2. Toda reservacion corresponde a un paquete.
3. Un cliente puede realizar varias reservaciones.
4. Un paquete puede aparecer en varias reservaciones.

## Pendiente
- Completar las entidades restantes.
- Definir restricciones y cardinalidad opcional.
- Diseñar el diagrama E-R completo.
- Validar la normalizacion.

# Pixel Studio — Modelo lógico

## Objetivo
Diseñar una base de datos relacional para gestionar
clientes, reservaciones, servicios y recursos de
un estudio fotográfico.

## Entidad: Clientes
- id_cliente (PK)
- nombre
- apellido_paterno
- apellido_materno
- telefono
- correo
- fecha_registro

## Entidad: Paquetes
- id_paquete (PK)
- id_servicio (FK)
- nombre
- precio

## Entidad: Reservaciones
- id_reservacion (PK)
- id_cliente (FK)
- id_paquete (FK)
- fecha_reservacion
- hora_reservacion
- estado
- observaciones

## Relaciones
- Clientes 1:N Reservaciones
- Paquetes 1:N Reservaciones
- Servicios 1:N Paquetes

## Reglas de negocio preliminares
1. Toda reservacion pertenece a un cliente.
2. Toda reservacion corresponde a un paquete.
3. Un cliente puede realizar varias reservaciones.
4. Un paquete puede aparecer en varias reservaciones.
5. Un servicio puede ofrecer varios paquetes.
6. Cada paquete pertenece a un único servicio.
7. Cada paquete tiene un identificador único.
8. Varios paquetes pueden compartir el mismo id_servicio.
9. El precio de un paquete debe ser mayor o igual a cero.
10. No puede registrarse un paquete asociado a un servicio inexistente.


## Relacion entre Reservaciones y Sesiones

Una reservacion puede existir sin una sesion asignada.

Cada sesion debe corresponder a una reservacion
existente.

Una reservacion puede generar como maximo una
sesion fotografica.

Cardinalidad:
- Reservaciones 1 : 0..1 Sesiones

Implementacion prevista:
- Sesiones.id_reservacion sera FOREIGN KEY.
- Sesiones.id_reservacion tendra UNIQUE.
- Sesiones.id_reservacion sera NOT NULL.

## Reglas adicionales

17. No se permite crear una sesion sin reservacion.
18. No se permite duplicar una sesion para la
    misma reservacion.
19. Una reservacion puede estar pendiente de
    asignacion de fotografo.


## Pendiente
- Completar las entidades restantes.
- Definir restricciones y cardinalidad opcional.
- Diseñar el diagrama E-R completo.
- Validar la normalizacion.

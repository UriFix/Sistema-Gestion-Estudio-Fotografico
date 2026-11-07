
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


## Pendiente
- Completar las entidades restantes.
- Definir restricciones y cardinalidad opcional.
- Diseñar el diagrama E-R completo.
- Validar la normalizacion.

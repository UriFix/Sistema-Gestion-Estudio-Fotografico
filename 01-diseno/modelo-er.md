# Pixel Studio — Modelo entidad-relación (versión 1)

## Alcance y decisiones

- Una reservación corresponde a un cliente y un paquete.
- Un servicio ofrece múltiples paquetes; cada paquete pertenece a un servicio.
- Una reservación puede existir sin sesión asignada, pero se permite **como máximo una sesión** por reservación.
- Cada sesión tiene un fotógrafo principal (empleado).
- Una reservación admite varios pagos.
- Una sesión puede usar varios equipos; cada equipo puede participar en muchas sesiones **si no coinciden los horarios**.
- Una sesión genera fotografías y puede tener varias entregas parciales.
- Una entrega puede incluir varias fotografías; una fotografía puede ser incluida en distintas entregas.

## Diagrama E-R (Mermaid)

```mermaid
erDiagram
    CLIENTES ||--o{ RESERVACIONES : realiza
    SERVICIOS ||--o{ PAQUETES : ofrece
    PAQUETES ||--o{ RESERVACIONES : contratado_en
    RESERVACIONES ||--o{ PAGOS : recibe
    RESERVACIONES ||--o| SESIONES : genera
    EMPLEADOS ||--o{ SESIONES : dirige
    SESIONES ||--o{ ASIGNACIONES_EQUIPO : requiere
    EQUIPOS ||--o{ ASIGNACIONES_EQUIPO : es_asignado
    SESIONES ||--o{ FOTOGRAFIAS : produce
    SESIONES ||--o{ ENTREGAS : tiene
    ENTREGAS ||--o{ DETALLE_ENTREGA : contiene
    FOTOGRAFIAS ||--o{ DETALLE_ENTREGA : se_incluye

    CLIENTES {
      int id_cliente PK
      nvarchar nombre
      nvarchar apellido_paterno
      nvarchar apellido_materno
      varchar telefono
      nvarchar correo
      datetime2 fecha_registro
    }
    SERVICIOS {
      int id_servicio PK
      nvarchar nombre
      nvarchar descripcion
      bit activo
    }
    PAQUETES {
      int id_paquete PK
      int id_servicio FK
      nvarchar nombre
      nvarchar descripcion
      decimal precio
      bit activo
    }
    RESERVACIONES {
      int id_reservacion PK
      int id_cliente FK
      int id_paquete FK
      date fecha_reservacion
      time hora_reservacion
      varchar estado
      nvarchar observaciones
    }
    EMPLEADOS {
      int id_empleado PK
      nvarchar nombre
      nvarchar apellido_paterno
      nvarchar apellido_materno
      varchar telefono
      varchar puesto
      date fecha_contratacion
      bit activo
    }
    SESIONES {
      int id_sesion PK
      int id_reservacion FK,UK
      int id_empleado FK
      datetime2 fecha_inicio
      datetime2 fecha_fin
      varchar estado
    }
    PAGOS {
      int id_pago PK
      int id_reservacion FK
      decimal monto
      datetime2 fecha_pago
      varchar metodo_pago
      varchar estado
    }
    EQUIPOS {
      int id_equipo PK
      nvarchar nombre
      nvarchar numero_serie UK
      varchar tipo
      varchar estado
    }
    ASIGNACIONES_EQUIPO {
      int id_asignacion PK
      int id_sesion FK
      int id_equipo FK
    }
    FOTOGRAFIAS {
      int id_fotografia PK
      int id_sesion FK
      nvarchar nombre_archivo
      nvarchar ruta_archivo
      datetime2 fecha_captura
      varchar estado
    }
    ENTREGAS {
      int id_entrega PK
      int id_sesion FK
      datetime2 fecha_entrega
      varchar metodo_entrega
      varchar estado
    }
    DETALLE_ENTREGA {
      int id_detalle PK
      int id_entrega FK
      int id_fotografia FK
    }
```

> `UK` indica clave única. La etiqueta FK,UK en `id_reservacion` significa que ese campo es a la vez clave foránea y única. En la tabla física los tipos incluyen longitudes, precisión y restricciones.

## Restricciones de negocio pendientes de implementación avanzada

1. Dos sesiones activas asignadas al mismo fotógrafo no pueden solaparse (validación transaccional).
2. Un equipo no puede estar asignado a sesiones activas con horarios superpuestos (validación transaccional).
3. Una fotografía agregada a una entrega debe pertenecer a la misma sesión que la entrega (validación entre tablas).
4. No permitir pagos que excedan el saldo contratado, si el negocio así lo define.
5. Una sesión solamente puede asignarse a empleados habilitados como fotógrafos.

Estas reglas requieren lógica entre filas o entre tablas; no quedan resueltas únicamente por las restricciones CHECK de la fase inicial.

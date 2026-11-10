/* Pixel Studio — SQL Server 2022; esquema inicial de 12 tablas.
   Ejecutar en una instancia de práctica con permisos CREATE DATABASE.
   No ejecuta DROP; si la base ya existe, revisa el estado antes de continuar.
*/
IF DB_ID(N'PixelStudio') IS NULL
    CREATE DATABASE PixelStudio;
GO
USE PixelStudio;
GO

CREATE TABLE dbo.Clientes (
    id_cliente INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Clientes PRIMARY KEY,
    nombre NVARCHAR(80) NOT NULL,
    apellido_paterno NVARCHAR(80) NOT NULL,
    apellido_materno NVARCHAR(80) NULL,
    telefono VARCHAR(20) NOT NULL,
    correo NVARCHAR(150) NULL,
    fecha_registro DATETIME2(0) NOT NULL CONSTRAINT DF_Clientes_Fecha DEFAULT SYSDATETIME()
);
GO
CREATE TABLE dbo.Servicios (
    id_servicio INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Servicios PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(500) NULL,
    activo BIT NOT NULL CONSTRAINT DF_Servicios_Activo DEFAULT (1),
    CONSTRAINT UQ_Servicios_Nombre UNIQUE (nombre)
);
GO
CREATE TABLE dbo.Paquetes (
    id_paquete INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Paquetes PRIMARY KEY,
    id_servicio INT NOT NULL,
    nombre NVARCHAR(120) NOT NULL,
    descripcion NVARCHAR(500) NULL,
    precio DECIMAL(10,2) NOT NULL,
    activo BIT NOT NULL CONSTRAINT DF_Paquetes_Activo DEFAULT (1),
    CONSTRAINT FK_Paquetes_Servicios FOREIGN KEY (id_servicio) REFERENCES dbo.Servicios(id_servicio),
    CONSTRAINT CK_Paquetes_Precio CHECK (precio >= 0),
    CONSTRAINT UQ_Paquetes_ServicioNombre UNIQUE(id_servicio, nombre)
);
GO
CREATE TABLE dbo.Empleados (
    id_empleado INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Empleados PRIMARY KEY,
    nombre NVARCHAR(80) NOT NULL,
    apellido_paterno NVARCHAR(80) NOT NULL,
    apellido_materno NVARCHAR(80) NULL,
    telefono VARCHAR(20) NULL,
    puesto VARCHAR(30) NOT NULL,
    fecha_contratacion DATE NOT NULL,
    activo BIT NOT NULL CONSTRAINT DF_Empleados_Activo DEFAULT (1),
    CONSTRAINT CK_Empleados_Puesto CHECK (puesto IN ('Fotografo','Editor','Administrativo'))
);
GO
CREATE TABLE dbo.Equipos (
    id_equipo INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Equipos PRIMARY KEY,
    nombre NVARCHAR(120) NOT NULL,
    numero_serie NVARCHAR(100) NULL,
    tipo VARCHAR(30) NOT NULL,
    estado VARCHAR(20) NOT NULL CONSTRAINT DF_Equipos_Estado DEFAULT ('Disponible'),
    CONSTRAINT CK_Equipos_Estado CHECK (estado IN ('Disponible','Mantenimiento','Baja'))
);
GO
CREATE UNIQUE INDEX UX_Equipos_NumeroSerie ON dbo.Equipos(numero_serie) WHERE numero_serie IS NOT NULL;
GO
CREATE TABLE dbo.Reservaciones (
    id_reservacion INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Reservaciones PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_paquete INT NOT NULL,
    fecha_reservacion DATE NOT NULL,
    hora_reservacion TIME(0) NOT NULL,
    precio_pactado DECIMAL(10,2) NOT NULL,
    estado VARCHAR(20) NOT NULL CONSTRAINT DF_Reservaciones_Estado DEFAULT ('Pendiente'),
    observaciones NVARCHAR(250) NULL,
    CONSTRAINT FK_Reservaciones_Clientes FOREIGN KEY (id_cliente) REFERENCES dbo.Clientes(id_cliente),
    CONSTRAINT FK_Reservaciones_Paquetes FOREIGN KEY (id_paquete) REFERENCES dbo.Paquetes(id_paquete),
    CONSTRAINT CK_Reservaciones_Precio CHECK (precio_pactado >= 0),
    CONSTRAINT CK_Reservaciones_Estado CHECK (estado IN ('Pendiente','Confirmada','Cancelada','Completada'))
);
GO
CREATE TABLE dbo.Sesiones (
    id_sesion INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Sesiones PRIMARY KEY,
    id_reservacion INT NOT NULL,
    id_empleado INT NOT NULL,
    fecha_inicio DATETIME2(0) NOT NULL,
    fecha_fin DATETIME2(0) NOT NULL,
    estado VARCHAR(20) NOT NULL CONSTRAINT DF_Sesiones_Estado DEFAULT ('Programada'),
    CONSTRAINT FK_Sesiones_Reservaciones FOREIGN KEY (id_reservacion) REFERENCES dbo.Reservaciones(id_reservacion),
    CONSTRAINT FK_Sesiones_Empleados FOREIGN KEY (id_empleado) REFERENCES dbo.Empleados(id_empleado),
    CONSTRAINT UQ_Sesiones_Reservacion UNIQUE (id_reservacion),
    CONSTRAINT CK_Sesiones_Fechas CHECK (fecha_fin > fecha_inicio),
    CONSTRAINT CK_Sesiones_Estado CHECK (estado IN ('Programada','Realizada','Cancelada'))
);
GO
CREATE TABLE dbo.Pagos (
    id_pago INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Pagos PRIMARY KEY,
    id_reservacion INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    fecha_pago DATETIME2(0) NOT NULL CONSTRAINT DF_Pagos_Fecha DEFAULT SYSDATETIME(),
    metodo_pago VARCHAR(20) NOT NULL,
    estado VARCHAR(20) NOT NULL CONSTRAINT DF_Pagos_Estado DEFAULT ('Aplicado'),
    CONSTRAINT FK_Pagos_Reservaciones FOREIGN KEY (id_reservacion) REFERENCES dbo.Reservaciones(id_reservacion),
    CONSTRAINT CK_Pagos_Monto CHECK (monto > 0),
    CONSTRAINT CK_Pagos_Metodo CHECK (metodo_pago IN ('Efectivo','Transferencia','Tarjeta')),
    CONSTRAINT CK_Pagos_Estado CHECK (estado IN ('Aplicado','Reembolsado'))
);
GO
CREATE TABLE dbo.AsignacionesEquipo (
    id_asignacion INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_AsignacionesEquipo PRIMARY KEY,
    id_sesion INT NOT NULL,
    id_equipo INT NOT NULL,
    CONSTRAINT FK_AsignacionesEquipo_Sesiones FOREIGN KEY (id_sesion) REFERENCES dbo.Sesiones(id_sesion),
    CONSTRAINT FK_AsignacionesEquipo_Equipos FOREIGN KEY (id_equipo) REFERENCES dbo.Equipos(id_equipo),
    CONSTRAINT UQ_AsignacionesEquipo_Par UNIQUE (id_sesion, id_equipo)
);
GO
CREATE TABLE dbo.Fotografias (
    id_fotografia INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Fotografias PRIMARY KEY,
    id_sesion INT NOT NULL,
    nombre_archivo NVARCHAR(200) NOT NULL,
    ruta_archivo NVARCHAR(500) NOT NULL,
    fecha_captura DATETIME2(0) NULL,
    estado VARCHAR(20) NOT NULL CONSTRAINT DF_Fotografias_Estado DEFAULT ('Original'),
    CONSTRAINT FK_Fotografias_Sesiones FOREIGN KEY (id_sesion) REFERENCES dbo.Sesiones(id_sesion),
    CONSTRAINT CK_Fotografias_Estado CHECK (estado IN ('Original','Editada','Seleccionada')),
    CONSTRAINT UQ_Fotografias_SesionArchivo UNIQUE(id_sesion, nombre_archivo)
);
GO
CREATE TABLE dbo.Entregas (
    id_entrega INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Entregas PRIMARY KEY,
    id_sesion INT NOT NULL,
    fecha_entrega DATETIME2(0) NOT NULL CONSTRAINT DF_Entregas_Fecha DEFAULT SYSDATETIME(),
    metodo_entrega VARCHAR(20) NOT NULL,
    estado VARCHAR(20) NOT NULL CONSTRAINT DF_Entregas_Estado DEFAULT ('Pendiente'),
    CONSTRAINT FK_Entregas_Sesiones FOREIGN KEY (id_sesion) REFERENCES dbo.Sesiones(id_sesion),
    CONSTRAINT CK_Entregas_Metodo CHECK (metodo_entrega IN ('Digital','Fisica')),
    CONSTRAINT CK_Entregas_Estado CHECK (estado IN ('Pendiente','Entregada','Cancelada'))
);
GO
CREATE TABLE dbo.DetalleEntrega (
    id_detalle INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DetalleEntrega PRIMARY KEY,
    id_entrega INT NOT NULL,
    id_fotografia INT NOT NULL,
    CONSTRAINT FK_DetalleEntrega_Entregas FOREIGN KEY (id_entrega) REFERENCES dbo.Entregas(id_entrega),
    CONSTRAINT FK_DetalleEntrega_Fotografias FOREIGN KEY (id_fotografia) REFERENCES dbo.Fotografias(id_fotografia),
    CONSTRAINT UQ_DetalleEntrega_Par UNIQUE (id_entrega, id_fotografia)
);
GO

SELECT t.name AS tabla FROM sys.tables AS t WHERE t.is_ms_shipped = 0 ORDER BY t.name;
GO
/* REGLAS AÚN PENDIENTES: conflictos de fotógrafos/equipos, pertenencia
   de foto y entrega a la misma sesión, personal habilitado, etc.
   Se implementarán y probarán con SP/triggers y transacciones. */

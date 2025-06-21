USE master;
GO
-- Cierra todas las conexiones activas a la base de datos Com2900G17
ALTER DATABASE Com2900G17
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE; -- Cierra las conexiones inmediatamente

-- Espera un poco (opcional, pero puede ayudar si hay latencia)
WAITFOR DELAY '00:00:01';

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'Com2900G17')
BEGIN
	USE master;
    DROP DATABASE Com2900G17;
END
GO

CREATE DATABASE Com2900G17
COLLATE Modern_Spanish_CI_AS;
GO

USE Com2900G17;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'ddbba')
BEGIN
    EXEC('CREATE SCHEMA ddbba');
END
GO
--

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'catSocio')
BEGIN
CREATE TABLE ddbba.catSocio (
    codCat INT IDENTITY(1,1) PRIMARY KEY,
    nombreCat VARCHAR(50),
    descripcion VARCHAR(50),
    edad_desde INT,
    edad_hasta INT
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'actDeportiva')
BEGIN
CREATE TABLE ddbba.actDeportiva (
    codAct INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'tutor')
BEGIN
CREATE TABLE ddbba.tutor (
    idTutor INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    dni INT,
    email VARCHAR(50),
    parentesco VARCHAR(50)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'inscripcion')
BEGIN
CREATE TABLE ddbba.inscripcion (
    idInscripcion INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
    hora TIME
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'socio')
BEGIN
CREATE TABLE ddbba.socio (
    ID_socio INT IDENTITY(1,1) PRIMARY KEY,
    nroSocio CHAR(7) UNIQUE,
    dni INT UNIQUE,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    telContacto INT,
    email VARCHAR(50),
    fechaNac DATE,
    telEmergencia INT,
    nombreObraSoc VARCHAR(40),
    numeroObraSoc VARCHAR(20),
    telObraSoc CHAR(30),
    estado CHAR(1) CHECK(estado IN ('A','I')), --activo inactivo
    codCat INT,
	codTutor INT,
	codInscripcion INT,
	codGrupoFamiliar INT,
    CONSTRAINT FK_socio_codCat FOREIGN KEY (codCat) REFERENCES ddbba.catSocio(codCat),
	CONSTRAINT FK_socio_codTutor FOREIGN KEY (codTutor) REFERENCES ddbba.tutor(idTutor),
	CONSTRAINT FK_socio_codInscripcion FOREIGN KEY (codInscripcion) REFERENCES ddbba.inscripcion(idInscripcion),
	CONSTRAINT FK_socio_codGrupoFamiliar FOREIGN KEY (codGrupoFamiliar) REFERENCES ddbba.socio(ID_socio)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'Presentismo')
BEGIN
CREATE TABLE ddbba.Presentismo (
    fecha DATE,
    presentismo CHAR(1) CHECK(presentismo IN ('P','A','J')), --presente ausente ausente justificado
    socio INT,
    act INT,
    profesor VARCHAR(50),
	PRIMARY KEY (socio, act),
    CONSTRAINT FK_Presentismo_socio FOREIGN KEY (socio) REFERENCES ddbba.socio(ID_socio),
    CONSTRAINT FK_Presentismo_actividad FOREIGN KEY (act) REFERENCES ddbba.actDeportiva(codAct)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'CuotaCatSocio')
BEGIN
CREATE TABLE ddbba.CuotaCatSocio (
    idCuotaCatSocio INT IDENTITY(1,1) PRIMARY KEY,
    fechaVigenciaHasta DATE,
    categoria VARCHAR(6),
    costoMembresia DECIMAL(7,2),
    catSocio INT,
    CONSTRAINT FK_CuotaCatSocio_catSocio FOREIGN KEY (catSocio) REFERENCES ddbba.catSocio(codCat)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'CuotaActividad')
BEGIN
CREATE TABLE ddbba.CuotaActividad (
    idCuotaAct INT IDENTITY(1,1) PRIMARY KEY,
    fechaVigenciaHasta DATE,
    actividad VARCHAR(20),
    costoActividad DECIMAL(7,2),
    codAct INT,
    CONSTRAINT FK_CuotaActividad_codAct FOREIGN KEY (codAct) REFERENCES ddbba.actDeportiva(codAct)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'costoColonia')
BEGIN
CREATE TABLE ddbba.costoColonia (
    codCostoColonia INT IDENTITY(1,1) PRIMARY KEY,
    costo DECIMAL(8,2),
    fechaVigenciaHasta DATE
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'coloniaVerano')
BEGIN
CREATE TABLE ddbba.coloniaVerano (
    codColonia INT IDENTITY(1,1) PRIMARY KEY,
    fechaDesde DATE,
	FechaHasta DATE,
    socio INT,
    codCostoColonia INT,
    CONSTRAINT FK_coloniaVerano_socio FOREIGN KEY (socio) REFERENCES ddbba.socio(ID_socio),
    CONSTRAINT FK_coloniaVerano_costo FOREIGN KEY (codCostoColonia) REFERENCES ddbba.costoColonia(codCostoColonia)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'costoSUM')
BEGIN
CREATE TABLE ddbba.costoSUM (
    codCostoSUM INT IDENTITY(1,1) PRIMARY KEY,
    costo DECIMAL(8,2),
    fechaVigenciaHasta DATE
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'alquilerSUM')
BEGIN
CREATE TABLE ddbba.alquilerSUM (
    codAlquilerSum INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
    horario TIME,
    socio INT,
    codCostoSUM INT,
    CONSTRAINT FK_alquilerSUM_socio FOREIGN KEY (socio) REFERENCES ddbba.socio(ID_socio),
    CONSTRAINT FK_alquilerSUM_costo FOREIGN KEY (codCostoSUM) REFERENCES ddbba.costoSUM(codCostoSUM)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'costoIngresoPileta')
BEGIN
CREATE TABLE ddbba.costoIngresoPileta (
    codCostoIngreso INT IDENTITY(1,1) PRIMARY KEY,
    edad int,
    precio DECIMAL(7,2),
    fechaVigenteHasta DATE
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'invitado')
BEGIN
CREATE TABLE ddbba.invitado (
    codInvitado INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    fechaNac DATE,
    dni int,
    mail VARCHAR(50)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'ingresoPiletaInvitado')
BEGIN
CREATE TABLE ddbba.ingresoPiletaInvitado (
    codIngreso INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
    hora TIME,
    socioInvitador INT,
    codCostoIngreso INT,
    codInvitado INT,
    CONSTRAINT FK_ingreso_socio FOREIGN KEY (socioInvitador) REFERENCES ddbba.socio(ID_socio),
    CONSTRAINT FK_ingreso_costo FOREIGN KEY (codCostoIngreso) REFERENCES ddbba.costoIngresoPileta(codCostoIngreso),
    CONSTRAINT FK_ingreso_invitado FOREIGN KEY (codInvitado) REFERENCES ddbba.invitado(codInvitado)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'pagoFactura')
BEGIN
CREATE TABLE ddbba.pagoFactura (
    codPago INT IDENTITY(1,1) PRIMARY KEY,
    Fecha_Pago DATE,
    hora TIME,
    montoTotal DECIMAL(8,2),
	montoMedioPago DECIMAL(8,2),
    saldoFavorUsado DECIMAL(8,2),
    medioPago VARCHAR(30),
    estadoPago CHAR(1) CHECK(estadoPago IN ('P','R')), --P de pendiente y R de realizado
    codSocio INT,
    CONSTRAINT FK_pagoFactura_socio FOREIGN KEY (codSocio) REFERENCES ddbba.socio(ID_socio)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'facturaInvitado')
BEGIN
CREATE TABLE ddbba.facturaInvitado (
    codFactura INT IDENTITY(1,1) PRIMARY KEY,
    fechaEmision DATE,
    horaEmision TIME,
    codInvitado INT,
    codPago INT,
    CONSTRAINT FK_facturaInvitado_invitado FOREIGN KEY (codInvitado) REFERENCES ddbba.invitado(codInvitado),
    CONSTRAINT FK_facturaInvitado_pago FOREIGN KEY (codPago) REFERENCES ddbba.pagoFactura(codPago)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'cuenta')
BEGIN
CREATE TABLE ddbba.cuenta (
    codCuenta INT IDENTITY(1,1) PRIMARY KEY,
    saldoAFavor DECIMAL(8,2),
    socio INT,
    CONSTRAINT FK_cuenta_socio FOREIGN KEY (socio) REFERENCES ddbba.socio(ID_socio)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'detalleFactura')
BEGIN
CREATE TABLE ddbba.detalleFactura (
    codDetalleFac INT IDENTITY(1,1) PRIMARY KEY,
    concepto VARCHAR(50),
    monto DECIMAL(8,2),
    descuento DECIMAL(7,2),
    recargoMorosidad DECIMAL(7,2),
    codCostoPileta INT,
    idCuotaCatSocio INT,
    idCuotaAct INT,
    codCostoColonia INT,
    codCostoSUM INT,
    CONSTRAINT FK_detalle_costoPileta FOREIGN KEY (codCostoPileta) REFERENCES ddbba.costoIngresoPileta(codCostoIngreso),
    CONSTRAINT FK_detalle_cuotaCat FOREIGN KEY (idCuotaCatSocio) REFERENCES ddbba.CuotaCatSocio(idCuotaCatSocio),
    CONSTRAINT FK_detalle_cuotaAct FOREIGN KEY (idCuotaAct) REFERENCES ddbba.CuotaActividad(idCuotaAct),
    CONSTRAINT FK_detalle_costoColonia FOREIGN KEY (codCostoColonia) REFERENCES ddbba.costoColonia(codCostoColonia),
    CONSTRAINT FK_detalle_costoSUM FOREIGN KEY (codCostoSUM) REFERENCES ddbba.costoSUM(codCostoSUM)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'pagCuenta')
BEGIN
CREATE TABLE ddbba.pagoCuenta (
    codPagoCuenta INT IDENTITY(1,1) PRIMARY KEY,
    monto DECIMAL(8,2),
    cuenta INT,
    detalleFactura INT,
    CONSTRAINT FK_pagoCuenta_cuenta FOREIGN KEY (cuenta) REFERENCES ddbba.cuenta(codCuenta),
	CONSTRAINT FK_pagoCuenta_detalleFactura FOREIGN KEY (detalleFactura) REFERENCES ddbba.detalleFactura(codDetalleFac)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'factura')
BEGIN
CREATE TABLE ddbba.factura (
    codFactura INT IDENTITY(1,1) PRIMARY KEY,
    fechaEmision DATE,
    mesFacturado INT,
    fechaVencimiento DATE,
    fecha2Vencimiento DATE,
    horaEmision TIME,
    totalNeto DECIMAL(8,2),
    estadoFactura CHAR(1) CHECK(estadoFactura IN ('P','I')),   --P de pago e I de impago
    codPago INT,
    codDetalleFac INT,
    ID_socio INT,
    CONSTRAINT FK_factura_pago FOREIGN KEY (codPago) REFERENCES ddbba.pagoFactura(codPago),
    CONSTRAINT FK_factura_detalle FOREIGN KEY (codDetalleFac) REFERENCES ddbba.detalleFactura(codDetalleFac),
    CONSTRAINT FK_factura_socio FOREIGN KEY (ID_socio) REFERENCES ddbba.socio(ID_socio)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'registroMoroso')
BEGIN
CREATE TABLE ddbba.registroMoroso (
    codMorosidad INT IDENTITY(1,1) PRIMARY KEY,
    montoAdeudado DECIMAL(8,2),
    fechaMorosidad DATE,
    mesAdeudado INT,
    mesAplicado INT,
    socio INT,
    codFactura INT,
    CONSTRAINT FK_morosidad_socio FOREIGN KEY (socio) REFERENCES ddbba.socio(ID_socio),
    CONSTRAINT FK_morosidad_factura FOREIGN KEY (codFactura) REFERENCES ddbba.factura(codFactura)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'pasePileta')
BEGIN
CREATE TABLE ddbba.pasePileta (
    codPase INT IDENTITY(1,1) PRIMARY KEY,
    tipo VARCHAR(10),
    fechaDesde DATE,
    fechaHasta DATE,
    idSocio INT,
    codCostoPileta INT,
    CONSTRAINT FK_pase_socio FOREIGN KEY (idSocio) REFERENCES ddbba.socio(ID_socio),
    CONSTRAINT FK_pase_costoPileta FOREIGN KEY (codCostoPileta) REFERENCES ddbba.costoIngresoPileta(codCostoIngreso)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'ddbba' AND TABLE_NAME =
'acceden')
BEGIN
CREATE TABLE ddbba.acceden (
    codCat INT,
    codAct INT,
    PRIMARY KEY (codCat, codAct),
    CONSTRAINT FK_acceden_cat FOREIGN KEY (codCat) REFERENCES ddbba.catSocio(codCat),
    CONSTRAINT FK_acceden_act FOREIGN KEY (codAct) REFERENCES ddbba.actDeportiva(codAct)
);
END
GO

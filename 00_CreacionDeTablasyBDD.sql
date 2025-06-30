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

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'tesoreria')
BEGIN
    EXEC('CREATE SCHEMA tesoreria');
END
GO
/*IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'ddbba')--DEFAULT
BEGIN
    EXEC('CREATE SCHEMA ddbba');
END
GO*/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'socio')
BEGIN
    EXEC('CREATE SCHEMA socio');
END
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'importaciones')
BEGIN
    EXEC('CREATE SCHEMA importaciones');
END
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'reportes')
BEGIN
    EXEC('CREATE SCHEMA reportes');
END
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'club')
BEGIN
    EXEC('CREATE SCHEMA club');
END
GO
--

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'club' AND TABLE_NAME =
'catSocio')
BEGIN
CREATE TABLE club.catSocio (
    codCat INT IDENTITY(1,1) PRIMARY KEY,
    nombreCat VARCHAR(50),
    edad_desde INT,
    edad_hasta INT
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'club' AND TABLE_NAME =
'actDeportiva')
BEGIN
CREATE TABLE club.actDeportiva (
    codAct INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'socio' AND TABLE_NAME =
'tutor')
BEGIN
CREATE TABLE socio.tutor (
    idTutor INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    dni CHAR(8) UNIQUE,
    email VARCHAR(50),
    parentesco VARCHAR(50)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'socio' AND TABLE_NAME =
'inscripcion')
BEGIN
CREATE TABLE socio.inscripcion (
    idInscripcion INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
    hora TIME
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'socio' AND TABLE_NAME =
'socio')
BEGIN
CREATE TABLE socio.socio (
    ID_socio INT IDENTITY(1,1) PRIMARY KEY,
    nroSocio CHAR(7) UNIQUE,
    dni CHAR(8) UNIQUE,
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
    CONSTRAINT FK_socio_codCat FOREIGN KEY (codCat) REFERENCES club.catSocio(codCat),
	CONSTRAINT FK_socio_codTutor FOREIGN KEY (codTutor) REFERENCES socio.tutor(idTutor),
	CONSTRAINT FK_socio_codInscripcion FOREIGN KEY (codInscripcion) REFERENCES socio.inscripcion(idInscripcion),
	CONSTRAINT FK_socio_codGrupoFamiliar FOREIGN KEY (codGrupoFamiliar) REFERENCES socio.socio(ID_socio)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'club' AND TABLE_NAME =
'Presentismo')
BEGIN
CREATE TABLE club.Presentismo (
    fecha DATE,
    presentismo CHAR(1) CHECK(presentismo IN ('P','A','J')), --presente ausente ausente justificado
    socio INT,
    act INT,
    profesor VARCHAR(50),
	PRIMARY KEY (socio, act, fecha),
    CONSTRAINT FK_Presentismo_socio FOREIGN KEY (socio) REFERENCES socio.socio(ID_socio),
    CONSTRAINT FK_Presentismo_actividad FOREIGN KEY (act) REFERENCES club.actDeportiva(codAct)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'club' AND TABLE_NAME =
'TarifarioCatSocio')
BEGIN
CREATE TABLE club.TarifarioCatSocio (
    idCuotaCatSocio INT IDENTITY(1,1) PRIMARY KEY,
    fechaVigenciaHasta DATE,
    categoria VARCHAR(6),
    costoMembresia DECIMAL(7,2),
    catSocio INT,
    CONSTRAINT FK_TarifarioCatSocio_catSocio FOREIGN KEY (catSocio) REFERENCES club.catSocio(codCat)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'club' AND TABLE_NAME =
'TarifarioActividad')
BEGIN
CREATE TABLE club.TarifarioActividad (
    idCuotaAct INT IDENTITY(1,1) PRIMARY KEY,
    fechaVigenciaHasta DATE,
    actividad VARCHAR(20),
    costoActividad DECIMAL(7,2),
    codAct INT,
    CONSTRAINT FK_TarifarioActividad_codAct FOREIGN KEY (codAct) REFERENCES club.actDeportiva(codAct)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'club' AND TABLE_NAME =
'costoColonia')
BEGIN
CREATE TABLE club.costoColonia (
    codCostoColonia INT IDENTITY(1,1) PRIMARY KEY,
    costo DECIMAL(8,2),
    fechaVigenciaHasta DATE
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'club' AND TABLE_NAME =
'coloniaVerano')
BEGIN
CREATE TABLE club.coloniaVerano (
    codColonia INT IDENTITY(1,1) PRIMARY KEY,
    fechaDesde DATE,
	FechaHasta DATE,
    socio INT,
    codCostoColonia INT,
    CONSTRAINT FK_coloniaVerano_socio FOREIGN KEY (socio) REFERENCES socio.socio(ID_socio),
    CONSTRAINT FK_coloniaVerano_costo FOREIGN KEY (codCostoColonia) REFERENCES club.costoColonia(codCostoColonia)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'club' AND TABLE_NAME =
'costoSUM')
BEGIN
CREATE TABLE club.costoSUM (
    codCostoSUM INT IDENTITY(1,1) PRIMARY KEY,
    costo DECIMAL(8,2),
    fechaVigenciaHasta DATE
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'club' AND TABLE_NAME =
'alquilerSUM')
BEGIN
CREATE TABLE club.alquilerSUM (
    codAlquilerSum INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
    horario TIME,
    socio INT,
    codCostoSUM INT,
    CONSTRAINT FK_alquilerSUM_socio FOREIGN KEY (socio) REFERENCES socio.socio(ID_socio),
    CONSTRAINT FK_alquilerSUM_costo FOREIGN KEY (codCostoSUM) REFERENCES club.costoSUM(codCostoSUM)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'club' AND TABLE_NAME =
'costoPiletaInvitado')
BEGIN
CREATE TABLE club.costoPiletaInvitado (
    codCostoIngreso INT IDENTITY(1,1) PRIMARY KEY,
    edad VARCHAR(6),
    precio DECIMAL(7,2),
    fechaVigenteHasta DATE
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'club' AND TABLE_NAME =
'invitado')
BEGIN
CREATE TABLE club.invitado (
    codInvitado INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    fechaNac DATE,
    dni CHAR(8) UNIQUE,
    mail VARCHAR(50)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'club' AND TABLE_NAME =
'ingresoPiletaInvitado')
BEGIN
CREATE TABLE club.ingresoPiletaInvitado (
    codIngreso INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
    socioInvitador INT,
    codCostoIngreso INT,
    codInvitado INT,
    CONSTRAINT FK_ingreso_socio FOREIGN KEY (socioInvitador) REFERENCES socio.socio(ID_socio),
    CONSTRAINT FK_ingreso_costo FOREIGN KEY (codCostoIngreso) REFERENCES club.costoPiletaInvitado(codCostoIngreso),
    CONSTRAINT FK_ingreso_invitado FOREIGN KEY (codInvitado) REFERENCES club.invitado(codInvitado)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'tesoreria' AND TABLE_NAME =
'pagoFactura')
BEGIN
CREATE TABLE tesoreria.pagoFactura (
	codPago INT IDENTITY (1,1) PRIMARY KEY,
    idPago CHAR(12),
    Fecha_Pago DATE,
    montoTotal DECIMAL(8,2),
	montoMedioPago DECIMAL(8,2),
    saldoFavorUsado DECIMAL(8,2),
    medioPago VARCHAR(30),
    estadoPago CHAR(1) CHECK(estadoPago IN ('P','R')), --P de pendiente y R de realizado
    codSocio INT,
    CONSTRAINT FK_pagoFactura_socio FOREIGN KEY (codSocio) REFERENCES socio.socio(ID_socio)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'tesoreria' AND TABLE_NAME =
'facturaInvitado')
BEGIN
CREATE TABLE tesoreria.facturaInvitado (
    codFactura INT IDENTITY(1,1) PRIMARY KEY,
    fechaEmision DATE,
    codInvitado INT,
    idPago INT,
	monto DECIMAL (8,2),
    CONSTRAINT FK_facturaInvitado_invitado FOREIGN KEY (codInvitado) REFERENCES club.invitado(codInvitado),
    CONSTRAINT FK_facturaInvitado_pago FOREIGN KEY (idPago) REFERENCES tesoreria.pagoFactura(codPago)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'socio' AND TABLE_NAME =
'cuenta')
BEGIN
CREATE TABLE socio.cuenta (
    codCuenta INT IDENTITY(1,1) PRIMARY KEY,
    saldoAFavor DECIMAL(8,2),
    socio INT,
    CONSTRAINT FK_cuenta_socio FOREIGN KEY (socio) REFERENCES socio.socio(ID_socio)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'tesoreria' AND TABLE_NAME =
'factura')
BEGIN
CREATE TABLE tesoreria.factura (
    codFactura INT IDENTITY(1,1) PRIMARY KEY,
    fechaEmision DATE,
    mesFacturado INT,
    fechaVencimiento DATE,
    fecha2Vencimiento DATE,
    totalNeto DECIMAL(9,2),
    estadoFactura CHAR(1) CHECK(estadoFactura IN ('P','I')),   --P de pago e I de impago
    idPago INT,
    ID_socio INT,
    CONSTRAINT FK_factura_pago FOREIGN KEY (idPago) REFERENCES tesoreria.pagoFactura(codPago),
    CONSTRAINT FK_factura_socio FOREIGN KEY (ID_socio) REFERENCES socio.socio(ID_socio)
);
END
GO

IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'club' AND TABLE_NAME = 'costoPileta'
)
BEGIN
    CREATE TABLE club.costoPileta (
        codCostoPileta INT IDENTITY(1,1) PRIMARY KEY,
        costo DECIMAL(10,2),
        tipo VARCHAR(9),
        categoria VARCHAR(6), 
        fechaVigenciaHasta DATE
    );
END;
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'tesoreria' AND TABLE_NAME =
'detalleFactura')
BEGIN
CREATE TABLE tesoreria.detalleFactura (
    codDetalleFac INT IDENTITY(1,1) PRIMARY KEY,
	codFactura INT,
	ID_socio INT,
    concepto VARCHAR(100),
    monto DECIMAL(8,2),
    descuento DECIMAL(7,2),
    recargoMorosidad DECIMAL(7,2),
	CONSTRAINT FK_detalle_factura FOREIGN KEY (codFactura) REFERENCES tesoreria.factura(codFactura),
	CONSTRAINT FK_detalleFactura_socio FOREIGN KEY (ID_socio) REFERENCES socio.socio(ID_socio)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'tesoreria' AND TABLE_NAME =
'pagoCuenta')
BEGIN
CREATE TABLE tesoreria.pagoCuenta (
    codPagoCuenta INT IDENTITY(1,1) PRIMARY KEY,
    monto DECIMAL(8,2),
    cuenta INT,
    detalleFactura INT,
    CONSTRAINT FK_pagoCuenta_cuenta FOREIGN KEY (cuenta) REFERENCES socio.cuenta(codCuenta),
	CONSTRAINT FK_pagoCuenta_detalleFactura FOREIGN KEY (detalleFactura) REFERENCES tesoreria.detalleFactura(codDetalleFac)
);
END
GO


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'tesoreria' AND TABLE_NAME =
'registroMoroso')
BEGIN
CREATE TABLE tesoreria.registroMoroso (
    codMorosidad INT IDENTITY(1,1) PRIMARY KEY,
    montoAdeudado DECIMAL(8,2),
    fechaMorosidad DATE,
    mesAdeudado INT,
    mesAplicado INT,
    socio INT,
    codFactura INT,
    CONSTRAINT FK_morosidad_socio FOREIGN KEY (socio) REFERENCES socio.socio(ID_socio),
    CONSTRAINT FK_morosidad_factura FOREIGN KEY (codFactura) REFERENCES tesoreria.factura(codFactura)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'club' AND TABLE_NAME =
'pasePileta')
BEGIN
CREATE TABLE club.pasePileta (
    codPase INT IDENTITY(1,1) PRIMARY KEY,
    tipo VARCHAR(10) CHECK (tipo IN ('día', 'mes', 'temporada')),
    fechaDesde DATE,
    fechaHasta DATE,
    idSocio INT,
    codCostoPileta INT,
    CONSTRAINT FK_pase_socio FOREIGN KEY (idSocio) REFERENCES socio.socio(ID_socio),
    CONSTRAINT FK_pase_costoPileta FOREIGN KEY (codCostoPileta) REFERENCES club.costoPileta(codCostoPileta)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'club' AND TABLE_NAME =
'acceden')
BEGIN
CREATE TABLE club.acceden (
    codCat INT,
    codAct INT,
    PRIMARY KEY (codCat, codAct),
    CONSTRAINT FK_acceden_cat FOREIGN KEY (codCat) REFERENCES club.catSocio(codCat),
    CONSTRAINT FK_acceden_act FOREIGN KEY (codAct) REFERENCES club.actDeportiva(codAct)
);
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'tesoreria' AND TABLE_NAME =
'cuotaMensualCategoria')
BEGIN
    CREATE TABLE tesoreria.cuotaMensualCategoria (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        ID_socio INT NOT NULL,
        codCat INT NOT NULL,
        precio_bruto DECIMAL(9,2) NOT NULL,
        descuento_aplicado DECIMAL(9,2) NOT NULL,
        fechaGeneracion DATE NOT NULL,
        CONSTRAINT FK_cuotaCategoria_socio FOREIGN KEY (ID_socio) REFERENCES socio.socio(ID_socio),
        CONSTRAINT FK_cuotaCategoria_categoria FOREIGN KEY (codCat) REFERENCES club.catSocio(codCat)
    );
END;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'tesoreria' AND TABLE_NAME =
'cuotaMensualActividad')
BEGIN
    CREATE TABLE tesoreria.cuotaMensualActividad (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        ID_socio INT NOT NULL,
        codAct INT NOT NULL,
        precio_bruto DECIMAL(9,2) NOT NULL,
        descuento_aplicado DECIMAL(9,2) NOT NULL,
        fechaGeneracion DATE NOT NULL,
        CONSTRAINT FK_cuotaActividad_socio FOREIGN KEY (ID_socio) REFERENCES socio.socio(ID_socio),
        CONSTRAINT FK_cuotaActividad_actividad FOREIGN KEY (codAct) REFERENCES club.actDeportiva(codAct)
    );
END;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA =
'tesoreria' AND TABLE_NAME =
'reembolso')
BEGIN
    CREATE TABLE tesoreria.reembolso (
        codReembolso INT IDENTITY(1,1) PRIMARY KEY,
		fecha DATE,
		monto DECIMAL (9,2),
		motivo VARCHAR (100),
        ID_socio INT,
        ID_pago INT,
        CONSTRAINT FK_reembolso_socio FOREIGN KEY (ID_socio) REFERENCES socio.socio(ID_socio),
        CONSTRAINT FK_reembolso_pago FOREIGN KEY (ID_pago) REFERENCES tesoreria.pagoFactura(codPago)
    );
END;
PRINT'Creación de base de datos, esquemas y tablas realizado'

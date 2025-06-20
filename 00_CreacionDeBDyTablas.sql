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

-----TABLAS----------

-- Tabla Socio
CREATE TABLE ddbba.Socio (
    ID_socio INT IDENTITY(1,1) PRIMARY KEY,
    nroSocio CHAR(7) UNIQUE,
    dni CHAR(9) NULL,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    telFijo CHAR(10) NULL,
    telEmergencia CHAR(10) NULL,
    email VARCHAR(50) NULL,
    fechaNac DATE,
    nombreObraSoc VARCHAR(40) NULL,
    numeroObraSoc VARCHAR(20) NULL,
    telObraSoc CHAR(30) NULL,
    saldoAFavor DECIMAL(8,2) NULL,
    saldoPendiente DECIMAL(8,2) NULL,
    estado CHAR(1) CHECK (estado IN ('A','I')) NULL
);
GO

-- Tabla CatSocio
CREATE TABLE ddbba.CatSocio (
    codCategoria INT IDENTITY(1,1) PRIMARY KEY,
    nombreCategoria VARCHAR(10),
    edadDesde INT,
    edadHasta INT
);
GO

-- Tabla actDeportiva
CREATE TABLE ddbba.actDeportiva (
    codActividad INT IDENTITY(1,1) PRIMARY KEY,
    nombreActividad VARCHAR(15)
);
GO

-- Tabla Inscripcion
CREATE TABLE ddbba.Inscripcion (
    idInscripcion INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
    hora TIME
);
GO

-- Tabla costoIngresoPileta
CREATE TABLE ddbba.costoIngresoPileta (
    CodCostoIngreso INT IDENTITY(1,1) PRIMARY KEY,
    edad CHAR(1) CHECK (edad IN ('A','M')),
    precioSocio DECIMAL(10,2),
    precioInvitado DECIMAL(10,2),
    vigencia DATE
);
GO

-- Tabla IngresoPiletaDiario
CREATE TABLE ddbba.IngresoPiletaDiario (
    codIngreso INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
    hora TIME,
    ID_socio INT,
    CodCostoIngreso INT,
    persona CHAR(1) CHECK (persona IN ('S','I')),
    CONSTRAINT FK_IngresoPiletaDiario_idsocio FOREIGN KEY (ID_socio) REFERENCES ddbba.Socio(ID_socio),
    CONSTRAINT FK_IngresoPiletaDiario_codcostoingreso FOREIGN KEY (CodCostoIngreso) REFERENCES ddbba.costoIngresoPileta(CodCostoIngreso)
);
GO

-- Tabla PagoaCuenta
CREATE TABLE ddbba.PagoaCuenta (
    codPagoCuenta INT IDENTITY(1,1) PRIMARY KEY,
    codIngreso INT,
    ID_socio INT,
    fecha DATE,
    hora TIME,
    monto DECIMAL(10,2),
    motivo VARCHAR(50),
    CONSTRAINT FK_PagoaCuenta_codingreso FOREIGN KEY (codIngreso) REFERENCES ddbba.IngresoPiletaDiario(codIngreso),
    CONSTRAINT FK_PagoaCuenta_idsocio FOREIGN KEY (ID_socio) REFERENCES ddbba.Socio(ID_socio)
);
GO

-- Tabla Invitado
CREATE TABLE ddbba.Invitado (
    codInvitado INT IDENTITY(1,1) PRIMARY KEY,
    codIngreso INT,
    nombre VARCHAR(30),
    apellido VARCHAR(30),
    fechaNac DATE,
    dni CHAR(8),
    direccion VARCHAR(50),
    email VARCHAR(50),
    CONSTRAINT FK_Invitado_codingreso FOREIGN KEY (codIngreso) REFERENCES ddbba.IngresoPiletaDiario(codIngreso)
);
GO

-- Tabla FacturaInvitado
CREATE TABLE ddbba.FacturaInvitado (
    codFactura INT IDENTITY(1,1) PRIMARY KEY,
    codInvitado INT,
    fechaEmision DATE,
    horaEmision TIME,
    totalNeto DECIMAL(10,2),
    CONSTRAINT FK_FacturaInvitado_codinvitado FOREIGN KEY (codInvitado) REFERENCES ddbba.Invitado(codInvitado)
);
GO

-- Tabla Presentismo
CREATE TABLE ddbba.Presentismo (
    codPresentismo INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
    presentismo CHAR(1),
    socio INT,
    act INT,
    profesor VARCHAR(30),
    CONSTRAINT FK_Presentismo_socio FOREIGN KEY (socio) REFERENCES ddbba.Socio(ID_socio),
    CONSTRAINT FK_Presentismo_actividad FOREIGN KEY (act) REFERENCES ddbba.actDeportiva(codActividad)
);
GO

-- Tabla GrupoFamiliar
CREATE TABLE ddbba.GrupoFamiliar (
    idRelacion INT IDENTITY(1,1) PRIMARY KEY,
	nroGrupo INT,
    socioMenor INT,
    responsableACargo INT,
    CONSTRAINT FK_GrupoFamiliar_socioMenor FOREIGN KEY (socioMenor) REFERENCES ddbba.Socio(ID_socio),
    CONSTRAINT FK_GrupoFamiliar_responsable FOREIGN KEY (responsableACargo) REFERENCES ddbba.Socio(ID_socio)
);
GO

-- Tabla Reembolso
CREATE TABLE ddbba.Reembolso (
    codReembolso INT PRIMARY KEY,
    fecha DATE,
    hora TIME,
    monto DECIMAL(8,2),
    motivo VARCHAR(50),
    ID_socio INT,
    CONSTRAINT FK_reembolso_socio FOREIGN KEY (ID_socio) REFERENCES ddbba.Socio(ID_socio)
);
GO




--ELIMINACION DE TABLAS EN ORDEN
-- Tablas dependientes (con FOREIGN KEYS hacia otras)
/*DROP TABLE IF EXISTS ddbba.FacturaInvitado;
DROP TABLE IF EXISTS ddbba.Invitado;
DROP TABLE IF EXISTS ddbba.PagoaCuenta;
DROP TABLE IF EXISTS ddbba.IngresoPiletaDiario;
DROP TABLE IF EXISTS ddbba.Presentismo;
DROP TABLE IF EXISTS ddbba.GrupoFamiliar;
DROP TABLE IF EXISTS ddbba.Reembolso;

-- Tablas base (referenciadas por otras)
DROP TABLE IF EXISTS ddbba.actDeportiva;
DROP TABLE IF EXISTS ddbba.Socio;
DROP TABLE IF EXISTS ddbba.CatSocio;
DROP TABLE IF EXISTS ddbba.costoIngresoPileta;
DROP TABLE IF EXISTS ddbba.Inscripcion;
*/


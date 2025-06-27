USE master
GO


--Logins
IF SUSER_ID(N'JefeTesoreria') IS NULL
BEGIN
    CREATE LOGIN Jefe_Tesoreria
		WITH PASSWORD = 'Millonario912',
		DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'AdministrativoCobranza') IS NULL
BEGIN
    CREATE LOGIN Administrativo_Cobranza
		WITH PASSWORD = 'Megustacobrar912',
		DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'AdministrativoMorosidad') IS NULL
BEGIN
    CREATE LOGIN Administrativo_Morosidad
        WITH PASSWORD = 'Moristeenmadrid9.12.18',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'AdministrativoFacturacion') IS NULL
BEGIN
    CREATE LOGIN Administrativo_Facturacion
        WITH PASSWORD = 'Sacandodelmedio31',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'AdministrativoSocio') IS NULL
BEGIN
    CREATE LOGIN Administrativo_Socio
        WITH PASSWORD = 'Labrunaeterno',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'Socios_Web') IS NULL
BEGIN
    CREATE LOGIN Socios_Web
        WITH PASSWORD = 'Ramondiaz1996',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'Presidente') IS NULL
BEGIN
    CREATE LOGIN Presidente
        WITH PASSWORD = 'j.milei10',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'Vicepresidente') IS NULL
BEGIN
    CREATE LOGIN Vicepresidente
        WITH PASSWORD = 'vickyvillaruel10',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'Secretario') IS NULL
BEGIN
    CREATE LOGIN Secretario
        WITH PASSWORD = 'tehizoungolunprofe',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'Vocales') IS NULL
BEGIN
    CREATE LOGIN Vocales
        WITH PASSWORD = 'Aguanteriver9.12',
        DEFAULT_DATABASE = Com2900G17;
END
GO

--Users
USE Com2900G17
GO

IF DATABASE_PRINCIPAL_ID('Jefe_Tesoreria') IS NULL
    CREATE USER user_Jefe_Tesoreria FOR LOGIN Jefe_Tesoreria WITH DEFAULT_SCHEMA = tesoreria;

IF DATABASE_PRINCIPAL_ID('Administrativo_Cobranza') IS NULL
    CREATE USER user_Administrativo_Cobranza FOR LOGIN Administrativo_Cobranza WITH DEFAULT_SCHEMA = tesoreria;

IF DATABASE_PRINCIPAL_ID('Administrativo_Morosidad') IS NULL
    CREATE USER user_Administrativo_Morosidad FOR LOGIN Administrativo_Morosidad WITH DEFAULT_SCHEMA = tesoreria;

IF DATABASE_PRINCIPAL_ID('Administrativo_Facturacion') IS NULL
    CREATE USER user_Administrativo_Facturacion FOR LOGIN Administrativo_Facturacion WITH DEFAULT_SCHEMA = tesoreria;
	
IF DATABASE_PRINCIPAL_ID('Administrativo_Socio') IS NULL
    CREATE USER user_Administrativo_Socio FOR LOGIN Administrativo_Socio WITH DEFAULT_SCHEMA = socios;

IF DATABASE_PRINCIPAL_ID('Socios_Web') IS NULL
    CREATE USER user_Socios_Web FOR LOGIN Socios_Web WITH DEFAULT_SCHEMA = socios;

IF DATABASE_PRINCIPAL_ID('Presidente') IS NULL
    CREATE USER user_Presidente FOR LOGIN Presidente WITH DEFAULT_SCHEMA = autoridades;

IF DATABASE_PRINCIPAL_ID('Vicepresidente') IS NULL
    CREATE USER user_Vicepresidente FOR LOGIN Vicepresidente WITH DEFAULT_SCHEMA = autoridades;

IF DATABASE_PRINCIPAL_ID('Secretario') IS NULL
    CREATE USER user_Secretario FOR LOGIN Secretario WITH DEFAULT_SCHEMA = autoridades;

IF DATABASE_PRINCIPAL_ID('user_Vocales') IS NULL
    CREATE USER user_Vocales FOR LOGIN Vocales WITH DEFAULT_SCHEMA = autoridades;
GO

--Roles
IF DATABASE_PRINCIPAL_ID('rol_Jefe_Tesoreria') IS NULL
    CREATE ROLE rol_Jefe_Tesoreria AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Administrativo_Cobranza') IS NULL
    CREATE ROLE rol_Administrativo_Cobranza AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Administrativo_Morosidad') IS NULL
    CREATE ROLE rol_Administrativo_Morosidad AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Administrativo_Facturacion') IS NULL
    CREATE ROLE rol_Administrativo_Facturacion AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Administrativo_Socio') IS NULL
    CREATE ROLE rol_Administrativo_Socio AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Socios_Web') IS NULL
    CREATE ROLE rol_Socios_Web AUTHORIZATION Administrativo_Socio;

IF DATABASE_PRINCIPAL_ID('rol_Presidente') IS NULL
    CREATE ROLE rol_Presidente AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Vicepresidente') IS NULL
    CREATE ROLE rol_Vicepresidente AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Secretario') IS NULL
    CREATE ROLE rol_Secretario AUTHORIZATION dbo;

IF DATABASE_PRINCIPAL_ID('rol_Vocales') IS NULL
    CREATE ROLE rol_Vocales AUTHORIZATION dbo;
GO

--Asignar roles
-- ALTER ROLE [nombre_rol] ADD MEMBER [nombre_usuario];
ALTER ROLE rol_Jefe_Tesoreria ADD MEMBER user_Jefe_Tesoreria;
ALTER ROLE rol_Administrativo_Cobranza ADD MEMBER user_Administrativo_Cobranza;
ALTER ROLE rol_Administrativo_Morosidad ADD MEMBER user_Administrativo_Morosidad;
ALTER ROLE rol_Administrativo_Facturacion ADD MEMBER user_Administrativo_Facturacion;
ALTER ROLE rol_Administrativo_Socio ADD MEMBER user_Administrativo_Facturacion;
ALTER ROLE rol_Socios_Web ADD MEMBER user_Socios_Web;
ALTER ROLE rol_Presidente ADD MEMBER user_Presidente;
ALTER ROLE rol_Vicepresidente ADD MEMBER user_Vicepresidente;
ALTER ROLE rol_Secretario ADD MEMBER user_Secretario;
ALTER ROLE rol_Vocales ADD MEMBER user_Vocales;
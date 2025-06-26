USE master
GO
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
    CREATE LOGIN login_Vicepresidente
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

-- creacion user
USE Com2900G17
GO

IF DATABASE_PRINCIPAL_ID('Jefe_Tesoreria') IS NULL
    CREATE USER Jefe_Tesoreria FOR LOGIN Jefe_Tesoreria WITH DEFAULT_SCHEMA = tesoreria;

IF DATABASE_PRINCIPAL_ID('Administrativo_Cobranza') IS NULL
    CREATE USER Administrativo_Cobranza FOR LOGIN Administrativo_Cobranza WITH DEFAULT_SCHEMA = tesoreria;

IF DATABASE_PRINCIPAL_ID('Administrativo_Morosidad') IS NULL
    CREATE USER Administrativo_Morosidad FOR LOGIN Administrativo_Morosidad WITH DEFAULT_SCHEMA = tesoreria;

IF DATABASE_PRINCIPAL_ID('Administrativo_Facturacion') IS NULL
    CREATE USER Administrativo_Facturacion FOR LOGIN Administrativo_Facturacion WITH DEFAULT_SCHEMA = tesoreria;
	
IF DATABASE_PRINCIPAL_ID('Administrativo_Socio') IS NULL
    CREATE USER Administrativo_Socio FOR LOGIN Administrativo_Socio WITH DEFAULT_SCHEMA = socios;

IF DATABASE_PRINCIPAL_ID('Socios_Web') IS NULL
    CREATE USER Socios_Web FOR LOGIN Socios_Web WITH DEFAULT_SCHEMA = socios;

IF DATABASE_PRINCIPAL_ID('Presidente') IS NULL
    CREATE USER Presidente FOR LOGIN Presidente WITH DEFAULT_SCHEMA = autoridades;

IF DATABASE_PRINCIPAL_ID('Vicepresidente') IS NULL
    CREATE USER Vicepresidente FOR LOGIN Vicepresidente WITH DEFAULT_SCHEMA = autoridades;

IF DATABASE_PRINCIPAL_ID('Secretario') IS NULL
    CREATE USER Secretario FOR LOGIN Secretario WITH DEFAULT_SCHEMA = autoridades;

IF DATABASE_PRINCIPAL_ID('user_Vocales') IS NULL
    CREATE USER Vocales FOR LOGIN Vocales WITH DEFAULT_SCHEMA = autoridades;
GO


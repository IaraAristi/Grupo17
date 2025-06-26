USE master
GO
IF SUSER_ID(N'login_JefeTesoreria') IS NULL
BEGIN
    CREATE LOGIN login_Jefe_Tesoreria
		WITH PASSWORD = 'Millonario912',
		DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'login_AdministrativoCobranza') IS NULL
BEGIN
    CREATE LOGIN login_Administrativo_Cobranza
		WITH PASSWORD = 'Megustacobrar912',
		DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'login_AdministrativoMorosidad') IS NULL
BEGIN
    CREATE LOGIN login_Administrativo_Morosidad
        WITH PASSWORD = 'Moristeenmadrid9.12.18',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'login_AdministrativoFacturacion') IS NULL
BEGIN
    CREATE LOGIN login_Administrativo_Facturacion
        WITH PASSWORD = 'Sacandodelmedio31',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'login_AdministrativoSocio') IS NULL
BEGIN
    CREATE LOGIN login_Administrativo_Socio
        WITH PASSWORD = 'Labrunaeterno',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'login_Socios_Web') IS NULL
BEGIN
    CREATE LOGIN login_Socios_Web
        WITH PASSWORD = 'Ramondiaz1996',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'login_Presidente') IS NULL
BEGIN
    CREATE LOGIN login_Presidente
        WITH PASSWORD = 'j.milei10',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'login_Vicepresidente') IS NULL
BEGIN
    CREATE LOGIN login_Vicepresidente
        WITH PASSWORD = 'vickyvillaruel10',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'login_Secretario') IS NULL
BEGIN
    CREATE LOGIN login_Secretario
        WITH PASSWORD = 'tehizoungolunprofe',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'login_Vocales') IS NULL
BEGIN
    CREATE LOGIN login_Vocales
        WITH PASSWORD = 'Aguanteriver9.12',
        DEFAULT_DATABASE = Com2900G17;
END
GO

-- creacion user
USE Com2900G17
GO

IF DATABASE_PRINCIPAL_ID('user_Jefe_Tesoreria') IS NULL
    CREATE USER user_Jefe_Tesoreria FOR LOGIN login_Jefe_Tesoreria WITH DEFAULT_SCHEMA = tesoreria;

IF DATABASE_PRINCIPAL_ID('user_Administrativo_Cobranza') IS NULL
    CREATE USER user_Administrativo_Cobranza FOR LOGIN login_Administrativo_Cobranza WITH DEFAULT_SCHEMA = tesoreria;

IF DATABASE_PRINCIPAL_ID('user_Administrativo_Morosidad') IS NULL
    CREATE USER user_Administrativo_Morosidad FOR LOGIN login_Administrativo_Morosidad WITH DEFAULT_SCHEMA = tesoreria;

IF DATABASE_PRINCIPAL_ID('user_Administrativo_Facturacion') IS NULL
    CREATE USER user_Administrativo_Facturacion FOR LOGIN login_Administrativo_Facturacion WITH DEFAULT_SCHEMA = tesoreria;
	
IF DATABASE_PRINCIPAL_ID('user_Administrativo_Socio') IS NULL
    CREATE USER user_Administrativo_Socio FOR LOGIN login_Administrativo_Socio WITH DEFAULT_SCHEMA = socios;

IF DATABASE_PRINCIPAL_ID('user_Socios_Web') IS NULL
    CREATE USER user_Socios_Web FOR LOGIN login_Socios_Web WITH DEFAULT_SCHEMA = socios;

IF DATABASE_PRINCIPAL_ID('user_Presidente') IS NULL
    CREATE USER user_Presidente FOR LOGIN login_Presidente WITH DEFAULT_SCHEMA = autoridades;

IF DATABASE_PRINCIPAL_ID('user_Vicepresidente') IS NULL
    CREATE USER user_Vicepresidente FOR LOGIN login_Vicepresidente WITH DEFAULT_SCHEMA = autoridades;

IF DATABASE_PRINCIPAL_ID('user_Secretario') IS NULL
    CREATE USER user_Secretario FOR LOGIN login_Secretario WITH DEFAULT_SCHEMA = autoridades;

IF DATABASE_PRINCIPAL_ID('user_Vocales') IS NULL
    CREATE USER user_Vocales FOR LOGIN login_Vocales WITH DEFAULT_SCHEMA = autoridades;
GO

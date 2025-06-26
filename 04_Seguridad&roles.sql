USE master
GO
IF SUSER_ID(N'login_Jefe_Tesoreria') IS NULL
BEGIN
    CREATE LOGIN login_Jefe_Tesoreria
		WITH PASSWORD = 'Millonario912',
		DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'login_Administrativo_Cobranza') IS NULL
BEGIN
    CREATE LOGIN login_Administrativo_Cobranza
		WITH PASSWORD = 'Julianyenzo',
		DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'login_Administrativo_Cobranza') IS NULL
BEGIN
    CREATE LOGIN login_Administrativo_Cobranza
		WITH PASSWORD = 'Megustacobrar912',
		DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'login_Administrativo_Morosidad') IS NULL
BEGIN
    CREATE LOGIN login_Administrativo_Morosidad
        WITH PASSWORD = 'Moristeenmadrid9.12.18',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'login_Administrativo_Facturacion') IS NULL
BEGIN
    CREATE LOGIN login_Administrativo_Facturacion
        WITH PASSWORD = 'Sacandodelmedio31',
        DEFAULT_DATABASE = Com2900G17;
END
GO

IF SUSER_ID(N'login_Administrativo_Socio') IS NULL
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

IF SUSER_ID(N'login_Vocal') IS NULL
BEGIN
    CREATE LOGIN login_Vocal
        WITH PASSWORD = 'Aguanteriver9.12',
        DEFAULT_DATABASE = Com2900G17;
END
GO
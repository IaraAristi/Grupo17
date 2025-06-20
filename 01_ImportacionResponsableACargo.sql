--importacion de responsables a cargo
USE Com2900G17
GO
CREATE OR ALTER PROCEDURE ddbba.sp_ImportarSociosRP
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    -- Eliminar la tabla temporal si existe
    IF OBJECT_ID('tempdb..#sociorp_temporal') IS NOT NULL
        DROP TABLE #sociorp_temporal;

    -- Crear tabla temporal con las columnas necesarias
    CREATE TABLE #sociorp_temporal (
        [Nro de Socio] VARCHAR(50),
        [Nombre] VARCHAR(100),
        [ apellido] VARCHAR(100),
        [ DNI] VARCHAR(20),
        [ email personal] VARCHAR(150),
        [ fecha de nacimiento] VARCHAR(30),
        [ teléfono de contacto] VARCHAR(30),
        [ teléfono de contacto emergencia] VARCHAR(30),
        [ Nombre de la obra social o prepaga] VARCHAR(100),
        [nro. de socio obra social/prepaga ] VARCHAR(50),
        [teléfono de contacto de emergencia ] VARCHAR(50)
    );

    -- Comando dinámico para importar datos desde archivo CSV
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
        BULK INSERT #sociorp_temporal
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001''
        );';

    EXEC sp_executesql @SQL;

    -- Insertar en la tabla definitiva Socio
    INSERT INTO ddbba.Socio (
        nroSocio,
        dni,
        nombre,
        apellido,
        telFijo,
        telEmergencia,
        email,
        fechaNac,
        nombreObraSoc,
        numeroObraSoc,
        telObraSoc
    )
    SELECT
        LTRIM(RTRIM([Nro de Socio])),
        LTRIM(RTRIM([ DNI])),
        LTRIM(RTRIM([Nombre])),
        LTRIM(RTRIM([ apellido])),
        LTRIM(RTRIM([ teléfono de contacto])),
        LTRIM(RTRIM([ teléfono de contacto emergencia])),
        LTRIM(RTRIM([ email personal])),
        TRY_CAST(LTRIM(RTRIM([ fecha de nacimiento])) AS DATE),
        LTRIM(RTRIM([ Nombre de la obra social o prepaga])),
        LTRIM(RTRIM([nro. de socio obra social/prepaga ])),
        LTRIM(RTRIM([teléfono de contacto de emergencia ]))
    FROM #sociorp_temporal;
END;
GO

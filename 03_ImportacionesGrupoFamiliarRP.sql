--importacion de RP del grupo familiar
USE Com2900G17
GO
--importacion de RP del grupo familiar
CREATE OR ALTER PROCEDURE ddbba.InsertarRP_GF
    @RutaArchivo VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#socio_gf') IS NOT NULL
        DROP TABLE #socio_gf;

    CREATE TABLE #socio_gf (
        [Nro de Socio] VARCHAR(50),
        [Nro de socio RP] VARCHAR(50),
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

    DECLARE @Sql NVARCHAR(MAX);
    SET @Sql = N'
        BULK INSERT #socio_gf
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001''
        );
    ';
    EXEC(@Sql);

    -- Insertar solo si no existe ya la combinación socioMenor + responsableACargo
    INSERT INTO ddbba.GrupoFamiliar (socioMenor, responsableACargo)
    SELECT
        sMenor.ID_socio,
        sResp.ID_socio
    FROM #socio_gf temp
    INNER JOIN ddbba.Socio sMenor
        ON LTRIM(RTRIM(temp.[Nro de Socio])) COLLATE Modern_Spanish_CI_AS = LTRIM(RTRIM(sMenor.nroSocio)) COLLATE Modern_Spanish_CI_AS
    INNER JOIN ddbba.Socio sResp
        ON LTRIM(RTRIM(temp.[Nro de socio RP])) COLLATE Modern_Spanish_CI_AS = LTRIM(RTRIM(sResp.nroSocio)) COLLATE Modern_Spanish_CI_AS
    WHERE NOT EXISTS (
        SELECT 1
        FROM ddbba.GrupoFamiliar gf
        WHERE gf.socioMenor = sMenor.ID_socio
          AND gf.responsableACargo = sResp.ID_socio
    );

    DROP TABLE #socio_gf;
END;
GO


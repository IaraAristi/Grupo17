USE Com2900G17
GO
CREATE OR ALTER PROCEDURE ddbba.sp_cargar_presentismo
    @rutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    -- Verifica si existe la tabla temporal y la elimina
    IF OBJECT_ID('tempdb..#presentismo_temp') IS NOT NULL
        DROP TABLE #presentismo_temp;

    -- Crea tabla temporal para importar los datos
    CREATE TABLE #presentismo_temp (
        [Nro de Socio] VARCHAR(10),
        [Actividad] VARCHAR(50),
        [fecha de asistencia] DATE,
        [Asistencia] VARCHAR(10),
        [Profesor] VARCHAR(50)
    );

    -- Construcción del SQL dinámico para importar CSV
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = '
        BULK INSERT #presentismo_temp
        FROM ''' + @rutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001''
        );
    ';
    EXEC (@sql);

    -- Inserta los datos limpios a la tabla real, verificando duplicados
    INSERT INTO ddbba.Presentismo (
        fecha,
        presentismo,
        socio,
        act,
        profesor
    )
    SELECT
        temp.[fecha de asistencia],
        LEFT(temp.Asistencia, 1),
        s.ID_socio,
        a.codActividad,
        temp.Profesor
    FROM #presentismo_temp temp
    JOIN ddbba.Socio s
        ON LTRIM(RTRIM(temp.[Nro de Socio])) COLLATE Modern_Spanish_CI_AS 
         = LTRIM(RTRIM(s.nroSocio))
    JOIN ddbba.actDeportiva a
        ON LTRIM(RTRIM(temp.Actividad)) COLLATE Modern_Spanish_CI_AS 
         = LTRIM(RTRIM(a.nombreActividad))
    WHERE NOT EXISTS (
        SELECT 1 
        FROM ddbba.Presentismo p
        WHERE p.socio = s.ID_socio
          AND p.act = a.codActividad
          AND p.fecha = temp.[fecha de asistencia]
    );

    DROP TABLE #presentismo_temp;
END;
GO
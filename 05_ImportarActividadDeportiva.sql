USE Com2900G17
GO
CREATE OR ALTER PROCEDURE ddbba.SP_InsertarActividades
    @rutaArchivo NVARCHAR(260)  -- Ejemplo: 'C:\ruta\actividades.csv'
AS
BEGIN
    SET NOCOUNT ON;


    IF OBJECT_ID('tempdb..#actividades_temp') IS NOT NULL
        DROP TABLE #actividades_temp;

    CREATE TABLE #actividades_temp (
    Actividad VARCHAR(50),
    ValorMensual VARCHAR(50),
    VigenteHasta VARCHAR(50)
	);


    DECLARE @sql NVARCHAR(MAX) = N'
    BULK INSERT #actividades_temp
    FROM ''' + @rutaArchivo + N'''
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        ROWTERMINATOR = ''\n'',
        CODEPAGE = ''65001''
    );';

    EXEC sp_executesql @sql;

    INSERT INTO ddbba.actDeportiva (nombreActividad)
	SELECT DISTINCT
	 CASE 
        WHEN LOWER(LTRIM(RTRIM(Actividad))) LIKE '%jederez%' THEN 'Ajedrez'
        ELSE LTRIM(RTRIM(Actividad)) COLLATE Modern_Spanish_CI_AS
	 END
	FROM #actividades_temp
	WHERE NOT EXISTS (
		SELECT 1 FROM ddbba.actDeportiva a
		WHERE a.nombreActividad = 
		 CASE 
            WHEN LOWER(LTRIM(RTRIM(Actividad))) LIKE '%jederez%' THEN 'Ajedrez'
            ELSE LTRIM(RTRIM(Actividad)) COLLATE Modern_Spanish_CI_AS
		 END
	);


END
GO

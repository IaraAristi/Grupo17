CREATE OR ALTER PROCEDURE ddbba.InsertarLluvias
    @rutaArchivo1 NVARCHAR(260),
    @rutaArchivo2 NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..##lluvias_temp') IS NOT NULL
        DROP TABLE ##lluvias_temp;

    CREATE TABLE ##lluvias_temp (
        [time] VARCHAR(25),
        [temperature_2m (Â°C)] VARCHAR(20), 
        [rain (mm)] VARCHAR(20), 
        [relative_humidity_2m (%)] VARCHAR(20),
        [wind_speed] VARCHAR(20),      
        [solar_radiation] VARCHAR(20)  
    );

    DECLARE @sql1 NVARCHAR(MAX) = N'
        BULK INSERT ##lluvias_temp
        FROM ''' + @rutaArchivo1 + '''
        WITH (
            FIRSTROW = 5,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''1252''
        );
    ';
    EXEC sp_executesql @sql1;

    DECLARE @sql2 NVARCHAR(MAX) = N'
        BULK INSERT ##lluvias_temp
        FROM ''' + @rutaArchivo2 + '''
        WITH (
            FIRSTROW = 5,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''1252''
        );
    ';
    EXEC sp_executesql @sql2;
	
    IF OBJECT_ID('tempdb..##lluvias_diarias') IS NOT NULL
        DROP TABLE ##lluvias_diarias;

    CREATE TABLE ##lluvias_diarias (
        fecha DATE,
        lluvia_mm DECIMAL(10,2)
    );

    INSERT INTO ##lluvias_diarias (fecha, lluvia_mm)
    SELECT 
        TRY_CONVERT(DATE, LEFT(LTRIM(RTRIM([time])), 10), 120),
        SUM(TRY_CONVERT(DECIMAL(10,2), LTRIM(RTRIM([rain (mm)]))))
    FROM ##lluvias_temp
    GROUP BY 
        TRY_CONVERT(DATE, LEFT(LTRIM(RTRIM([time])), 10), 120);

    -- Verificación
    SELECT * FROM ##lluvias_diarias ORDER BY fecha desc;
	DROP TABLE ##lluvias_diarias
	DROP TABLE ##lluvias_temp
END;
GO


exec ddbba.InsertarLluvias
	@rutaArchivo1 = 'C:\Users\agusr\Downloads\lluvias 2024 funciona.csv',
	@rutaArchivo2 = 'C:\Users\agusr\Downloads\lluvias 2025.csv'
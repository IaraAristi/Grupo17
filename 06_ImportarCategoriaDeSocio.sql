USE Com2900G17
GO
CREATE OR ALTER PROCEDURE ddbba.InsertarCatSocio
    @RutaArchivo VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#cat_temp') IS NOT NULL
        DROP TABLE #cat_temp;

    CREATE TABLE #cat_temp (
        [Categoria socio] VARCHAR(50),
        [Valor cuota] VARCHAR(50),     
        [Vigente hasta] VARCHAR(50)      
    );

    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        BULK INSERT #cat_temp
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001''
        );';
    EXEC (@sql);

    INSERT INTO ddbba.CatSocio (nombreCategoria, edadDesde, edadHasta)
    SELECT DISTINCT
        LTRIM(RTRIM([Categoria socio])) AS nombreCategoria,
        CASE 
            WHEN LOWER([Categoria socio]) = 'menor' THEN NULL
            WHEN LOWER([Categoria socio]) = 'cadete' THEN 13
            WHEN LOWER([Categoria socio]) = 'mayor' THEN 18
            ELSE NULL
        END AS edadDesde,
        CASE 
            WHEN LOWER([Categoria socio]) = 'menor' THEN 12
            WHEN LOWER([Categoria socio]) = 'cadete' THEN 17
            WHEN LOWER([Categoria socio]) = 'mayor' THEN NULL
            ELSE NULL
        END AS edadHasta
    FROM #cat_temp t
    WHERE NOT EXISTS (
        SELECT 1
        FROM ddbba.CatSocio c
        WHERE c.nombreCategoria = LTRIM(RTRIM(t.[Categoria socio]))
    );

    DROP TABLE #cat_temp;
END;
GO

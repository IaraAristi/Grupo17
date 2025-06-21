--SP PARA IMPORTACION

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

    INSERT INTO ddbba.catSocio (nombreCat, descripcion, edad_desde, edad_hasta)
    SELECT DISTINCT
        LTRIM(RTRIM([Categoria socio])) AS nombreCat,
        'Categoría ' + LTRIM(RTRIM([Categoria socio])) AS descripcion,
        CASE 
            WHEN LOWER([Categoria socio]) = 'menor' THEN 0
            WHEN LOWER([Categoria socio]) = 'cadete' THEN 13
            WHEN LOWER([Categoria socio]) = 'mayor' THEN 18
            ELSE NULL
        END AS edad_desde,
        CASE 
            WHEN LOWER([Categoria socio]) = 'menor' THEN 12
            WHEN LOWER([Categoria socio]) = 'cadete' THEN 17
            WHEN LOWER([Categoria socio]) = 'mayor' THEN NULL
            ELSE NULL
        END AS edad_hasta
    FROM #cat_temp t
    WHERE NOT EXISTS (
        SELECT 1
        FROM ddbba.catSocio c
        WHERE c.nombreCat = LTRIM(RTRIM(t.[Categoria socio]))
    );

    DROP TABLE #cat_temp;
END;
GO


---Levantar tabla RP
CREATE OR ALTER PROCEDURE ddbba.ImportarSociosRP
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Eliminar si existen
        IF OBJECT_ID('tempdb..#sociorp_temporal') IS NOT NULL DROP TABLE #sociorp_temporal;
        IF OBJECT_ID('tempdb..#socios_duplicados') IS NOT NULL DROP TABLE #socios_duplicados;
        IF OBJECT_ID('tempdb..#ordenados_temp') IS NOT NULL DROP TABLE #ordenados_temp;

        -- Tabla temporal para datos del archivo
        CREATE TABLE #sociorp_temporal (
            [Nro de Socio] VARCHAR(50),
            [Nombre] VARCHAR(100),
            [Apellido] VARCHAR(100),
            [DNI] VARCHAR(20),
            [Email] VARCHAR(150),
            [FechaNacimiento] VARCHAR(30),
            [Telefono] VARCHAR(30),
            [TelefonoEmergencia] VARCHAR(30),
            [ObraSocial] VARCHAR(100),
            [NumeroObraSocial] VARCHAR(50),
            [TelefonoObraSocial] VARCHAR(30)
        );

        -- Tabla de duplicados
        CREATE TABLE #socios_duplicados (
            nroSocio CHAR(7),
            dni INT,
            nombre VARCHAR(50),
            apellido VARCHAR(50),
            telContacto INT,
            telEmergencia INT,
            email VARCHAR(50),
            fechaNac DATE,
            nombreObraSoc VARCHAR(40),
            numeroObraSoc VARCHAR(20),
            telObraSoc CHAR(30)
        );

        -- Cargar CSV
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

        -- Crear tabla temporal con datos ordenados y numerados
        ;WITH ordenados AS (
            SELECT 
                LEFT(LTRIM(RTRIM([Nro de Socio])), 7) AS nroSocio,
                TRY_CAST(LTRIM(RTRIM([DNI])) AS INT) AS dni,
                LEFT(LTRIM(RTRIM([Nombre])), 50) AS nombre,
                LEFT(LTRIM(RTRIM([Apellido])), 50) AS apellido,
                TRY_CAST(LTRIM(RTRIM([Telefono])) AS INT) AS telContacto,
                TRY_CAST(LTRIM(RTRIM([TelefonoEmergencia])) AS INT) AS telEmergencia,
                LEFT(LTRIM(RTRIM([Email])), 50) AS email,
                TRY_CAST(LTRIM(RTRIM([FechaNacimiento])) AS DATE) AS fechaNac,
                LEFT(LTRIM(RTRIM([ObraSocial])), 40) AS nombreObraSoc,
                LEFT(LTRIM(RTRIM([NumeroObraSocial])), 20) AS numeroObraSoc,
                LEFT(LTRIM(RTRIM([TelefonoObraSocial])), 30) AS telObraSoc,
                ROW_NUMBER() OVER (PARTITION BY TRY_CAST(LTRIM(RTRIM([DNI])) AS INT) ORDER BY [Nro de Socio]) AS rn
            FROM #sociorp_temporal
            WHERE TRY_CAST(LTRIM(RTRIM([DNI])) AS INT) IS NOT NULL
        )
        SELECT * INTO #ordenados_temp FROM ordenados;

        -- Insertar duplicados (los repetidos en el archivo o que ya existen en la base)
        INSERT INTO #socios_duplicados
		SELECT o.nroSocio, o.dni, o.nombre, o.apellido, o.telContacto, o.telEmergencia,
			   o.email, o.fechaNac, o.nombreObraSoc, o.numeroObraSoc, o.telObraSoc
		FROM #ordenados_temp o
		WHERE o.rn > 1
		   OR EXISTS (
			   SELECT 1 
			   FROM ddbba.socio s 
			   WHERE s.dni = o.dni
		   );


        -- Insertar registros únicos en la tabla socio
        INSERT INTO ddbba.socio (
            nroSocio, dni, nombre, apellido, telContacto, telEmergencia,
            email, fechaNac, nombreObraSoc, numeroObraSoc, telObraSoc,
            estado, codCat, codTutor, codInscripcion, codGrupoFamiliar
        )
        SELECT o.nroSocio, o.dni, o.nombre, o.apellido, o.telContacto, o.telEmergencia,
               o.email, o.fechaNac, o.nombreObraSoc, o.numeroObraSoc, o.telObraSoc,
               'A', NULL, NULL, NULL, NULL
        FROM #ordenados_temp o
        WHERE o.rn = 1
          AND NOT EXISTS (SELECT 1 FROM ddbba.socio s WHERE s.dni = o.dni);

        -- Mostrar los DNI duplicados
        SELECT * FROM #socios_duplicados;

        -- Eliminar tabla auxiliar
        DROP TABLE #ordenados_temp;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO


------------------
CREATE OR ALTER PROCEDURE ddbba.ImportarSociosConGrupoFamiliar
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF OBJECT_ID('tempdb..#socios_importar') IS NOT NULL DROP TABLE #socios_importar;

        CREATE TABLE #socios_importar (
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

        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = '
            BULK INSERT #socios_importar
            FROM ''' + @RutaArchivo + '''
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = '','',
                ROWTERMINATOR = ''\n'',
                CODEPAGE = ''65001''
            );';
        EXEC sp_executesql @SQL;

        -- Insertar titulares (primeros por Nro de socio RP)
        WITH primeros_por_rp AS (
            SELECT *,
                   ROW_NUMBER() OVER (PARTITION BY [Nro de socio RP] ORDER BY [Nro de Socio]) AS rn
            FROM #socios_importar
            WHERE [ DNI] IS NOT NULL
        )
        INSERT INTO ddbba.socio (
            nroSocio, dni, nombre, apellido, telContacto, email,
            fechaNac, telEmergencia, nombreObraSoc, numeroObraSoc,
            telObraSoc, estado, codCat, codTutor, codInscripcion, codGrupoFamiliar
        )
        SELECT 
            LEFT(LTRIM(RTRIM([Nro de Socio])), 9),
            TRY_CAST([ DNI] AS INT),
            LEFT(LTRIM(RTRIM([Nombre])), 50),
            LEFT(LTRIM(RTRIM([ apellido])), 50),
            TRY_CAST([ teléfono de contacto] AS INT),
            LEFT(LTRIM(RTRIM([ email personal])), 50),
            TRY_CAST([ fecha de nacimiento] AS DATE),
            TRY_CAST([ teléfono de contacto emergencia] AS INT),
            LEFT(LTRIM(RTRIM([ Nombre de la obra social o prepaga])), 40),
            LEFT(LTRIM(RTRIM([nro. de socio obra social/prepaga ])), 20),
            LEFT(LTRIM(RTRIM([teléfono de contacto de emergencia ])), 30),
            'A',
            NULL,
            NULL,
            NULL,
            -- Subconsulta para obtener el ID_socio del grupo familiar a partir del nroSocio RP
            (SELECT TOP 1 ID_socio FROM ddbba.socio WHERE nroSocio = LEFT(LTRIM(RTRIM([Nro de socio RP])), 9))
        FROM primeros_por_rp
        WHERE rn = 1;

        -- Insertar familiares con grupoFamiliar referenciado (join para obtener ID_socio)
        WITH datos_familiares AS (
            SELECT *,
                   ROW_NUMBER() OVER (PARTITION BY [Nro de socio RP] ORDER BY [Nro de Socio]) AS rn
            FROM #socios_importar
        )
        INSERT INTO ddbba.socio (
            nroSocio, dni, nombre, apellido, telContacto, email,
            fechaNac, telEmergencia, nombreObraSoc, numeroObraSoc,
            telObraSoc, estado, codCat, codTutor, codInscripcion, codGrupoFamiliar
        )
        SELECT 
            LEFT(LTRIM(RTRIM(f.[Nro de Socio])), 9),
            TRY_CAST(f.[ DNI] AS INT),
            LEFT(LTRIM(RTRIM(f.[Nombre])), 50),
            LEFT(LTRIM(RTRIM(f.[ apellido])), 50),
            TRY_CAST(f.[ teléfono de contacto] AS INT),
            LEFT(LTRIM(RTRIM(f.[ email personal])), 50),
            TRY_CAST(f.[ fecha de nacimiento] AS DATE),
            TRY_CAST(f.[ teléfono de contacto emergencia] AS INT),
            LEFT(LTRIM(RTRIM(f.[ Nombre de la obra social o prepaga])), 40),
            LEFT(LTRIM(RTRIM(f.[nro. de socio obra social/prepaga ])), 20),
            LEFT(LTRIM(RTRIM(f.[teléfono de contacto de emergencia ])), 30),
            'A', NULL, NULL, NULL,
            s.ID_socio
        FROM datos_familiares f
        JOIN ddbba.socio s
          ON s.nroSocio = LEFT(LTRIM(RTRIM(f.[Nro de socio RP])), 9)
        WHERE f.rn > 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

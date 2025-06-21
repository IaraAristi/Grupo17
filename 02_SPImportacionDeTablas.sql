--SP PARA IMPORTACION

USE Com2900G17
GO

-----------------------------
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

    INSERT INTO ddbba.catSocio (nombreCat, edad_desde, edad_hasta)
    SELECT DISTINCT
        LTRIM(RTRIM([Categoria socio])) AS nombreCat,
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
            [ apellido] VARCHAR(100),
            [ DNI] VARCHAR(20),
            [ email personal] VARCHAR(150),
            [ fecha de nacimiento] VARCHAR(30),
            [ teléfono de contacto] VARCHAR(30),
            [ teléfono de contacto emergencia] VARCHAR(30),
            [ Nombre de la obra social o prepaga] VARCHAR(100),
            [nro. de socio obra social/prepaga ] VARCHAR(50),
            [teléfono de contacto de emergencia ] VARCHAR(30)
        );

        -- Tabla de duplicados
        CREATE TABLE #socios_duplicados (
            nroSocio CHAR(7),
            dni CHAR(8),
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
                LEFT(LTRIM(RTRIM([ DNI])), 8) AS dni,
                LEFT(LTRIM(RTRIM([Nombre])), 50) AS nombre,
                LEFT(LTRIM(RTRIM([ apellido])), 50) AS apellido,
                TRY_CAST(LTRIM(RTRIM([ teléfono de contacto])) AS INT) AS telContacto,
                TRY_CAST(LTRIM(RTRIM([ teléfono de contacto emergencia])) AS INT) AS telEmergencia,
                LEFT(LTRIM(RTRIM([ email personal])), 50) AS email,
                TRY_CAST(LTRIM(RTRIM([ fecha de nacimiento])) AS DATE) AS fechaNac,
                LEFT(LTRIM(RTRIM([ Nombre de la obra social o prepaga])), 40) AS nombreObraSoc,
                LEFT(LTRIM(RTRIM([nro. de socio obra social/prepaga ])), 20) AS numeroObraSoc,
                LEFT(LTRIM(RTRIM([teléfono de contacto de emergencia ])), 30) AS telObraSoc,
                ROW_NUMBER() OVER (PARTITION BY LEFT(LTRIM(RTRIM([ DNI])), 8) ORDER BY [Nro de Socio]) AS rn
            FROM #sociorp_temporal
            WHERE LEN(LTRIM(RTRIM([ DNI]))) >= 8
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
            LEFT(LTRIM(RTRIM([ DNI])), 8),
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
            LEFT(LTRIM(RTRIM(f.[ DNI])), 8),
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


---------------------------------------------------

CREATE OR ALTER PROCEDURE ddbba.InsertarActividades
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

    INSERT INTO ddbba.actDeportiva (nombre)
    SELECT DISTINCT
        CASE 
            WHEN LOWER(LTRIM(RTRIM(Actividad))) LIKE '%jederez%' THEN 'Ajedrez'
            ELSE LTRIM(RTRIM(Actividad)) COLLATE Modern_Spanish_CI_AS
        END
    FROM #actividades_temp
    WHERE NOT EXISTS (
        SELECT 1
        FROM ddbba.actDeportiva a
        WHERE a.nombre = 
            CASE 
                WHEN LOWER(LTRIM(RTRIM(Actividad))) LIKE '%jederez%' THEN 'Ajedrez'
                ELSE LTRIM(RTRIM(Actividad)) COLLATE Modern_Spanish_CI_AS
            END
    );
END;
GO


-------------------------------------------------
CREATE OR ALTER PROCEDURE ddbba.InsertarCuotasActividad
    @rutaArchivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#cuotas_actividad_temp') IS NOT NULL
        DROP TABLE #cuotas_actividad_temp;

    CREATE TABLE #cuotas_actividad_temp (
        Actividad VARCHAR(50),
        ValorMensual VARCHAR(50),
        VigenteHasta VARCHAR(50)
    );

    DECLARE @sql NVARCHAR(MAX) = N'
        BULK INSERT #cuotas_actividad_temp
        FROM ''' + @rutaArchivo + N'''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001''
        );';

    EXEC sp_executesql @sql;

    INSERT INTO ddbba.CuotaActividad (
        fechaVigenciaHasta, actividad, costoActividad, codAct
    )
    SELECT 
        TRY_CONVERT(DATE, VigenteHasta, 103),
        CASE 
            WHEN LOWER(LTRIM(RTRIM(Actividad))) LIKE '%jederez%' THEN 'Ajedrez'
            ELSE LTRIM(RTRIM(Actividad)) COLLATE Modern_Spanish_CI_AS
        END,
        TRY_CAST(ValorMensual AS DECIMAL(7,2)),
        a.codAct
    FROM #cuotas_actividad_temp t
    JOIN ddbba.actDeportiva a 
        ON a.nombre = CASE 
                         WHEN LOWER(LTRIM(RTRIM(t.Actividad))) LIKE '%jederez%' THEN 'Ajedrez'
                         ELSE LTRIM(RTRIM(t.Actividad)) COLLATE Modern_Spanish_CI_AS
                     END
    WHERE NOT EXISTS (
        SELECT 1
        FROM ddbba.CuotaActividad ca
        WHERE ca.actividad = 
              CASE 
                  WHEN LOWER(LTRIM(RTRIM(t.Actividad))) LIKE '%jederez%' THEN 'Ajedrez'
                  ELSE LTRIM(RTRIM(t.Actividad)) COLLATE Modern_Spanish_CI_AS
              END
          AND ca.fechaVigenciaHasta = TRY_CONVERT(DATE, VigenteHasta, 103)

    );

    DROP TABLE #cuotas_actividad_temp;
END;
GO


----------------------------
CREATE OR ALTER PROCEDURE ddbba.InsertarCuotasCatSocio
    @rutaArchivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

    -- Eliminar tabla temporal si ya existe
    IF OBJECT_ID('tempdb..#cuotas_cat_temp') IS NOT NULL
        DROP TABLE #cuotas_cat_temp;

    -- Crear tabla temporal con los datos del archivo
    CREATE TABLE #cuotas_cat_temp (
        [Categoria socio] VARCHAR(50),
        [Valor cuota] VARCHAR(50),
        [Vigente hasta] VARCHAR(50)
    );

    -- Cargar datos desde el archivo CSV
    DECLARE @sql NVARCHAR(MAX) = N'
        BULK INSERT #cuotas_cat_temp
        FROM ''' + @rutaArchivo + N'''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001''
        );';

    EXEC sp_executesql @sql;

    -- Insertar datos en la tabla CuotaCatSocio evitando duplicados
    INSERT INTO ddbba.CuotaCatSocio (
        fechaVigenciaHasta, categoria, costoMembresia, catSocio
    )
    SELECT 
        TRY_CONVERT(DATE, [Vigente hasta], 103),
        LTRIM(RTRIM([Categoria socio])),
        TRY_CAST([Valor cuota] AS DECIMAL(7,2)),
        c.codCat
    FROM #cuotas_cat_temp t
    JOIN ddbba.catSocio c
        ON c.nombreCat = LTRIM(RTRIM(t.[Categoria socio]))
    WHERE NOT EXISTS (
        SELECT 1
        FROM ddbba.CuotaCatSocio cs
        WHERE cs.categoria = LTRIM(RTRIM(t.[Categoria socio]))
          AND cs.fechaVigenciaHasta = TRY_CONVERT(DATE, t.[Vigente hasta], 103)
    );

    -- Limpiar tabla temporal
    DROP TABLE #cuotas_cat_temp;
END;
GO


----------------------------------------------
CREATE OR ALTER PROCEDURE ddbba.cargarPresentismo
    @rutaArchivo NVARCHAR(255) 
AS
BEGIN
    SET NOCOUNT ON;

    -- Eliminar tabla temporal si ya existe
    IF OBJECT_ID('tempdb..#presentismo_temp') IS NOT NULL
        DROP TABLE #presentismo_temp;

    -- Crear tabla temporal para importar datos desde CSV
    CREATE TABLE #presentismo_temp (
        [Nro de Socio] VARCHAR(10),
        [Actividad] VARCHAR(50),
        [fecha de asistencia] VARCHAR(20), 
        [Asistencia] VARCHAR(10),
        [Profesor] VARCHAR(50)
    );

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

    -- Insertar datos en la tabla definitiva
    INSERT INTO ddbba.Presentismo (
        fecha,
        presentismo,
        socio,
        act,
        profesor
    )
    SELECT
        TRY_CONVERT(DATE, LTRIM(RTRIM(temp.[fecha de asistencia])), 101),  -- Formato mm/dd/yyyy
        LEFT(LTRIM(RTRIM(temp.Asistencia)), 1),
        s.ID_socio,
        a.codAct,
        LTRIM(RTRIM(temp.Profesor))
    FROM #presentismo_temp temp
    JOIN ddbba.Socio s
        ON LTRIM(RTRIM(temp.[Nro de Socio])) COLLATE Modern_Spanish_CI_AS = s.nroSocio
    JOIN ddbba.actDeportiva a
        ON LTRIM(RTRIM(temp.Actividad)) COLLATE Modern_Spanish_CI_AS = a.nombre
    WHERE 
        TRY_CONVERT(DATE, LTRIM(RTRIM(temp.[fecha de asistencia])), 101) IS NOT NULL
        AND TRY_CONVERT(DATE, LTRIM(RTRIM(temp.[fecha de asistencia])), 101) <= CAST(GETDATE() AS DATE)
        AND NOT EXISTS (
            SELECT 1
            FROM ddbba.Presentismo p
            WHERE p.socio = s.ID_socio
              AND p.act = a.codAct
              AND p.fecha = TRY_CONVERT(DATE, LTRIM(RTRIM(temp.[fecha de asistencia])), 101)
        );

    -- Eliminar la tabla temporal
    DROP TABLE #presentismo_temp;
END;
GO


-------------------------------------------------------
CREATE OR ALTER PROCEDURE ddbba.importarPago
    @rutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#pago_temp') IS NOT NULL
        DROP TABLE #pago_temp;

    CREATE TABLE #pago_temp (
        [Id de pago] VARCHAR(50),
        [fecha] VARCHAR(20),
        [Responsable de pago] VARCHAR(20),
        [Valor] VARCHAR(30),
        [Medio de pago] VARCHAR(30)
    );

    DECLARE @sql NVARCHAR(MAX);
    SET @sql = '
        BULK INSERT #pago_temp
        FROM ''' + @rutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001''
        );
    ';
    EXEC (@sql);

    INSERT INTO ddbba.pagoFactura (
        idPago,
        Fecha_Pago,
        hora,
        montoTotal,
        montoMedioPago,
        saldoFavorUsado,
        medioPago,
        estadoPago,
        codSocio
    )
    SELECT
        LEFT(LTRIM(RTRIM(t.[Id de pago])), 12),
        TRY_CONVERT(DATE, LTRIM(RTRIM(t.[fecha])), 103), -- Formato dd/mm/yyyy
        NULL, -- hora no provista
        TRY_CONVERT(DECIMAL(8,2), LTRIM(RTRIM(t.[Valor]))),
        NULL, -- montoMedioPago no provisto
        NULL, -- saldoFavorUsado no provisto
        LTRIM(RTRIM(t.[Medio de pago])),
        NULL, -- estadoPago no provisto
        s.ID_socio
    FROM #pago_temp t
    JOIN ddbba.socio s
        ON LTRIM(RTRIM(t.[Responsable de pago])) = s.nroSocio
    WHERE 
        TRY_CONVERT(DATE, t.[fecha], 103) IS NOT NULL
        AND TRY_CONVERT(DECIMAL(8,2), t.[Valor]) IS NOT NULL
        AND LEFT(LTRIM(RTRIM(t.[Id de pago])), 12) IS NOT NULL;

    DROP TABLE #pago_temp;
END;
GO


-------------------
CREATE OR ALTER PROCEDURE ddbba.importarCostoPiletaInvitado
    @rutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#costo_temp') IS NOT NULL
        DROP TABLE #costo_temp;

    CREATE TABLE #costo_temp (
        edad VARCHAR(50),
        precio VARCHAR(50),
        fechaVigenteHasta VARCHAR(50)
    );

    DECLARE @sql NVARCHAR(MAX);
    SET @sql = '
        BULK INSERT #costo_temp
        FROM ''' + @rutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001''
        );
    ';
    EXEC (@sql);

    INSERT INTO ddbba.costoIngresoPileta (
        edad,
        precio,
        fechaVigenteHasta
    )
    SELECT
        CASE 
            WHEN LOWER(LTRIM(RTRIM(edad))) LIKE '%adult%' THEN 'Mayor'
            WHEN LOWER(LTRIM(RTRIM(edad))) LIKE '%menor%' THEN 'Menor'
            ELSE NULL
        END,
        TRY_CONVERT(DECIMAL(7,2), LTRIM(RTRIM(precio))),
        TRY_CONVERT(DATE, LTRIM(RTRIM(fechaVigenteHasta)), 101) -- Formato mm/dd/yyyy
    FROM #costo_temp c
    WHERE
        ISNULL(LTRIM(RTRIM(edad)), '') <> ''
        AND TRY_CONVERT(DECIMAL(7,2), precio) IS NOT NULL
        AND TRY_CONVERT(DATE, fechaVigenteHasta, 101) IS NOT NULL
        AND NOT EXISTS (
            SELECT 1 FROM ddbba.costoIngresoPileta p
            WHERE p.edad = CASE 
                            WHEN LOWER(LTRIM(RTRIM(c.edad))) LIKE '%adult%' THEN 'Mayor'
                            WHEN LOWER(LTRIM(RTRIM(c.edad))) LIKE '%menor%' THEN 'Menor'
                            ELSE NULL
                          END
              AND p.precio = TRY_CONVERT(DECIMAL(7,2), LTRIM(RTRIM(c.precio)))
              AND p.fechaVigenteHasta = TRY_CONVERT(DATE, LTRIM(RTRIM(c.fechaVigenteHasta)), 101)
        );

    DROP TABLE #costo_temp;
END;
GO

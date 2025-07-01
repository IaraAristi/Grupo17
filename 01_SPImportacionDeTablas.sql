/*Entrega 5:Conjunto de pruebas.Importacion de datos a partir de archivos .CSV
Fecha de entrega: 01/07/2025
Número de comisión: 2900
Número de grupo: 17
Materia: Bases de datos aplicadas
Alumnos:Aristimuño,Iara Belén DNI:45237225 
		Domínguez,Luana Milena DNI:46362353
		Lopardo, Tomás Matías DNI: 45495734
		Rico, Agustina Micaela DNI: 46028153
*/
USE Com2900G17
GO
-----------------------------
CREATE OR ALTER PROCEDURE importaciones.InsertarCatSocio
    @RutaArchivo VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#cat_temp') IS NOT NULL
        DROP TABLE #cat_temp;
    CREATE TABLE #cat_temp(
        [Categoria socio] VARCHAR(50) COLLATE Modern_Spanish_CI_AS ,
        [Valor cuota] VARCHAR(50) COLLATE Modern_Spanish_CI_AS ,     
        [Vigente hasta] VARCHAR(50) COLLATE Modern_Spanish_CI_AS       
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
        );
	'; EXEC (@sql);

    INSERT INTO club.catSocio (nombreCat, edad_desde, edad_hasta)
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
        FROM club.catSocio c
        WHERE c.nombreCat = LTRIM(RTRIM(t.[Categoria socio])) --esta es la comparación en la que, de ser necesario, si no cambiamos la collation nos devuelve error
    );

    DROP TABLE #cat_temp;
END;
GO


---Levantar tabla RP
CREATE OR ALTER PROCEDURE importaciones.ImportarSociosRP
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
            [Nro de Socio] VARCHAR(50)COLLATE Modern_Spanish_CI_AS,
            [Nombre] VARCHAR(100)COLLATE Modern_Spanish_CI_AS,
            [Apellido] VARCHAR(100)COLLATE Modern_Spanish_CI_AS,
            [DNI] VARCHAR(20)COLLATE Modern_Spanish_CI_AS,
            [Email] VARCHAR(150)COLLATE Modern_Spanish_CI_AS,
            [FechaNacimiento] VARCHAR(30)COLLATE Modern_Spanish_CI_AS,
            [Telefono] VARCHAR(30)COLLATE Modern_Spanish_CI_AS,
            [TelefonoEmergencia] VARCHAR(30)COLLATE Modern_Spanish_CI_AS,
            [ObraSocial] VARCHAR(100)COLLATE Modern_Spanish_CI_AS,
            [NumeroObraSocial] VARCHAR(50)COLLATE Modern_Spanish_CI_AS,
            [TelefonoObraSocial] VARCHAR(30)COLLATE Modern_Spanish_CI_AS
        );

        -- Tabla de duplicados
        CREATE TABLE #socios_duplicados (
            nroSocio CHAR(7)COLLATE Modern_Spanish_CI_AS,
            dni VARCHAR(10)COLLATE Modern_Spanish_CI_AS,
            nombre VARCHAR(50)COLLATE Modern_Spanish_CI_AS,
            apellido VARCHAR(50)COLLATE Modern_Spanish_CI_AS,
            telContacto INT,
            telEmergencia INT,
            email VARCHAR(50),
            fechaNac DATE,
            nombreObraSoc VARCHAR(40) COLLATE Modern_Spanish_CI_AS,
            numeroObraSoc VARCHAR(20) COLLATE Modern_Spanish_CI_AS,
            telObraSoc CHAR(30) COLLATE Modern_Spanish_CI_AS
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
                LEFT(TRY_CAST(LTRIM(RTRIM([DNI])) AS CHAR),8) AS dni,
                LEFT(LTRIM(RTRIM([Nombre])), 50) AS nombre,
                LEFT(LTRIM(RTRIM([Apellido])), 50) AS apellido,
                TRY_CAST(LTRIM(RTRIM([Telefono])) AS INT) AS telContacto,
                TRY_CAST(LTRIM(RTRIM([TelefonoEmergencia])) AS INT) AS telEmergencia,
                LEFT(LTRIM(RTRIM([Email])), 50) AS email,
                TRY_CAST(LTRIM(RTRIM([FechaNacimiento])) AS DATE) AS fechaNac,
                LEFT(LTRIM(RTRIM([ObraSocial])), 40) AS nombreObraSoc,
                LEFT(LTRIM(RTRIM([NumeroObraSocial])), 20) AS numeroObraSoc,
                LEFT(LTRIM(RTRIM([TelefonoObraSocial])), 30) AS telObraSoc,
                ROW_NUMBER() OVER (PARTITION BY TRY_CAST(LTRIM(RTRIM([DNI])) AS CHAR) ORDER BY [Nro de Socio]) AS rn
            FROM #sociorp_temporal
            WHERE TRY_CAST(LTRIM(RTRIM([DNI])) AS CHAR) IS NOT NULL
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
			   FROM socio.socio s 
			   WHERE s.dni = o.dni
		   );
		
        -- Insertar registros únicos en la tabla socio
        INSERT INTO socio.socio (
            nroSocio, dni, nombre, apellido, telContacto, telEmergencia,
            email, fechaNac, nombreObraSoc, numeroObraSoc, telObraSoc,
            estado, codCat, codTutor, codInscripcion, codGrupoFamiliar
        )
        SELECT o.nroSocio, o.dni, o.nombre, o.apellido, o.telContacto, o.telEmergencia,
               o.email, o.fechaNac, o.nombreObraSoc, o.numeroObraSoc, o.telObraSoc,
               'A', NULL, NULL, NULL, NULL
        FROM #ordenados_temp o
        WHERE o.rn = 1
          AND NOT EXISTS (SELECT 1 FROM socio.socio s WHERE s.dni = o.dni);

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
CREATE OR ALTER PROCEDURE importaciones.ImportarSociosConGrupoFamiliar
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF OBJECT_ID('tempdb..#socios_importar') IS NOT NULL DROP TABLE #socios_importar;

        CREATE TABLE #socios_importar (
            [Nro de Socio] VARCHAR(50) COLLATE Modern_Spanish_CI_AS ,
            [Nro de socio RP] VARCHAR(50) COLLATE Modern_Spanish_CI_AS ,
            [Nombre] VARCHAR(100) COLLATE Modern_Spanish_CI_AS ,
            [ apellido] VARCHAR(100) COLLATE Modern_Spanish_CI_AS ,
            [ DNI] VARCHAR(20) COLLATE Modern_Spanish_CI_AS ,
            [ email personal] VARCHAR(150) COLLATE Modern_Spanish_CI_AS ,
            [ fecha de nacimiento] VARCHAR(30) COLLATE Modern_Spanish_CI_AS ,
            [ teléfono de contacto] VARCHAR(30) COLLATE Modern_Spanish_CI_AS ,
            [ teléfono de contacto emergencia] VARCHAR(30) COLLATE Modern_Spanish_CI_AS ,
            [ Nombre de la obra social o prepaga] VARCHAR(100) COLLATE Modern_Spanish_CI_AS ,
            [nro. de socio obra social/prepaga ] VARCHAR(50) COLLATE Modern_Spanish_CI_AS ,
            [teléfono de contacto de emergencia ] VARCHAR(50) COLLATE Modern_Spanish_CI_AS 
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
        INSERT INTO socio.socio (
            nroSocio, dni, nombre, apellido, telContacto, email,
            fechaNac, telEmergencia, nombreObraSoc, numeroObraSoc,
            telObraSoc, estado, codCat, codTutor, codInscripcion, codGrupoFamiliar
        )
        SELECT 
            LEFT(LTRIM(RTRIM([Nro de Socio])), 9),
            LEFT(TRY_CAST([ DNI] AS CHAR),8),
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
            (SELECT TOP 1 ID_socio FROM socio.socio WHERE nroSocio = LEFT(LTRIM(RTRIM([Nro de socio RP])), 9))
        FROM primeros_por_rp
        WHERE rn = 1;

        -- Insertar familiares con grupoFamiliar referenciado (join para obtener ID_socio)
        WITH datos_familiares AS (
            SELECT *,
                   ROW_NUMBER() OVER (PARTITION BY [Nro de socio RP] ORDER BY [Nro de Socio]) AS rn
            FROM #socios_importar
        )
        INSERT INTO socio.socio (
            nroSocio, dni, nombre, apellido, telContacto, email,
            fechaNac, telEmergencia, nombreObraSoc, numeroObraSoc,
            telObraSoc, estado, codCat, codTutor, codInscripcion, codGrupoFamiliar
        )
        SELECT 
            LEFT(LTRIM(RTRIM(f.[Nro de Socio])), 9),
            LEFT(TRY_CAST(f.[ DNI] AS CHAR),8),
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
        JOIN socio.socio s
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

CREATE OR ALTER PROCEDURE importaciones.InsertarActividades
    @rutaArchivo NVARCHAR(260)  
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

    INSERT INTO club.actDeportiva (nombre)
    SELECT DISTINCT
        CASE 
            WHEN LOWER(LTRIM(RTRIM(Actividad))) LIKE '%jederez%' THEN 'Ajedrez'
            ELSE LTRIM(RTRIM(Actividad)) COLLATE Modern_Spanish_CI_AS
        END
    FROM #actividades_temp
    WHERE NOT EXISTS (
        SELECT 1
        FROM club.actDeportiva a
        WHERE a.nombre = 
            CASE 
                WHEN LOWER(LTRIM(RTRIM(Actividad))) LIKE '%jederez%' THEN 'Ajedrez'
                ELSE LTRIM(RTRIM(Actividad)) COLLATE Modern_Spanish_CI_AS
            END
    );
END;
GO


-------------------------------------------------
CREATE OR ALTER PROCEDURE importaciones.InsertarCuotasActividad
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

    INSERT INTO club.TarifarioActividad (
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
    JOIN club.actDeportiva a 
        ON a.nombre = CASE 
                         WHEN LOWER(LTRIM(RTRIM(t.Actividad))) LIKE '%jederez%' THEN 'Ajedrez'
                         ELSE LTRIM(RTRIM(t.Actividad)) COLLATE Modern_Spanish_CI_AS
                     END
    WHERE NOT EXISTS (
        SELECT 1
        FROM club.TarifarioActividad ca
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
CREATE OR ALTER PROCEDURE importaciones.InsertarCuotasCatSocio
    @rutaArchivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

    -- Eliminar tabla temporal si ya existe
    IF OBJECT_ID('tempdb..#cuotas_cat_temp') IS NOT NULL
        DROP TABLE #cuotas_cat_temp;

    -- Crear tabla temporal con los datos del archivo
    CREATE TABLE #cuotas_cat_temp (
        [Categoria socio] VARCHAR(50) COLLATE Modern_Spanish_CI_AS ,
        [Valor cuota] VARCHAR(50) COLLATE Modern_Spanish_CI_AS ,
        [Vigente hasta] VARCHAR(50) COLLATE Modern_Spanish_CI_AS 
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
    INSERT INTO club.TarifarioCatSocio(
        fechaVigenciaHasta, categoria, costoMembresia, catSocio
    )
    SELECT 
        TRY_CONVERT(DATE, [Vigente hasta], 103),
        LTRIM(RTRIM([Categoria socio])),
        TRY_CAST([Valor cuota] AS DECIMAL(7,2)),
        c.codCat
    FROM #cuotas_cat_temp t
    JOIN club.catSocio c
        ON c.nombreCat = LTRIM(RTRIM(t.[Categoria socio]))
    WHERE NOT EXISTS (
        SELECT 1
        FROM club.TarifarioCatSocio cs
        WHERE cs.categoria = LTRIM(RTRIM(t.[Categoria socio]))
          AND cs.fechaVigenciaHasta = TRY_CONVERT(DATE, t.[Vigente hasta], 103)
    );

    -- Limpiar tabla temporal
    DROP TABLE #cuotas_cat_temp;
END;
GO


----------------------------------------------

CREATE OR ALTER PROCEDURE importaciones.cargarPresentismo
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
        [fecha de asistencia] VARCHAR(20),  -- se carga como texto para mayor tolerancia
        [Asistencia] VARCHAR(10),
        [Profesor] VARCHAR(50)
    );

    -- Importar desde el archivo CSV
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = '
        BULK INSERT #presentismo_temp
        FROM ''' + @rutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '';'', 
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001''
        );
    ';-- Si esta en inglés el Excel desde el cual descargamos el csv va FIELDTERMINATOR = '','' 
	  --sino FIELDTERMINATOR = '';''
    EXEC (@sql);

    -- Insertar en la tabla Presentismo
		   INSERT INTO club.Presentismo (
			fecha,
			presentismo,
			socio,
			act,
			profesor
		)
		-- FORMATO DE FECHAS:
		-- TRY_CONVERT para definir el formato de la fecha.
		-- Elegir el número correcto según el formato de fecha en el archivo .CSV:
		-- 101 = mm/dd/yyyy (ESTILO ESTADOUNIDENSE) -> USAR ESTE si el archivo se generó desde un Excel en idioma inglés.
		-- 103 = dd/mm/yyyy (ESTILO EUROPEO/LATINO) -> USAR ESTE si el archivo se generó desde un Excel en español.
		SELECT
			TRY_CONVERT(DATE, LTRIM(RTRIM(temp.[fecha de asistencia])), 103) AS fechaAsistencia,
			LEFT(LTRIM(RTRIM(temp.Asistencia)), 1),
			s.ID_socio,
			a.codAct,
			LTRIM(RTRIM(temp.Profesor))
		FROM #presentismo_temp temp
		JOIN socio.Socio s
			ON LTRIM(RTRIM(temp.[Nro de Socio])) COLLATE Modern_Spanish_CI_AS = s.nroSocio
		JOIN club.actDeportiva a
			ON LTRIM(RTRIM(temp.Actividad)) COLLATE Modern_Spanish_CI_AS = a.nombre
		WHERE 
			TRY_CONVERT(DATE, LTRIM(RTRIM(temp.[fecha de asistencia])), 103) IS NOT NULL
			AND TRY_CONVERT(DATE, LTRIM(RTRIM(temp.[fecha de asistencia])), 103) <= CAST(GETDATE() AS DATE)
			AND NOT EXISTS (
				SELECT 1 
				FROM club.Presentismo p
				WHERE p.socio = s.ID_socio
				  AND p.act = a.codAct
				  AND p.fecha = TRY_CONVERT(DATE, LTRIM(RTRIM(temp.[fecha de asistencia])), 103)
			);


    -- Limpiar tabla temporal
    DROP TABLE #presentismo_temp;
END;
GO


--insercion datos pago factura
CREATE OR ALTER PROCEDURE importaciones.InsertarPagoFactura
    @rutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#pago_temp') IS NOT NULL
        DROP TABLE #pago_temp;

    CREATE TABLE #pago_temp (
        [Id de pago] VARCHAR(15),
        [fecha] VARCHAR(20),
        [Responsable de pago] VARCHAR(20),
        [Valor] VARCHAR(20),
        [Medio de pago] VARCHAR(30)
    );

    DECLARE @sql NVARCHAR(MAX) = N'
        BULK INSERT #pago_temp
        FROM ''' + @rutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '';'',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001''
        );';

    EXEC sp_executesql @sql;

    INSERT INTO tesoreria.pagoFactura (
		idPago,
        Fecha_Pago,
        montoTotal,
        medioPago,
        codSocio
    )
    SELECT
		LEFT(LTRIM(RTRIM(p.[Id de pago])),12),
        TRY_CONVERT(DATE, LTRIM(RTRIM(p.[fecha])), 103), 
        TRY_CAST(p.[Valor] AS DECIMAL(8,2)),
        LTRIM(RTRIM(p.[Medio de pago])) COLLATE Modern_Spanish_CI_AS,
        s.ID_socio
    FROM #pago_temp p
    JOIN socio.Socio s
        ON LTRIM(RTRIM(p.[Responsable de pago])) COLLATE Modern_Spanish_CI_AS = s.nroSocio;

    DROP TABLE #pago_temp;
END;
GO

--SP TARIFA PILETA INVITADO
CREATE OR ALTER PROCEDURE importaciones.InsertarCostoPiletaInvitado
    @rutaArchivo NVARCHAR(260)  
AS
BEGIN
    SET NOCOUNT ON;

    -- Eliminar tabla temporal si ya existe
    IF OBJECT_ID('tempdb..#costoPileta_temp') IS NOT NULL
        DROP TABLE #costoPileta_temp;

    -- Crear tabla temporal con campos tipo texto para limpieza
    CREATE TABLE #costoPileta_temp (
        edad VARCHAR(20),
        precio VARCHAR(20),
        fechaVigenteHasta VARCHAR(20)
    );

    -- Cargar datos desde el archivo CSV
    DECLARE @sql NVARCHAR(MAX) = N'
        BULK INSERT #costoPileta_temp
        FROM ''' + @rutaArchivo + N'''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001''
        );
    ';
    EXEC sp_executesql @sql;

    -- Insertar en la tabla final con limpieza y conversión
    INSERT INTO club.costoPiletaInvitado (edad, precio, fechaVigenteHasta)
    SELECT
        LTRIM(RTRIM(edad)),
        TRY_CAST(precio AS DECIMAL(7,2)),
        TRY_CONVERT(DATE, fechaVigenteHasta, 103)  -- mm/dd/yyyy
    FROM #costoPileta_temp
    WHERE 
        TRY_CAST(precio AS DECIMAL(7,2)) IS NOT NULL AND
        TRY_CONVERT(DATE, fechaVigenteHasta, 103) IS NOT NULL;

    -- Eliminar tabla temporal
    DROP TABLE #costoPileta_temp;
END;
GO



--sp costo pileta socios
CREATE OR ALTER PROCEDURE importaciones.InsertarCostoPileta
    @rutaArchivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#costoPileta_temp') IS NOT NULL
        DROP TABLE #costoPileta_temp;

    CREATE TABLE #costoPileta_temp (
        costo VARCHAR(50),
        tipo VARCHAR(20),
        categoria VARCHAR(20),
        fechaVigenciaHasta VARCHAR(20)
    );

    DECLARE @sql NVARCHAR(MAX) = N'
        BULK INSERT #costoPileta_temp
        FROM ''' + @rutaArchivo + N'''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001''
        );
    ';
    EXEC sp_executesql @sql;


		INSERT INTO club.costoPileta (costo, tipo, categoria, fechaVigenciaHasta)
	SELECT
		TRY_CAST(LTRIM(RTRIM(costo)) AS DECIMAL(9,2)),
		LTRIM(RTRIM(tipo)),
		LTRIM(RTRIM(categoria)),
		TRY_CONVERT(DATE, LTRIM(RTRIM(fechaVigenciaHasta)), 103)
	FROM #costoPileta_temp AS t
	WHERE 
		TRY_CAST(costo AS DECIMAL(9,2)) IS NOT NULL AND
		TRY_CONVERT(DATE, fechaVigenciaHasta, 103) IS NOT NULL AND
		NOT EXISTS (
			SELECT 1 FROM club.costoPileta AS c
			WHERE
				c.costo = TRY_CAST(LTRIM(RTRIM(t.costo)) AS DECIMAL(9,2))
				AND c.tipo = LTRIM(RTRIM(t.tipo))
				AND c.categoria = LTRIM(RTRIM(t.categoria))
				AND c.fechaVigenciaHasta = TRY_CONVERT(DATE, LTRIM(RTRIM(t.fechaVigenciaHasta)), 103)
		)



    DROP TABLE #costoPileta_temp;
END;
GO

--SP IMPORTAR LLUVIAS
CREATE OR ALTER PROCEDURE importaciones.InsertarLluvias
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
	DROP TABLE ##lluvias_temp
END;
GO

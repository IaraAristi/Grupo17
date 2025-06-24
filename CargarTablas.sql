USE Com2900G17
GO

--Cargar categoria de socio en Socio
-- ================================================
CREATE OR ALTER PROCEDURE ddbba.ActualizarCategoriaSociosPorEdad
AS
BEGIN
    -- Desactivar el conteo de filas afectadas para mejorar el rendimiento
    SET NOCOUNT ON;

    -- Iniciar una transacción para asegurar la atomicidad de la operación
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE s
        SET s.codCat = cs.codCat
        FROM
            ddbba.socio AS s
        JOIN
            (
                -- Subconsulta para calcular la edad actual de cada socio
                SELECT
                    ID_Socio,
                    fechaNac,
                    -- Calcula la edad en años completos (para SQL Server)
                    DATEDIFF(year, fechaNac, GETDATE()) -
                    CASE
                        WHEN MONTH(fechaNac) > MONTH(GETDATE()) OR
                             (MONTH(fechaNac) = MONTH(GETDATE()) AND DAY(fechaNac) > DAY(GETDATE()))
                        THEN 1
                        ELSE 0
                    END AS EdadActual
                FROM
                    ddbba.socio
                WHERE
                    fechaNac IS NOT NULL
            ) AS s_edad ON s.ID_Socio = s_edad.ID_Socio
        JOIN
            ddbba.catSocio AS cs ON s_edad.EdadActual >= cs.edad_desde
                                    AND (s_edad.EdadActual <= cs.edad_hasta OR cs.edad_hasta IS NULL)
        WHERE
            s.fechaNac IS NOT NULL; -- Solo actualiza a socios con fecha de nacimiento

        -- Confirmar la transacción si todo fue bien
        COMMIT TRANSACTION;

        PRINT 'La actualización de la categoría de socios se completó exitosamente.';

    END TRY
    BEGIN CATCH
        -- Si ocurre un error, revertir la transacción
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Capturar y mostrar información del error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

        PRINT 'Ocurrió un error durante la actualización de la categoría de socios. La transacción fue revertida.';
    END CATCH;
END;
GO
--------------------------------------------------------------------------------------------------------------------------
--Actualizar el número de grupo familiar para aquellos socios que sean responsables de pago del grupo
-- ================================================
CREATE OR ALTER PROCEDURE ddbba.ActualizarGrupoFamiliarResponsables
AS
BEGIN
    SET NOCOUNT ON;

    -- Actualiza el campo grupoFamiliar de todos los socios responsables (que tienen a otros socios a cargo)
    UPDATE s
    SET codGrupoFamiliar = s.ID_socio
    FROM ddbba.socio s
    WHERE EXISTS (
        SELECT 1
        FROM ddbba.socio m
        WHERE m.codGrupoFamiliar = s.ID_socio
    )
    AND s.codGrupoFamiliar IS NULL;
END;
GO

----------------------------------------------------------------------------------------------
--Cargar en base al CSV de detalle de factura la tabla detalle de factura y factura
-- ================================================
CREATE OR ALTER PROCEDURE ddbba.cargarDetalleFacturaDesdeCSV
    @rutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #detalleCarga (
        socio                        INT,
        categoria                    INT,
        actividad                    INT,
        costoActividadIndividual     DECIMAL(9,2),
        costoMembresia               DECIMAL(9,2),
        mes_fecha                    INT,
        nombre_actividad             VARCHAR(100),
        nombre_mes                   VARCHAR(20)
    );

    DECLARE @sql NVARCHAR(MAX) = '
        BULK INSERT #detalleCarga
        FROM ''' + @rutaArchivo + '''
        WITH (
            FIELDTERMINATOR = '';'',
            ROWTERMINATOR = ''\n'',
            FIRSTROW = 2
        );';
    EXEC(@sql);

    ;WITH FacturasAgrupadas AS (
        SELECT DISTINCT socio, mes_fecha
        FROM #detalleCarga
    )
    INSERT INTO ddbba.factura (
        ID_socio,
        fechaEmision,
        mesFacturado,
        fechaVencimiento,
        fecha2Vencimiento,
        totalNeto,
        estadoFactura
    )
    SELECT
        fa.socio,
        DATEFROMPARTS(2025, fa.mes_fecha, 1),
        fa.mes_fecha,
        DATEADD(DAY, 5, DATEFROMPARTS(2025, fa.mes_fecha, 1)),
        DATEADD(DAY, 10, DATEFROMPARTS(2025, fa.mes_fecha, 1)),
        0,
        'I'
    FROM FacturasAgrupadas fa;

    SELECT 
        f.codFactura,
        dc.*
    INTO #detalleExpandida
    FROM #detalleCarga dc
    JOIN ddbba.factura f
        ON f.mesFacturado = dc.mes_fecha
       AND f.ID_socio = dc.socio
       AND f.estadoFactura = 'I';

    INSERT INTO ddbba.detalleFactura (
        codFactura,
        concepto,
        monto,
        descuento,
        recargoMorosidad,
        idCuotaCatSocio
    )
    SELECT
        d.codFactura,
        'Membresía Categoría',
        d.costoMembresia,
        CASE WHEN s.codGrupoFamiliar IS NOT NULL THEN d.costoMembresia * 0.15 ELSE 0 END,
        0,
        d.categoria
    FROM (
        SELECT DISTINCT codFactura, socio, categoria, costoMembresia
        FROM #detalleExpandida
    ) d
    JOIN ddbba.Socio s ON s.ID_socio = d.socio;

    ;WITH ActividadesPorSocio AS (
        SELECT socio, mes_fecha, COUNT(DISTINCT actividad) AS cant
        FROM #detalleCarga
        GROUP BY socio, mes_fecha
    )
    INSERT INTO ddbba.detalleFactura (
        codFactura,
        concepto,
        monto,
        descuento,
        recargoMorosidad,
        idCuotaAct
    )
    SELECT
        d.codFactura,
        'Actividad ' + CAST(d.actividad AS VARCHAR),
        d.costoActividadIndividual,
        CASE WHEN a.cant > 1 THEN d.costoActividadIndividual * 0.10 ELSE 0 END,
        0,
        d.actividad
    FROM #detalleExpandida d
    JOIN ActividadesPorSocio a
        ON d.socio = a.socio AND d.mes_fecha = a.mes_fecha;

    UPDATE f
    SET totalNeto = df.total
    FROM ddbba.factura f
    JOIN (
        SELECT codFactura, SUM(monto - descuento + recargoMorosidad) AS total
        FROM ddbba.detalleFactura
        GROUP BY codFactura
    ) df ON f.codFactura = df.codFactura;

    DROP TABLE #detalleCarga;
    DROP TABLE #detalleExpandida;

    PRINT 'Carga finalizada correctamente';
END;
GO

-------------------------------------------------------------------------------------------------
--Reporte 3:  cantidad de socios que han realizado alguna actividad de forma alternada(inasistencias)
CREATE OR ALTER PROCEDURE ddbba.reporteInasistenciasAlternadas
AS
BEGIN
    SET NOCOUNT ON;

    WITH PresentismoConContexto AS (
        SELECT 
            p.socio,
            p.act,
            p.fecha,
            p.presentismo,
            LAG(p.presentismo) OVER (PARTITION BY p.socio, p.act ORDER BY p.fecha) AS anterior,
            LEAD(p.presentismo) OVER (PARTITION BY p.socio, p.act ORDER BY p.fecha) AS siguiente
        FROM ddbba.Presentismo p
    ),
    InasistenciasAlternadas AS (
        SELECT 
            pc.socio,
            pc.act,
            pc.fecha
        FROM PresentismoConContexto pc
        WHERE pc.presentismo IN ('A', 'J')  -- la fila actual es una inasistencia
          AND ('P' IN (pc.anterior, pc.siguiente)) --tine al menos una P
    )

    SELECT 
        cs.nombreCat AS Categoria,
        ad.nombre AS Actividad,
        COUNT(*) AS CantidadInasistenciasAlternadas
    FROM InasistenciasAlternadas ia
    JOIN ddbba.socio s ON ia.socio = s.ID_socio
    JOIN ddbba.catSocio cs ON s.codCat = cs.codCat
    JOIN ddbba.actDeportiva ad ON ia.act = ad.codAct
    GROUP BY cs.nombreCat, ad.nombre
    ORDER BY CantidadInasistenciasAlternadas DESC;
END;
GO

---------------------------------------------------------------------------------------------
--Reporte 4:  socios que no han asistido a alguna clase de la actividad
CREATE OR ALTER PROCEDURE ddbba.SociosConAlgunaInasistencia
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        s.nombre,
        s.apellido,
        DATEDIFF(YEAR, s.fechaNac, GETDATE()) - 
            CASE 
                WHEN MONTH(s.fechaNac) > MONTH(GETDATE()) 
                     OR (MONTH(s.fechaNac) = MONTH(GETDATE()) AND DAY(s.fechaNac) > DAY(GETDATE()))
                THEN 1 ELSE 0 
            END AS edad,
        cs.nombreCat AS categoria,
        ad.nombre AS actividad
    FROM ddbba.socio s
    JOIN ddbba.catSocio cs ON s.codCat = cs.codCat
    JOIN ddbba.Presentismo p ON s.ID_socio = p.socio
    JOIN ddbba.actDeportiva ad ON p.act = ad.codAct
    WHERE p.presentismo = 'A' OR p.presentismo = 'J'
END;
GO
--------------------------------------------------------------------------------
--Reporte 1: Socios morosos recurrentes
CREATE OR ALTER PROCEDURE ddbba.MorososRecurrentes
    @FechaDesde DATE,
    @FechaHasta DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Paso 1: Obtener todas las morosidades del período con datos del socio
    WITH Morosidades AS (
        SELECT
            rm.socio,
            s.nroSocio,
            s.nombre,
            s.apellido,
            rm.mesAdeudado
        FROM ddbba.registroMoroso rm
        JOIN ddbba.socio s ON s.ID_socio = rm.socio
        WHERE rm.fechaMorosidad BETWEEN @FechaDesde AND @FechaHasta
    ),
    
    -- Paso 2: Contar morosidades por socio
    ConteoMorosidades AS (
        SELECT 
            socio,
            nroSocio,
            nombre,
            apellido,
            COUNT(*) AS CantidadIncumplimientos
        FROM Morosidades
        GROUP BY socio, nroSocio, nombre, apellido
        HAVING COUNT(*) > 2
    ),
    
    -- Paso 3: Calcular el ranking
    RankingMorosidades AS (
        SELECT *,
            RANK() OVER (ORDER BY CantidadIncumplimientos DESC) AS RankingMorosidad
        FROM ConteoMorosidades
    )

    -- Paso 4: Mostrar los resultados finales
    SELECT
        'Morosos Recurrentes' AS [Nombre del Reporte],
        CONCAT(CONVERT(VARCHAR, @FechaDesde, 103), ' al ', CONVERT(VARCHAR, @FechaHasta, 103)) AS [Periodo],
        r.nroSocio,
        CONCAT(r.nombre, ' ', r.apellido) AS [Nombre y Apellido],
        m.mesAdeudado AS [Mes Incumplido],
        r.RankingMorosidad
    FROM RankingMorosidades r
    JOIN Morosidades m ON r.socio = m.socio
    ORDER BY r.RankingMorosidad;
END;
GO




-----------------------------------------------------------------------------------------------------
--Reporte 2: ingresos mensuales por actividad
-- ================================================
CREATE OR ALTER PROCEDURE ddbba.Reporte_ingresos_por_actividad
AS
BEGIN
    SET NOCOUNT ON;

    WITH MontoFacturadoPorMes AS (
        SELECT 
            f.mesFacturado, 
            ad.nombre AS Actividad, 
            df.monto - df.descuento AS MontoConDescuento
        FROM ddbba.detalleFactura df
        JOIN ddbba.factura AS f ON f.codFactura = df.codFactura
        JOIN ddbba.actDeportiva AS ad ON ad.codAct = df.idCuotaAct
        WHERE df.concepto <> 'Membresía Categoría'
    )
    SELECT
        mesFacturado,
        ISNULL([Ajedrez], 0) AS Ajedrez,
        ISNULL([Baile Artístico], 0) AS [Baile Artístico],
        ISNULL([Futsal], 0) AS Futsal,
        ISNULL([Natación], 0) AS Natación,
        ISNULL([Taekwondo], 0) AS Taekwondo,
        ISNULL([Vóley], 0) AS Vóley
    FROM MontoFacturadoPorMes
    PIVOT (
        SUM(MontoConDescuento)
        FOR Actividad IN (
            [Ajedrez], 
            [Baile Artístico], 
            [Futsal], 
            [Natación], 
            [Taekwondo], 
            [Vóley]
        )
    ) AS ReporteMensual
    ORDER BY mesFacturado;
END;
GO
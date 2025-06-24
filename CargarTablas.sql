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
-----------------------------------------------------------------------------------------------------
--Reporte ingresos mensuales por actividad
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
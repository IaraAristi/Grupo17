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
        JOIN ddbba.factura f ON f.codFactura = df.codFactura
        JOIN ddbba.cuotaMensualActividad cma ON cma.ID_socio = df.ID_socio
        JOIN ddbba.actDeportiva ad ON ad.codAct = cma.codAct
        WHERE MONTH(cma.fechaGeneracion) = f.mesFacturado
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

--STORE PROCEDURES PARA DETALLE DE FACTURA Y FACTURA

CREATE OR ALTER PROCEDURE ddbba.GenerarCuotasMensuales
    @mes INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @fechaFactura DATE = DATEFROMPARTS(2025, @mes, 1);

    DELETE FROM ddbba.cuotaMensualCategoria WHERE MONTH(fechaGeneracion) = @mes;
    DELETE FROM ddbba.cuotaMensualActividad WHERE MONTH(fechaGeneracion) = @mes;
	
    INSERT INTO ddbba.cuotaMensualCategoria (
        ID_socio, codCat, precio_bruto, descuento_aplicado, fechaGeneracion
    )
    SELECT 
        s.ID_socio,
        s.codCat,
        t.costoMembresia,
        CASE 
            WHEN s.codGrupoFamiliar IS NOT NULL THEN t.costoMembresia * 0.10
            ELSE 0
        END,
        @fechaFactura
    FROM ddbba.socio s
    CROSS APPLY (
        SELECT TOP 1 *
        FROM ddbba.TarifarioCatSocio t
        WHERE t.catSocio = s.codCat
          AND t.fechaVigenciaHasta >= @fechaFactura
        ORDER BY t.fechaVigenciaHasta
    ) t
		WHERE s.codCat IS NOT NULL

    ;WITH actividades_presentes AS (
        SELECT 
            p.socio,
            p.act,
            COUNT(*) AS cantidadPresencias
        FROM ddbba.Presentismo p
        WHERE 
            MONTH(p.fecha) = @mes
            AND YEAR(p.fecha) = 2025
            AND p.presentismo = 'P'
        GROUP BY p.socio, p.act
    ),
    cantidad_actividades AS (
        SELECT socio, COUNT(DISTINCT act) AS cant_acts
        FROM actividades_presentes
        GROUP BY socio
    )
    INSERT INTO ddbba.cuotaMensualActividad (ID_socio, codAct, precio_bruto, descuento_aplicado, fechaGeneracion)
    SELECT 
        ap.socio,
        ap.act,
        ta.costoActividad,
        CASE 
            WHEN ca.cant_acts >= 2 THEN ta.costoActividad * 0.15
            ELSE 0
        END,
        @fechaFactura
    FROM actividades_presentes ap
    JOIN cantidad_actividades ca ON ca.socio = ap.socio
    CROSS APPLY (
        SELECT TOP 1 *
        FROM ddbba.TarifarioActividad t
        WHERE t.codAct = ap.act
          AND t.fechaVigenciaHasta >= @fechaFactura
        ORDER BY t.fechaVigenciaHasta
    ) ta;

    PRINT 'Cuotas mensuales generadas correctamente.';
END;
GO


CREATE OR ALTER PROCEDURE ddbba.GenerarDetalleFactura
    @mes INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @fechaFactura DATE = DATEFROMPARTS(2025, @mes, 1);

    DELETE FROM ddbba.detalleFactura
    WHERE codFactura IS NULL AND MONTH(@fechaFactura) = @mes;

    INSERT INTO ddbba.detalleFactura (codFactura, concepto, monto, descuento,ID_socio)
    SELECT 
        NULL,  
        CONCAT('Membresía ', cs.nombreCat, ' - ', s.nombre, ' ', s.apellido),
        cmmc.precio_bruto,
        cmmc.descuento_aplicado,
		s.ID_socio
    FROM ddbba.socio s
    JOIN ddbba.cuotaMensualCategoria cmmc ON cmmc.ID_socio = s.ID_socio
    JOIN ddbba.catSocio cs ON cs.codCat = s.codCat
    WHERE MONTH(cmmc.fechaGeneracion) = @mes;

    INSERT INTO ddbba.detalleFactura (codFactura, concepto, monto, descuento,ID_socio)
    SELECT 
        NULL,
        CONCAT('Actividad ', ad.nombre, ' - ', s.nombre, ' ', s.apellido),
        cma.precio_bruto,
        cma.descuento_aplicado,
		s.ID_socio
    FROM ddbba.socio s
    JOIN ddbba.cuotaMensualActividad cma ON cma.ID_socio = s.ID_socio
    JOIN ddbba.actDeportiva ad ON ad.codAct = cma.codAct
    WHERE MONTH(cma.fechaGeneracion) = @mes;

    PRINT 'Detalle de facturas generado.';
END;
GO

CREATE OR ALTER PROCEDURE ddbba.GenerarFacturasMensuales
    @mes INT
AS
BEGIN
    SET NOCOUNT ON;

	DELETE FROM ddbba.detalleFactura
    WHERE codFactura IN (
        SELECT codFactura FROM ddbba.factura WHERE mesFacturado = @mes
    );

    DELETE FROM ddbba.factura WHERE mesFacturado = @mes;

    INSERT INTO ddbba.factura (
        fechaEmision,
        mesFacturado,
        fechaVencimiento,
        fecha2Vencimiento,
        totalNeto,
        estadoFactura,
        idPago,
        ID_socio
    )
    SELECT 
        DATEFROMPARTS(2025, @mes, 1),
        @mes,
        DATEFROMPARTS(2025, @mes, 5),
        DATEFROMPARTS(2025, @mes, 10),
        0.00,
        'I',
        NULL,
        s.ID_socio
    FROM ddbba.socio s
    WHERE s.codGrupoFamiliar IS NULL OR s.codGrupoFamiliar = s.ID_socio;

	--agregar fk factura a detalle
	    UPDATE df
    SET codFactura = f.codFactura
    FROM ddbba.detalleFactura df
    JOIN ddbba.socio s ON df.ID_socio = s.ID_socio
    JOIN ddbba.factura f ON f.ID_socio = 
        CASE 
            WHEN s.codGrupoFamiliar IS NULL THEN s.ID_socio
            ELSE s.codGrupoFamiliar
        END
    WHERE f.mesFacturado = @mes;

    -- Calcular totales
    UPDATE f
    SET totalNeto = ISNULL(
        (SELECT SUM(monto - descuento)
         FROM ddbba.detalleFactura df
         WHERE df.codFactura = f.codFactura), 0.00)
    FROM ddbba.factura f
    WHERE f.mesFacturado = @mes

    PRINT 'Facturas base creadas correctamente.';
END;
GO

--INTENTE RELACIONAR LAS FACTURAS QUE TENEMOS CON LOS PAGOS QUE NOS DIERON EN EL EXCEL PERO NO COINCIDE NINGUNO
/*UPDATE f
SET f.idPago = p.idPago
FROM ddbba.factura f
JOIN ddbba.pagoFactura p
    ON f.ID_socio = p.codSocio
    AND f.totalNeto = p.montoTotal
    AND f.mesFacturado = MONTH(p.Fecha_Pago)
WHERE f.idPago IS NULL;*/

--SP PARA LLENAR PASES PILETA
CREATE OR ALTER PROCEDURE ddbba.InsertarPasesPileta
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#pases_temp') IS NOT NULL
        DROP TABLE #pases_temp;

    CREATE TABLE #pases_temp (
        tipo VARCHAR(10),
        fechaDesde DATE,
        fechaHasta DATE,
        idSocio INT
    );

    INSERT INTO #pases_temp (tipo, fechaDesde, fechaHasta, idSocio)
    VALUES
        ('día', '2025-01-20', '2025-01-20', 5),
        ('día', '2025-02-28', '2025-02-28', 12),
        ('día', '2025-02-28', '2025-02-28', 50),
        ('día', '2025-01-15', '2025-01-15', 87),
        ('día', '2025-02-10', '2025-02-10', 119),
        ('mes', '2025-01-01', '2025-01-31', 11),
        ('mes', '2025-02-01', '2025-02-28', 17);

    INSERT INTO ddbba.pasePileta (tipo, fechaDesde, fechaHasta, idSocio, codCostoPileta)
    SELECT 
		p.tipo,
        p.fechaDesde,
        p.fechaHasta,
        p.idSocio,
        cp.codCostoPileta
    FROM #pases_temp p
    JOIN ddbba.socio s ON s.ID_socio = p.idSocio
    JOIN ddbba.catSocio cs ON cs.codCat = s.codCat
    OUTER APPLY (
        SELECT TOP 1 cp.codCostoPileta
        FROM ddbba.costoPileta cp
        WHERE cp.tipo COLLATE Modern_Spanish_CI_AS = p.tipo COLLATE Modern_Spanish_CI_AS
          AND cp.categoria COLLATE Modern_Spanish_CI_AS = 
                CASE 
                    WHEN cs.nombreCat COLLATE Modern_Spanish_CI_AS LIKE '%menor%' THEN 'menor'
                    ELSE 'adulto'
                END
          AND cp.fechaVigenciaHasta >= p.fechaDesde
        ORDER BY cp.fechaVigenciaHasta ASC
    ) cp;

    DROP TABLE #pases_temp;

    PRINT 'Pases de pileta insertados correctamente con codCostoPileta calculado.';
END;
GO


--SP DETALLES DE FACTURA PASE PILETA SOCIOS
CREATE OR ALTER PROCEDURE ddbba.GenerarDetallePasePileta
    @mes INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @inicioMes DATE = DATEFROMPARTS(2025, @mes, 1);
    DECLARE @finMes DATE = EOMONTH(@inicioMes);

    -- Elimina detalles del mes actual vinculados a Pase Pileta que no tengan codFactura todavía
    DELETE FROM ddbba.detalleFactura
    WHERE codFactura IS NULL
      AND concepto LIKE 'Pase pileta%';

    INSERT INTO ddbba.detalleFactura (codFactura, concepto, monto, descuento, ID_socio)
    SELECT 
        NULL,
        CONCAT('Pase pileta - ', cp.tipo, ' (', FORMAT(pp.fechaDesde, 'dd/MM/yyyy'), ')'),
        cp.costo,
        0,
        s.ID_socio
    FROM ddbba.pasePileta pp
    JOIN ddbba.costoPileta cp ON cp.codCostoPileta = pp.codCostoPileta
    JOIN ddbba.socio s ON s.ID_socio = pp.idSocio
    WHERE pp.fechaDesde BETWEEN @inicioMes AND @finMes;
    
    PRINT 'Detalles de pase pileta generados';
END;
GO

--SP PARA PAGOS A CUENTA EN CASO DE LLUVIAS
CREATE OR ALTER PROCEDURE ddbba.GenerarReintegrosPiletaPorLluvia
AS
BEGIN
    SET NOCOUNT ON;

    -- Paso 1: Verificar cuenta existente o crearla si no existe
    INSERT INTO ddbba.cuenta (socio, saldoAFavor)
    SELECT s.ID_socio, 0.00
    FROM ddbba.socio s
    WHERE NOT EXISTS (
        SELECT 1 FROM ddbba.cuenta c WHERE c.socio = s.ID_socio
    );

    -- Paso 2: Depuración - Visualizar fechas con lluvia
    SELECT fecha
    INTO #dias_lluvia
    FROM ##lluvias_diarias
    WHERE lluvia_mm > 0;

    -- Paso 3: Detectar detalles de factura por pase de pileta con lluvia
    SELECT 
        df.codDetalleFac,
        df.ID_socio,
        p.fechaDesde,
        p.fechaHasta,
        COUNT(*) AS dias_lluvia_en_rango,
        df.monto AS monto_detalle,
        ROUND(df.monto * 0.60, 2) AS reintegro
    INTO #reintegros_detectados
    FROM ddbba.detalleFactura df
    JOIN ddbba.pasePileta p ON p.idSocio = df.ID_socio
    CROSS APPLY (
        SELECT DATEADD(DAY, n, p.fechaDesde) AS dia
        FROM (SELECT TOP (DATEDIFF(DAY, p.fechaDesde, p.fechaHasta) + 1) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
              FROM sys.all_objects) AS dias
    ) AS rango
    WHERE rango.dia IN (SELECT fecha FROM #dias_lluvia)
      AND df.concepto LIKE '%pileta%'
    GROUP BY df.codDetalleFac, df.ID_socio, p.fechaDesde, p.fechaHasta, df.monto;

    -- Paso 4: Generar reintegros
    INSERT INTO ddbba.pagoCuenta (monto, cuenta, detalleFactura)
    SELECT 
        r.reintegro,
        c.codCuenta,
        r.codDetalleFac
    FROM #reintegros_detectados r
    JOIN ddbba.cuenta c ON c.socio = r.ID_socio;

    -- Paso 5: Actualizar saldos
    UPDATE c
    SET c.saldoAFavor = c.saldoAFavor + r.reintegro
    FROM ddbba.cuenta c
    JOIN #reintegros_detectados r ON r.ID_socio = c.socio;

    PRINT 'Reintegros por lluvia procesados.';
END;
GO

--SP PARA CARGAR REEMBOLSOS
CREATE OR ALTER PROCEDURE ddbba.InsertarReembolso
    @codPago INT,
    @motivo VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ID_socio INT;
    DECLARE @monto DECIMAL(9,2);

    -- Buscar datos en pagoFactura
    SELECT 
        @ID_socio = codSocio,
        @monto = montoTotal
    FROM ddbba.pagoFactura
    WHERE codPago = @codPago;

    -- Insertar en reembolso
    INSERT INTO ddbba.reembolso (
        fecha,
        monto,
        motivo,
        ID_socio,
        ID_pago
    )
    VALUES (
        GETDATE(),
        @monto,
        @motivo,
        @ID_socio,
        @codPago
    );

    PRINT 'Reembolso registrado correctamente.';
END;
GO

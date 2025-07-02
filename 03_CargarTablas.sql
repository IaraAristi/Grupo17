/*Entrega 5:Conjunto de pruebas.Creación de Stored Procedures para la carga y actualización de tablas fuera del excel.
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

--Asignar inscripciones
CREATE OR ALTER PROCEDURE socio.AsignarInscripcionesASocios
AS
BEGIN
    SET NOCOUNT ON;

    -- Crear una tabla temporal con los socios y su grupo NTILE
    IF OBJECT_ID('tempdb..#socios_ntile') IS NOT NULL
        DROP TABLE #socios_ntile;

    SELECT 
        s.ID_socio,
        grupo = NTILE(10) OVER (ORDER BY s.ID_socio)
    INTO #socios_ntile
    FROM socio.socio s
    WHERE s.codInscripcion IS NULL;

    -- Actualizar cada socio con el ID de inscripción correspondiente al grupo
    UPDATE s
    SET s.codInscripcion = i.idInscripcion
    FROM socio.socio s
    JOIN #socios_ntile sn ON s.ID_socio = sn.ID_socio
    JOIN (
        SELECT i.idInscripcion, ROW_NUMBER() OVER (ORDER BY i.idInscripcion) AS grupo
        FROM socio.inscripcion i
    ) i ON sn.grupo = i.grupo;

    PRINT 'Inscripciones asignadas a socios correctamente.';
END;
GO

--Cargar categoria de socio en Socio
CREATE OR ALTER PROCEDURE socio.ActualizarCategoriaSociosPorEdad
AS
BEGIN
    -- Desactivar el conteo de filas afectadas para que no moleste el mensaje
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE s
        SET s.codCat = cs.codCat
        FROM
            socio.socio AS s
        JOIN
            (
                -- Subconsulta para calcular la edad actual de cada socio
                SELECT
                    ID_Socio,
                    fechaNac,
                    -- Calcula la edad en años completos 
                    DATEDIFF(year, fechaNac, GETDATE()) -
                    CASE
                        WHEN MONTH(fechaNac) > MONTH(GETDATE()) OR
                             (MONTH(fechaNac) = MONTH(GETDATE()) AND DAY(fechaNac) > DAY(GETDATE()))
                        THEN 1
                        ELSE 0
                    END AS EdadActual
                FROM
                    socio.socio
                WHERE
                    fechaNac IS NOT NULL
            ) AS s_edad ON s.ID_Socio = s_edad.ID_Socio
        JOIN
            club.catSocio AS cs ON s_edad.EdadActual >= cs.edad_desde
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

--Actualizar el número de grupo familiar para aquellos socios que sean responsables de pago del grupo
CREATE OR ALTER PROCEDURE socio.ActualizarGrupoFamiliarResponsables
AS
BEGIN
    SET NOCOUNT ON;

    -- Actualiza el campo grupoFamiliar de todos los socios responsables (que tienen a otros socios a cargo)
    UPDATE s
    SET codGrupoFamiliar = s.ID_socio
    FROM socio.socio s
    WHERE EXISTS (
        SELECT 1
        FROM socio.socio m
        WHERE m.codGrupoFamiliar = s.ID_socio
    )
    AND s.codGrupoFamiliar IS NULL;
END;
GO

--Generar registro moroso
CREATE OR ALTER PROCEDURE tesoreria.GenerarRegistroMoroso
    @anio INT,
    @mes INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tesoreria.registroMoroso (
        montoAdeudado,
        fechaMorosidad,
        mesAdeudado,
        mesAplicado,
        socio,
        codFactura
    )
    SELECT
        f.totalNeto AS montoAdeudado,
        f.fecha2Vencimiento AS fechaMorosidad,
        f.mesFacturado AS mesAdeudado,
        (f.mesFacturado + 1) AS mesAplicado,
        f.ID_socio,
        f.codFactura
    FROM tesoreria.factura f
    WHERE
        f.estadoFactura = 'I'
        AND f.mesFacturado <= @mes
        AND YEAR(f.fechaEmision) = @anio
        AND NOT EXISTS (
            SELECT 1
            FROM tesoreria.registroMoroso rm
            WHERE rm.codFactura = f.codFactura
        );

    PRINT 'Registro de morosos generado correctamente.';
END;
GO


--DETALLE DE FACTURA Y FACTURA
--Generación de cuotas mensuales(Categoria+Actividad)
CREATE OR ALTER PROCEDURE tesoreria.GenerarCuotasMensuales
    @mes INT,
	@anio INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @fechaFactura DATE = DATEFROMPARTS(@anio, @mes, 1);

    DELETE FROM tesoreria.cuotaMensualCategoria WHERE MONTH(fechaGeneracion) = @mes;
    DELETE FROM tesoreria.cuotaMensualActividad WHERE MONTH(fechaGeneracion) = @mes;
	
    INSERT INTO tesoreria.cuotaMensualCategoria (
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
    FROM socio.socio s
    CROSS APPLY (
        SELECT TOP 1 *
        FROM club.TarifarioCatSocio t
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
        FROM club.Presentismo p
        WHERE 
            MONTH(p.fecha) = @mes
            AND YEAR(p.fecha) = @anio
            AND p.presentismo = 'P'
        GROUP BY p.socio, p.act
    ),
    cantidad_actividades AS (
        SELECT socio, COUNT(DISTINCT act) AS cant_acts
        FROM actividades_presentes
        GROUP BY socio
    )
    INSERT INTO tesoreria.cuotaMensualActividad (ID_socio, codAct, precio_bruto, descuento_aplicado, fechaGeneracion)
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
        FROM club.TarifarioActividad t
        WHERE t.codAct = ap.act
          AND t.fechaVigenciaHasta >= @fechaFactura
        ORDER BY t.fechaVigenciaHasta
    ) ta;

    PRINT 'Cuotas mensuales generadas correctamente.';
END;
GO

--Generación de detalle de factura
CREATE OR ALTER PROCEDURE tesoreria.GenerarDetalleFactura
    @mes INT,
	@anio INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @fechaFactura DATE = DATEFROMPARTS(@anio, @mes, 1);

    DELETE FROM tesoreria.detalleFactura
    WHERE codFactura IS NULL AND MONTH(@fechaFactura) = @mes;

    INSERT INTO tesoreria.detalleFactura (codFactura, concepto, monto, descuento,ID_socio)
    SELECT 
        NULL,  
        CONCAT('Membresía ', cs.nombreCat, ' - ', s.nombre, ' ', s.apellido),
        cmmc.precio_bruto,
        cmmc.descuento_aplicado,
		s.ID_socio
    FROM socio.socio s
    JOIN tesoreria.cuotaMensualCategoria cmmc ON cmmc.ID_socio = s.ID_socio
    JOIN club.catSocio cs ON cs.codCat = s.codCat
    WHERE MONTH(cmmc.fechaGeneracion) = @mes;

    INSERT INTO tesoreria.detalleFactura (codFactura, concepto, monto, descuento,ID_socio)
    SELECT 
        NULL,
        CONCAT('Actividad ', ad.nombre, ' - ', s.nombre, ' ', s.apellido),
        cma.precio_bruto,
        cma.descuento_aplicado,
		s.ID_socio
    FROM socio.socio s
    JOIN tesoreria.cuotaMensualActividad cma ON cma.ID_socio = s.ID_socio
    JOIN club.actDeportiva ad ON ad.codAct = cma.codAct
    WHERE MONTH(cma.fechaGeneracion) = @mes;

    PRINT 'Detalle de facturas generado.';
END;
GO

--Generación de facturas mensuales
CREATE OR ALTER PROCEDURE tesoreria.GenerarFacturasMensuales
    @mes INT,
	@anio INT
AS
BEGIN
    SET NOCOUNT ON;

	DELETE FROM tesoreria.detalleFactura
    WHERE codFactura IN (
        SELECT codFactura FROM tesoreria.factura WHERE mesFacturado = @mes
    );

    DELETE FROM tesoreria.factura WHERE mesFacturado = @mes;

    INSERT INTO tesoreria.factura (
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
        DATEFROMPARTS(@anio, @mes, 1),
        @mes,
        DATEFROMPARTS(@anio, @mes, 5),
        DATEFROMPARTS(@anio, @mes, 10),
        0.00,
        'I',
        NULL,
        s.ID_socio
    FROM socio.socio s
    WHERE s.codGrupoFamiliar IS NULL OR s.codGrupoFamiliar = s.ID_socio;

	--agregar fk factura a detalle
	    UPDATE df
    SET codFactura = f.codFactura
    FROM tesoreria.detalleFactura df
    JOIN socio.socio s ON df.ID_socio = s.ID_socio
    JOIN tesoreria.factura f ON f.ID_socio = 
        CASE 
            WHEN s.codGrupoFamiliar IS NULL THEN s.ID_socio
            ELSE s.codGrupoFamiliar
        END
    WHERE f.mesFacturado = @mes;

    -- Calcular totales
    UPDATE f
    SET totalNeto = ISNULL(
        (SELECT SUM(monto - descuento)
         FROM tesoreria.detalleFactura df
         WHERE df.codFactura = f.codFactura), 0.00)
    FROM tesoreria.factura f
    WHERE f.mesFacturado = @mes

    PRINT 'Facturas base creadas correctamente.';
END;
GO

--PASES PILETA
--Asignación de los costos de pileta a los pases
--SP PARA LLENAR PASES PILETA
CREATE OR ALTER PROCEDURE club.AsignarCostoPiletaAPases
AS
BEGIN
    SET NOCOUNT ON;
 
    UPDATE p
    SET p.codCostoPileta = cp.codCostoPileta
    FROM club.pasePileta p
    JOIN socio.socio s ON s.ID_socio = p.idSocio
    JOIN club.catSocio cs ON cs.codCat = s.codCat
    OUTER APPLY (
        SELECT TOP 1 cp.codCostoPileta
        FROM club.costoPileta cp
        WHERE cp.tipo COLLATE Modern_Spanish_CI_AS = p.tipo COLLATE Modern_Spanish_CI_AS
          AND cp.categoria COLLATE Modern_Spanish_CI_AS = 
                CASE 
                    WHEN cs.nombreCat COLLATE Modern_Spanish_CI_AS LIKE '%menor%' 
                         OR cs.nombreCat COLLATE Modern_Spanish_CI_AS LIKE '%Menor%' THEN 'menor'
                    ELSE 'adulto'
                END
          AND cp.fechaVigenciaHasta >= p.fechaDesde
        ORDER BY cp.fechaVigenciaHasta ASC
    ) cp
    WHERE p.codCostoPileta IS NULL;
 
    PRINT 'CodCostoPileta actualizado correctamente en los pases existentes.';
END;
GO
 


--DETALLES DE FACTURA PASE PILETA SOCIOS
--Generación de los detalles de factura para la colonia
CREATE OR ALTER PROCEDURE tesoreria.GenerarDetalleFacturaColonia
    @mes INT,
    @anio INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tesoreria.detalleFactura (
        ID_socio,
        concepto,
        monto,
        descuento
    )
    SELECT 
        ac.codSocio,
        CONCAT('Colonia de verano - Turno ', cv.turno),
        cc.costo,
        0
    FROM club.InscripcionColonia ac
    JOIN club.coloniaVerano cv ON ac.codColonia = cv.codColonia
    JOIN club.costoColonia cc ON cc.turno = cv.turno AND cc.fechaVigenciaHasta >= DATEFROMPARTS(@anio, @mes, 1)
    WHERE cv.mes = @mes AND cv.anio = @anio
      AND NOT EXISTS (
            SELECT 1
            FROM tesoreria.detalleFactura df
            WHERE df.ID_socio = ac.codSocio
              AND df.concepto LIKE CONCAT('Colonia de verano%', cv.turno)
        );
END;
GO

--REINTEGROS PARA PAGOS A CUENTA EN CASO DE LLUVIAS
--Generación de reintegros a pagos por motivo de lluvia
--SP PARA PAGOS A CUENTA EN CASO DE LLUVIAS
CREATE OR ALTER PROCEDURE tesoreria.GenerarReintegrosPiletaPorLluvia
AS
BEGIN
    SET NOCOUNT ON;
 
    -- Crear cuentas si no existen
    INSERT INTO socio.cuenta (socio, saldoAFavor)
    SELECT s.ID_socio, 0.00
    FROM socio.socio s
    WHERE NOT EXISTS (
        SELECT 1 FROM socio.cuenta c WHERE c.socio = s.ID_socio
    );
 
    -- Días de lluvia
    IF OBJECT_ID('tempdb..#dias_lluvia') IS NOT NULL DROP TABLE #dias_lluvia;
    SELECT fecha INTO #dias_lluvia
    FROM ##lluvias_diarias
    WHERE lluvia_mm > 0;
 
    -- Costos diarios para tipo "mes"
    IF OBJECT_ID('tempdb..#costos_dia') IS NOT NULL DROP TABLE #costos_dia;
    SELECT 
        p.codPase,
        p.idSocio,
        cp.costo AS costo_diario
    INTO #costos_dia
    FROM club.pasePileta p
    JOIN socio.socio s ON s.ID_socio = p.idSocio
    JOIN club.catSocio cs ON cs.codCat = s.codCat
    JOIN club.costoPileta cp ON 
        cp.tipo COLLATE Modern_Spanish_CI_AS = 'día' COLLATE Modern_Spanish_CI_AS AND
        cp.categoria COLLATE Modern_Spanish_CI_AS = 
            CASE 
                WHEN cs.nombreCat COLLATE Modern_Spanish_CI_AS LIKE '%menor%' THEN 'menor'
                ELSE 'adulto'
            END COLLATE Modern_Spanish_CI_AS
    WHERE p.tipo = 'mes';
 
    -- Reintegros por PASE MES
    IF OBJECT_ID('tempdb..#reintegros_mes') IS NOT NULL DROP TABLE #reintegros_mes;
    SELECT 
        df.codDetalleFac,
        df.ID_socio,
        COUNT(*) AS dias_lluvia_en_rango,
        ROUND(cd.costo_diario * COUNT(*) * 0.60, 2) AS reintegro
    INTO #reintegros_mes
    FROM tesoreria.detalleFactura df
    JOIN club.pasePileta p ON p.idSocio = df.ID_socio AND df.concepto LIKE '%pileta%' AND p.tipo = 'mes'
    LEFT JOIN #costos_dia cd ON cd.codPase = p.codPase
    CROSS APPLY (
        SELECT DATEADD(DAY, n, p.fechaDesde) AS dia
        FROM (SELECT TOP (DATEDIFF(DAY, p.fechaDesde, p.fechaHasta) + 1) 
              ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
              FROM sys.all_objects) AS dias
    ) AS rango
    WHERE rango.dia IN (SELECT fecha FROM #dias_lluvia)
    GROUP BY df.codDetalleFac, df.ID_socio, cd.costo_diario;
 
    -- Reintegros por PASE DÍA
    IF OBJECT_ID('tempdb..#reintegros_dia') IS NOT NULL DROP TABLE #reintegros_dia;
    SELECT 
        df.codDetalleFac,
        df.ID_socio,
        1 AS dias_lluvia_en_rango,
        ROUND(df.monto * 0.60, 2) AS reintegro
    INTO #reintegros_dia
    FROM tesoreria.detalleFactura df
    JOIN club.pasePileta p ON p.idSocio = df.ID_socio AND df.concepto LIKE '%pileta%' AND p.tipo = 'día'
    WHERE p.fechaDesde IN (SELECT fecha FROM #dias_lluvia);
 
    -- Unificar resultados
    IF OBJECT_ID('tempdb..#reintegros_total') IS NOT NULL DROP TABLE #reintegros_total;
    SELECT * INTO #reintegros_total FROM #reintegros_mes
    UNION ALL
    SELECT * FROM #reintegros_dia;
 
    -- Insertar reintegros
    INSERT INTO tesoreria.pagoCuenta (monto, cuenta, detalleFactura)
    SELECT 
        r.reintegro,
        c.codCuenta,
        r.codDetalleFac
    FROM #reintegros_total r
    JOIN socio.cuenta c ON c.socio = r.ID_socio
    WHERE r.reintegro > 0;
 
    -- Actualizar saldos
    UPDATE c
    SET c.saldoAFavor = c.saldoAFavor + r.reintegro
    FROM socio.cuenta c
    JOIN #reintegros_total r ON r.ID_socio = c.socio
    WHERE r.reintegro > 0;
 
    PRINT 'Reintegros por lluvia generados correctamente.';
END;
GO


--CARGAR REEMBOLSOS
--Inserción de reembolsos
CREATE OR ALTER PROCEDURE tesoreria.InsertarReembolso
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
    FROM tesoreria.pagoFactura
    WHERE codPago = @codPago;

    -- Insertar en reembolso
    INSERT INTO tesoreria.reembolso (
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

--ASIGNACION COSTO DE INGRESO PARA INVITADOS PILETA
CREATE OR ALTER PROCEDURE club.AsignarCostoIngresoInvitados
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ipi
    SET codCostoIngreso = cp.codCostoIngreso
    FROM club.ingresoPiletaInvitado ipi
    JOIN club.invitado i ON i.codInvitado = ipi.codInvitado
    OUTER APPLY (
        SELECT TOP 1 cp.codCostoIngreso
        FROM club.costoPiletaInvitado cp
        WHERE 
            cp.edad = CASE 
                        WHEN DATEDIFF(YEAR, i.fechaNac, ipi.fecha) - 
                             CASE WHEN MONTH(ipi.fecha) < MONTH(i.fechaNac) 
                                  OR (MONTH(ipi.fecha) = MONTH(i.fechaNac) AND DAY(ipi.fecha) < DAY(i.fechaNac)) 
                             THEN 1 ELSE 0 END < 18 
                        THEN 'menor' ELSE 'adulto' END
            AND cp.fechaVigenteHasta >= ipi.fecha
        ORDER BY cp.fechaVigenteHasta
    ) cp
    WHERE ipi.codCostoIngreso IS NULL;

    PRINT 'Costo de ingreso asignado a invitados correctamente.';
END;
GO

--GENERACION FACTURAS INVITADOS
CREATE OR ALTER PROCEDURE tesoreria.GenerarFacturasInvitados
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @hoy DATE = GETDATE();

    -- Genera una única factura por invitado, sumando los ingresos no facturados
    INSERT INTO tesoreria.facturaInvitado (fechaEmision, codInvitado, idPago, monto)
    SELECT 
        @hoy,
        ipi.codInvitado,
        NULL,
        SUM(cpi.precio)
    FROM club.ingresoPiletaInvitado ipi
    JOIN club.costoPiletaInvitado cpi ON cpi.codCostoIngreso = ipi.codCostoIngreso
    GROUP BY ipi.codInvitado;

    PRINT 'Facturas de invitados generadas correctamente con su monto.';
END;
GO

--ASIGNACIÓN CODICO DE COSTO DE LA COLONIA
CREATE OR ALTER PROCEDURE club.AsignarCostoColonia
	@mes INT,
    @anio INT
AS
BEGIN
    DECLARE @fecha DATE = DATEFROMPARTS(@anio, @mes, 1);

    UPDATE c
    SET c.codCostoColonia = cc.codCostoColonia
    FROM club.coloniaVerano c
    JOIN club.costoColonia cc ON
        cc.turno COLLATE Modern_Spanish_CI_AS = c.turno COLLATE Modern_Spanish_CI_AS
        AND cc.fechaVigenciaHasta >= @fecha
    WHERE c.codCostoColonia IS NULL;
END;
GO


--GENERAR DETALLES DE FACTURA POR COLONIA
CREATE OR ALTER PROCEDURE tesoreria.GenerarDetalleFacturaColonia
    @mes INT,
    @anio INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tesoreria.detalleFactura (
        ID_socio,
        concepto,
        monto,
        descuento
    )
    SELECT 
        ac.codSocio,
        CONCAT('Colonia de verano - Turno ', cv.turno),
        cc.costo,
        0
    FROM club.InscripcionColonia ac
    JOIN club.coloniaVerano cv ON ac.codColonia = cv.codColonia
    JOIN club.costoColonia cc ON cc.turno = cv.turno 
                              AND cc.fechaVigenciaHasta >= DATEFROMPARTS(@anio, @mes, 1)
    WHERE cv.mes = @mes AND cv.anio = @anio
      AND NOT EXISTS (
            SELECT 1
            FROM tesoreria.detalleFactura df
            WHERE df.ID_socio = ac.codSocio
              AND df.concepto LIKE CONCAT('Colonia de verano - Turno ', cv.turno)
        );
END;
GO

--ASIGNAR COSTO A ALQUILER DE SUM
CREATE OR ALTER PROCEDURE club.AsignarCostoSUM
	@mes INT,
    @anio INT
AS
BEGIN
    DECLARE @fecha DATE = DATEFROMPARTS(@anio, @mes, 1);

    UPDATE a
    SET a.codCostoSUM = cs.codCostoSUM
    FROM club.alquilerSUM a
    JOIN club.costoSUM cs ON cs.fechaVigenciaHasta >= @fecha
    WHERE a.codCostoSUM IS NULL;
END;
GO

--GENERAR DETALLE DE FACTURA POR ALQUILER DE SUM
CREATE OR ALTER PROCEDURE tesoreria.GenerarDetalleFacturaSUM
    @mes INT,
    @anio INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tesoreria.detalleFactura (
        ID_socio,
        concepto,
        monto,
		descuento
    )
    SELECT 
        a.socio,
        CONCAT('Alquiler SUM - ', a.turno, ' - ', FORMAT(a.fecha, 'yyyy-MM-dd')),
        cs.costo,
		0
    FROM club.alquilerSUM a
    JOIN club.costoSUM cs ON cs.codCostoSUM = a.codCostoSUM
    WHERE MONTH(a.fecha) = @mes AND YEAR(a.fecha) = @anio
      AND NOT EXISTS (
            SELECT 1
            FROM tesoreria.detalleFactura df
            WHERE df.ID_socio = a.socio
              AND df.concepto LIKE CONCAT('Alquiler SUM - ', a.turno, ' - ', FORMAT(a.fecha, 'yyyy-MM-dd'))
        );
END;
GO

--SP DETALLES DE FACTURA PASE PILETA SOCIOS
--SP DETALLES DE FACTURA PASE PILETA SOCIOS
CREATE OR ALTER PROCEDURE tesoreria.GenerarDetallePasePileta
    @mes INT,
	@anio INT
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE @inicioMes DATE = DATEFROMPARTS(@anio, @mes, 1);
    DECLARE @finMes DATE = EOMONTH(@inicioMes);
 
    -- Elimina detalles del mes actual vinculados a Pase Pileta que no tengan codFactura todavía
    DELETE FROM tesoreria.detalleFactura
    WHERE codFactura IS NULL
      AND concepto LIKE 'Pase pileta%';
 
    INSERT INTO tesoreria.detalleFactura (codFactura, concepto, monto, descuento, ID_socio)
    SELECT 
        NULL,
        CONCAT('Pase pileta - ', cp.tipo, ' (', FORMAT(pp.fechaDesde, 'dd/MM/yyyy'), ')'),
        cp.costo,
        0,
        s.ID_socio
    FROM club.pasePileta pp
    JOIN club.costoPileta cp ON cp.codCostoPileta = pp.codCostoPileta
    JOIN socio.socio s ON s.ID_socio = pp.idSocio
    WHERE pp.fechaDesde BETWEEN @inicioMes AND @finMes;
    PRINT 'Detalles de pase pileta generados';
END;
GO
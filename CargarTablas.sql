USE Com2900G17
GO

--Cargar categoria de socio en Socio
-- ================================================
-- Nombre: USP_ActualizarCategoriaSociosPorEdad
-- Descripción: Actualiza la columna Categoria_Socio en la tabla Socios
--              basándose en la fecha de nacimiento del socio y las reglas
--              definidas en la tabla Categoria_Socios.
-- Fecha Creación: 2025-06-22
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

CREATE OR ALTER PROCEDURE ddbba.cargarDetalleFactura
    @rutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Eliminar tabla temporal si ya existe
    IF OBJECT_ID('tempdb..#detalle_temp') IS NOT NULL
        DROP TABLE #detalle_temp;

	CREATE TABLE #detalle_temp (
    socio                        INT,
    categoria                    INT,
    actividad                    INT,
    costoActividadIndividual     DECIMAL(9,2),
    costoMembresia               DECIMAL(9,2),
    mes_fecha                    INT,
    nombre_actividad             VARCHAR(100),
    nombre_mes                   VARCHAR(20),
    codAct                       INT
	);
	DECLARE @sql NVARCHAR(MAX) = N'
        BULK INSERT #detalle_temp
        FROM ''' + @rutaArchivo + N'''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n''
        );
    ';
    EXEC sp_executesql @sql;
	SELECT TOP 10 * FROM #detalle_temp;

	INSERT INTO ddbba.detalleFactura(
	concepto,
	monto,
	descuento,
	recargoMorosidad,
	idCuotaCatSocio
	)
	SELECT
	'Membresia' AS Concepto,
	dc.costoMembresia AS Monto,
	CASE 
		WHEN s.codGrupoFamiliar IS NOT NULL THEN dc.costoMembresia* 0.10
		ELSE 0
	END AS Descuento,
	0 AS RecargoMorosidad,
	dc.categoria AS idCuotaCatUsuario
	FROM (
		SELECT socio, categoria, costoMembresia,
		row_number() OVER(PARTITION BY socio ORDER BY actividad) AS rn
		FROM #detalle_temp
	) dc
	JOIN ddbba.socio s ON s.ID_socio=dc.socio
	WHERE dc.rn=1;

	;WITH ActividadesPorSocio AS(
		SELECT socio, COUNT(distinct actividad) AS cantActividades
		FROM #detalle_temp
		GROUP BY socio
	)
	INSERT INTO ddbba.detalleFactura(
		concepto,
		monto,
		descuento,
		recargoMorosidad,
		idCuotaAct
	)
	SELECT 
	'Actividad' + CAST(d.actividad AS VARCHAR),
	d.costoActividadIndividual,
	CASE 
		WHEN a.cantActividades >1 THEN d.costoActividadIndividual * 0.15
		ELSE 0
	END,
	0,
	d.actividad
	FROM #detalle_temp d
	JOIN ActividadesPorSocio a ON a.socio=d.socio;
	DROP TABLE #detalle_temp
END;
GO
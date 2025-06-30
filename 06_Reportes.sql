USE Com2900G17
GO

--REPORTES

--Reporte 1: Socios morosos recurrentes
CREATE OR ALTER PROCEDURE reportes.MorososRecurrentes
    @FechaDesde DATE,
    @FechaHasta DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Paso 1: Obtener todas las morosidades del per�odo con datos del socio
    WITH Morosidades AS (
        SELECT
            rm.socio,
            s.nroSocio,
            s.nombre,
            s.apellido,
            rm.mesAdeudado
        FROM tesoreria.registroMoroso rm
        JOIN socio.socio s ON s.ID_socio = rm.socio
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




--Reporte 2: ingresos mensuales por actividad
CREATE OR ALTER PROCEDURE reportes.Reporte_ingresos_por_actividad
AS
BEGIN
    SET NOCOUNT ON;

    WITH MontoFacturadoPorMes AS (
        SELECT 
            f.mesFacturado,
            ad.nombre AS Actividad,
            df.monto - df.descuento AS MontoConDescuento
        FROM tesoreria.detalleFactura df
        JOIN tesoreria.factura f ON f.codFactura = df.codFactura
        JOIN tesoreria.cuotaMensualActividad cma ON cma.ID_socio = df.ID_socio
        JOIN club.actDeportiva ad ON ad.codAct = cma.codAct
        WHERE MONTH(cma.fechaGeneracion) = f.mesFacturado
    )
    SELECT
        mesFacturado,
        ISNULL([Ajedrez], 0) AS Ajedrez,
        ISNULL([Baile Art�stico], 0) AS [Baile Art�stico],
        ISNULL([Futsal], 0) AS Futsal,
        ISNULL([Nataci�n], 0) AS Nataci�n,
        ISNULL([Taekwondo], 0) AS Taekwondo,
        ISNULL([V�ley], 0) AS V�ley
    FROM MontoFacturadoPorMes
    PIVOT (
        SUM(MontoConDescuento)
        FOR Actividad IN (
            [Ajedrez], 
            [Baile Art�stico], 
            [Futsal], 
            [Nataci�n], 
            [Taekwondo], 
            [V�ley]
        )
    ) AS ReporteMensual
    ORDER BY mesFacturado;
END;
GO

--Reporte 3:  cantidad de socios que han realizado alguna actividad de forma alternada(inasistencias)
CREATE OR ALTER PROCEDURE reportes.reporteInasistenciasAlternadas
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
        FROM club.Presentismo p
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
    JOIN socio.socio s ON ia.socio = s.ID_socio
    JOIN socio.catSocio cs ON s.codCat = cs.codCat
    JOIN socio.actDeportiva ad ON ia.act = ad.codAct
    GROUP BY cs.nombreCat, ad.nombre
    ORDER BY CantidadInasistenciasAlternadas DESC;
END;
GO

--Reporte 4:  socios que no han asistido a alguna clase de la actividad
CREATE OR ALTER PROCEDURE reportes.SociosConAlgunaInasistencia
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
    FROM socio.socio s
    JOIN socio.catSocio cs ON s.codCat = cs.codCat
    JOIN socio.Presentismo p ON s.ID_socio = p.socio
    JOIN socio.actDeportiva ad ON p.act = ad.codAct
    WHERE p.presentismo = 'A' OR p.presentismo = 'J'
END;
GO

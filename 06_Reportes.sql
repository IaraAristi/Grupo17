/*Entrega 6:Reportes solicitados. Creación de Stored Procedures para la generación de reportes
Reporte 1: Reporte de los socios morosos, que hayan incumplido en más de dos oportunidades dado un
rango de fechas a ingresar. El reporte debe contener los siguientes datos:
Nombre del reporte: Morosos Recurrentes
Período: rango de fechas
Nro de socio
Nombre y apellido.
Mes incumplido
Ordenados de Mayor a menor por ranking de morosidad
El mismo debe ser desarrollado utilizando Windows Function.
Reporte 2: Reporte acumulado mensual de ingresos por actividad deportiva al momento en que se saca
el reporte tomando como inicio enero.
Reporte 3: Reporte de la cantidad de socios que han realizado alguna actividad de forma alternada
(inasistencias) por categoría de socios y actividad, ordenado según cantidad de inasistencias
ordenadas de mayor a menor.
Reporte 4: Reporte que contenga a los socios que no han asistido a alguna clase de la actividad que realizan.
El reporte debe contener: Nombre, Apellido, edad, categoría y la actividad
-----------------------------------------------------------------------------------------------------------
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

--REPORTES

--Reporte 1: Socios morosos recurrentes
CREATE OR ALTER PROCEDURE reportes.MorososRecurrentes
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

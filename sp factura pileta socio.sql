CREATE OR ALTER PROCEDURE ddbba.FacturarPasesPileta
AS
BEGIN
    SET NOCOUNT ON;
-- 1. Crear facturas por socio y mes
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
    pp.idSocio,
    DATEFROMPARTS(2025, MONTH(pp.fechaDesde), 1),
    MONTH(pp.fechaDesde),
    DATEADD(DAY, 5, DATEFROMPARTS(2025, MONTH(pp.fechaDesde), 1)),
    DATEADD(DAY, 10, DATEFROMPARTS(2025, MONTH(pp.fechaDesde), 1)),
    0,
    'I'
FROM ddbba.pasePileta pp
GROUP BY pp.idSocio, MONTH(pp.fechaDesde);

-- 2. Unir pases de pileta con facturas y obtener el costo vigente
SELECT 
    f.codFactura,
    pp.idSocio,
    pp.codCostoPileta,
    cp.costo,
    pp.tipo,
    MONTH(pp.fechaDesde) AS mes_fecha
INTO #detallePases
FROM ddbba.pasePileta pp
JOIN ddbba.factura f
    ON f.ID_socio = pp.idSocio
    AND f.mesFacturado = MONTH(pp.fechaDesde)
    AND f.estadoFactura = 'I'
JOIN ddbba.costoPileta cp
    ON cp.codCostoPileta = pp.codCostoPileta
    AND cp.fechaVigenciaHasta >= pp.fechaDesde;

-- 3. Insertar detalle de factura con concepto dinámico según tipo
INSERT INTO ddbba.detalleFactura (
    codFactura,
    concepto,
    monto,
    descuento,
    recargoMorosidad,
    codCostoPileta
)
SELECT
    d.codFactura,
    'Pase Pileta - ' + d.tipo,
    d.costo,
    0,
    0,
    d.codCostoPileta
FROM #detallePases d;

-- 4. Actualizar el total neto de cada factura
UPDATE f
SET totalNeto = df.total
FROM ddbba.factura f
JOIN (
    SELECT codFactura, SUM(monto - descuento + recargoMorosidad) AS total
    FROM ddbba.detalleFactura
    GROUP BY codFactura
) df ON f.codFactura = df.codFactura;

-- 5. Limpieza
DROP TABLE IF EXISTS #detallePases;

PRINT 'Carga de pases de pileta y facturación completada correctamente';
END;
GO
exec ddbba.FacturarPasesPileta
select top 5 * from ddbba.detalleFactura order by codDetalleFac desc


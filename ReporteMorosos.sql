Use Com2900G17;
-- ========================================
-- SCRIPT DE TESTING PARA sp_MorososRecurrentes
-- ========================================
-- CARGA DE DATOS FICTICIOS
-- ========================================
-- Insertar socios

INSERT INTO ddbba.socio (
    nroSocio, dni, nombre, apellido, telContacto, email, fechaNac,
    telEmergencia, nombreObraSoc, numeroObraSoc, telObraSoc, estado
)
VALUES
-- Juan P�rez: 4 morosidades
('SN-5000', '33456456', 'Juan', 'P�rez', 11345678, 'juan@mail.com', '1990-01-01', 1120639585, 'Osde', 'SS83', '4802-0022', 'A')

-- Mar�a L�pez: 2 morosidades (no deber�a aparecer en el reporte)
INSERT INTO ddbba.socio (
    nroSocio, dni, nombre, apellido, telContacto, email, fechaNac,
    telEmergencia, nombreObraSoc, numeroObraSoc, telObraSoc, estado
)
VALUES
('SN-5011', '33456900', 'Mar�a', 'L�pez', 11206365, 'maria@mail.com', '1995-05-05', 1144445555, 'Osdepym', 'SS84', '11-2344-4444', 'A')

-- Pedro G�mez: 3 morosidades
INSERT INTO ddbba.socio (
    nroSocio, dni, nombre, apellido, telContacto, email, fechaNac,
    telEmergencia, nombreObraSoc, numeroObraSoc, telObraSoc, estado
)
VALUES
('SN-5002', '39002137', 'Pedro', 'G�mez', 11206365, 'pedro@mail.com', '1975-03-10', 1166667777, 'Omint', 'SS85', '11-2344-4466', 'A');

-- Juan P�rez (34 a�os) - Adulto
UPDATE ddbba.socio SET codCat = 2 WHERE nroSocio = 'SN-5000';

-- Mar�a L�pez (28 a�os) - Adulto
UPDATE ddbba.socio SET codCat = 2 WHERE nroSocio = 'SN-5011';

-- Pedro G�mez (48 a�os) - Adulto
UPDATE ddbba.socio SET codCat = 2 WHERE nroSocio = 'SN-5002';


SELECT * FROM ddbba.socio



-- Generar facturas para los 3 socios en los meses requeridos
EXEC ddbba.GenerarFacturaMensual 1, 2025; -- Enero
EXEC ddbba.GenerarFacturaMensual 2, 2025; -- Febrero
EXEC ddbba.GenerarFacturaMensual 3, 2025; -- Marzo
EXEC ddbba.GenerarFacturaMensual 4, 2025; -- Abril



SELECT *FROM ddbba.factura
SELECT *FROM ddbba.detalleFactura



-- Morosidades para Juan P�rez (Nataci�n)
-- Morosidades para Juan P�rez (Nataci�n)
INSERT INTO ddbba.registroMoroso (montoAdeudado, fechaMorosidad, mesAdeudado, mesAplicado, socio, codFactura)
SELECT 
    (ccs.costoMembresia + ca.costoActividad) * 1.10, -- Total con 10% de recargo
    DATEADD(DAY, 1, f.fecha2Vencimiento),
    f.mesFacturado,
    MONTH(DATEADD(DAY, 1, f.fecha2Vencimiento)),
    f.ID_socio,
    f.codFactura
FROM ddbba.factura f
JOIN ddbba.socio s ON f.ID_socio = s.ID_socio
JOIN ddbba.detalleFactura df ON f.codDetalleFac = df.codDetalleFac
JOIN ddbba.CuotaCatSocio ccs ON df.idCuotaCatSocio = ccs.idCuotaCatSocio
JOIN ddbba.CuotaActividad ca ON df.idCuotaAct = ca.idCuotaAct
WHERE s.nroSocio = 'SN-5000'
  AND f.mesFacturado BETWEEN 1 AND 4
  AND f.estadoFactura = 'I'; -- Solo impagas


-- Morosidades para Pedro G�mez (Tenis)
INSERT INTO ddbba.registroMoroso (montoAdeudado, fechaMorosidad, mesAdeudado, mesAplicado, socio, codFactura)
SELECT 
    (ccs.costoMembresia + ca.costoActividad) * 1.10, -- Total con 10% de recargo
    DATEADD(DAY, 1, f.fecha2Vencimiento),
    f.mesFacturado,
    MONTH(DATEADD(DAY, 1, f.fecha2Vencimiento)),
    f.ID_socio,
    f.codFactura
FROM ddbba.factura f
JOIN ddbba.socio s ON f.ID_socio = s.ID_socio
JOIN ddbba.detalleFactura df ON f.codDetalleFac = df.codDetalleFac
JOIN ddbba.CuotaCatSocio ccs ON df.idCuotaCatSocio = ccs.idCuotaCatSocio
JOIN ddbba.CuotaActividad ca ON df.idCuotaAct = ca.idCuotaAct
WHERE s.nroSocio = 'SN-5011'
  AND f.mesFacturado BETWEEN 1 AND 4
  AND f.estadoFactura = 'I'; -- Solo impagas

-- Morosidades para Mar�a L�pez (Pilates)
INSERT INTO ddbba.registroMoroso (montoAdeudado, fechaMorosidad, mesAdeudado, mesAplicado, socio, codFactura)
SELECT 
    (ccs.costoMembresia + ca.costoActividad) * 1.10, -- Total con 10% de recargo
    DATEADD(DAY, 1, f.fecha2Vencimiento),
    f.mesFacturado,
    MONTH(DATEADD(DAY, 1, f.fecha2Vencimiento)),
    f.ID_socio,
    f.codFactura
FROM ddbba.factura f
JOIN ddbba.socio s ON f.ID_socio = s.ID_socio
JOIN ddbba.detalleFactura df ON f.codDetalleFac = df.codDetalleFac
JOIN ddbba.CuotaCatSocio ccs ON df.idCuotaCatSocio = ccs.idCuotaCatSocio
JOIN ddbba.CuotaActividad ca ON df.idCuotaAct = ca.idCuotaAct
WHERE s.nroSocio = 'SN-5002'
  AND f.mesFacturado BETWEEN 1 AND 4
  AND f.estadoFactura = 'I'; -- Solo impagas




-- Activo hace Nataci�n
INSERT INTO ddbba.acceden (codCat, codAct) VALUES (2, 1);

-- Cadete hace Tenis
INSERT INTO ddbba.acceden (codCat, codAct) VALUES (2, 4);

-- Infantil hace Pilates
INSERT INTO ddbba.acceden (codCat, codAct) VALUES (2, 3);


SELECT *FROM ddbba.socio

INSERT INTO ddbba.registroMoroso (montoAdeudado, fechaMorosidad, mesAdeudado, mesAplicado, socio)
VALUES
(1500, '2025-02-01', 1, 2, 154),
(1600, '2025-03-01', 2, 3, 154),
(1700, '2025-04-01', 3, 4, 154),
(1800, '2025-05-01', 4, 5, 154),

(2000, '2024-03-15', 2, 3, 155),
(2100, '2024-05-15', 4, 5, 155),

(1800, '2025-03-10', 1, 1, 156),
(1850, '2025-04-10', 2, 2, 156),
(1900, '2025-06-10', 4, 4, 156);



-- ========================================
-- PRUEBA 1: Ejecutar el procedimiento con rango que incluya todos los datos
-- Resultado esperado: debe listar a Juan P�rez (4 incumplimientos) y Pedro G�mez (3 incumplimientos), ordenados por ranking.
EXEC ddbba.MorososRecurrentes '2025-01-01', '2025-06-24';
-- Esperado: 2 registros (Juan y Pedro), Juan primero

-- ========================================
-- PRUEBA 2: Ejecutar con rango m�s acotado que excluya parte de las morosidades
-- Resultado esperado: solo aparece quien a�n cumple la condici�n en ese rango
EXEC ddbba.MorososRecurrentes '2025-03-01', '2025-05-31';
-- Esperado: solo Juan P�rez con 3 registros (porque tiene marzo, abril y mayo)

-- ========================================
-- PRUEBA 3: Rango sin morosos con m�s de 2 incumplimientos
-- Resultado esperado: sin resultados
EXEC ddbba.MorososRecurrentes '2025-06-01', '2025-05-30';
-- Esperado: 0 registros (nadie con >2 morosidades en ese mes)

-- ========================================
-- FIN DEL SCRIPT DE TESTING
-- ========================================
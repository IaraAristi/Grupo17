USE Com2900G17
GO

--EJECUCIONES REPORTES

--REPORTE 1
--Juegos de Prueba
--LOTE DE DATOS DE SOCIOS FICTICIOS PARA PROBAR EL REPORTE1:MOROSIDAD

INSERT INTO socio.socio (
    nroSocio, dni, nombre, apellido, telContacto, email, fechaNac,
    telEmergencia, nombreObraSoc, numeroObraSoc, telObraSoc, estado
)
VALUES
('SN-5000', '33456456', 'Juan', 'Pérez', 11345678, 'juan@mail.com', '1990-01-01', 1120639585, 'Osde', 'SS83', '4802-0022', 'A'),
('SN-5011', '33456900', 'María', 'López', 11206365, 'maria@mail.com', '1995-05-05', 1144445555, 'Osdepym', 'SS84', '11-2344-4444', 'A'),
('SN-5002', '39002137', 'Pedro', 'Gómez', 11206365, 'pedro@mail.com', '1975-03-10', 1166667777, 'Omint', 'SS85', '11-2344-4466', 'A');


INSERT INTO club.Presentismo (fecha, presentismo, socio, act, profesor) VALUES
('2025-01-10', 'P', 154, 1, 'Hector Alvarez'),
('2025-02-15', 'P', 154, 1, 'Hector Alvarez'),
('2025-03-10', 'P', 154, 1, 'Hector Alvarez'),
('2025-04-12', 'P', 154, 1, 'Hector Alvarez'),
('2025-05-08', 'P', 154, 1, 'Hector Alvarez'),

('2025-01-12', 'P', 155, 3, 'Pablo Rodrigez'),
('2025-02-17', 'P', 155, 3, 'Pablo Rodrigez'),
('2025-03-14', 'P', 155, 3, 'Pablo Rodrigez'),
('2025-04-15', 'P', 155, 3, 'Pablo Rodrigez'),
('2025-05-09', 'P', 155, 3, 'Pablo Rodrigez'),

('2025-01-18', 'P', 156, 4, 'Paula Quiroga'),
('2025-02-20', 'P', 156, 4, 'Paula Quiroga'),
('2025-03-16', 'P', 156, 4, 'Paula Quiroga'),
('2025-04-18', 'P', 156, 4, 'Paula Quiroga'),
('2025-05-12', 'P', 156, 4, 'Paula Quiroga');

--FIN LOTE DE DATOS DE SOCIOS FICTICIOS PARA PROBAR EL REPORTE1:MOROSIDAD
--para ver los 3 socios creados
SELECT * FROM socio.socio
WHERE nombre in ('Juan', 'María', 'Pedro');


--para ver las 3 facturas creadas para cada socio
SELECT * FROM tesoreria.factura f
JOIN socio.socio s ON f.ID_socio = s.ID_socio
WHERE s.nombre in ('Juan', 'María', 'Pedro')

DECLARE @mes INT = 1;
DECLARE @anio INT = 2025;

WHILE @mes <= 3
BEGIN
    EXEC tesoreria.GenerarCuotasMensuales @mes, @anio;
    EXEC tesoreria.GenerarDetalleFactura @mes, @anio;
    EXEC tesoreria.GenerarFacturasMensuales @mes, @anio;

    SET @mes = @mes + 1;
END;

EXEC tesoreria.GenerarRegistroMoroso '2025', '1';
EXEC tesoreria.GenerarRegistroMoroso '2025', '2';
EXEC tesoreria.GenerarRegistroMoroso '2025', '3';

--Paso2: le ingreso mas datos ficticios para ver bien el ranking
INSERT INTO tesoreria.registroMoroso (montoAdeudado, fechaMorosidad, mesAdeudado, mesAplicado, socio)
VALUES
(1800, '2025-05-10', 4, 5, 154),--juan
(1800, '2025-05-10', 5, 6, 154),--juan

(1900, '2025-06-10', 4, 4, 156);--pedro

-- PRUEBA 1:debe listar a Juan Pérez (5 incumplimientos) y Pedro Gómez (4 incumplimientos), ordenados por ranking.
EXEC reportes.MorososRecurrentes '2025-01-01', '2025-06-24';
-- Esperado: 2 registros (Juan y Pedro), Juan primero


-- PRUEBA 2:solo aparece quien todavia cumple la condición en ese rango
EXEC reportes.MorososRecurrentes '2025-03-01', '2025-05-31';
-- Esperado: solo Juan Pérez con 3 registros (porque tiene marzo, abril y mayo)

-- PRUEBA 3:sin resultados
EXEC reportes.MorososRecurrentes '2025-06-01', '2025-05-30';
-- Esperado: 0 registros (nadie con >2 morosidades en ese mes)




--REPORTE 2

EXEC reportes.Reporte_ingresos_por_actividad

--REPORTE 3

EXEC reportes.reporteInasistenciasAlternadas 

--REPORTE 4

EXEC reportes.SociosConAlgunaInasistencia


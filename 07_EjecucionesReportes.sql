USE Com2900G17
GO

--EJECUCIONES REPORTES

--REPORTE 1
--Juegos de Prueba

-- Insertar socios

INSERT INTO ddbba.socio (
    nroSocio, dni, nombre, apellido, telContacto, email, fechaNac,
    telEmergencia, nombreObraSoc, numeroObraSoc, telObraSoc, estado
)
VALUES
('SN-5000', '33456456', 'Juan', 'Pérez', 11345678, 'juan@mail.com', '1990-01-01', 1120639585, 'Osde', 'SS83', '4802-0022', 'A'), -- 4 morosidades
('SN-5011', '33456900', 'María', 'López', 11206365, 'maria@mail.com', '1995-05-05', 1144445555, 'Osdepym', 'SS84', '11-2344-4444', 'A'), -- 2 morosidades (no debería aparecer en el reporte)
('SN-5002', '39002137', 'Pedro', 'Gómez', 11206365, 'pedro@mail.com', '1975-03-10', 1166667777, 'Omint', 'SS85', '11-2344-4466', 'A'); -- 3 morosidades

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

-- PRUEBA 1: Ejecutar el procedimiento con rango que incluya todos los datos
-- Resultado esperado: debe listar a Juan Pérez (4 incumplimientos) y Pedro Gómez (3 incumplimientos), ordenados por ranking.
EXEC ddbba.MorososRecurrentes '2025-01-01', '2025-06-30';

-- PRUEBA 2: Ejecutar con rango más acotado que excluya parte de las morosidades
-- Resultado esperado: solo aparece quien aún cumple la condición en ese rango
EXEC ddbba.MorososRecurrentes '2025-03-01', '2025-05-31';

-- PRUEBA 3: Rango sin morosos con más de 2 incumplimientos
-- Resultado esperado: sin resultados
EXEC ddbba.MorososRecurrentes '2025-06-01', '2025-05-30';

--REPORTE 2

EXEC reportes.Reporte_ingresos_por_actividad

--REPORTE 3

EXEC reportes.reporteInasistenciasAlternadas 

--REPORTE 4

EXEC reportes.SociosConAlgunaInasistencia


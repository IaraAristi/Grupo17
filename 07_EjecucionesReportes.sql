/*Entrega 6:Reportes solicitados. Ejecuci�n de Stored Procedures para la generaci�n de reportes
Reporte 1: Reporte de los socios morosos, que hayan incumplido en m�s de dos oportunidades dado un
rango de fechas a ingresar. El reporte debe contener los siguientes datos:
Nombre del reporte: Morosos Recurrentes
Per�odo: rango de fechas
Nro de socio
Nombre y apellido.
Mes incumplido
Ordenados de Mayor a menor por ranking de morosidad
El mismo debe ser desarrollado utilizando Windows Function.
Reporte 2: Reporte acumulado mensual de ingresos por actividad deportiva al momento en que se saca
el reporte tomando como inicio enero.
Reporte 3: Reporte de la cantidad de socios que han realizado alguna actividad de forma alternada
(inasistencias) por categor�a de socios y actividad, ordenado seg�n cantidad de inasistencias
ordenadas de mayor a menor.
Reporte 4: Reporte que contenga a los socios que no han asistido a alguna clase de la actividad que realizan.
El reporte debe contener: Nombre, Apellido, edad, categor�a y la actividad
-----------------------------------------------------------------------------------------------------------
Fecha de entrega: 01/07/2025
N�mero de comisi�n: 2900
N�mero de grupo: 17
Materia: Bases de datos aplicadas
Alumnos:Aristimu�o,Iara Bel�n DNI:45237225 
		Dom�nguez,Luana Milena DNI:46362353
		Lopardo, Tom�s Mat�as DNI: 45495734
		Rico, Agustina Micaela DNI: 46028153
*/
USE Com2900G17
GO

--EJECUCIONES REPORTES

--REPORTE 1
--Juegos de Prueba

--para ver los 3 socios creados
SELECT * FROM socio.socio
WHERE nombre in ('Juan', 'Mar�a', 'Pedro');


--para ver las 3 facturas creadas para cada socio
SELECT * FROM tesoreria.factura f
JOIN socio.socio s ON f.ID_socio = s.ID_socio
WHERE s.nombre in ('Juan', 'Mar�a', 'Pedro')

EXEC tesoreria.GenerarRegistroMoroso '2025', '1';
EXEC tesoreria.GenerarRegistroMoroso '2025', '2';
EXEC tesoreria.GenerarRegistroMoroso '2025', '3';

--Paso2: le ingreso mas datos ficticios para ver bien el ranking
INSERT INTO tesoreria.registroMoroso (montoAdeudado, fechaMorosidad, mesAdeudado, mesAplicado, socio)
VALUES
(1800, '2025-05-10', 4, 5, 154),--juan
(1800, '2025-05-10', 5, 6, 154),--juan

(1900, '2025-06-10', 4, 4, 156);--pedro

-- PRUEBA 1:debe listar a Juan P�rez (5 incumplimientos) y Pedro G�mez (4 incumplimientos), ordenados por ranking.
EXEC reportes.MorososRecurrentes '2025-01-01', '2025-06-24';
-- Esperado: 2 registros (Juan y Pedro), Juan primero


-- PRUEBA 2:solo aparece quien todavia cumple la condici�n en ese rango
EXEC reportes.MorososRecurrentes '2025-03-01', '2025-05-31';
-- Esperado: solo Juan P�rez con 3 registros (porque tiene marzo, abril y mayo)

-- PRUEBA 3:sin resultados
EXEC reportes.MorososRecurrentes '2025-06-01', '2025-05-30';
-- Esperado: 0 registros (nadie con >2 morosidades en ese mes)

--REPORTE 2
EXEC reportes.Reporte_ingresos_por_actividad
--REPORTE 3
EXEC reportes.reporteInasistenciasAlternadas 
--REPORTE 4
EXEC reportes.SociosConAlgunaInasistencia


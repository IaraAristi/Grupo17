--INSERCCION DE TABLAS FUERA DEL EXCEL
Use Com2900G17;
GO

INSERT INTO ddbba.tutor (nombre, apellido, dni, email, parentesco) VALUES
('Juan', 'Pérez', 25123456, 'juan.perez@email.com', 'padre'),
('María', 'Gómez', 27567890, 'maria.gomez@email.com', 'madre'),
('Carlos', 'López', 28444555, 'carlos.lopez@email.com', 'tutor'),
('Laura', 'Fernández', 29555111, 'laura.fernandez@email.com', 'madre'),
('José', 'Martínez', 30666222, 'jose.martinez@email.com', 'padre'),
('Ana', 'Ruiz', 31888999, 'ana.ruiz@email.com', 'hermana'),
('Pablo', 'Sosa', 32555333, 'pablo.sosa@email.com', 'tío'),
('Verónica', 'Díaz', 33556677, 'vero.diaz@email.com', 'tía'),
('Lucía', 'Torres', 34555666, 'lucia.torres@email.com', 'madre'),
('Andrés', 'Molina', 35511223, 'andres.molina@email.com', 'padre');


SELECT* FROM ddbba.Tutor

INSERT INTO ddbba.inscripcion (fecha, hora) VALUES
('2025-02-10', '10:00'),
('2025-02-11', '11:00'),
('2025-02-12', '12:00'),
('2025-02-13', '13:00'),
('2025-02-14', '14:00'),
('2025-02-15', '15:00'),
('2025-02-16', '16:00'),
('2025-02-17', '17:00'),
('2025-02-18', '18:00'),
('2025-02-19', '19:00');


SELECT* FROM ddbba.inscripcion
GO
EXEC ddbba.AsignarInscripcionesAleatorias

SELECT *FROM ddbba.socio


EXEC ddbba.ActualizarCategoriaSociosPorEdad
GO

EXEC ddbba.cargarDetalleFacturaDesdeCSV
	@rutaArchivo='C:\Users\Diego\Desktop\LOS DOMINGUEZ\Luana Unlam\Bdda\Grupo17-main\Grupo17-main\Detalle De Factura.csv'
GO


EXEC ddbba.ActualizarGrupoFamiliarResponsables
GO



EXEC ddbba.Reporte_ingresos_por_actividad --Reporte 2
GO


EXEC ddbba.reporteInasistenciasAlternadas --Reporte 3


EXEC ddbba.SociosConAlgunaInasistencia --Reporte 4

SELECT * FROM ddbba.socio


---------------
---Lote para probar el reintegro por lluvia
INSERT INTO ddbba.pasePileta (tipo, fechaDesde, fechaHasta, idSocio, codCostoPileta)
VALUES
    ('dia', '2025-01-20', '2025-01-20', 5, 1),        -- Socio 5, 20 de enero
    ('dia', '2025-02-28', '2025-02-28', 12, 1),       -- Socio 12, 28 de febrero
    ('dia', '2025-02-28', '2025-02-27', 50, 1),       -- Socio 50, 28 de febrero
    ('dia', '2025-01-15', '2025-01-15', 87, 1),       -- Socio 87, otra de enero
    ('dia', '2025-02-10', '2025-02-10', 120, 2);      -- Socio 120, otra de febrero

SELECT * FROM ddbba.pasePileta



INSERT INTO ddbba.invitado (nombre, apellido, fechaNac, dni, mail) VALUES
('Lucía', 'Pérez', '2001-05-23', '34567890', 'lucia.perez@email.com'),
('Mateo', 'Fernández', '1999-11-12', '32145678', 'mateo.fernandez@email.com'),
('Sofía', 'Gómez', '2003-02-01', '33445566', 'sofia.gomez@email.com'),
('Julián', 'Rodríguez', '1998-08-17', '31234567', 'julian.rodriguez@email.com'),
('Valentina', 'López', '2000-03-09', '35678901', 'valentina.lopez@email.com');

-- Nuevo invitado menor de edad
INSERT INTO ddbba.invitado (nombre, apellido, fechaNac, dni, mail)
VALUES ('Bruno', 'Sánchez', '2010-09-15', '37890123', 'bruno.sanchez@email.com');
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
('2025-01-10', '10:00'),
('2025-01-11', '11:00'),
('2025-01-12', '12:00'),
('2025-01-13', '13:00'),
('2025-01-14', '14:00'),
('2025-01-15', '15:00'),
('2025-01-16', '16:00'),
('2025-01-17', '17:00'),
('2025-01-18', '18:00'),
('2025-01-19', '19:00');

SELECT* FROM ddbba.inscripcion
GO

EXEC ddbba.ActualizarCategoriaSociosPorEdad
GO
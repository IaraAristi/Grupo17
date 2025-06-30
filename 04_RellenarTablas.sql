--INSERCCION DE TABLAS FUERA DEL EXCEL
Use Com2900G17;
GO


--DATOS TUTOR
INSERT INTO socio.tutor (nombre, apellido, dni, email, parentesco) VALUES
('Juan', 'Pérez', 25123456, 'juan.perez@email.com', 'padre'),
('María', 'Gómez', 27567890, 'maria.gomez@email.com', 'madre'),
('Carlos', 'López', 28444555, 'carlos.lopez@email.com', 'tutor'),
('Laura', 'Fernández', 29555111, 'laura.fernandez@email.com', 'madre'),
('José', 'Martínez', 30666222, 'jose.martinez@email.com', 'padre')

SELECT* FROM socio.Tutor

--DATOS SOCIOS MENORES DE EDAD, PARA PODER ASIGNARLES UN TUTOR
INSERT INTO socio.socio (
    nroSocio, dni, nombre, apellido, fechaNac,
    telEmergencia, nombreObraSoc, numeroObraSoc, telObraSoc, estado, codTutor
)
VALUES
('SN-4155', '47258775', 'Benjamín', 'Gómez', '2010-05-20',
 1133124567, 'OSDE', '0001234567', '0116000111', 'A',1),
('SN-4156', '47258776', 'Emilia', 'Ponce', '2012-08-15',
 1133124568, 'Swiss Medical', '0002233445', '0116000222', 'A',2),
('SN-4157', '47258777', 'Franco', 'Rivas', '2013-11-03',
 1133124569, 'IOMA', '0003344556', '0116000333', 'A',3),
('SN-4158', '47258778', 'Catalina', 'Luna', '2015-02-10',
 1133124570, 'Galeno', '0004455667', '0116000444', 'A',4),
('SN-4159', '47258779', 'Tomás', 'Molina', '2014-04-22',
 1133124571, 'Medife', '0005566778', '0116000555', 'A',5);

--DATOS INSCRIPCION
INSERT INTO socio.inscripcion (fecha, hora) VALUES
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


SELECT* FROM socio.inscripcion
GO
--------------------------------------------------
EXEC socio.AsignarInscripcionesASocios

SELECT *FROM socio.socio
---------------------------------------------------

EXEC socio.ActualizarCategoriaSociosPorEdad
GO
-------------------------------------------------
EXEC socio.ActualizarGrupoFamiliarResponsables
GO
-----------------------------------------------------
EXEC tesoreria.GenerarCuotasMensuales
	@mes = 3,
	@anio = 2025

select * from tesoreria.cuotaMensualActividad
select * from tesoreria.cuotaMensualCategoria
-----------------------------------------------------------
EXEC tesoreria.GenerarDetalleFactura
	@mes = 3,
	@anio = 2025

select * from tesoreria.detalleFactura
---------------------------------------------------------
EXEC tesoreria.GenerarFacturasMensuales
	@mes = 3,
	@anio = 2025

SELECT * from tesoreria.Factura
select * from tesoreria.detalleFactura
-----------------------------------------------------------

INSERT INTO club.pasePileta (tipo, fechaDesde, fechaHasta, idSocio)
VALUES
    ('día', '2025-01-20', '2025-01-20', 5),
    ('día', '2025-02-28', '2025-02-28', 12),
    ('día', '2025-02-28', '2025-02-28', 50),
    ('día', '2025-01-15', '2025-01-15', 87),
    ('día', '2025-02-10', '2025-02-10', 119),
    ('mes', '2025-01-01', '2025-01-31', 11),
    ('mes', '2025-02-01', '2025-02-28', 17);

EXEC club.AsignarCostoPiletaAPases --agrega el cod del costo del pase de pileta

SELECT * FROM club.pasePileta
--------------------------------------------------------
EXEC tesoreria.GenerarDetallePasePileta
	@mes = 2,
	@anio = 2025

SELECT * FROM tesoreria.detalleFactura WHERE concepto LIKE 'Pase pileta%'

EXEC tesoreria.GenerarFacturasMensuales
	@mes = 2,
	@anio = 2025;

SELECT * FROM tesoreria.factura WHERE mesFacturado = 2
SELECT * FROM tesoreria.detalleFactura WHERE concepto LIKE 'Pase pileta%'

-------------------------------------------------------------------------------
EXEC tesoreria.GenerarReintegrosPiletaPorLluvia

SELECT * FROM tesoreria.pagoCuenta
SELECT * FROM socio.cuenta
-------------------------------------------------------------

INSERT INTO club.invitado (nombre, apellido, fechaNac, dni, mail) VALUES
('Lucía', 'Pérez', '2001-05-23', '34567890', 'lucia.perez@email.com'),
('Mateo', 'Fernández', '1999-11-12', '32145678', 'mateo.fernandez@email.com'),
('Julián', 'Rodríguez', '1998-08-17', '31234567', 'julian.rodriguez@email.com'),
('Valentina', 'López', '2000-03-09', '35678901', 'valentina.lopez@email.com'),
('Bruno', 'Sánchez', '2010-09-15', '37890123', 'bruno.sanchez@email.com');

INSERT INTO club.ingresoPiletaInvitado (fecha, socioInvitador, codInvitado) VALUES
('2025-01-20',5,1),
('2025-01-20',5,2),
('2025-01-15',87,3),
('2025-02-28',50,4),
('2025-02-28',50,5);

EXEC club.AsignarCostoIngresoInvitados

SELECT * FROM club.ingresoPiletaInvitado

EXEC tesoreria.GenerarFacturasInvitados
SELECT * FROM tesoreria.facturaInvitado
---------------------------------------
EXEC tesoreria.InsertarReembolso
	@codPago = 1,
	@motivo = 'error en facturacion'

SELECT * FROM tesoreria.reembolso
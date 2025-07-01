--INSERCCION DE TABLAS FUERA DEL EXCEL
Use Com2900G17;
GO

--LOTE DE DATOS DE SOCIOS FICTICIOS PARA PROBAR EL REPORTE1:MOROSIDAD

EXEC socio.AgregarSocio
    @nroSocio = 'SN-5000',
    @dni = '33456456',
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @telContacto = 11345678,
    @email = 'juan@mail.com',
    @fechaNac = '1990-01-01',
    @telEmergencia = 1120639585,
    @nombreObraSoc = 'Osde',
    @numeroObraSoc = 'SS83',
    @telObraSoc = '4802-0022',
    @estado = 'A';
GO

EXEC socio.AgregarSocio
    @nroSocio = 'SN-5011',
    @dni = '33456900',
    @nombre = 'María',
    @apellido = 'López',
    @telContacto = 11206365,
    @email = 'maria@mail.com',
    @fechaNac = '1995-05-05',
    @telEmergencia = 1144445555,
    @nombreObraSoc = 'Osdepym',
    @numeroObraSoc = 'SS84',
    @telObraSoc = '11-2344-4444',
    @estado = 'A';
GO

EXEC socio.AgregarSocio
    @nroSocio = 'SN-5002',
    @dni = '39002137',
    @nombre = 'Pedro',
    @apellido = 'Gómez',
    @telContacto = 11206365,
    @email = 'pedro@mail.com',
    @fechaNac = '1975-03-10',
    @telEmergencia = 1166667777,
    @nombreObraSoc = 'Omint',
    @numeroObraSoc = 'SS85',
    @telObraSoc = '11-2344-4466',
    @estado = 'A';
GO

--este socio es para probar agregar,actualizar y eliminar socio

EXEC socio.AgregarSocio
    @nroSocio = 'SN-5020',
    @dni = '40445566',
    @nombre = 'Lucía',
    @apellido = 'Fernández',
    @telContacto = 1199998888,
    @email = 'lucia@mail.com',
    @fechaNac = '1992-07-15',
    @telEmergencia = 1188887777,
    @nombreObraSoc = 'SwissMedical',
    @numeroObraSoc = 'SS90',
    @telObraSoc = '11-3333-2222',
    @estado = 'A';

SELECT * FROM socio.socio
WHERE nroSocio = 'SN-5020';

EXEC socio.ModificarAtributoSocio
    @ID_socio = 157,
    @atributo = 'telContacto',
    @nuevoValor = '1177776666';

EXEC socio.EliminarSocio
    @ID_socio = 157; 

-----------------------------------------------------------------------------

INSERT INTO club.Presentismo (fecha, presentismo, socio, act, profesor) VALUES
('2025-03-10', 'P', 154, 1, 'Hector Alvarez'),
('2025-03-15', 'P', 154, 1, 'Hector Alvarez'),
('2025-03-10', 'P', 154, 1, 'Hector Alvarez'),
('2025-04-12', 'P', 154, 1, 'Hector Alvarez'),
('2025-05-08', 'P', 154, 1, 'Hector Alvarez'),

('2025-03-12', 'P', 155, 3, 'Pablo Rodrigez'),
('2025-03-17', 'P', 155, 3, 'Pablo Rodrigez'),
('2025-03-14', 'P', 155, 3, 'Pablo Rodrigez'),
('2025-04-15', 'P', 155, 3, 'Pablo Rodrigez'),
('2025-05-09', 'P', 155, 3, 'Pablo Rodrigez'),

('2025-03-18', 'P', 156, 4, 'Paula Quiroga'),
('2025-03-20', 'P', 156, 4, 'Paula Quiroga'),
('2025-03-16', 'P', 156, 4, 'Paula Quiroga'),
('2025-04-18', 'P', 156, 4, 'Paula Quiroga'),
('2025-05-12', 'P', 156, 4, 'Paula Quiroga');

--FIN LOTE DE DATOS DE SOCIOS FICTICIOS PARA PROBAR EL REPORTE1:MOROSIDAD

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

 INSERT INTO club.Presentismo (fecha, presentismo, socio, act, profesor) VALUES
('2025-03-03', 'P', 157, 1, 'Hector Alvarez'),
('2025-03-10', 'P', 157, 1, 'Hector Alvarez'),
('2025-03-17', 'P', 157, 1, 'Hector Alvarez'),
('2025-04-7', 'P', 158, 1, 'Hector Alvarez'),
('2025-04-14', 'P', 158, 1, 'Hector Alvarez'),
('2025-04-21', 'P', 158, 1, 'Hector Alvarez'),
('2025-03-9', 'P', 159, 3, 'Pablo Rodrigez'),
('2025-03-16', 'P', 159, 3, 'Pablo Rodrigez'),
('2025-03-23', 'P', 159, 3, 'Pablo Rodrigez'),
('2025-04-13', 'P', 160, 3, 'Pablo Rodrigez'),
('2025-04-20', 'P', 160, 3, 'Pablo Rodrigez'),
('2025-04-27', 'P', 160, 3, 'Pablo Rodrigez'),
('2025-03-4', 'P', 161, 4, 'Paula Quiroga'),
('2025-03-11', 'P', 161, 4, 'Paula Quiroga'),
('2025-03-18', 'P', 161, 4, 'Paula Quiroga');

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

INSERT INTO club.costoColonia (costo, fechaVigenciaHasta, turno) VALUES
(3000, '2025-02-28', 'mañana'),
(3000, '2025-02-28', 'tarde'),
(5000, '2025-02-28', 'doble');

INSERT INTO club.coloniaVerano (mes, turno, anio) VALUES
(1, 'mañana', 2025),
(1, 'tarde', 2025),
(2, 'doble', 2025);

INSERT INTO club.asistenciaColonia (codSocio, codColonia) VALUES
(124,1),
(150,2),
(133,3);

EXEC club.AsignarCostoColonia
	@mes = 1,
	@anio = 2025

SELECT * FROM club.coloniaVerano

---------------------------------------------

INSERT INTO club.costoSUM (costo, fechaVigenciaHasta) VALUES
(1000, '2025-06-30');

INSERT INTO club.alquilerSUM (fecha, turno, socio) VALUES
('2025-03-03', 'mañana', 100),
('2025-04-03', 'noche', 10);

EXEC club.AsignarCostoSUM
	@mes = 3,
	@anio = 2025

SELECT * FROM club.alquilerSUM

-----------------------------------------------

DECLARE @mes INT = 1;
DECLARE @anio INT = 2025;

WHILE @mes <= 3
BEGIN
    EXEC tesoreria.GenerarCuotasMensuales @mes, @anio;
    EXEC tesoreria.GenerarDetalleFactura @mes, @anio;
    EXEC tesoreria.GenerarFacturasMensuales @mes, @anio,
	EXEC tesoreria.GenerarDetallePasePileta @mes, @anio,
	EXEC tesoreria.GenerarDetalleFacturaColonia @mes, @anio,
	EXEC tesoreria.GenerarDetalleFacturaSUM @mes, @anio

    SET @mes = @mes + 1;
END;

select * from tesoreria.cuotaMensualActividad
select * from tesoreria.cuotaMensualCategoria
select * from tesoreria.detalleFactura
SELECT * from tesoreria.Factura

-----------------------------------------------------------------

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
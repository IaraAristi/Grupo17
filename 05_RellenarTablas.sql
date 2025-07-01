/*Entrega 5:Conjunto de pruebas. Juegos de pruebas
Fecha de entrega: 01/07/2025
Número de comisión: 2900
Número de grupo: 17
Materia: Bases de datos aplicadas
Alumnos:Aristimuño,Iara Belén DNI:45237225 
		Domínguez,Luana Milena DNI:46362353
		Lopardo, Tomás Matías DNI: 45495734
		Rico, Agustina Micaela DNI: 46028153

OBSERVACIÓN: Los lotes de prueba deben ejecutarse en el orden en el cual estan declarados
*/

Use Com2900G17;
GO

--LOTE DE DATOS DE SOCIOS FICTICIOS PARA PROBAR EL REPORTE1:MOROSIDAD
EXEC socio.AgregarSocio
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
GO 
--------------------------------------------------------------
SELECT * FROM socio.socio
WHERE nroSocio = 'SN-4158';--Buscar a cual corresponde ahora
--------------------------------------------------------------
EXEC socio.ModificarAtributoSocio
    @ID_socio = 157,
    @atributo = 'telContacto',
    @nuevoValor = '1177776666';
------------------------------------------------------------------
EXEC socio.EliminarSocio
    @ID_socio = 157; 
----------------------------------------------------------------------

--Insercion de prueba en la tabla presentismo
INSERT INTO club.Presentismo (fecha, presentismo, socio, act, profesor) VALUES
('2025-03-10', 'P', 154, 1, 'Hector Alvarez'),
('2025-03-15', 'P', 154, 1, 'Hector Alvarez'),
('2025-03-18', 'P', 154, 1, 'Hector Alvarez'),
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
-------------------------------------------------------------------------------
--DATOS TUTOR
INSERT INTO socio.tutor (nombre, apellido, dni, email, parentesco) VALUES
('Juan', 'Pérez', 25123456, 'juan.perez@email.com', 'padre'),
('María', 'Gómez', 27567890, 'maria.gomez@email.com', 'madre'),
('Carlos', 'López', 28444555, 'carlos.lopez@email.com', 'tutor'),
('Laura', 'Fernández', 29555111, 'laura.fernandez@email.com', 'madre'),
('José', 'Martínez', 30666222, 'jose.martinez@email.com', 'padre')
-------------------------------------------------------------------------------
SELECT* FROM socio.Tutor
-------------------------------------------------------------------------------
--DATOS SOCIOS MENORES DE EDAD, PARA PODER ASIGNARLES UN TUTOR
EXEC socio.AgregarSocio 
    @dni = '47258775',
    @nombre = 'Benjamín',
    @apellido = 'Gómez',
    @telContacto = NULL,
    @email = NULL,
    @fechaNac = '2010-05-20',
    @telEmergencia = 1133124567,
    @nombreObraSoc = 'OSDE',
    @numeroObraSoc = '0001234567',
    @telObraSoc = '0116000111',
    @estado = 'A',
    @codCat = NULL,
    @codTutor = 1,
    @codInscripcion = NULL,
    @codGrupoFamiliar = NULL;

EXEC socio.AgregarSocio 
    @dni = '47258776',
    @nombre = 'Emilia',
    @apellido = 'Ponce',
    @telContacto = NULL,
    @email = NULL,
    @fechaNac = '2012-08-15',
    @telEmergencia = 1133124568,
    @nombreObraSoc = 'Swiss Medical',
    @numeroObraSoc = '0002233445',
    @telObraSoc = '0116000222',
    @estado = 'A',
    @codCat = NULL,
    @codTutor = 2,
    @codInscripcion = NULL,
    @codGrupoFamiliar = NULL;

EXEC socio.AgregarSocio 
    @dni = '47258777',
    @nombre = 'Franco',
    @apellido = 'Rivas',
    @telContacto = NULL,
    @email = NULL,
    @fechaNac = '2013-11-03',
    @telEmergencia = 1133124569,
    @nombreObraSoc = 'IOMA',
    @numeroObraSoc = '0003344556',
    @telObraSoc = '0116000333',
    @estado = 'A',
    @codCat = NULL,
    @codTutor = 3,
    @codInscripcion = NULL,
    @codGrupoFamiliar = NULL;

EXEC socio.AgregarSocio 
    @dni = '47258778',
    @nombre = 'Catalina',
    @apellido = 'Luna',
    @telContacto = NULL,
    @email = NULL,
    @fechaNac = '2015-02-10',
    @telEmergencia = 1133124570,
    @nombreObraSoc = 'Galeno',
    @numeroObraSoc = '0004455667',
    @telObraSoc = '0116000444',
    @estado = 'A',
    @codCat = NULL,
    @codTutor = 4,
    @codInscripcion = NULL,
    @codGrupoFamiliar = NULL;

EXEC socio.AgregarSocio 
    @dni = '47258779',
    @nombre = 'Tomás',
    @apellido = 'Molina',
    @telContacto = NULL,
    @email = NULL,
    @fechaNac = '2014-04-22',
    @telEmergencia = 1133124571,
    @nombreObraSoc = 'Medife',
    @numeroObraSoc = '0005566778',
    @telObraSoc = '0116000555',
    @estado = 'A',
    @codCat = NULL,
    @codTutor = 5,
    @codInscripcion = NULL,
    @codGrupoFamiliar = NULL;
-------------------------------------------------------------------------------
 INSERT INTO club.Presentismo (fecha, presentismo, socio, act, profesor) VALUES--Ajustar si hace falta
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
-------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------
SELECT* FROM socio.inscripcion
GO

--------------------------------------------------
--Asignacion de inscripciones a los socios recien inscriptos
EXEC socio.AsignarInscripcionesASocios
-------------------------------------------------------------------------------
SELECT *FROM socio.socio
-------------------------------------------------------------------------------
--Asignación de categoria de socio al socio según su edad
EXEC socio.ActualizarCategoriaSociosPorEdad
GO
-------------------------------------------------------------------------------
--Actualización de grupo familiar para el socio responsable de pago del grupo
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

--Asignación del codigo de costo del pase de pileta
EXEC club.AsignarCostoPiletaAPases 
-------------------------------------------------------------------------------
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

INSERT INTO club.InscripcionColonia (codSocio, codColonia) VALUES
(124,1),
(150,2),
(133,3);
-------------------------------------------------------------------------------
EXEC club.AsignarCostoColonia
	@mes = 1,
	@anio = 2025
-------------------------------------------------------------------------------
SELECT * FROM club.coloniaVerano

---------------------------------------------

INSERT INTO club.costoSUM (costo, fechaVigenciaHasta) VALUES
(1000, '2025-06-30');

INSERT INTO club.alquilerSUM (fecha, turno, socio) VALUES
('2025-03-03', 'mañana', 100),
('2025-04-03', 'noche', 10);
-------------------------------------------------------------------------------
EXEC club.AsignarCostoSUM
	@mes = 3,
	@anio = 2025
-------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------
SELECT * FROM tesoreria.cuotaMensualActividad
-------------------------------------------------------------------------------
SELECT * FROM tesoreria.cuotaMensualCategoria
-------------------------------------------------------------------------------
SELECT * FROM tesoreria.detalleFactura
-------------------------------------------------------------------------------
SELECT * FROM tesoreria.Factura

-----------------------------------------------------------------

EXEC tesoreria.GenerarReintegrosPiletaPorLluvia
-----------------------------------------------------------------
SELECT * FROM tesoreria.pagoCuenta
-----------------------------------------------------------------
SELECT * FROM socio.cuenta

-------------------------------------------------------------

INSERT INTO club.invitado (nombre, apellido, fechaNac, dni, mail) VALUES
('Lucía', 'Pérez', '2001-05-23', '34567890', 'lucia.perez@email.com'),
('Mateo', 'Fernández', '1999-11-12', '32145678', 'mateo.fernandez@email.com'),
('Julián', 'Rodríguez', '1998-08-17', '31234567', 'julian.rodriguez@email.com'),
('Valentina', 'López', '2000-03-09', '35678901', 'valentina.lopez@email.com'),
('Bruno', 'Sánchez', '2010-09-15', '37890123', 'bruno.sanchez@email.com');
-----------------------------------------------------------------
INSERT INTO club.ingresoPiletaInvitado (fecha, socioInvitador, codInvitado) VALUES
('2025-01-20',5,1),
('2025-01-20',5,2),
('2025-01-15',87,3),
('2025-02-28',50,4),
('2025-02-28',50,5);
-----------------------------------------------------------------
EXEC club.AsignarCostoIngresoInvitados
-----------------------------------------------------------------
SELECT * FROM club.ingresoPiletaInvitado
-----------------------------------------------------------------
EXEC tesoreria.GenerarFacturasInvitados
-----------------------------------------------------------------
SELECT * FROM tesoreria.facturaInvitado

---------------------------------------

EXEC tesoreria.InsertarReembolso
	@codPago = 1,
	@motivo = 'error en facturacion'
	-----------------------------------------------------------------

SELECT * FROM tesoreria.reembolso

----------------------------------------
--Prueba 
EXEC socio.VerPagosYEstado @nroSocio = 'SN-4045';
----------------------------------------------------
EXEC socio.QuitarSocioDeGrupoFamiliar 
    @nroSocioResponsabledePago = 'SN-4045',
    @nroSocioAQuitar = 'SN-4154';
----------------------------------------------------
EXEC socio.AgregarSocioAGrupoFamiliar 
    @nroSocioResponsabledePago = 'SN-4045',
    @nroSocioAAgregar = 'SN-4154';



	

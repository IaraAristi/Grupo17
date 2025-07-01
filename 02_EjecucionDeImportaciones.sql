/*Entrega 5:Conjunto de pruebas.Ejecución de Stored Procedures de importación de datos
Fecha de entrega: 01/07/2025
Número de comisión: 2900
Número de grupo: 17
Materia: Bases de datos aplicadas
Alumnos:Aristimuño,Iara Belén DNI:45237225 
		Domínguez,Luana Milena DNI:46362353
		Lopardo, Tomás Matías DNI: 45495734
		Rico, Agustina Micaela DNI: 46028153

Ubicación de los archivos de importación: consideramos que el lugar más accesible y con una ruta menos compleja
para localizar los archivos de importación es en la carpeta de descargas, por lo cual estarán accesible para la
demostración desde allí.
*/
USE Com2900G17;
GO

EXEC  importaciones.ImportarSociosRP
    @rutaArchivo = 'C:\Users\iaraa\Downloads\Datos socios-Responsables de Pago.csv';
-- verificamos inserción de responsables de pago
SELECT * FROM socio.socio
-------------------------
EXEC  importaciones.ImportarSociosConGrupoFamiliar
    @rutaArchivo = 'C:\Users\iaraa\Downloads\Datos socios-Grupo Familiar.csv';
--verificamos inserción de socios que se encuentran en grupos familiares
SELECT * FROM socio.socio
-----------------------------------------
EXEC  importaciones.InsertarActividades
    @rutaArchivo = 'C:\Users\iaraa\Downloads\Actividad deportiva.csv';
SELECT * FROM club.
-----------------------------------------
EXEC importaciones.InsertarCuotasActividad
	@rutaArchivo = 'C:\Users\iaraa\Downloads\Actividad deportiva.csv'
-----------------------------
EXEC importaciones.InsertarCuotasCatSocio
	@rutaArchivo = 'C:\Users\iaraa\Downloads\Categoria de socio.csv'
------------------------------------------
EXEC importaciones.InsertarCatSocio
    @rutaArchivo = 'C:\Users\iaraa\Downloads\Categoria de socio.csv';
------------------------------------------------
EXEC importaciones.cargarPresentismo
	@rutaArchivo = 'C:\Users\iaraa\Downloads\presentismo.csv'
-------------------------------
EXEC importaciones.InsertarPagoFactura
	@rutaArchivo = 'C:\Users\iaraa\Downloads\pago cuotas.csv'
---------------------------------
EXEC importaciones.InsertarCostoPileta 
	@rutaArchivo = 'C:\Users\iaraa\Downloads\Costo Pase Pileta.csv'
---------------------------------
EXEC importaciones.InsertarCostoPiletaInvitado 
	@rutaArchivo = 'C:\Users\iaraa\Downloads\Costo Pileta Invitado.csv'
----------------------------------------------------
EXEC importaciones.InsertarLluvias
	@rutaArchivo1 = 'C:\Users\iaraa\Downloads\lluvias 2024.csv',
	@rutaArchivo2 = 'C:\Users\iaraa\Downloads\lluvias 2025.csv'


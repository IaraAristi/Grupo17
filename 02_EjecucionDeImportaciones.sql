/*Entrega 5:Conjunto de pruebas.Ejecuci�n de Stored Procedures de importaci�n de datos
Fecha de entrega: 01/07/2025
N�mero de comisi�n: 2900
N�mero de grupo: 17
Materia: Bases de datos aplicadas
Alumnos:Aristimu�o,Iara Bel�n DNI:45237225 
		Dom�nguez,Luana Milena DNI:46362353
		Lopardo, Tom�s Mat�as DNI: 45495734
		Rico, Agustina Micaela DNI: 46028153

Ubicaci�n de los archivos de importaci�n: consideramos que el lugar m�s accesible y con una ruta menos compleja
para localizar los archivos de importaci�n es en la carpeta de descargas, por lo cual estar�n accesible para la
demostraci�n desde all�.
*/
USE Com2900G17;
GO

EXEC  importaciones.ImportarSociosRP
    @rutaArchivo = 'C:\Users\iaraa\Downloads\Datos socios-Responsables de Pago.csv';
-- verificamos inserci�n de responsables de pago
SELECT * FROM socio.socio
-------------------------
EXEC  importaciones.ImportarSociosConGrupoFamiliar
    @rutaArchivo = 'C:\Users\iaraa\Downloads\Datos socios-Grupo Familiar.csv';
--verificamos inserci�n de socios que se encuentran en grupos familiares
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


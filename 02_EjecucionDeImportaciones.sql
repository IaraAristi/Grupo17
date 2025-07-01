/*Entrega 5:Conjunto de pruebas.Ejecuci�n de Stored Procedures de importaci�n de datos
Fecha de entrega: 01/07/2025
N�mero de comisi�n: 2900
N�mero de grupo: 17
Materia: Bases de datos aplicadas
Alumnos:Aristimu�o,Iara Bel�n DNI:45237225 
		Dom�nguez,Luana Milena DNI:46362353
		Lopardo, Tom�s Mat�as DNI: 45495734
		Rico, Agustina Micaela DNI: 46028153
*/
USE Com2900G17;
GO

EXEC  importaciones.ImportarSociosRP
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17-Nuevos-cambios\Grupo17-Nuevos-cambios\Datos socios.csv';
-------------------------
EXEC  importaciones.ImportarSociosConGrupoFamiliar
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17-Nuevos-cambios\Grupo17-Nuevos-cambios\Datos socios GF.csv';
-----------------------------------------
EXEC  importaciones.InsertarActividades
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17-Nuevos-cambios\Grupo17-Nuevos-cambios\Actividad deportiva.csv';
-----------------------------------------
EXEC importaciones.InsertarCuotasActividad
	@rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17-Nuevos-cambios\Grupo17-Nuevos-cambios\Actividad deportiva.csv'
-----------------------------
EXEC importaciones.InsertarCuotasCatSocio
	@rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17-Nuevos-cambios\Grupo17-Nuevos-cambios\Categoria de socio.csv'
------------------------------------------
EXEC importaciones.InsertarCatSocio
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17\Grupo17\Categoria de socio.csv';
------------------------------------------------
EXEC importaciones.cargarPresentismo
	@rutaArchivo = 'C:\Users\iaraa\Downloads\Datos socios2(presentismo_actividades).csv'
-------------------------------
EXEC importaciones.InsertarPagoFactura
	@rutaArchivo = 'C:\Users\iaraa\Downloads\Datos socios2(pago cuotas).csv'
---------------------------------
EXEC importaciones.InsertarCostoPileta 
	@rutaArchivo = 'C:\Users\agusr\Downloads\Costo Pase Pileta.csv'
---------------------------------
EXEC importaciones.InsertarCostoPiletaInvitado 
	@rutaArchivo = 'C:\Users\agusr\Downloads\Costo Pileta Invitado.csv'
----------------------------------------------------
EXEC importaciones.InsertarLluvias
	@rutaArchivo1 = 'C:\Users\agusr\Downloads\lluvias 2024 funciona.csv',
	@rutaArchivo2 = 'C:\Users\agusr\Downloads\lluvias 2025.csv'


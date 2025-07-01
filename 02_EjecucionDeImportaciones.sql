/*Entrega 5:Conjunto de pruebas.Ejecución de Stored Procedures de importación de datos
Fecha de entrega: 01/07/2025
Número de comisión: 2900
Número de grupo: 17
Materia: Bases de datos aplicadas
Alumnos:Aristimuño,Iara Belén DNI:45237225 
		Domínguez,Luana Milena DNI:46362353
		Lopardo, Tomás Matías DNI: 45495734
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


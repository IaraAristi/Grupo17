--EJECUCION DE SP DE EXPORTACION DE TABLAS

USE Com2900G17;
GO

EXEC  importaciones.ImportarSociosRP
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17-Nuevos-cambios\Grupo17-Nuevos-cambios\Datos socios.csv';

SELECT * FROM socio.Socio
-------------------------
EXEC  importaciones.ImportarSociosConGrupoFamiliar
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17-Nuevos-cambios\Grupo17-Nuevos-cambios\Datos socios GF.csv';

SELECT * FROM socio.Socio order by nroSocio desc

-----------------------------------------

EXEC  importaciones.InsertarActividades
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17-Nuevos-cambios\Grupo17-Nuevos-cambios\Actividad deportiva.csv';

SELECT * FROM club.actDeportiva

-----------------------------------------

EXEC importaciones.InsertarCuotasActividad
	@rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17-Nuevos-cambios\Grupo17-Nuevos-cambios\Actividad deportiva.csv'

SELECT * FROM club.TarifarioActividad

-----------------------------

EXEC importaciones.InsertarCuotasCatSocio
	@rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17-Nuevos-cambios\Grupo17-Nuevos-cambios\Categoria de socio.csv'

SELECT * FROM club.TarifarioCatSocio

------------------------------------------

EXEC importaciones.InsertarCatSocio
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17\Grupo17\Categoria de socio.csv';

SELECT * FROM club.catSocio

------------------------------------------------

EXEC importaciones.cargarPresentismo
	@rutaArchivo = 'C:\Users\iaraa\Downloads\Datos socios2(presentismo_actividades).csv'

select * from club.Presentismo order by fecha desc--Revisar ,,, del final

-------------------------------
EXEC importaciones.InsertarPagoFactura
	@rutaArchivo = 'C:\Users\iaraa\Downloads\Datos socios2(pago cuotas).csv'

select * from tesoreria.pagoFactura order by idPago desc

---------------------------------

EXEC importaciones.InsertarCostoPileta 
	@rutaArchivo = 'C:\Users\agusr\Downloads\Costo Pase Pileta.csv'

select * from club.costoPileta 

---------------------------------

EXEC importaciones.InsertarCostoPiletaInvitado 
	@rutaArchivo = 'C:\Users\agusr\Downloads\Costo Pileta Invitado.csv'

select * from club.costoPiletaInvitado

-----------------------------------------------------

EXEC importaciones.InsertarLluvias
	@rutaArchivo1 = 'C:\Users\agusr\Downloads\lluvias 2024 funciona.csv',
	@rutaArchivo2 = 'C:\Users\agusr\Downloads\lluvias 2025.csv'


--EJECUCION DE SP DE EXPORTACION DE TABLAS

USE Com2900G17;
GO

EXEC  importaciones.ImportarSociosRP
    @rutaArchivo = 'C:\Users\Diego\Desktop\excel tp bdda\Datos socios.csv';

-------------------------
EXEC  importaciones.ImportarSociosConGrupoFamiliar
    @rutaArchivo = 'C:\Users\Diego\Desktop\excel tp bdda\Datos socios GF.csv';

SELECT * FROM socio.Socio order by nroSocio 

-----------------------------------------

EXEC  importaciones.InsertarActividades
    @rutaArchivo = 'C:\Users\Diego\Desktop\excel tp bdda\Actividad deportiva.csv';

SELECT * FROM club.actDeportiva

-----------------------------------------

EXEC importaciones.InsertarCuotasActividad
	@rutaArchivo = 'C:\Users\Diego\Desktop\excel tp bdda\Actividad deportiva.csv'

SELECT * FROM club.TarifarioActividad

-----------------------------

EXEC importaciones.InsertarCatSocio
    @rutaArchivo = 'C:\Users\Diego\Desktop\excel tp bdda\Categoria de socio.csv';

SELECT * FROM club.catSocio

------------------------------------------------

EXEC importaciones.InsertarCuotasCatSocio
	@rutaArchivo = 'C:\Users\Diego\Desktop\excel tp bdda\Categoria de socio.csv'

SELECT * FROM club.TarifarioCatSocio

------------------------------------------
EXEC importaciones.cargarPresentismo
	@rutaArchivo = 'C:\Users\Diego\Desktop\excel tp bdda\Presentismo.csv'

select * from club.Presentismo order by fecha desc--Revisar ,,, del final

-------------------------------
EXEC importaciones.InsertarPagoFactura
	@rutaArchivo = 'C:\Users\Diego\Desktop\excel tp bdda\Pago Cuotas.csv'

select * from tesoreria.pagoFactura order by idPago desc

------------------------------


EXEC importaciones.InsertarCostoPileta
	@rutaArchivo = 'C:\Users\Diego\Desktop\excel tp bdda\Costo Pase Pileta.csv'

select * from club.costoPileta

---------------------------------

EXEC importaciones.InsertarCostoPiletaInvitado 
	@rutaArchivo = 'C:\Users\Diego\Desktop\excel tp bdda\Costo Pileta Invitado.csv'

select * from club.costoPiletaInvitado

-----------------------------------------------------

EXEC importaciones.InsertarLluvias
	@rutaArchivo1 = 'C:\Users\Diego\Desktop\excel tp bdda\lluvias 2024 funciona.csv',
	@rutaArchivo2 = 'C:\Users\Diego\Desktop\excel tp bdda\lluvias 2025.csv'


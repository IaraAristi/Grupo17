--EJECUCION DE SP DE EXPORTACION DE TABLAS

USE Com2900G17;
GO

EXEC ddbba.InsertarCatSocio
    @rutaArchivo = 'C:\Users\Diego\Desktop\LOS DOMINGUEZ\Luana Unlam\Bdda\Grupo17-main\Grupo17-main\Categoria de socio.csv';

SELECT * FROM ddbba.catSocio


EXEC ddbba.InsertarCatSocio
    @rutaArchivo = 'C:\Users\Diego\Desktop\LOS DOMINGUEZ\Luana Unlam\Bdda\Grupo17-main\Grupo17-main\Categoria de socio.csv';


SELECT * FROM ddbba.CatSocio


EXEC  ddbba.ImportarSociosRP
    @rutaArchivo = 'C:\Users\Diego\Desktop\LOS DOMINGUEZ\Luana Unlam\Bdda\Grupo17-main\Grupo17-main\Responsables a cargo.csv';

SELECT * FROM ddbba.Socio
-------------------------
EXEC  ddbba.ImportarSociosConGrupoFamiliar
    @rutaArchivo = 'C:\Users\Diego\Desktop\LOS DOMINGUEZ\Luana Unlam\Bdda\Grupo17-main\Grupo17-main\Grupo familiar.csv';

SELECT * FROM ddbba.Socio


-----------------

EXEC  ddbba.InsertarActividades
    @rutaArchivo = 'C:\Users\Diego\Desktop\LOS DOMINGUEZ\Luana Unlam\Bdda\Grupo17-main\Grupo17-main\Actividad deportiva.csv';

SELECT * FROM ddbba.actDeportiva

-----------------------------------------

EXEC ddbba.InsertarCuotasActividad
	@rutaArchivo = 'C:\Users\Diego\Desktop\LOS DOMINGUEZ\Luana Unlam\Bdda\Grupo17-main\Grupo17-main\Actividad deportiva.csv'

SELECT * FROM ddbba.CuotaActividad

-----------------------------

EXEC ddbba.InsertarCuotasCatSocio
	@rutaArchivo = 'C:\Users\Diego\Desktop\LOS DOMINGUEZ\Luana Unlam\Bdda\Grupo17-main\Grupo17-main\Categoria de socio.csv'

SELECT * FROM ddbba.CuotaCatSocio

------------------------------------------
EXEC ddbba.cargarPresentismo
	@rutaArchivo = 'C:\Users\Diego\Desktop\LOS DOMINGUEZ\Luana Unlam\Bdda\Grupo17-main\Grupo17-main\Presentismo.csv'

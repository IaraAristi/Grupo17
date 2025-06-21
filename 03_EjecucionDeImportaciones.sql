--EJECUCION DE SP DE EXPORTACION DE TABLAS

USE Com2900G17;
GO

EXEC ddbba.InsertarCatSocio
    @rutaArchivo = 'C:\Users\agusr\Downloads\Categoria de socio.csv';

SELECT * FROM ddbba.catSocio


EXEC  ddbba.ImportarSociosRP
    @rutaArchivo = 'C:\Users\agusr\Downloads\Datos socios.csv';

SELECT * FROM ddbba.Socio
-------------------------
EXEC  ddbba.ImportarSociosConGrupoFamiliar
    @rutaArchivo = 'C:\Users\agusr\Downloads\Datos socios GF.csv';

SELECT * FROM ddbba.Socio


-----------------

EXEC  ddbba.InsertarActividades
    @rutaArchivo = 'C:\Users\agusr\Downloads\Cuota Actividad.csv';

SELECT * FROM ddbba.actDeportiva

-----------------------------------------

EXEC ddbba.InsertarCuotasActividad
	@rutaArchivo = 'C:\Users\agusr\Downloads\Cuota Actividad.csv'

SELECT * FROM ddbba.CuotaActividad

-----------------------------

EXEC ddbba.InsertarCuotasCatSocio
	@rutaArchivo = 'C:\Users\agusr\Downloads\Cuota Cat. Socio.csv'

SELECT * FROM ddbba.CuotaCatSocio

------------------------------------------
EXEC ddbba.cargarPresentismo
	@rutaArchivo = 'C:\Users\agusr\Downloads\Presentismo Corregido.csv'

select * from ddbba.Presentismo order by fecha

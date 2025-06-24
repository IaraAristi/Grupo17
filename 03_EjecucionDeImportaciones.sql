--EJECUCION DE SP DE EXPORTACION DE TABLAS

USE Com2900G17;
GO

EXEC ddbba.InsertarCatSocio
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17\Categoria de socio.csv';

SELECT * FROM ddbba.catSocio


EXEC  ddbba.ImportarSociosRP
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17\Responsables a cargo.csv';

SELECT * FROM ddbba.Socio
-------------------------
EXEC  ddbba.ImportarSociosConGrupoFamiliar
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17\Grupo familiar.csv';

SELECT * FROM ddbba.Socio s
WHERE s.codGrupoFamiliar IS NOT NULL
ORDER BY ID_socio


-----------------

EXEC  ddbba.InsertarActividades
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17\Actividad deportiva.csv';

SELECT * FROM ddbba.actDeportiva

-----------------------------------------

EXEC ddbba.InsertarCuotasActividad
	@rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17\Actividad deportiva.csv'

SELECT * FROM ddbba.CuotaActividad

-----------------------------

EXEC ddbba.InsertarCuotasCatSocio
	@rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17\Categoria de socio.csv'

SELECT * FROM ddbba.CuotaCatSocio


------------------------------------------
EXEC ddbba.cargarPresentismo
	@rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17\Presentismo.csv'

SELECT * FROM ddbba.Presentismo
ORDER BY fecha DESC



EXEC ddbba.InsertarPagoFactura
	@rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17\Pago Cuotas.csv'



SELECT * FROM ddbba.pagoFactura



--EJECUCION DE SP DE EXPORTACION DE TABLAS

USE Com2900G17;
GO

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







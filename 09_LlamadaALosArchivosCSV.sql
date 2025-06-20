use Com2900G17;
--LLAMADA A LOS ARCHIVOS

--archivo Responsables a cargo
EXEC ddbba.sp_ImportarSociosRP
    @RutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\TRABAJOPRACTICO\Trabajo-Practico\Responsables a cargo.csv';

SELECT * FROM ddbba.Socio

--archivo socios menores

EXEC ddbba.sp_InsertarSociosMenores 
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\TRABAJOPRACTICO\Trabajo-Practico\Grupo familiar.csv';

SELECT * FROM ddbba.Socio

--archivo RP de grupo familiar
EXEC ddbba.InsertarRP_GF
	@rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\TRABAJOPRACTICO\Trabajo-Practico\Grupo familiar.csv';

	--Revisar codigo de grupo -> si dos socios menores tienen el mismo RaC, sean del mismo grupo
SELECT * FROM ddbba.GrupoFamiliar

--Actualizacion de los numeros de grupo
EXEC ddbba.ActualizarNumeroDeGrupo
SELECT * FROM ddbba.GrupoFamiliar 

--archivo actividad deportiva


EXEC ddbba.SP_InsertarActividades
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\TRABAJOPRACTICO\Trabajo-Practico\Actividad deportiva.csv';


SELECT * FROM ddbba.actDeportiva

--archivo presentismo


EXEC ddbba.sp_cargar_presentismo
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\TRABAJOPRACTICO\Trabajo-Practico\Presentismo.csv';

SELECT * FROM ddbba.Presentismo


--archivo categoria de socio

EXEC ddbba.InsertarCatSocio
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\TRABAJOPRACTICO\Trabajo-Practico\Categoria de socio.csv';


SELECT * FROM ddbba.CatSocio
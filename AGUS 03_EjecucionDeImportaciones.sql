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
	@rutaArchivo = 'C:\Users\agusr\Downloads\Presentismo.csv'

select * from ddbba.Presentismo order by fecha

-------------------------------
EXEC ddbba.InsertarPagoFactura
	@rutaArchivo = 'C:\Users\agusr\Downloads\Pago Cuotas.csv'

select * from ddbba.pagoFactura

---------------------------------
EXEC ddbba.InsertarCostoIngresoPileta  ------invitado
	@rutaArchivo = 'C:\Users\agusr\Downloads\Costo Pileta Invitado.csv'

select * from ddbba.costoPiletaInvitado
---------------------------------
EXEC ddbba.InsertarCostoPileta ----socio
	@rutaArchivo = 'C:\Users\agusr\Downloads\Costo Pase Pileta.csv'

select * from ddbba.costoPileta --falta el registro de pase por temporada

-----------------------------------------------
EXEC ddbba.ActualizarCategoriaSociosPorEdad

select * from ddbba.socio
-----------------------------------------------------
EXEC ddbba.ActualizarGrupoFamiliarResponsables

select * from ddbba.socio
---------------------------------------------------
EXEC ddbba.reporteInasistenciasAlternadas --reporte 3
------------------------------------------------
EXEC ddbba.SociosConAlgunaInasistencia  --reporte 4
---------------------------------------
EXEC ddbba.GenerarCuotasMensuales
	@mes = 3

select * from ddbba.cuota_mensual_membresia_categoria
select * from ddbba.cuota_mensual_actividad

-----------------------------------------------------------
EXEC ddbba.GenerarDetalleFacturaFamiliar
	@mes = 3

select * from ddbba.detalleFactura

---------------------------------------------------------
EXEC ddbba.GenerarFacturasMensualesConsolidadas
	@mes = 3

SELECT * from ddbba.Factura
select * from ddbba.detalleFactura

-----------------------------------------------------------
EXEC ddbba.Reporte_ingresos_por_actividad --reporte 2
---------------------------------------------------------------
EXEC ddbba.GenerarDetallePasePileta @mes = 2;

SELECT * FROM ddbba.detalleFactura WHERE concepto LIKE 'Pase pileta%'

EXEC ddbba.GenerarFacturasMensualesConsolidadas @mes = 2;

SELECT * FROM ddbba.factura WHERE mesFacturado = 2
-------------------------------------------------------------------
EXEC ddbba.GenerarReintegrosPiletaPorLluvia

SELECT * FROM ddbba.pagoCuenta
----------------------------------------------------------------
EXEC ddbba.InsertarLluvias
	@rutaArchivo1 = 'C:\Users\agusr\Downloads\lluvias 2024 funciona.csv',
	@rutaArchivo2 = 'C:\Users\agusr\Downloads\lluvias 2025.csv'

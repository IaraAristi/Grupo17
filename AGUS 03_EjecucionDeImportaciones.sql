--EJECUCION DE SP DE EXPORTACION DE TABLAS

USE Com2900G17;
GO

EXEC importaciones.InsertarCatSocio
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17\Grupo17\Categoria de socio.csv';

SELECT * FROM club.catSocio


EXEC  importaciones.ImportarSociosRP
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17-Nuevos-cambios\Grupo17-Nuevos-cambios\Datos socios.csv';

SELECT * FROM socio.Socio
-------------------------
EXEC  importaciones.ImportarSociosConGrupoFamiliar
    @rutaArchivo = 'C:\Users\iaraa\OneDrive\Documentos\BDAA\BASEDEDATOSTP\Grupo17-Nuevos-cambios\Grupo17-Nuevos-cambios\Datos socios GF.csv';

SELECT * FROM socio.Socio order by nroSocio desc

-----------------------------------------------
EXEC socio.ActualizarCategoriaSociosPorEdad

select * from socio.socio
-----------------------------------------------------
EXEC socio.ActualizarGrupoFamiliarResponsables

select * from socio.socio
-----------------
--AGREGAR SP PARA ASIGNAR INSCRIPCIONES Y TUTORES
---------------------------------------------------------

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
EXEC importaciones.cargarPresentismo
	@rutaArchivo = 'C:\Users\iaraa\Downloads\Datos socios2(presentismo_actividades).csv'

select * from club.Presentismo order by fecha desc--Revisar ,,, del final

-------------------------------
EXEC importaciones.InsertarPagoFactura
	@rutaArchivo = 'C:\Users\iaraa\Downloads\Datos socios2(pago cuotas).csv'

select * from tesoreria.pagoFactura order by idPago desc

---------------------------------
EXEC importaciones.InsertarCostoPiletaInvitado  ------invitado
	@rutaArchivo = 'C:\Users\agusr\Downloads\Costo Pileta Invitado.csv'

select * from club.costoPiletaInvitado
---------------------------------
EXEC importaciones.InsertarCostoPileta ----socio
	@rutaArchivo = 'C:\Users\agusr\Downloads\Costo Pase Pileta.csv'

select * from club.costoPileta --falta el registro de pase por temporada no se por que no se me importa
---------------------------------------------------
EXEC reportes.reporteInasistenciasAlternadas --reporte 3
------------------------------------------------
EXEC reportes.SociosConAlgunaInasistencia  --reporte 4
---------------------------------------
EXEC tesoreria.GenerarCuotasMensuales
	@mes = 3

select * from tesoreria.cuotaMensualActividad
select * from tesoreria.cuotaMensualCategoria

-----------------------------------------------------------
EXEC tesoreria.GenerarDetalleFactura
	@mes = 3

select * from tesoreria.detalleFactura

---------------------------------------------------------
EXEC tesoreria.GenerarFacturasMensuales
	@mes = 3

SELECT * from tesoreria.Factura
select * from tesoreria.detalleFactura

-----------------------------------------------------------
EXEC reportes.Reporte_ingresos_por_actividad --reporte 2
---------------------------------------------------------------
EXEC club.InsertarPasesPileta

SELECT * FROM club.pasePileta
--------------------------------------------------------
EXEC tesoreria.GenerarDetallePasePileta @mes = 2;

SELECT * FROM tesoreria.detalleFactura WHERE concepto LIKE 'Pase pileta%'

EXEC tesoreria.GenerarFacturasMensuales @mes = 2;

SELECT * FROM tesoreria.factura WHERE mesFacturado = 2
SELECT * FROM tesoreria.detalleFactura WHERE concepto LIKE 'Pase pileta%'
-------------------------------------------------------------------
EXEC importaciones.InsertarLluvias
	@rutaArchivo1 = 'C:\Users\agusr\Downloads\lluvias 2024 funciona.csv',
	@rutaArchivo2 = 'C:\Users\agusr\Downloads\lluvias 2025.csv'

-------------------------------------------------------------------------------
EXEC tesoreria.GenerarReintegrosPiletaPorLluvia

SELECT * FROM tesoreria.pagoCuenta
----------------------------------------------------------------


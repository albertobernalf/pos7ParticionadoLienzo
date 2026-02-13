-- FUNCTION: public.creaestanciaautomatica()

-- DROP FUNCTION IF EXISTS public.creaestanciaautomatica();

CREATE OR REPLACE FUNCTION public.creaestanciaautomatica(
	)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

	DECLARE  estancias character(50000);
             tabla  RECORD;
BEGIN

/* PRIMERO ISS */

INSERT INTO facturacion_liquidaciondetalle(consecutivo, fecha, cantidad, "valorUnitario", "valorTotal",  "fechaCrea", 
		observaciones, "fechaRegistro", "estadoRegistro", examen_id, liquidacion_id 
		,"tipoRegistro",anulado, "codigoHomologado") 
select 
	(SELECT  coalesce(max(liqDet.consecutivo), 1) AS MaxX
		FROM facturacion_liquidaciondetalle liqdet
		WHERE liqDet.liquidacion_id = l1.id) consecutivo,
		now(),1,tar.valor,tar.valor,now(),'',now(),'A',dep.cups_id,l1.id,'SISTEMA','N',tar.referencia
FROM facturacion_liquidacion l1
INNER JOIN admisiones_ingresos ing on (ing."tipoDoc_id" = l1."tipoDoc_id" and ing.documento_id = l1.documento_id and ing.consec = l1."consecAdmision")	
INNER JOIN SITIOS_SERVICIOSSEDES servSed on (servSed."sedesClinica_id"=l1."sedesClinica_id")
INNER JOIN clinico_servicios serv on (serv.id =servSed.servicios_id   )
INNER JOIN sitios_dependencias dep on (dep."sedesClinica_id" = servSed."sedesClinica_id" AND   dep."serviciosSedes_id" = servSed.id and dep.id=ing."dependenciasActual_id")	
INNER JOIN contratacion_convenios conv on (conv.id = l1.convenio_id)
INNER JOIN tarifarios_tarifariosdescripcion descripcion ON (descripcion.id=conv."tarifariosDescripcionProc_id")	
INNER JOIN 	tarifarios_tipostarifa tiptar on (tiptar.id= descripcion."tiposTarifa_id" AND tiptar.nombre = 'ISS 2001')	
INNER JOIN 	tarifarios_tipostarifaproducto tipProd on (tipProd.id=tiptar."tiposTarifaProducto_id" and tipProd.nombre='PROCEDIMIENTOS')
INNER JOIN 	tarifarios_estancias tar on (tar.cups_id = dep.cups_id and tar."tipoEstancia" = 'I')	
WHERE serv.nombre = 'HOSPITALIZACION' and  l1.anulado = 'N' and l1.convenio_id = (SELECT max(l2.convenio_id) 
											FROM facturacion_liquidacion l2 
											where  l2."tipoDoc_id" = l1."tipoDoc_id" AND l2.documento_id = l1.documento_id AND l2."consecAdmision" = l1."consecAdmision");

raise notice 'Voy por el FOR LOOP :' ;

FOR tabla IN SELECT * FROM facturacion_liquidacion l1
	INNER JOIN admisiones_ingresos ing on (ing."tipoDoc_id" = l1."tipoDoc_id" and ing.documento_id = l1.documento_id and ing.consec = l1."consecAdmision")	
	INNER JOIN SITIOS_SERVICIOSSEDES servSed on (servSed."sedesClinica_id"=l1."sedesClinica_id")
	INNER JOIN clinico_servicios serv on (serv.id =servSed.servicios_id   )
	INNER JOIN sitios_dependencias dep on (dep."sedesClinica_id" = servSed."sedesClinica_id" AND   dep."serviciosSedes_id" = servSed.id and dep.id=ing."dependenciasActual_id")	
	INNER JOIN contratacion_convenios conv on (conv.id = l1.convenio_id)
	INNER JOIN tarifarios_tarifariosdescripcion descripcion ON (descripcion.id=conv."tarifariosDescripcionProc_id")	
	INNER JOIN 	tarifarios_tipostarifa tiptar on (tiptar.id= descripcion."tiposTarifa_id" AND tiptar.nombre = 'ISS 2001')	
	INNER JOIN 	tarifarios_tipostarifaproducto tipProd on (tipProd.id=tiptar."tiposTarifaProducto_id" and tipProd.nombre='PROCEDIMIENTOS')
	INNER JOIN 	tarifarios_estancias tar on (tar.cups_id = dep.cups_id and tar."tipoEstancia" = 'I')	
	WHERE serv.nombre = 'HOSPITALIZACION' and  l1.anulado = 'N' and l1.convenio_id = (SELECT max(l2.convenio_id) 
											FROM facturacion_liquidacion l2 
											where  l2."tipoDoc_id" = l1."tipoDoc_id" AND l2.documento_id = l1.documento_id AND l2."consecAdmision" = l1."consecAdmision")
LOOP 
			
			raise notice 'Voy a guardar encabezados : %s' , tabla.id;
			Update facturacion_liquidacion SET  "totalProcedimientos" = "totalProcedimientos" + tabla.valor        where id = tabla.id;
			raise notice 'ya guarde1: %s' , tabla.id;
			Update facturacion_liquidacion SET  "totalLiquidacion" = "totalSuministros" + "totalProcedimientos"    where id = tabla.id;
			raise notice 'ya guarde2: : %s' , tabla.id;
			Update facturacion_liquidacion SET  "valorApagar" = "totalLiquidacion" - "totalRecibido"    where id = tabla.id;
			raise notice 'En teoria ya guardes : %s' , tabla.valor;

END LOOP;

/* SEGUNDO SOAT */ 

INSERT INTO facturacion_liquidaciondetalle(consecutivo, fecha, cantidad, "valorUnitario", "valorTotal",  "fechaCrea", 
		observaciones, "fechaRegistro", "estadoRegistro", examen_id, liquidacion_id 
		,"tipoRegistro",anulado, "codigoHomologado") 
select 
	(SELECT  coalesce(max(liqDet.consecutivo), 1) AS MaxX
		FROM facturacion_liquidaciondetalle liqdet
		WHERE liqDet.liquidacion_id = l1.id) consecutivo,	
		now(),1,tar.valor,tar.valor,now(),'',now(),'A',dep.cups_id,l1.id,'SISTEMA','N',tar.referencia
FROM facturacion_liquidacion l1
INNER JOIN admisiones_ingresos ing on (ing."tipoDoc_id" = l1."tipoDoc_id" and ing.documento_id = l1.documento_id and ing.consec = l1."consecAdmision")		
INNER JOIN SITIOS_SERVICIOSSEDES servSed on (servSed."sedesClinica_id"=l1."sedesClinica_id")
INNER JOIN clinico_servicios serv on (serv.id =servSed.servicios_id and serv.nombre = 'HOSPITALIZACION' )
INNER JOIN sitios_dependencias dep on (dep."sedesClinica_id" = servSed."sedesClinica_id" AND   dep."serviciosSedes_id" = servSed.id and dep.id=ing."dependenciasActual_id")	
INNER JOIN contratacion_convenios conv on (conv.id = l1.convenio_id)
INNER JOIN tarifarios_tarifariosdescripcion descripcion ON (descripcion.id=conv."tarifariosDescripcionProc_id")	
INNER JOIN 	tarifarios_tipostarifa tiptar on (tiptar.id= descripcion."tiposTarifa_id" AND tiptar.nombre = 'SOAT 2024')	
INNER JOIN 	tarifarios_tipostarifaproducto tipProd on (tipProd.id=tiptar."tiposTarifaProducto_id" and tipProd.nombre='PROCEDIMIENTOS')
INNER JOIN 	tarifarios_estancias tar on (tar.cups_id = dep.cups_id and tar."tipoEstancia" = 'S')	
WHERE l1.anulado = 'N' and l1.convenio_id = (SELECT max(l2.convenio_id) 
											FROM facturacion_liquidacion l2 
											where  l2."tipoDoc_id" = l1."tipoDoc_id" AND l2.documento_id = l1.documento_id AND l2."consecAdmision" = l1."consecAdmision");

FOR tabla IN SELECT * FROM facturacion_liquidacion l1
	INNER JOIN admisiones_ingresos ing on (ing."tipoDoc_id" = l1."tipoDoc_id" and ing.documento_id = l1.documento_id and ing.consec = l1."consecAdmision")		
	INNER JOIN SITIOS_SERVICIOSSEDES servSed on (servSed."sedesClinica_id"=l1."sedesClinica_id")
	INNER JOIN clinico_servicios serv on (serv.id =servSed.servicios_id and serv.nombre = 'HOSPITALIZACION' )
	INNER JOIN sitios_dependencias dep on (dep."sedesClinica_id" = servSed."sedesClinica_id" AND   dep."serviciosSedes_id" = servSed.id and dep.id=ing."dependenciasActual_id")	
	INNER JOIN contratacion_convenios conv on (conv.id = l1.convenio_id)
	INNER JOIN tarifarios_tarifariosdescripcion descripcion ON (descripcion.id=conv."tarifariosDescripcionProc_id")	
	INNER JOIN 	tarifarios_tipostarifa tiptar on (tiptar.id= descripcion."tiposTarifa_id" AND tiptar.nombre = 'SOAT 2024')	
	INNER JOIN 	tarifarios_tipostarifaproducto tipProd on (tipProd.id=tiptar."tiposTarifaProducto_id" and tipProd.nombre='PROCEDIMIENTOS')
	INNER JOIN 	tarifarios_estancias tar on (tar.cups_id = dep.cups_id and tar."tipoEstancia" = 'S')	
	WHERE l1.anulado = 'N' and l1.convenio_id = (SELECT max(l2.convenio_id) 
											FROM facturacion_liquidacion l2 
											where  l2."tipoDoc_id" = l1."tipoDoc_id" AND l2.documento_id = l1.documento_id AND l2."consecAdmision" = l1."consecAdmision")
LOOP 
			
			raise notice 'Voy a guardar encabezados : %s' , tabla.id;
			Update facturacion_liquidacion SET  "totalProcedimientos" = "totalProcedimientos" + tabla.valor        where id = tabla.id;
			raise notice 'ya guarde1: %s' , tabla.id;
			Update facturacion_liquidacion SET  "totalLiquidacion" = "totalSuministros" + "totalProcedimientos"    where id = tabla.id;
			raise notice 'ya guarde2: : %s' , tabla.id;
			Update facturacion_liquidacion SET  "valorApagar" = "totalLiquidacion" - "totalRecibido"    where id = tabla.id;
			raise notice 'En teoria ya guardes : %s' , tabla.valor;

END LOOP;

/* TERCERO PARTICULAR */

INSERT INTO facturacion_liquidaciondetalle(consecutivo, fecha, cantidad, "valorUnitario", "valorTotal",  "fechaCrea", 
		observaciones, "fechaRegistro", "estadoRegistro", examen_id, liquidacion_id 
		,"tipoRegistro",anulado, "codigoHomologado") 
select 
	(SELECT  coalesce(max(liqDet.consecutivo), 1) AS MaxX
		FROM facturacion_liquidaciondetalle liqdet
		WHERE liqDet.liquidacion_id = l1.id) consecutivo,	
		now(),1,tar.valor,tar.valor,now(),'',now(),'A',dep.cups_id,l1.id,'SISTEMA','N',tar.referencia
FROM facturacion_liquidacion l1
INNER JOIN admisiones_ingresos ing on (ing."tipoDoc_id" = l1."tipoDoc_id" and ing.documento_id = l1.documento_id and ing.consec = l1."consecAdmision")		
INNER JOIN SITIOS_SERVICIOSSEDES servSed on (servSed."sedesClinica_id"=l1."sedesClinica_id")
INNER JOIN clinico_servicios serv on (serv.id =servSed.servicios_id and serv.nombre = 'HOSPITALIZACION' )
INNER JOIN sitios_dependencias dep on (dep."sedesClinica_id" = servSed."sedesClinica_id" AND   dep."serviciosSedes_id" = servSed.id and dep.id=ing."dependenciasActual_id")	
INNER JOIN contratacion_convenios conv on (conv.id = l1.convenio_id)
INNER JOIN tarifarios_tarifariosdescripcion descripcion ON (descripcion.id=conv."tarifariosDescripcionProc_id")	
INNER JOIN 	tarifarios_tipostarifa tiptar on (tiptar.id= descripcion."tiposTarifa_id" AND tiptar.nombre = 'PARTICULAR')	
INNER JOIN 	tarifarios_tipostarifaproducto tipProd on (tipProd.id=tiptar."tiposTarifaProducto_id" and tipProd.nombre='PROCEDIMIENTOS')
INNER JOIN 	tarifarios_estancias tar on (tar.cups_id = dep.cups_id and tar."tipoEstancia" = 'P')	
WHERE l1.anulado = 'N' and l1.convenio_id = (SELECT max(l2.convenio_id) 
											FROM facturacion_liquidacion l2 
											where  l2."tipoDoc_id" = l1."tipoDoc_id" AND l2.documento_id = l1.documento_id AND l2."consecAdmision" = l1."consecAdmision");

FOR tabla IN SELECT * FROM facturacion_liquidacion l1
	INNER JOIN admisiones_ingresos ing on (ing."tipoDoc_id" = l1."tipoDoc_id" and ing.documento_id = l1.documento_id and ing.consec = l1."consecAdmision")		
	INNER JOIN SITIOS_SERVICIOSSEDES servSed on (servSed."sedesClinica_id"=l1."sedesClinica_id")
	INNER JOIN clinico_servicios serv on (serv.id =servSed.servicios_id and serv.nombre = 'HOSPITALIZACION' )
	INNER JOIN sitios_dependencias dep on (dep."sedesClinica_id" = servSed."sedesClinica_id" AND   dep."serviciosSedes_id" = servSed.id and dep.id=ing."dependenciasActual_id")	
	INNER JOIN contratacion_convenios conv on (conv.id = l1.convenio_id)
	INNER JOIN tarifarios_tarifariosdescripcion descripcion ON (descripcion.id=conv."tarifariosDescripcionProc_id")	
	INNER JOIN 	tarifarios_tipostarifa tiptar on (tiptar.id= descripcion."tiposTarifa_id" AND tiptar.nombre = 'PARTICULAR')	
	INNER JOIN 	tarifarios_tipostarifaproducto tipProd on (tipProd.id=tiptar."tiposTarifaProducto_id" and tipProd.nombre='PROCEDIMIENTOS')
	INNER JOIN 	tarifarios_estancias tar on (tar.cups_id = dep.cups_id and tar."tipoEstancia" = 'P')	
	WHERE l1.anulado = 'N' and l1.convenio_id = (SELECT max(l2.convenio_id) 
											FROM facturacion_liquidacion l2 
											where  l2."tipoDoc_id" = l1."tipoDoc_id" AND l2.documento_id = l1.documento_id AND l2."consecAdmision" = l1."consecAdmision")
	
LOOP 
			
			raise notice 'Voy a guardar encabezados : %s' , tabla.id;
			Update facturacion_liquidacion SET  "totalProcedimientos" = "totalProcedimientos" + tabla.valor        where id = tabla.id;
			raise notice 'ya guarde1: %s' , tabla.id;
			Update facturacion_liquidacion SET  "totalLiquidacion" = "totalSuministros" + "totalProcedimientos"    where id = tabla.id;
			raise notice 'ya guarde2: : %s' , tabla.id;
			Update facturacion_liquidacion SET  "valorApagar" = "totalLiquidacion" - "totalRecibido"    where id = tabla.id;
			raise notice 'En teoria ya guardes : %s' , tabla.valor;

END LOOP;

RETURN 'OK'; 
END 
$BODY$;

ALTER FUNCTION public.creaestanciaautomatica()
    OWNER TO postgres;

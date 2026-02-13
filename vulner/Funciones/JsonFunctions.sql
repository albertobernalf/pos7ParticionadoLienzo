-- Verificar con aplicativos cuales son las funciones RIPS activas
-- Por el momento coloco estas
-- Hacer esto mas adelante OJOOO

-- FUNCTION: public.generaenvioripsjson1(numeric, character varying)

-- DROP FUNCTION IF EXISTS public.generaenvioripsjson1(numeric, character varying);

CREATE OR REPLACE FUNCTION public.generaenvioripsjson1(
	envioripsid numeric,
	tipo character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
 
DECLARE
	 
		valorJson character(50000);
		mide integer := 0;
		facturas RECORD; 
		facturaId integer := 0;
		notaFacturaId integer := 0;
	    valorTransaccionYusuarios character(50000) :='';
	    valorProcedimientos character(50000) :='';
		valorHospitalizacion character(50000) :='';
		valorUrgencias character(50000) :='';
	    valorOtrosServicios character(50000) :='';
	    valorMedicamentos character(50000) :='';
		valorConsultas character(50000) :='';
		totalUrgencias integer := 0;
		totalHospitalizacion integer := 0;
		totalProcedimientos integer := 0;
		totalMedicamentos integer := 0; 
		totalOtrosServicios integer := 0; 
	
		totalRecienNacidos integer := 0;
		valorRecienNacidos character(50000):='';
		contador integer := 1;
		tabla RECORD;
		consecutivos integer[] ;

BEGIN

	valorJson= '[{';
 	FOR facturas IN SELECT "numeroFactura_id", glosa_id, "notaCredito_id" FROM rips_ripsdetalle WHERE "ripsEnvios_id" = envioRipsId
        LOOP

	if (tipo = 'FACTURA') then 
		facturaId:=facturas."numeroFactura_id";
	end if;
	if (tipo = 'GLOSA') then 
		facturaId:=facturas.glosa_id;
	end if;

	if (tipo = 'NOTA CREDITO') then 
		facturaId:=facturas."notaCredito_id";
		notaFacturaId := facturas."numeroFactura_id";
	end if;

if (tipo = 'FACTURA') then 
	
	
SELECT '"numDocumentoIdObligado": "' || "numDocumentoIdObligado" ||'",' || '"numFactura": ""' || "numFactura" || '"", "TipoNota": null,"numNota": null,"usuarios": [{'
		||'"tipoDocumentoIdentificacion": '|| '"' ||tiposDoc.codigo || '",'||'"numDocumentoIdentificacion": '|| '"' || u."numDocumentoIdentificacion" || '",'
		||'"tipoUsuario": '|| '"' || CASE WHEN trim(u."tipoUsuario") is null THEN 'null' ELSE u."tipoUsuario"  END    || '",'||'"fechaNacimiento": '|| '"' || u."fechaNacimiento" || '",'
		||'"codSexo": '|| '"' || u."codSexo" || '",'||'"codPaisResidencia": '|| '"' || pais.codigo || '",'||'"codMunicipioResidencia": '|| '"' ||
	CASE WHEN trim(ripsMuni.codigo) is null THEN 'null' ELSE ripsMuni.codigo  END
	|| '",'
		||'"codZonaTerritorialResidencia": '|| '"' ||CASE WHEN trim(zona.codigo) is null THEN 'null' ELSE zona.codigo  END || '",'||'"incapacidad": '|| '"' || u."incapacidad" || '",'
		||'"consecutivo": '|| u."consecutivo" || ',' ||'"codPaisOrigen": '|| '"' ||  pais.codigo
	|| '"' DATO1
INTO valorTransaccionYusuarios
	from rips_ripstransaccion ripstra
	inner join  rips_ripsusuarios u on (u."ripsTransaccion_id" = ripstra.id)
	left join  rips_ripspaises pais on (pais.id =  u."codPaisResidencia_id")
	left join  sitios_municipios muni on ( muni.id = u."codMunicipioResidencia_id")	
	left join  rips_ripsmunicipios ripsMuni on ( ripsMuni.id = muni."ripsMunicipios_id")
	-- inner join usuarios_tiposDocumento tipoDocUsu on (tipoDocUsu.id = cast(u."tipoDocumentoIdentificacion" as integer))
	 inner join rips_ripstiposdocumento tiposDoc on (tiposDoc.id = cast(u."tipoDocumentoIdentificacion" as integer))
	left join rips_ripszonaterritorial zona on (zona.id = cast(u."codZonaTerritorialResidencia_id" as integer))
where  ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" = cast(facturaId as text)  and u."ripsTransaccion_id" = ripstra.id  ;

valorJson = valorJson ||' ' || valorTransaccionYusuarios;

end if;

if (tipo = 'GLOSA') then 
	
SELECT '"numDocumentoIdObligado": "' || "numDocumentoIdObligado" ||'",' || '"numFactura": "' || 'null' || '", "TipoNota":'|| '"' ||tipnot.codigo||'","numNota": ' || ripstra."numNota" || ',"usuarios": [{'
		||'"tipoDocumentoIdentificacion": '|| '"' ||tiposDoc.codigo || '",'||'"numDocumentoIdentificacion": '|| '"' || u."numDocumentoIdentificacion" || '",'
		||'"tipoUsuario": '|| '"' || CASE WHEN trim(u."tipoUsuario") is null THEN 'null' ELSE u."tipoUsuario"  END    || '",'||'"fechaNacimiento": '|| '"' || u."fechaNacimiento" || '",'
		||'"codSexo": '|| '"' || u."codSexo" || '",'||'"codPaisResidencia": '|| '"' || pais.codigo || '",'||'"codMunicipioResidencia": '|| '"' ||
	CASE WHEN trim(ripsMuni.codigo) is null THEN 'null' ELSE ripsMuni.codigo  END
	|| '",'	
		||'"codZonaTerritorialResidencia": '|| '"' ||CASE WHEN trim(zona.codigo) is null THEN 'null' ELSE zona.codigo  END || '",'||'"incapacidad": '|| '"' || u."incapacidad" || '",'
		||'"consecutivo": '|| u."consecutivo" || ',' ||'"codPaisOrigen": '|| '"' ||  pais.codigo
	|| '"' DATO1
INTO valorTransaccionYusuarios
	from rips_ripstransaccion ripstra
	inner join  rips_ripsusuarios u on (u."ripsTransaccion_id" = ripstra.id)
	left join  rips_ripspaises pais on (pais.id =  u."codPaisResidencia_id")
	left join  sitios_municipios muni on ( muni.id = u."codMunicipioResidencia_id")	
	left join  rips_ripsmunicipios ripsMuni on ( ripsMuni.id = muni."ripsMunicipios_id")
--	inner join usuarios_tiposDocumento tipoDocUsu on (tipoDocUsu.id = cast(u."tipoDocumentoIdentificacion" as integer))
	 inner join rips_ripstiposdocumento tiposDoc on (tiposDoc.id = cast(u."tipoDocumentoIdentificacion" as integer))
	left join rips_ripszonaterritorial zona on (zona.id = cast(u."codZonaTerritorialResidencia_id" as integer))
	inner join rips_ripstiposnotas tipnot on (tipnot.id = ripstra."tipoNota_id")	
--where  ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" = cast(facturaId as text)  and u."ripsTransaccion_id" = ripstra.id  and ripstra.id=transaccionid;
where  ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" = cast(facturaId as text)  and u."ripsTransaccion_id" = ripstra.id  ;

valorJson = valorJson ||' ' || valorTransaccionYusuarios;

end if;

if (tipo = 'NOTA CREDITO') then 
	
SELECT '"numDocumentoIdObligado": "' || "numDocumentoIdObligado" ||'",' || '"numFactura": "' || 'null' || '", "TipoNota":'|| '"' ||tipnot.codigo||'","numNota": ' || ripstra."numNota" || ',"usuarios": [{'
		||'"tipoDocumentoIdentificacion": '|| '"' ||tiposDoc.codigo || '",'||'"numDocumentoIdentificacion": '|| '"' || u."numDocumentoIdentificacion" || '",'
		||'"tipoUsuario": '|| '"' || CASE WHEN trim(u."tipoUsuario") is null THEN 'null' ELSE u."tipoUsuario"  END    || '",'||'"fechaNacimiento": '|| '"' || u."fechaNacimiento" || '",'
		||'"codSexo": '|| '"' || u."codSexo" || '",'||'"codPaisResidencia": '|| '"' || pais.codigo || '",'||'"codMunicipioResidencia": '|| '"' ||
	CASE WHEN trim(ripsMuni.codigo) is null THEN 'null' ELSE ripsMuni.codigo  END
	|| '",'	
		||'"codZonaTerritorialResidencia": '|| '"' ||CASE WHEN trim(zona.codigo) is null THEN 'null' ELSE zona.codigo  END || '",'||'"incapacidad": '|| '"' || u."incapacidad" || '",'
		||'"consecutivo": '|| u."consecutivo" || ',' ||'"codPaisOrigen": '|| '"' ||  pais.codigo
	|| '"' DATO1
INTO valorTransaccionYusuarios
	from rips_ripstransaccion ripstra
	inner join  rips_ripsusuarios u on (u."ripsTransaccion_id" = ripstra.id)
	left join  rips_ripspaises pais on (pais.id =  u."codPaisResidencia_id")
	left join  sitios_municipios muni on ( muni.id = u."codMunicipioResidencia_id")	
	left join  rips_ripsmunicipios ripsMuni on ( ripsMuni.id = muni."ripsMunicipios_id")
--	inner join usuarios_tiposDocumento tipoDocUsu on (tipoDocUsu.id = cast(u."tipoDocumentoIdentificacion" as integer))
	 inner join rips_ripstiposdocumento tiposDoc on (tiposDoc.id = cast(u."tipoDocumentoIdentificacion" as integer))
	left join rips_ripszonaterritorial zona on (zona.id = cast(u."codZonaTerritorialResidencia_id" as integer))
	inner join rips_ripstiposnotas tipnot on (tipnot.id = ripstra."tipoNota_id")	
where  ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" = cast(facturaId as text)  and u."ripsTransaccion_id" = ripstra.id; --  and ripstra.id=transaccionid;

valorJson = valorJson ||' ' || valorTransaccionYusuarios;

end if;

raise notice 'Va esto en el JSON INICIAL: %s' , valorJson;

-- Procedimientos

if (tipo = 'FACTURA') then 
	
	totalProcedimientos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsprocedimientos proc where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and proc."ripsTransaccion_id" = ripstra.id and cast("numNota" as float)  = 0   and ripstra."numFactura" = cast(facturaId as text) );

	contador = 1;
	   	FOR tabla IN select * from rips_ripstransaccion ripstra, rips_ripsprocedimientos proc where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and proc."ripsTransaccion_id" = ripstra.id 
		LOOP 
          consecutivos[contador] := tabla.consecutivo;
          contador := contador + 1;
		--raise notice 'consecutivos : %' , consecutivos[contador];
		--raise notice 'contador : %' , contador;
		END LOOP;
end if;

if (tipo = 'GLOSA') then 
	totalProcedimientos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsprocedimientos proc where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and proc."ripsTransaccion_id" = ripstra.id);	
	contador = 1;
	   	FOR tabla IN select * from rips_ripstransaccion ripstra, rips_ripsprocedimientos proc where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and proc."ripsTransaccion_id" = ripstra.id
		LOOP 
          consecutivos[contador] := tabla.consecutivo;
          contador := contador + 1;
		raise notice 'consecutivos : %' , consecutivos[contador];
		END LOOP;

end if;

if (tipo = 'NOTA CREDITO') then 
	totalProcedimientos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsprocedimientos proc where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and proc."ripsTransaccion_id" = ripstra.id  and cast(ripstra."numFactura" as integer)  = notaFacturaId   );	
	
	
	contador = 1;
	   	FOR tabla IN select * from rips_ripstransaccion ripstra, rips_ripsprocedimientos proc where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and proc."ripsTransaccion_id" = ripstra.id
		LOOP 
          consecutivos[contador] := tabla.consecutivo;
          contador := contador + 1;
		--raise notice 'consecutivos : %' , consecutivos[contador];
		END LOOP;

end if;

raise notice 'Va esto en el JSON  totalProcedimientos: %s' , totalProcedimientos;

valorJson = valorJson ||',"servicios": { "procedimientos" : [' ;
raise notice 'Detalle JSON PROCED SERVICIOS: %s' , valorJson;

if (totalProcedimientos> 0) then

   contador :=1 ;

   for i in 1..totalProcedimientos 
	loop

	   if (tipo = 'FACTURA') then 
	SELECT '{"codPrestador": '|| '"' || proc."codPrestador" || '",'  ||'"fechaInicioAtencion": '|| '"' || substring(cast(proc."fechaInicioAtencion" as text), 1,16) || '",'  

	 	  '"idMIPRES": ' || '"'   ||CASE WHEN trim(proc."idMIPRES") is null THEN 'null'  WHEN trim(proc."idMIPRES") = null THEN 'null' WHEN trim(proc."idMIPRES") = '' THEN 'null'  ELSE proc."idMIPRES"  END|| '"'  
	   ||',"numAutorizacion": '|| '"' || CASE WHEN trim(proc."numAutorizacion") is null THEN 'null' ELSE proc."numAutorizacion"  END || '"'	
	||',"codProcedimiento": '|| '"' || exa."codigoCups" || '",'	
		||'"viaIngresoServicioSalud": '|| '"' ||proc."viaIngresoServicioSalud_id"  || '",'	
	--	||'"modalidadGrupoServicioTecSal": '|| '"' || proc."modalidadGrupoServicioTecSal_id"  || '",'	
		||'"grupoServicios": '|| '"' ||ripsGrupoServ.codigo || '",'	
	   	||'"codServicio": '||ripsServicios.codigo || ','	
		||'"finalidadTecnologiaSalud": '|| '"' ||CASE WHEN trim(cast(ripsFinalidadConsulta.codigo as text)) is null THEN 'null' ELSE ripsFinalidadConsulta.codigo  END  || '",'			   
	||'"tipoDocumentoIdentificacion": '|| '"' || ripsTiposDoc.codigo  || '"'	
	||',"numDocumentoIdentificacion":  '|| '"' || CASE WHEN trim(proc."numDocumentoIdentificacion") is null THEN 'null' ELSE proc."numDocumentoIdentificacion"  END  || '",'	
	||'"codDiagnosticoPrincipal": '|| '"' || CASE WHEN trim(cast(diag1.cie10 as text)) is null THEN 'null' ELSE diag1.cie10  END || '",'	
	||'"codDiagnosticoRelacionado": '|| '"' ||  CASE WHEN trim(cast(diag2.cie10 as text)) is null THEN 'null' ELSE diag2.cie10  END    || '",'	
	||'"codComplicacion": '|| '"' ||CASE WHEN trim(cast(diag3.cie10 as text)) is null THEN 'null' ELSE diag3.cie10 END   || '",'
	||'"vrServicio": '||proc."vrServicio"   || ','		
	 ||'"conceptoRecaudo": '|| '"' || ripsRecaudo.codigo   || '",'		
	||'"valorPagoModerador": '||  CASE WHEN trim(cast(proc."valorPagoModerador" as text)) is null THEN 0 ELSE proc."valorPagoModerador"  END  || ','	
	||'"numFEVPagoModerador": '|| '"' || proc."numFEVPagoModerador" || '",'
	||'"consecutivo": '||  proc."consecutivo" ||'	},'
	INTO valorProcedimientos
	from rips_ripstransaccion ripstra
	inner join rips_ripsprocedimientos proc on (proc."ripsTransaccion_id" = ripstra.id)
	inner join clinico_examenes exa on (exa.id = proc."codProcedimiento_id" )   
	left join clinico_diagnosticos diag1 on (diag1.id=proc."codDiagnosticoPrincipal_id")   
	left join clinico_diagnosticos diag2 on (diag2.id=proc."codDiagnosticoRelacionado_id")   
	left join clinico_diagnosticos diag3 on (diag3.id=proc."codComplicacion_id")  
	left  join rips_ripsviasingresosalud ripsIngresoSalud ON (ripsIngresoSalud.id = proc."viaIngresoServicioSalud_id")   
	left  join rips_ripsgruposervicios ripsGrupoServ ON (ripsGrupoServ.id = proc."grupoServicios_id")
--	left  join rips_ripsmodalidadgruposerviciosTecSalud  ripsModalidadGrupoServ ON (ripsModalidadGrupoServ.id = proc."modalidadGrupoServicioTecSal_id")
	left  join rips_ripsservicios ripsServicios ON (ripsServicios.id = proc."codServicio_id")
	left  join rips_ripsfinalidadconsulta ripsFinalidadConsulta ON (ripsFinalidadConsulta.id = proc."finalidadTecnologiaSalud_id")	   
	inner join rips_ripstiposdocumento ripsTiposDoc on (ripsTiposDoc.id = proc."tipoDocumentoIdentificacion_id" )
	left join rips_RipsConceptoRecaudo ripsRecaudo on (ripsRecaudo.id = proc."conceptoRecaudo_id")
    where  ripstra."ripsEnvio_id" = envioRipsId AND  ripstra."numFactura" = cast(facturaId as text) and proc.consecutivo = i; 

    raise notice 'valorProcedimientos: %s' , valorProcedimientos;
	valorJson = valorJson ||' '||valorProcedimientos;
	raise notice 'contador: %s' , contador;
    raise notice 'Detalle JSON PROCED ACUMULADO: %s' , valorJson;
	contador := contador +1;

	end if;

	if (tipo = 'GLOSA') then
	SELECT '{"codPrestador": '|| '"' || proc."codPrestador" || '",'  ||'"fechaInicioAtencion": '|| '"' || substring(cast(proc."fechaInicioAtencion" as text), 1,16) || '",'  
	 	  '"idMIPRES": ' || '"'   ||CASE WHEN trim(proc."idMIPRES") is null THEN 'null'  WHEN trim(proc."idMIPRES") = null THEN 'null' WHEN trim(proc."idMIPRES") = '' THEN 'null'  ELSE proc."idMIPRES"  END|| '"'  
	   ||',"numAutorizacion": '|| '"' || CASE WHEN trim(proc."numAutorizacion") is null THEN 'null' ELSE proc."numAutorizacion"  END || '"'	
	||',"codProcedimiento": '|| '"' || exa."codigoCups" || '",'	
		||'"viaIngresoServicioSalud": '|| '"' ||proc."viaIngresoServicioSalud_id"  || '",'	
	--	||'"modalidadGrupoServicioTecSal": '|| '"' || proc."modalidadGrupoServicioTecSal_id"  || '",'	
		||'"grupoServicios": '|| '"' ||ripsGrupoServ.codigo || '",'	
	   	||'"codServicio": '||ripsServicios.codigo || ','	
		||'"finalidadTecnologiaSalud": '|| '"' ||CASE WHEN trim(cast(ripsFinalidadConsulta.codigo as text)) is null THEN 'null' ELSE ripsFinalidadConsulta.codigo  END  || '",'			   
	||'"tipoDocumentoIdentificacion": '|| '"' || ripsTiposDoc.codigo  || '"'	
	||',"numDocumentoIdentificacion":  '|| '"' || CASE WHEN trim(proc."numDocumentoIdentificacion") is null THEN 'null' ELSE proc."numDocumentoIdentificacion"  END  || '",'	
	||'"codDiagnosticoPrincipal": '|| '"' || CASE WHEN trim(cast(diag1.cie10 as text)) is null THEN 'null' ELSE diag1.cie10  END || '",'	
	||'"codDiagnosticoRelacionado": '|| '"' ||  CASE WHEN trim(cast(diag2.cie10 as text)) is null THEN 'null' ELSE diag2.cie10  END    || '",'	
	||'"codComplicacion": '|| '"' ||CASE WHEN trim(cast(diag3.cie10 as text)) is null THEN 'null' ELSE diag3.cie10 END   || '",'
	||'"vrServicio": '|| CASE WHEN proc."notasCreditoGlosa" is null then 0  ELSE proc."notasCreditoGlosa" end   || ','		
	 ||'"conceptoRecaudo": '|| '"' || ripsRecaudo.codigo   || '",'		
	||'"valorPagoModerador": '||  CASE WHEN trim(cast(proc."valorPagoModerador" as text)) is null THEN 0 ELSE proc."valorPagoModerador"  END  || ','	
	||'"numFEVPagoModerador": '|| '"' || proc."numFEVPagoModerador" || '",'
	||'"consecutivo": '||  proc."consecutivo" ||'	},'
	INTO valorProcedimientos
	from rips_ripstransaccion ripstra
	inner join rips_ripsprocedimientos proc on (proc."ripsTransaccion_id" = ripstra.id)
	inner join clinico_examenes exa on (exa.id = proc."codProcedimiento_id" )   
	left join clinico_diagnosticos diag1 on (diag1.id=proc."codDiagnosticoPrincipal_id")   
	left join clinico_diagnosticos diag2 on (diag2.id=proc."codDiagnosticoRelacionado_id")   
	left join clinico_diagnosticos diag3 on (diag3.id=proc."codComplicacion_id")  
	left  join rips_ripsviasingresosalud ripsIngresoSalud ON (ripsIngresoSalud.id = proc."viaIngresoServicioSalud_id")   
	left  join rips_ripsgruposervicios ripsGrupoServ ON (ripsGrupoServ.id = proc."grupoServicios_id")
--	left  join rips_ripsmodalidadgruposerviciosTecSalud  ripsModalidadGrupoServ ON (ripsModalidadGrupoServ.id = proc."modalidadGrupoServicioTecSal_id")
	left  join rips_ripsservicios ripsServicios ON (ripsServicios.id = proc."codServicio_id")
	left  join rips_ripsfinalidadconsulta ripsFinalidadConsulta ON (ripsFinalidadConsulta.id = proc."finalidadTecnologiaSalud_id")	   
	inner join rips_ripstiposdocumento ripsTiposDoc on (ripsTiposDoc.id = proc."tipoDocumentoIdentificacion_id" )
	left join rips_RipsConceptoRecaudo ripsRecaudo on (ripsRecaudo.id = proc."conceptoRecaudo_id")	   
	where  ripstra."ripsEnvio_id" = envioRipsId AND ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" = cast(facturaId as text)  and proc.consecutivo = i;

	valorJson = valorJson ||' '||valorProcedimientos;

	end if;

	if (tipo = 'NOTA CREDITO') then 
	SELECT '{"codPrestador": '|| '"' || proc."codPrestador" || '",'  ||'"fechaInicioAtencion": '|| '"' || substring(cast(proc."fechaInicioAtencion" as text), 1,16) || '",'  
	 	  '"idMIPRES": ' || '"'   ||CASE WHEN trim(proc."idMIPRES") is null THEN 'null'  WHEN trim(proc."idMIPRES") = null THEN 'null' WHEN trim(proc."idMIPRES") = '' THEN 'null'  ELSE proc."idMIPRES"  END|| '"'  
	   ||',"numAutorizacion": '|| '"' || CASE WHEN trim(proc."numAutorizacion") is null THEN 'null' ELSE proc."numAutorizacion"  END || '"'	
	||',"codProcedimiento": '|| '"' || exa."codigoCups" || '",'	
		||'"viaIngresoServicioSalud": '|| '"' ||proc."viaIngresoServicioSalud_id"  || '",'	
	--	||'"modalidadGrupoServicioTecSal": '|| '"' || proc."modalidadGrupoServicioTecSal_id"  || '",'	
		||'"grupoServicios": '|| '"' ||ripsGrupoServ.codigo || '",'	
	   	||'"codServicio": '||ripsServicios.codigo || ','	
		||'"finalidadTecnologiaSalud": '|| '"' ||CASE WHEN trim(cast(ripsFinalidadConsulta.codigo as text)) is null THEN 'null' ELSE ripsFinalidadConsulta.codigo  END  || '",'			   
	||'"tipoDocumentoIdentificacion": '|| '"' || ripsTiposDoc.codigo  || '"'	
	||',"numDocumentoIdentificacion":  '|| '"' || CASE WHEN trim(proc."numDocumentoIdentificacion") is null THEN 'null' ELSE proc."numDocumentoIdentificacion"  END  || '",'	
	||'"codDiagnosticoPrincipal": '|| '"' || CASE WHEN trim(cast(diag1.cie10 as text)) is null THEN 'null' ELSE diag1.cie10  END || '",'	
	||'"codDiagnosticoRelacionado": '|| '"' ||  CASE WHEN trim(cast(diag2.cie10 as text)) is null THEN 'null' ELSE diag2.cie10  END    || '",'	
	||'"codComplicacion": '|| '"' ||CASE WHEN trim(cast(diag3.cie10 as text)) is null THEN 'null' ELSE diag3.cie10 END   || '",'
	||'"vrServicio": '|| proc."notasCreditoOtras"   || ','		
	 ||'"conceptoRecaudo": '|| '"' || ripsRecaudo.codigo   || '",'		
	||'"valorPagoModerador": '||  CASE WHEN trim(cast(proc."valorPagoModerador" as text)) is null THEN 0 ELSE proc."valorPagoModerador"  END  || ','	
	||'"numFEVPagoModerador": '|| '"' || proc."numFEVPagoModerador" || '",'
	||'"consecutivo": '||  proc."consecutivo" ||'	},'
	INTO valorProcedimientos
	from rips_ripstransaccion ripstra
	inner join rips_ripsprocedimientos proc on (proc."ripsTransaccion_id" = ripstra.id  and proc."numFEVPagoModerador" = ripstra."numFactura")
	inner join clinico_examenes exa on (exa.id = proc."codProcedimiento_id" )   
	left join clinico_diagnosticos diag1 on (diag1.id=proc."codDiagnosticoPrincipal_id")   
	left join clinico_diagnosticos diag2 on (diag2.id=proc."codDiagnosticoRelacionado_id")   
	left join clinico_diagnosticos diag3 on (diag3.id=proc."codComplicacion_id")  
	left  join rips_ripsviasingresosalud ripsIngresoSalud ON (ripsIngresoSalud.id = proc."viaIngresoServicioSalud_id")   
	left  join rips_ripsgruposervicios ripsGrupoServ ON (ripsGrupoServ.id = proc."grupoServicios_id")
--	left  join rips_ripsmodalidadgruposerviciosTecSalud  ripsModalidadGrupoServ ON (ripsModalidadGrupoServ.id = proc."modalidadGrupoServicioTecSal_id")
	left  join rips_ripsservicios ripsServicios ON (ripsServicios.id = proc."codServicio_id")
	left  join rips_ripsfinalidadconsulta ripsFinalidadConsulta ON (ripsFinalidadConsulta.id = proc."finalidadTecnologiaSalud_id")	   
	inner join rips_ripstiposdocumento ripsTiposDoc on (ripsTiposDoc.id = proc."tipoDocumentoIdentificacion_id" )
	left join rips_RipsConceptoRecaudo ripsRecaudo on (ripsRecaudo.id = proc."conceptoRecaudo_id")	   
	where  ripstra."ripsEnvio_id" = envioRipsId AND ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" = cast(facturaId as text) and cast(ripstra."numFactura" as integer) = notaFacturaId and proc.consecutivo = i;

    raise notice 'valorProcedimientos: %s' , valorProcedimientos;
	valorJson = valorJson ||' '||valorProcedimientos;
	raise notice 'contador: %s' , contador;
    raise notice 'Detalle JSON PROCED ACUMULADO: %s' , valorJson;
	contador := contador +1;

	end if;

	end loop;
	mide := length(valorJson);
	RAISE NOTICE 'mide = %s' , mide ;
	SELECT SUBSTRING(valorJson,1, mide-1) INTO valorJson;	
	valorJson = valorJson || ']' ;
else
	 valorJson = valorJson || ']' ; 

end if;
	
RAISE NOTICE 'VALOR PROCEDIMIENTOS = %s' ,valorProcedimientos ;

raise notice 'Va esto en el JSON PROCED: %s' , valorJson;

-- Hospitalizacion

 valorJson = valorJson || ', "hospitalizacion":' ;

if (tipo = 'FACTURA') then 

totalHospitalizacion  = (select count(*) from rips_ripstransaccion ripstra, rips_ripshospitalizacion hosp where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and hosp."ripsTransaccion_id" = ripstra.id and cast("numNota" as float)  = 0);

end if;

if (tipo = 'GLOSA') then 
totalHospitalizacion  = (select count(*) from rips_ripstransaccion ripstra, rips_ripshospitalizacion hosp where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and hosp."ripsTransaccion_id" = ripstra.id);
end if;	

if (tipo = 'NOTA CREDITO') then 
totalHospitalizacion  = (select count(*) from rips_ripstransaccion ripstra, rips_ripshospitalizacion hosp where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and hosp."ripsTransaccion_id" = ripstra.id );
end if;

if (totalHospitalizacion> 0) then

	RAISE NOTICE 'ENTRE TOTAL totalHospitalizacion = %s', totalHospitalizacion;

if (tipo = 'FACTURA') then 

SELECT ' [{"codPrestador": ' ||'"'  ||   hosp."codPrestador"|| '",'  ||
	   '"viaIngresoServicioSalud": ' || '"'  ||hosp."viaIngresoServicioSalud_id"|| '",'  ||
	    '"fechaInicioAtencion": ' || '"'  ||substring(cast(hosp."fechaInicioAtencion" as text),1,16)|| '",'  || 
		 '"numAutorizacion": ' || '"'  ||CASE WHEN trim(cast(hosp."numAutorizacion" as text)) is null THEN 'null' WHEN trim(cast(hosp."numAutorizacion" as text)) = '' THEN 'null' ELSE hosp."numAutorizacion"  END|| '",'   || 
	 '"causaMotivoAtencion": ' || '"'  ||cauext.codigo|| '",'   || 
	 '"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '",'   || 
		  '"codDiagnosticoPrincipalE": ' || '"'  ||dxppale.cie10|| '",'    ||
   '"codDiagnosticoRelacionadoE1": ' || '"'  ||CASE WHEN trim(cast(dxrel1.cie10 as text)) is null THEN 'null' WHEN trim(cast(dxrel1.cie10 as text)) = '' THEN 'null' ELSE dxrel1.cie10  END|| '",'   || 	
   '"codDiagnosticoRelacionadoE2": ' || '"'  ||CASE WHEN trim(cast(dxrel2.cie10  as text)) is null THEN 'null' WHEN trim(cast(dxrel2.cie10 as text)) = '' THEN 'null' ELSE dxrel2.cie10  END|| '",'   || 	
   '"codDiagnosticoRelacionadoE3": ' || '"'  ||CASE WHEN trim(cast(dxrel3.cie10  as text)) is null THEN 'null' WHEN trim(cast(dxrel3.cie10 as text)) = '' THEN 'null' ELSE dxrel3.cie10  END|| '",'   || 	
	'"codComplicacion": ' || '"'  ||'null'|| '",'  ||
		 '"condicionDestinoUsuarioEgreso": ' || '"'  ||cauext.codigo|| '",'   || 
		'"codDiagnosticoMuerte": ' || '"'  ||'null'|| '",'  ||
		 '"fechaEgreso": ' || '"'  ||case when hosp."fechaEgreso" is null then 'null' else substring(cast(hosp."fechaEgreso" as text),1,16) end|| '",'   || 
	'"consecutivo": ' ||hosp.consecutivo||  '}]'
INTO valorHospitalizacion
from rips_ripstransaccion
	left join rips_ripshospitalizacion hosp on (hosp."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join rips_ripscausaexterna cauext on (cauext.id =hosp."causaMotivoAtencion_id" )
	left join clinico_diagnosticos dxppal on (dxppal.id =hosp."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxppale on (dxppale.id =hosp."codDiagnosticoPrincipalE_id")
	left join clinico_diagnosticos dxrel1 on (dxrel1.id = hosp."codDiagnosticoRelacionadoE1_id")
	left join clinico_diagnosticos dxrel2 on (dxrel2.id =  hosp."codDiagnosticoRelacionadoE2_id")
	left join clinico_diagnosticos dxrel3 on (dxrel3.id =  hosp."codDiagnosticoRelacionadoE3_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = hosp."condicionDestinoUsuarioEgreso_id" )
where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numFactura" =cast(facturaId as text) ;
	valorJson = valorJson ||' ' ||  valorHospitalizacion;
end if;	

if (tipo = 'GLOSA') then 

SELECT '[{"codPrestador": ' ||'"'  ||   hosp."codPrestador"|| '",'  ||
	   '"viaIngresoServicioSalud": ' || '"'  ||hosp."viaIngresoServicioSalud_id"|| '",'  ||
	    '"fechaInicioAtencion": ' || '"'  ||substring(CAST( hosp."fechaInicioAtencion"  as text),1,16) || '",'  || 
		 '"numAutorizacion": ' || '"'  ||CASE WHEN trim(cast(hosp."numAutorizacion" as text)) is null THEN 'null' WHEN trim(cast(hosp."numAutorizacion" as text)) = '' THEN 'null' ELSE hosp."numAutorizacion"  END|| '",'   || 
	 '"causaMotivoAtencion": ' || '"'  ||cauext.codigo|| '",'   || 
	 '"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '",'   || 
		  '"codDiagnosticoPrincipalE": ' || '"'  ||dxppale.cie10|| '",'    ||
   '"codDiagnosticoRelacionadoE1": ' || '"'  ||CASE WHEN trim(cast(dxrel1.cie10 as text)) is null THEN 'null' WHEN trim(cast(dxrel1.cie10 as text)) = '' THEN 'null' ELSE dxrel1.cie10  END|| '",'   || 	
   '"codDiagnosticoRelacionadoE2": ' || '"'  ||CASE WHEN trim(cast(dxrel2.cie10  as text)) is null THEN 'null' WHEN trim(cast(dxrel2.cie10 as text)) = '' THEN 'null' ELSE dxrel2.cie10  END|| '",'   || 	
   '"codDiagnosticoRelacionadoE3": ' || '"'  ||CASE WHEN trim(cast(dxrel3.cie10  as text)) is null THEN 'null' WHEN trim(cast(dxrel3.cie10 as text)) = '' THEN 'null' ELSE dxrel3.cie10  END|| '",'   || 	
	'"codComplicacion": ' || '"'  ||'null'|| '",'  ||
		 '"condicionDestinoUsuarioEgreso": ' || '"'  ||cauext.codigo|| '",'   || 
		'"codDiagnosticoMuerte": ' || '"'  ||'null'|| '",'  ||
		 '"fechaEgreso": ' || '"'  ||case when hosp."fechaEgreso" is null then 'null' else substring(cast(hosp."fechaEgreso" as text),1,16) end|| '",'   || 
	'"consecutivo": ' || hosp.consecutivo|| '}]'
INTO valorHospitalizacion
from rips_ripstransaccion
	left join rips_ripshospitalizacion hosp on (hosp."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join rips_ripscausaexterna cauext on (cauext.id =hosp."causaMotivoAtencion_id" )
	left join clinico_diagnosticos dxppal on (dxppal.id =hosp."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxppale on (dxppale.id =hosp."codDiagnosticoPrincipalE_id")
	left join clinico_diagnosticos dxrel1 on (dxrel1.id = hosp."codDiagnosticoRelacionadoE1_id")
	left join clinico_diagnosticos dxrel2 on (dxrel2.id =  hosp."codDiagnosticoRelacionadoE2_id")
	left join clinico_diagnosticos dxrel3 on (dxrel3.id =  hosp."codDiagnosticoRelacionadoE3_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = hosp."condicionDestinoUsuarioEgreso_id" )
where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numNota" =cast(facturaId as text) ;

valorJson = valorJson ||' ' ||  valorHospitalizacion;
end if;	
	-- valorJson = valorJson || ',' ; ESTABA
if (tipo = 'NOTA CREDITO') then 

SELECT '[{"codPrestador": ' ||'"'  ||   hosp."codPrestador"|| '",'  ||
	   '"viaIngresoServicioSalud": ' || '"'  ||hosp."viaIngresoServicioSalud_id"|| '",'  ||
	    '"fechaInicioAtencion": ' || '"'  ||substring(CAST( hosp."fechaInicioAtencion"  as text),1,16) || '",'  || 
		 '"numAutorizacion": ' || '"'  ||CASE WHEN trim(cast(hosp."numAutorizacion" as text)) is null THEN 'null' WHEN trim(cast(hosp."numAutorizacion" as text)) = '' THEN 'null' ELSE hosp."numAutorizacion"  END|| '",'   || 
	 '"causaMotivoAtencion": ' || '"'  ||cauext.codigo|| '",'   || 
	 '"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '",'   || 
		  '"codDiagnosticoPrincipalE": ' || '"'  ||dxppale.cie10|| '",'    ||
   '"codDiagnosticoRelacionadoE1": ' || '"'  ||CASE WHEN trim(cast(dxrel1.cie10 as text)) is null THEN 'null' WHEN trim(cast(dxrel1.cie10 as text)) = '' THEN 'null' ELSE dxrel1.cie10  END|| '",'   || 	
   '"codDiagnosticoRelacionadoE2": ' || '"'  ||CASE WHEN trim(cast(dxrel2.cie10  as text)) is null THEN 'null' WHEN trim(cast(dxrel2.cie10 as text)) = '' THEN 'null' ELSE dxrel2.cie10  END|| '",'   || 	
   '"codDiagnosticoRelacionadoE3": ' || '"'  ||CASE WHEN trim(cast(dxrel3.cie10  as text)) is null THEN 'null' WHEN trim(cast(dxrel3.cie10 as text)) = '' THEN 'null' ELSE dxrel3.cie10  END|| '",'   || 	
	'"codComplicacion": ' || '"'  ||'null'|| '",'  ||
		 '"condicionDestinoUsuarioEgreso": ' || '"'  ||cauext.codigo|| '",'   || 
		'"codDiagnosticoMuerte": ' || '"'  ||'null'|| '",'  ||
		 '"fechaEgreso": ' || '"'  ||case when hosp."fechaEgreso" is null then 'null' else substring(cast(hosp."fechaEgreso" as text),1,16) end|| '",'   || 
	'"consecutivo": ' || hosp.consecutivo|| '}]'
INTO valorHospitalizacion
from rips_ripstransaccion
	left join rips_ripshospitalizacion hosp on (hosp."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join rips_ripscausaexterna cauext on (cauext.id =hosp."causaMotivoAtencion_id" )
	left join clinico_diagnosticos dxppal on (dxppal.id =hosp."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxppale on (dxppale.id =hosp."codDiagnosticoPrincipalE_id")
	left join clinico_diagnosticos dxrel1 on (dxrel1.id = hosp."codDiagnosticoRelacionadoE1_id")
	left join clinico_diagnosticos dxrel2 on (dxrel2.id =  hosp."codDiagnosticoRelacionadoE2_id")
	left join clinico_diagnosticos dxrel3 on (dxrel3.id =  hosp."codDiagnosticoRelacionadoE3_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = hosp."condicionDestinoUsuarioEgreso_id" )
where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numNota" =cast(facturaId as text) ;

valorJson = valorJson ||' ' ||  valorHospitalizacion;
end if;	
	valorJson = valorJson || ' ' ;

else
	valorJson = valorJson || '[]' ;
 end if;

raise notice 'Va esto en el JSON HOSP: %s' , valorJson;

-- Urgencias

totalUrgencias  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsurgenciasobservacion urg where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and urg."ripsTransaccion_id" = ripstra.id);

if (tipo = 'FACTURA') then 

totalUrgencias  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsurgenciasobservacion urg where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and urg."ripsTransaccion_id" = ripstra.id and cast("numNota" as float)  = 0);

end if;

if (tipo = 'GLOSA') then 

totalUrgencias  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsurgenciasobservacion urg where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and urg."ripsTransaccion_id" = ripstra.id );

end if;	
if (tipo = 'NOTA CREDITO') then 

totalUrgencias  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsurgenciasobservacion urg where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and urg."ripsTransaccion_id" = ripstra.id);

end if;	

	RAISE NOTICE 'ANTES DE URGENCIAS';
RAISE NOTICE 'TOTAL URGENCIAS = %s', totalUrgencias;
valorJson = valorJson || ',"urgencias":' ;

if (totalUrgencias> 0) then

	RAISE NOTICE 'eNTRE uRGENCIAS';

	if (tipo = 'FACTURA') then 
	
	 SELECT ' [{"codPrestador": ' ||  '"' || urg."codPrestador"|| '",'  ||
	   	    '"fechaInicioAtencion": ' || '"'  ||substring(cast(urg."fechaInicioAtencion" as text),1,16)|| '",'  || 	
			 '"causaMotivoAtencion": ' || '"'  ||cauext.codigo|| '",'   || 
	 		'"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '",'   || 
		  '"codDiagnosticoPrincipalE": ' || '"'  ||dxppale.cie10|| '",'    ||
			'"codDiagnosticoRelacionadoE1": ' || '"'  ||coalesce(dxrel1.cie10,'null')|| '",'  ||
		 	'"codDiagnosticoRelacionadoE2": ' || '"'  ||coalesce(dxrel2.cie10,'null')|| '",'  ||
			'"codDiagnosticoRelacionadoE3": ' || '"'  ||coalesce(dxrel3.cie10,'null')|| '",'  ||
		 	'"condicionDestinoUsuarioEgreso": ' || '"'  ||cauext.codigo|| '",'   || 
			'"codDiagnosticoCausaMuerte": ' || '"'  ||coalesce(dxMuerte.cie10,'null')|| '",'  ||
		 	'"fechaEgreso": ' || '"'  ||substring(cast(urg."fechaEgreso"  as text),1,16)|| '",'   || 
		'"consecutivo": ' ||urg.consecutivo|| 	'}]'
	INTO valorUrgencias
	from rips_ripstransaccion
	left join rips_ripsurgenciasobservacion urg on (urg."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join rips_ripscausaexterna cauext on (cauext.id =urg."causaMotivoAtencion_id" )
	left join clinico_diagnosticos dxppal on (dxppal.id =urg."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxppale on (dxppale.id =urg."codDiagnosticoPrincipalE_id")
	left join clinico_diagnosticos dxrel1 on (dxrel1.id = urg."codDiagnosticoRelacionadoE1_id")
	left join clinico_diagnosticos dxrel2 on (dxrel2.id =  urg."codDiagnosticoRelacionadoE2_id")
	left join clinico_diagnosticos dxrel3 on (dxrel3.id =  urg."codDiagnosticoRelacionadoE3_id")
	left join clinico_diagnosticos dxMuerte on (dxMuerte.id =  urg."codDiagnosticoCausaMuerte_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = urg."condicionDestinoUsuarioEgreso_id" )
	where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numFactura" =cast(facturaId as text);
	
	valorJson = valorJson ||' ' || valorUrgencias;
    end if;

if (tipo = 'GLOSA') then 
	 SELECT '[{"codPrestador": ' ||  '"' || urg."codPrestador"|| '",'  ||
	   	    '"fechaInicioAtencion": ' || '"'  ||substring(cast(urg."fechaInicioAtencion" as text),1,16)|| '",'  || 	
			 '"causaMotivoAtencion": ' || '"'  ||cauext.codigo|| '",'   || 
	 		'"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '",'   || 
		  '"codDiagnosticoPrincipalE": ' || '"'  ||dxppale.cie10|| '",'    ||
			'"codDiagnosticoRelacionadoE1": ' || '"'  ||coalesce(dxrel1.cie10,'null')|| '",'  ||
		 	'"codDiagnosticoRelacionadoE2": ' || '"'  ||coalesce(dxrel2.cie10,'null')|| '",'  ||
			'"codDiagnosticoRelacionadoE3": ' || '"'  ||coalesce(dxrel3.cie10,'null')|| '",'  ||
		 	'"condicionDestinoUsuarioEgreso": ' || '"'  ||cauext.codigo|| '",'   || 
			'"codDiagnosticoCausaMuerte": ' || '"'  ||coalesce(dxMuerte.cie10,'null')|| '",'  ||
		 	'"fechaEgreso": ' || '"'  ||substring(cast(urg."fechaEgreso"  as text),1,16)|| '",'   || 
		'"consecutivo": ' ||urg.consecutivo|| 	'}]'
	INTO valorUrgencias
	from rips_ripstransaccion
	left join rips_ripsurgenciasobservacion urg on (urg."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join rips_ripscausaexterna cauext on (cauext.id =urg."causaMotivoAtencion_id" )
	left join clinico_diagnosticos dxppal on (dxppal.id =urg."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxppale on (dxppale.id =urg."codDiagnosticoPrincipalE_id")
	left join clinico_diagnosticos dxrel1 on (dxrel1.id = urg."codDiagnosticoRelacionadoE1_id")
	left join clinico_diagnosticos dxrel2 on (dxrel2.id =  urg."codDiagnosticoRelacionadoE2_id")
	left join clinico_diagnosticos dxrel3 on (dxrel3.id =  urg."codDiagnosticoRelacionadoE3_id")
	left join clinico_diagnosticos dxMuerte on (dxMuerte.id =  urg."codDiagnosticoCausaMuerte_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = urg."condicionDestinoUsuarioEgreso_id" )
	where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numNota" =cast(facturaId as text) ;
	valorJson = valorJson ||' ' || valorUrgencias;
    end if;

if (tipo = 'NOTA CREDITO') then 
		
	 SELECT '[{"codPrestador": ' ||  '"' || urg."codPrestador"|| '",'  ||
	   	    '"fechaInicioAtencion": ' || '"'  ||substring(cast(urg."fechaInicioAtencion" as text),1,16)|| '",'  || 	
			 '"causaMotivoAtencion": ' || '"'  ||cauext.codigo|| '",'   || 
	 		'"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '",'   || 
		  '"codDiagnosticoPrincipalE": ' || '"'  ||dxppale.cie10|| '",'    ||
			'"codDiagnosticoRelacionadoE1": ' || '"'  ||coalesce(dxrel1.cie10,'null')|| '",'  ||
		 	'"codDiagnosticoRelacionadoE2": ' || '"'  ||coalesce(dxrel2.cie10,'null')|| '",'  ||
			'"codDiagnosticoRelacionadoE3": ' || '"'  ||coalesce(dxrel3.cie10,'null')|| '",'  ||
		 	'"condicionDestinoUsuarioEgreso": ' || '"'  ||cauext.codigo|| '",'   || 
			'"codDiagnosticoCausaMuerte": ' || '"'  ||coalesce(dxMuerte.cie10,'null')|| '",'  ||
		 	'"fechaEgreso": ' || '"'  ||substring(cast(urg."fechaEgreso"  as text),1,16)|| '",'   || 
		'"consecutivo": ' ||urg.consecutivo|| 	'}]'
	INTO valorUrgencias
	from rips_ripstransaccion
	left join rips_ripsurgenciasobservacion urg on (urg."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join rips_ripscausaexterna cauext on (cauext.id =urg."causaMotivoAtencion_id" )
	left join clinico_diagnosticos dxppal on (dxppal.id =urg."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxppale on (dxppale.id =urg."codDiagnosticoPrincipalE_id")
	left join clinico_diagnosticos dxrel1 on (dxrel1.id = urg."codDiagnosticoRelacionadoE1_id")
	left join clinico_diagnosticos dxrel2 on (dxrel2.id =  urg."codDiagnosticoRelacionadoE2_id")
	left join clinico_diagnosticos dxrel3 on (dxrel3.id =  urg."codDiagnosticoRelacionadoE3_id")
	left join clinico_diagnosticos dxMuerte on (dxMuerte.id =  urg."codDiagnosticoCausaMuerte_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = urg."condicionDestinoUsuarioEgreso_id" )
	where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numNota" =cast(facturaId as text) and rips_ripstransaccion.id=transaccionid;
	valorJson = valorJson ||' ' || valorUrgencias;
    end if;

else
	valorJson = valorJson || '[]' ;

END IF;

raise notice 'Va esto en el JSON URGE: %s' , valorJson;

totalMedicamentos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsmedicamentos ripsmed where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and ripsmed."ripsTransaccion_id" = ripstra.id);

if (tipo = 'FACTURA') then 

totalMedicamentos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsmedicamentos ripsmed where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and ripsmed."ripsTransaccion_id" = ripstra.id  and cast("numNota" as float)  = 0);

end if;

if (tipo = 'GLOSA') then 

totalMedicamentos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsmedicamentos ripsmed where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and ripsmed."ripsTransaccion_id" = ripstra.id);

end if;	

if (tipo = 'NOTA CREDITO') then 

totalMedicamentos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsmedicamentos ripsmed where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and ripsmed."ripsTransaccion_id" = ripstra.id  and ripstra."numFactura" = cast(notaFacturaId as text) );

end if;	

RAISE NOTICE 'ANTES DE totalMedicamentos';
valorJson = valorJson ||' ,"medicamentos" : [' ;

	RAISE NOTICE 'TOTAL totalMedicamentos = %s', totalMedicamentos;

if (totalMedicamentos> 0) then

	RAISE NOTICE 'ENTRE TOTAL totalMedicamentos = %s', totalMedicamentos;

   
	for i in 1..totalMedicamentos
	loop   

			if (tipo = 'FACTURA') then 
		
 SELECT	'{"codPrestador": ' ||  '"' ||med."codPrestador"|| '",'   ||		
	   	    '"numAutorizacion": ' || '"'  ||CASE WHEN trim(med."numAutorizacion") is null THEN 'null' ELSE med."numAutorizacion"  END|| '",'   || 	
	 	  '"idMIPRES": ' || '"'   ||CASE WHEN trim(med."idMIPRES") is null THEN 'null'  WHEN trim(med."idMIPRES") = null THEN 'null' WHEN trim(med."idMIPRES") = '' THEN 'null'  ELSE med."idMIPRES"  END|| '",'  || 	
		  '"fechaDispensAdmon": ' || '"'  ||substring(cast(med."fechaDispensAdmon" as text),1,16) || '",'     || 	
	  '"codDiagnosticoPrincipal": ' || '"'  ||CASE WHEN trim(diag1.cie10) is null THEN 'null' ELSE diag1.cie10  END|| '",'  || 	
	'"codDiagnosticoRelacionado": ' || '"'  ||CASE WHEN trim(diag2.cie10) is null THEN 'null' ELSE diag2.cie10  END|| '",' 	  || 	
	'"tipoMedicamento": ' || '"'  ||CASE WHEN trim(tipmed.codigo) is null THEN 'null' ELSE tipmed.codigo  END|| '",'   || 	
	'"codTecnologiaSalud": ' || '"'  ||  CASE WHEN trim(ripscums.cum) is null THEN 'null' ELSE ripscums.cum  END           || '",'  || 	
	'"nomTecnologiaSalud": ' || '"'  ||   CASE WHEN trim(med."nomTecnologiaSalud") is null THEN 'null' ELSE med."nomTecnologiaSalud"  END               || '",'  || 	
	'"concentracionMedicamento": ' || '"'  || CASE WHEN trim(med."concentracionMedicamento") is null THEN 'null' ELSE med."concentracionMedicamento"  END  || '",'    || 		
	'"unidadMedida": ' ||CASE WHEN ripsumm.codigo is null THEN 'null' WHEN ripsumm.codigo = 'null' THEN 'null' ELSE ripsumm.codigo  END|| ','  || 	
	'"formaFarmaceutica": ' || '"'  ||  CASE WHEN trim(ripsfarma.codigo) is null THEN 'null' ELSE ripsfarma.codigo  END  || '",'  || 	
	'"unidadMinDispensa": ' || CASE WHEN trim(ripsupr.codigo) is null THEN 'null' WHEN trim(ripsupr.codigo) = 'null' THEN 'null' ELSE ripsupr.codigo  END || ','  || 	
	'"cantidadMedicamento": ' || case when med."cantidadMedicamento" is null then 0 else  med."cantidadMedicamento" end   || ','    || 	
	'"diasTratamiento": ' ||  case when med."diasTratamiento" is null then 0 else  med."diasTratamiento" end   || ','   || 		
	'"tipoDocumentoldentificacion": ' || '"'  || CASE WHEN trim(ripstipdoc.codigo) is null THEN 'null' ELSE ripstipdoc.codigo  END   || '",'  || 	
	'"numDocumentoIdentificacion": ' || '"'  || CASE WHEN trim(med."numDocumentoIdentificacion") is null THEN 'null' ELSE med."numDocumentoIdentificacion"  END     || '",'  || 	
		'"vrUnitMedicamento": ' || med."vrUnitMedicamento" || ','  || 	
		'"vrServicio": ' || med."vrServicio"|| ','  || 	
		'"conceptoRecaudo": ' || '"'  ||CASE WHEN trim(recaudo.codigo) is null THEN 'null' ELSE recaudo.codigo  END|| '",'  || 	
		'"tipoPagoModerador": ' || '"'  ||  CASE WHEN trim( ripstipopago.codigo) is null THEN 'null' ELSE  ripstipopago.codigo  END || '",'  || 	
	'"valorPagoModerador": ' || med."valorPagoModerador" || ','  || 				
	'"numFEVPagoModerador": ' || '"'  || CASE WHEN trim(med."numFEVPagoModerador") is null THEN 'null' ELSE  med."numFEVPagoModerador"  END|| '",'   || 	
	'"consecutivo": ' || med.consecutivo || '},'
		INTO valorMedicamentos
	from rips_ripstransaccion
	inner join rips_ripsenvios  env on (env."sedesClinica_id" = rips_ripstransaccion."sedesClinica_id" and env.id = rips_ripstransaccion."ripsEnvio_id" )
	inner join rips_ripsmedicamentos med on (med."ripsTransaccion_id" = rips_ripstransaccion.id)
	inner join sitios_sedesclinica sed on (sed.id = env."sedesClinica_id" )
	inner join rips_ripsdetalle det on (det."ripsEnvios_id" = env.id and det."numeroFactura_id" = cast(rips_ripstransaccion."numFactura" as numeric))
	inner join facturacion_facturacion fac on (fac.id = det."numeroFactura_id" )
	inner join facturacion_facturaciondetalle facdet on (facdet."facturacion_id" = fac.id and facdet."cums_id" is not null )
	inner join facturacion_suministros sum  on (sum.id = facdet.cums_id )
	left join rips_ripstipomedicamento tipmed on (tipmed.id =sum."ripsTipoMedicamento_id" )
	left join rips_ripscums ripscums on (ripscums.id = med."codTecnologiaSalud_id")	
	left join rips_ripsumm ripsumm on (ripsumm.id = sum."ripsUnidadMedida_id")	
	left join rips_RipsFormaFarmaceutica ripsfarma on (ripsfarma.id = sum."ripsFormaFarmaceutica_id")	
	left join rips_ripsunidadupr ripsupr on (ripsupr.id = sum."ripsUnidadUpr_id")	
    left join rips_ripsconceptorecaudo recaudo on (recaudo.id = med."conceptoRecaudo_id")		
	inner join  rips_RipsTiposDocumento ripstipdoc on (ripstipdoc.id = med."tipoDocumentoIdentificacion_id")
	left join cartera_pagos pagos on (pagos."tipoDoc_id" =  fac."tipoDoc_id"  and pagos.documento_id = fac.documento_id and pagos.consec = fac."consecAdmision")	
	left join cartera_formaspagos formaspagos on (formaspagos.id = pagos."formaPago_id")		
	left join rips_ripstipospagomoderador ripstipopago on (cast(ripstipopago."codigoAplicativo" as numeric) = formaspagos.id and cast(ripstipopago."codigoAplicativo" as numeric) in ('3','4') )	
	left join clinico_diagnosticos diag1 on (diag1.id = med."codDiagnosticoPrincipal_id")	
	left join clinico_diagnosticos diag2 on (diag2.id = med."codDiagnosticoRelacionado_id")	
	where rips_ripstransaccion."ripsEnvio_id" = envioRipsId and rips_ripstransaccion."ripsEnvio_id" = env.id  and cast(rips_ripstransaccion."numFactura" as numeric) = fac.id	and rips_ripstransaccion."numFactura" =cast(facturaId as text ) and med.consecutivo = i;

	valorJson = valorJson ||' ' ||  valorMedicamentos;
    end if;

			if (tipo = 'GLOSA') then 
		
	 SELECT	'{"codPrestador": ' ||  '"' ||med."codPrestador"|| '",'   ||		
	   	    '"numAutorizacion": ' || '"'  ||CASE WHEN trim(med."numAutorizacion") is null THEN 'null' ELSE med."numAutorizacion"  END|| '",'   || 	
	 	  '"idMIPRES": ' || '"'   ||CASE WHEN trim(med."idMIPRES") is null THEN 'null'  WHEN trim(med."idMIPRES") = null THEN 'null' WHEN trim(med."idMIPRES") = '' THEN 'null'  ELSE med."idMIPRES"  END|| '",'  || 	
		'"fechaDispensAdmon": ' || '"'  ||substring(cast(med."fechaDispensAdmon" as text),1,16) || '",'     || 	
	  '"codDiagnosticoPrincipal": ' || '"'  ||CASE WHEN trim(diag1.cie10) is null THEN 'null' ELSE diag1.cie10  END|| '",'  || 	
	'"codDiagnosticoRelacionado": ' || '"'  ||CASE WHEN trim(diag2.cie10) is null THEN 'null' ELSE diag2.cie10  END|| '",' 	  || 	
	'"tipoMedicamento": ' || '"'  ||CASE WHEN trim(tipmed.codigo) is null THEN 'null' ELSE tipmed.codigo  END|| '",'   || 	
	'"codTecnologiaSalud": ' || '"'  ||  CASE WHEN trim(ripscums.cum) is null THEN 'null' ELSE ripscums.cum  END           || '",'  || 	
	'"nomTecnologiaSalud": ' || '"'  ||   CASE WHEN trim(med."nomTecnologiaSalud") is null THEN 'null' ELSE med."nomTecnologiaSalud"  END               || '",'  || 	
	'"concentracionMedicamento": ' || '"'  || CASE WHEN trim(med."concentracionMedicamento") is null THEN 'null' ELSE med."concentracionMedicamento"  END  || '",'    || 		
	'"unidadMedida": ' ||  CASE WHEN ripsumm.codigo is null THEN 'null' WHEN ripsumm.codigo = 'null' THEN 'null' ELSE ripsumm.codigo  END|| ','  || 	
	'"formaFarmaceutica": ' || '"'  ||  CASE WHEN trim(ripsfarma.codigo) is null THEN 'null' ELSE ripsfarma.codigo  END  || '",'  || 	
	'"unidadMinDispensa": ' || CASE WHEN trim(ripsupr.codigo) is null THEN 'null' WHEN trim(ripsupr.codigo) = 'null' THEN 'null' ELSE ripsupr.codigo  END || ','  || 	
	'"cantidadMedicamento": ' || med."cantidadMedicamento"  || ','    || 	
	'"diasTratamiento": ' ||    med."diasTratamiento"   || ','   || 		
	'"tipoDocumentoldentificacion": ' || '"'  || CASE WHEN trim(ripstipdoc.codigo) is null THEN 'null' ELSE ripstipdoc.codigo  END   || '",'  || 	
	'"numDocumentoIdentificacion": ' || '"'  || CASE WHEN trim(med."numDocumentoIdentificacion") is null THEN 'null' ELSE med."numDocumentoIdentificacion"  END     || '",'  || 	
		'"vrUnitMedicamento": ' || med."vrUnitMedicamento" || ','  || 	
		'"vrServicio": ' || CASE WHEN med."notasCreditoGlosa" is null then 0  ELSE med."notasCreditoGlosa" end|| ','  || 	
		'"conceptoRecaudo": ' || '"'  ||CASE WHEN trim(recaudo.codigo) is null THEN 'null' ELSE recaudo.codigo  END|| '",'  || 	
		'"tipoPagoModerador": ' || '"'  ||  CASE WHEN trim( ripstipopago.codigo) is null THEN 'null' ELSE  ripstipopago.codigo  END || '",'  || 	
	'"valorPagoModerador": ' || med."valorPagoModerador" || ','  || 				
	'"numFEVPagoModerador": ' || '"'  || CASE WHEN trim(med."numFEVPagoModerador") is null THEN 'null' ELSE  med."numFEVPagoModerador"  END|| '",'   || 	
	'"consecutivo": ' || med.consecutivo || '},'
	INTO valorMedicamentos
	from rips_ripstransaccion
	inner join rips_ripsenvios  env on (env."sedesClinica_id" = rips_ripstransaccion."sedesClinica_id" and env.id = rips_ripstransaccion."ripsEnvio_id" )
	inner join rips_ripsmedicamentos med on (med."ripsTransaccion_id" = rips_ripstransaccion.id)
	inner join sitios_sedesclinica sed on (sed.id = env."sedesClinica_id" )
	inner join rips_ripsdetalle det on (det."ripsEnvios_id" = env.id and det."numeroFactura_id" = cast(rips_ripstransaccion."numFactura" as numeric))
	inner join facturacion_facturacion fac on (fac.id = det."numeroFactura_id" )
	inner join facturacion_facturaciondetalle facdet on (facdet."facturacion_id" = fac.id and facdet."cums_id" is not null and facDet."consecutivoFactura" = med."itemFactura")
	inner join facturacion_suministros sum  on (sum.id = facdet.cums_id )
	left join rips_ripstipomedicamento tipmed on (tipmed.id =sum."ripsTipoMedicamento_id" )
	left join rips_ripscums ripscums on (ripscums.id = med."codTecnologiaSalud_id")	
	left join rips_ripsumm ripsumm on (ripsumm.id = sum."ripsUnidadMedida_id")	
	left join rips_RipsFormaFarmaceutica ripsfarma on (ripsfarma.id = sum."ripsFormaFarmaceutica_id")	
	left join rips_ripsunidadupr ripsupr on (ripsupr.id = sum."ripsUnidadUpr_id")	
    left join rips_ripsconceptorecaudo recaudo on (recaudo.id = med."conceptoRecaudo_id")		
	inner join  rips_RipsTiposDocumento ripstipdoc on (ripstipdoc.id = med."tipoDocumentoIdentificacion_id")
	left join cartera_pagos pagos on (pagos."tipoDoc_id" =  fac."tipoDoc_id"  and pagos.documento_id = fac.documento_id and pagos.consec = fac."consecAdmision")	
	left join cartera_formaspagos formaspagos on (formaspagos.id = pagos."formaPago_id")		
	left join rips_ripstipospagomoderador ripstipopago on (cast(ripstipopago."codigoAplicativo" as numeric) = formaspagos.id and cast(ripstipopago."codigoAplicativo" as numeric) in ('3','4') )	
	left join clinico_diagnosticos diag1 on (diag1.id = med."codDiagnosticoPrincipal_id")	
	left join clinico_diagnosticos diag2 on (diag2.id = med."codDiagnosticoRelacionado_id")	
    where rips_ripstransaccion."ripsEnvio_id" = envioRipsId and rips_ripstransaccion."ripsEnvio_id" = env.id  and cast(rips_ripstransaccion."numNota" as numeric) = det.glosa_id	and rips_ripstransaccion."numNota" =cast(facturaId as text ) and med.consecutivo = i and rips_ripstransaccion.id is not null;

	valorJson = valorJson ||' ' ||  valorMedicamentos;

    end if;

	if (tipo = 'NOTA CREDITO') then 

		RAISE NOTICE 'ENTRE CREDITO %s' , valorJson ;
		RAISE NOTICE 'ENTRE CREDITO  envioRipsId %s' , envioRipsId ;
		RAISE NOTICE 'ENTRE CREDITO  facturaId %s' , facturaId ;
		RAISE NOTICE 'ENTRE CREDITO i =  %s' , i ;

		
	 SELECT	'{"codPrestador": ' ||  '"' ||med."codPrestador"|| '",'   ||		
	   	    '"numAutorizacion": ' || '"'  ||CASE WHEN trim(med."numAutorizacion") is null THEN 'null' ELSE med."numAutorizacion"  END|| '",'   || 	
	 	  '"idMIPRES": ' || '"'   ||CASE WHEN trim(med."idMIPRES") is null THEN 'null'  WHEN trim(med."idMIPRES") = null THEN 'null' WHEN trim(med."idMIPRES") = '' THEN 'null'  ELSE med."idMIPRES"  END|| '",'  || 	
		'"fechaDispensAdmon": ' || '"'  ||substring(cast(med."fechaDispensAdmon" as text),1,16) || '",'     || 	
	  '"codDiagnosticoPrincipal": ' || '"'  ||CASE WHEN trim(diag1.cie10) is null THEN 'null' ELSE diag1.cie10  END|| '",'  || 	
	'"codDiagnosticoRelacionado": ' || '"'  ||CASE WHEN trim(diag2.cie10) is null THEN 'null' ELSE diag2.cie10  END|| '",' 	  || 	
	'"tipoMedicamento": ' || '"'  ||CASE WHEN trim(tipmed.codigo) is null THEN 'null' ELSE tipmed.codigo  END|| '",'   || 	
	'"codTecnologiaSalud": ' || '"'  ||  CASE WHEN trim(ripscums.cum) is null THEN 'null' ELSE ripscums.cum  END           || '",'  || 	
	'"nomTecnologiaSalud": ' || '"'  ||   CASE WHEN trim(med."nomTecnologiaSalud") is null THEN 'null' ELSE med."nomTecnologiaSalud"  END               || '",'  || 	
	'"concentracionMedicamento": ' || '"'  || CASE WHEN trim(med."concentracionMedicamento") is null THEN 'null' ELSE med."concentracionMedicamento"  END  || '",'    || 		
	'"unidadMedida": ' ||  CASE WHEN ripsumm.codigo is null THEN 'null' WHEN ripsumm.codigo = 'null' THEN 'null' ELSE ripsumm.codigo  END|| ','  || 	
	'"formaFarmaceutica": ' || '"'  ||  CASE WHEN trim(ripsfarma.codigo) is null THEN 'null' ELSE ripsfarma.codigo  END  || '",'  || 	
	'"unidadMinDispensa": ' || CASE WHEN trim(ripsupr.codigo) is null THEN 'null' WHEN trim(ripsupr.codigo) = 'null' THEN 'null' ELSE ripsupr.codigo  END || ','  || 	
	'"cantidadMedicamento": ' || med."cantidadMedicamento"  || ','    || 	
	'"diasTratamiento": ' ||    med."diasTratamiento"   || ','   || 		
	'"tipoDocumentoldentificacion": ' || '"'  || CASE WHEN trim(ripstipdoc.codigo) is null THEN 'null' ELSE ripstipdoc.codigo  END   || '",'  || 	
	'"numDocumentoIdentificacion": ' || '"'  || CASE WHEN trim(med."numDocumentoIdentificacion") is null THEN 'null' ELSE med."numDocumentoIdentificacion"  END     || '",'  || 	
		'"vrUnitMedicamento": ' || med."vrUnitMedicamento" || ','  || 	
		'"vrServicio": ' || med."notasCreditoOtras"|| ','  || 	
		'"conceptoRecaudo": ' || '"'  ||CASE WHEN trim(recaudo.codigo) is null THEN 'null' ELSE recaudo.codigo  END|| '",'  || 	
		'"tipoPagoModerador": ' || '"'  ||  CASE WHEN trim( ripstipopago.codigo) is null THEN 'null' ELSE  ripstipopago.codigo  END || '",'  || 	
	'"valorPagoModerador": ' || med."valorPagoModerador" || ','  || 				
	'"numFEVPagoModerador": ' || '"'  || CASE WHEN trim(med."numFEVPagoModerador") is null THEN 'null' ELSE  med."numFEVPagoModerador"  END|| '",'   || 	
	'"consecutivo": ' || med.consecutivo || '},'
	INTO valorMedicamentos
	from rips_ripstransaccion
	inner join rips_ripsenvios  env on (env."sedesClinica_id" = rips_ripstransaccion."sedesClinica_id" and env.id = rips_ripstransaccion."ripsEnvio_id" )
	inner join rips_ripsmedicamentos med on (med."ripsTransaccion_id" = rips_ripstransaccion.id)
	inner join sitios_sedesclinica sed on (sed.id = env."sedesClinica_id" )
	inner join rips_ripsdetalle det on (det."ripsEnvios_id" = env.id and det."numeroFactura_id" = cast(rips_ripstransaccion."numFactura" as numeric) and det."numeroFactura_id" = cast(rips_ripstransaccion."numFactura" as integer) and  det."numeroFactura_id" = notaFacturaId )
	inner join facturacion_facturacion fac on (fac.id = det."numeroFactura_id" )
	inner join facturacion_facturaciondetalle facdet on (facdet."facturacion_id" = fac.id and facdet."cums_id" is not null and facDet."consecutivoFactura" = med."itemFactura" )
	inner join facturacion_suministros sum  on (sum.id = facdet.cums_id )
	left join rips_ripstipomedicamento tipmed on (tipmed.id =sum."ripsTipoMedicamento_id" )
	left join rips_ripscums ripscums on (ripscums.id = med."codTecnologiaSalud_id")	
	left join rips_ripsumm ripsumm on (ripsumm.id = sum."ripsUnidadMedida_id")	
	left join rips_RipsFormaFarmaceutica ripsfarma on (ripsfarma.id = sum."ripsFormaFarmaceutica_id")	
	left join rips_ripsunidadupr ripsupr on (ripsupr.id = sum."ripsUnidadUpr_id")	
    left join rips_ripsconceptorecaudo recaudo on (recaudo.id = med."conceptoRecaudo_id")		
	inner join  rips_RipsTiposDocumento ripstipdoc on (ripstipdoc.id = med."tipoDocumentoIdentificacion_id")
	left join cartera_pagos pagos on (pagos."tipoDoc_id" =  fac."tipoDoc_id"  and pagos.documento_id = fac.documento_id and pagos.consec = fac."consecAdmision")	
	left join cartera_formaspagos formaspagos on (formaspagos.id = pagos."formaPago_id")		
	left join rips_ripstipospagomoderador ripstipopago on (cast(ripstipopago."codigoAplicativo" as numeric) = formaspagos.id and cast(ripstipopago."codigoAplicativo" as numeric) in ('3','4') )	
	left join clinico_diagnosticos diag1 on (diag1.id = med."codDiagnosticoPrincipal_id")	
	left join clinico_diagnosticos diag2 on (diag2.id = med."codDiagnosticoRelacionado_id")	
    where rips_ripstransaccion."ripsEnvio_id" = envioRipsId and rips_ripstransaccion."ripsEnvio_id" = env.id  and cast(rips_ripstransaccion."numNota" as numeric) = det."notaCredito_id"	and rips_ripstransaccion."numNota" =cast(facturaId as text ) and  med.consecutivo = i and rips_ripstransaccion.id is not null;

	valorJson = valorJson ||' ' || valorMedicamentos;
	RAISE NOTICE 'FIN GLOSA MEDICAMENTOS %s' , valorJson ;
	RAISE NOTICE 'FIN GLOSA valorMedicamentos %s' , valorMedicamentos ;
    end if;

	end loop;
	mide := length(valorJson);
	RAISE NOTICE 'mide = %s' , mide ;
	SELECT SUBSTRING(valorJson,1, mide-1) INTO valorJson;	
	valorJson = valorJson || ']' ;

else
	valorJson = valorJson || ']' ;

 END IF;

raise notice 'Va esto en el JSON MEDICAMENTOS: %s' , valorJson;

	totalRecienNacidos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsreciennacido ripsnac where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and ripsnac."ripsTransaccion_id" = ripstra.id);

if (tipo = 'FACTURA') then 

totalRecienNacidos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsreciennacido ripsnac where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and ripsnac."ripsTransaccion_id" = ripstra.id);

end if;

if (tipo = 'GLOSA') then 

totalRecienNacidos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsreciennacido ripsnac where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and ripsnac."ripsTransaccion_id" = ripstra.id);

end if;

if (tipo = 'NOTA CREDITO') then 

totalRecienNacidos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsreciennacido ripsnac where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and ripsnac."ripsTransaccion_id" = ripstra.id );

end if;	

RAISE NOTICE 'ANTES DE totalRecienNacidos';

valorJson = valorJson ||' ,"recienNacidos": ' ;

RAISE NOTICE 'TOTAL totalRecienNacidos = %s', totalMedicamentos;

if (totalRecienNacidos> 0) then

	if (tipo = 'FACTURA') then 

	SELECT '[{"codPrestador": ' ||  '"' || nac."codPrestador"|| '",'  ||
	   	    '"tipoDocumentoIdentificacion": ' || '"'  ||tipoDoc.codigo|| '",'  || 	
			 '"numDocumentoIdentificacion": ' || '"'  ||nac."numDocumentoIdentificacion"|| '",'   || 
	 		'"fechaNacimiento": ' || '"'  ||nac."fechaNacimiento"|| '",'    
	 ||'"edadGestacional": '|| '"' || CASE WHEN trim(nac."edadGestacional") is null THEN 'null' WHEN trim(nac."edadGestacional") = '' THEN 'null' ELSE nac."edadGestacional"  END || '"'	
	 ||',"numConsultasCPrenatal": '|| '"' || CASE WHEN trim(nac."numConsultasCPrenatal") is null THEN 'null' WHEN trim(nac."numConsultasCPrenatal") = '' THEN 'null'  ELSE nac."numConsultasCPrenatal"  END || '"'		
	 ||',"codSexoBiologico": '|| '"' || CASE WHEN trim(nac."codSexoBiologico") is null THEN 'null'  WHEN trim(nac."codSexoBiologico") = '' THEN 'null' ELSE nac."codSexoBiologico"  END || '"'		
	 ||',"peso": '|| '"' || CASE WHEN trim(nac."peso") is null THEN 'null' WHEN trim(nac."peso") = '' THEN 'null'  ELSE nac."peso"  END || '"'		
	 ||',"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '"'   
	-- ||',"condicionDestino": '|| '"' || CASE WHEN trim(nac."condicionDestino") is null THEN 'null' ELSE nac."condicionDestino"  END || '"'		
	 	',"codDiagnosticoCausaMuerte": ' || '"'  ||egreso.codigo|| '",'   || 
		'"fechaEgreso": ' || '"'  ||nac."fechaEgreso"|| '",'   || 
		'"consecutivo": ' || '"'  ||nac.consecutivo|| '"'   || 
		'}]'
	INTO valorRecienNacidos
	from rips_ripstransaccion
	left join rips_ripsreciennacido nac on (nac."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join clinico_diagnosticos dxppal on (dxppal.id =nac."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxMuerte on (dxMuerte.id =  nac."codDiagnosticoCausaMuerte_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = nac."condicionDestinoUsuarioEgreso_id" )
	left join rips_ripstiposdocumento tipoDoc on (tipoDoc.id = nac."tipoDocumentoIdentificacion_id" )
	where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numFactura" =cast(facturaId as text);

	valorJson = valorJson ||' ' || valorRecienNacidos;

end if;

	if (tipo = 'GLOSA') then 

	SELECT '{"codPrestador": ' ||  '"' || nac."codPrestador"|| '",'  ||
	   	    '"tipoDocumentoIdentificacion": ' || '"'  ||tipoDoc.codigo|| '",'  || 	
			 '"numDocumentoIdentificacion": ' || '"'  ||nac."numDocumentoIdentificacion"|| '",'   || 
	 		'"fechaNacimiento": ' || '"'  ||substring(CAST( nac."fechaNacimiento"  as text),1,16)|| '",'    
	 ||'"edadGestacional": '|| CASE WHEN trim(nac."edadGestacional") is null THEN 'null' WHEN trim(nac."edadGestacional") = '' THEN 'null' ELSE nac."edadGestacional"  END 
	 ||',"numConsultasCPrenatal": '|| CASE WHEN trim(nac."numConsultasCPrenatal") is null THEN 'null' WHEN trim(nac."numConsultasCPrenatal") = '' THEN 'null'  ELSE nac."numConsultasCPrenatal"  END 		
	 ||',"codSexoBiologico": '|| '"' || CASE WHEN trim(nac."codSexoBiologico") is null THEN 'null'  WHEN trim(nac."codSexoBiologico") = '' THEN 'null' ELSE nac."codSexoBiologico"  END || '"'		
	 ||',"peso": '|| CASE WHEN trim(nac."peso") is null THEN 'null' WHEN trim(nac."peso") = '' THEN 'null'  ELSE nac."peso"  END 		
	 ||',"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '"'   
	 ||',"condicionDestino": '|| '"' || CASE WHEN trim(egreso.codigo) is null THEN 'null' ELSE egreso.codigo  END || '"'		
	 	',"codDiagnosticoCausaMuerte": ' || '"'  ||dxMuerte.cie10|| '",'   || 
		'"fechaEgreso": ' || '"'  ||substring(cast(nac."fechaEgreso" as text),1,16)|| '",'   || 
		'"consecutivo": ' ||nac.consecutivo|| 
		'},'
	INTO valorRecienNacidos
	from rips_ripstransaccion
	left join rips_ripsreciennacido nac on (nac."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join clinico_diagnosticos dxppal on (dxppal.id =nac."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxMuerte on (dxMuerte.id =  nac."codDiagnosticoCausaMuerte_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = nac."condicionDestinoUsuarioEgreso_id" )
	left join rips_ripstiposdocumento tipoDoc on (tipoDoc.id = nac."tipoDocumentoIdentificacion_id" )
	where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numNota" =cast(facturaId as text) ;

	valorJson = valorJson ||' ' || totalRecienNacidos;

end if;

	if (tipo = 'NOTA CREDITO') then 

	SELECT '{"codPrestador": ' ||  '"' || nac."codPrestador"|| '",'  ||
	   	    '"tipoDocumentoIdentificacion": ' || '"'  ||tipoDoc.codigo|| '",'  || 	
			 '"numDocumentoIdentificacion": ' || '"'  ||nac."numDocumentoIdentificacion"|| '",'   || 
	 		'"fechaNacimiento": ' || '"'  ||substring(CAST( nac."fechaNacimiento"  as text),1,16)|| '",'    
	 ||'"edadGestacional": '|| CASE WHEN trim(nac."edadGestacional") is null THEN 'null' WHEN trim(nac."edadGestacional") = '' THEN 'null' ELSE nac."edadGestacional"  END 
	 ||',"numConsultasCPrenatal": '|| CASE WHEN trim(nac."numConsultasCPrenatal") is null THEN 'null' WHEN trim(nac."numConsultasCPrenatal") = '' THEN 'null'  ELSE nac."numConsultasCPrenatal"  END 		
	 ||',"codSexoBiologico": '|| '"' || CASE WHEN trim(nac."codSexoBiologico") is null THEN 'null'  WHEN trim(nac."codSexoBiologico") = '' THEN 'null' ELSE nac."codSexoBiologico"  END || '"'		
	 ||',"peso": '|| CASE WHEN trim(nac."peso") is null THEN 'null' WHEN trim(nac."peso") = '' THEN 'null'  ELSE nac."peso"  END 		
	 ||',"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '"'   
	 ||',"condicionDestino": '|| '"' || CASE WHEN trim(egreso.codigo) is null THEN 'null' ELSE egreso.codigo  END || '"'		
	 	',"codDiagnosticoCausaMuerte": ' || '"'  ||dxMuerte.cie10|| '",'   || 
		'"fechaEgreso": ' || '"'  ||substring(cast(nac."fechaEgreso" as text),1,16)|| '",'   || 
		'"consecutivo": ' ||nac.consecutivo|| 
		'},'
	INTO valorRecienNacidos
	from rips_ripstransaccion
	left join rips_ripsreciennacido nac on (nac."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join clinico_diagnosticos dxppal on (dxppal.id =nac."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxMuerte on (dxMuerte.id =  nac."codDiagnosticoCausaMuerte_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = nac."condicionDestinoUsuarioEgreso_id" )
	left join rips_ripstiposdocumento tipoDoc on (tipoDoc.id = nac."tipoDocumentoIdentificacion_id" )
	where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numNota" =cast(facturaId as text) ;

	valorJson = valorJson ||' ' || valorRecienNacidos;

end if;

  	mide := length(valorJson);
	RAISE NOTICE 'mide = %s' , mide ;
	SELECT SUBSTRING(valorJson,1, mide-1) INTO valorJson;	
	valorJson = valorJson || ']' ;
else
	valorJson = valorJson || '[]' ;
 
end if;

raise notice 'Va esto en el JSON RECIEN NACIDOS : %s' , valorJson;

-- Desde aquip RipsOtrosServicios

if (tipo = 'FACTURA') then 

totalOtrosServicios  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsotrosservicios ripsOtros where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and ripsOtros."ripsTransaccion_id" = ripstra.id);

end if;

if (tipo = 'GLOSA') then 

totalOtrosServicios  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsotrosservicios ripsOtros where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and ripsOtros."ripsTransaccion_id" = ripstra.id);

end if;	

if (tipo = 'NOTA CREDITO') then 

totalOtrosServicios  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsotrosservicios ripsOtros where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and ripsOtros."ripsTransaccion_id" = ripstra.id and ripstra."numFactura" = cast(notaFacturaId as text)) ;

end if;	

RAISE NOTICE 'ENTRE TOTAL totalOtrosServicios = %s', totalOtrosServicios;
valorJson = valorJson ||',"otrosServicios" : [' ;
	  raise notice 'Detalle JSON PROCED totalOtrosServicios: %s' , valorJson;

if (totalOtrosServicios> 0) then

	contador :=1 ;

   for i in 1..totalOtrosServicios 
	loop

	   if (tipo = 'FACTURA') then 
	   
		SELECT '{"codPrestador": '|| '"' || otros."codPrestador" || '"' 
	   ||',"numAutorizacion": '|| '"' || CASE WHEN trim(otros."numAutorizacion") is null THEN 'null' ELSE otros."numAutorizacion"  END || '"'		
  		',"idMIPRES": ' || '"'   ||CASE WHEN trim(otros."idMIPRES") is null THEN 'null'  WHEN trim(otros."idMIPRES") = null THEN 'null' WHEN trim(otros."idMIPRES") = '' THEN 'null'  ELSE otros."idMIPRES"  END|| '"'  
	||',"fechaSuministroTecnologia": '|| '"' || substring(cast(otros."fechaSuministroTecnologia" as text), 1,16) || '"'  
	 	||',"tipoOs": '|| '"' ||ripsTipo.codigo || '"'	
		||',"codTecnologiaSalud": '|| '"' || ripsCums.cum || '"'	
		||',"nomTecnologiaSalud": '|| '"' ||substring(otros."nomTecnologiaSalud",1,60)  || '"'	
	   ||',"cantidadOS": '||  otros."cantidadOS" ||'	'
	||',"tipoDocumentoIdentificacion": '|| '"' || ripsTiposDoc.codigo  || '"'		
	||',"numDocumentoIdentificacion":  '|| '"' || CASE WHEN trim(otros."numDocumentoIdentificacion") is null THEN 'null' ELSE otros."numDocumentoIdentificacion"  END  || '"'		
	||',"vrUnitOS": '|| otros."vrUnitOS"   || ''		
	||',"vrServicio": '|| otros."vrServicio"   || ''		
	||',"tipoPagoModerador": '|| '"' || case when modera.codigo is null then 'null' else modera.codigo end   || '"'		
	||',"valorPagoModerador": '||  CASE WHEN trim(cast(otros."valorPagoModerador" as text)) is null THEN 0 ELSE otros."valorPagoModerador"  END  || ''
	||',"numFEVPagoModerador": '|| '"' || otros."numFEVPagoModerador" || '"'
	||',"consecutivo": '||  otros."consecutivo" ||'	},'
	INTO valorOtrosServicios
	from rips_ripstransaccion ripstra
	inner join rips_ripsotrosservicios otros on (otros."ripsTransaccion_id" = ripstra.id)
	left join rips_ripscums ripsCums on (ripsCums.id = otros."codTecnologiaSalud_id" )
	inner join rips_ripstipootrosservicios ripsTipo on (ripsTipo.id = otros."tipoOS_id" ) 
	left join rips_ripstipospagomoderador modera on (modera.id=otros."tipoPagoModerador_id")
	inner join rips_ripstiposdocumento ripsTiposDoc on (ripsTiposDoc.id = otros."tipoDocumentoIdentificacion_id" )
	   where  ripstra."ripsEnvio_id" = envioRipsId AND  ripstra."numFactura" = cast(facturaId as text)  and otros.consecutivo = i; 

    raise notice 'valorOtrosServicios: %s' , valorOtrosServicios;
	valorJson = valorJson ||' '||valorOtrosServicios;
	raise notice 'contador: %s' , contador;
    raise notice 'Detalle JSON OTROS_SERVICIOS ACUMULADO: %s' , valorJson;
	contador := contador +1;

	end if;

	   if (tipo = 'GLOSA') then 

		SELECT '{"codPrestador": '|| '"' || otros."codPrestador" || '"' 
	   ||',"numAutorizacion": '|| '"' || CASE WHEN trim(otros."numAutorizacion") is null THEN 'null' ELSE otros."numAutorizacion"  END || '"'		
  		',"idMIPRES": ' || '"'   ||CASE WHEN trim(otros."idMIPRES") is null THEN 'null'  WHEN trim(otros."idMIPRES") = null THEN 'null' WHEN trim(otros."idMIPRES") = '' THEN 'null'  ELSE otros."idMIPRES"  END|| '"'  
	||',"fechaSuministroTecnologia": '|| '"' || substring(cast(otros."fechaSuministroTecnologia" as text), 1,16) || '"'  
	 	||',"tipoOs": '|| '"' ||ripsTipo.codigo || '"'	
		||',"codTecnologiaSalud": '|| '"' || ripsCums.cum || '"'	
		||',"nomTecnologiaSalud": '|| '"' ||otros."nomTecnologiaSalud"  || '"'	
	   ||',"cantidadOS": '||  otros."cantidadOS" ||''
	||',"tipoDocumentoIdentificacion": '|| '"' || ripsTiposDoc.codigo  || '"'		
	||',"numDocumentoIdentificacion":  '|| '"' || CASE WHEN trim(otros."numDocumentoIdentificacion") is null THEN 'null' ELSE otros."numDocumentoIdentificacion"  END  || '"'		
	||',"vrUnitOS": '|| otros."vrUnitOS"   || ''		
	||',"vrServicio": '|| CASE WHEN otros."notasCreditoGlosa" is null then 0  ELSE otros."notasCreditoGlosa" end  || ''		
	||',"tipoPagoModerador": '|| '"' || case when modera.codigo is null then 'null' else modera.codigo end   || '"'		
	||',"valorPagoModerador": '||  CASE WHEN trim(cast(otros."valorPagoModerador" as text)) is null THEN 0 ELSE otros."valorPagoModerador"  END  || ''
	||',"numFEVPagoModerador": '|| '"' || otros."numFEVPagoModerador" || '"'
	||',"consecutivo": '||  otros."consecutivo" ||'	},'
	INTO valorOtrosServicios
	from rips_ripstransaccion ripstra
	inner join rips_ripsotrosservicios otros on (otros."ripsTransaccion_id" = ripstra.id)
	left join rips_ripscums ripsCums on (ripsCums.id = otros."codTecnologiaSalud_id" )
	inner join rips_ripstipootrosservicios ripsTipo on (ripsTipo.id = otros."tipoOS_id" ) 
	left join rips_ripstipospagomoderador modera on (modera.id=otros."tipoPagoModerador_id")
	inner join rips_ripstiposdocumento ripsTiposDoc on (ripsTiposDoc.id = otros."tipoDocumentoIdentificacion_id" )		   
    where  ripstra."ripsEnvio_id" = envioRipsId AND ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" = cast(facturaId as text)  and otros.consecutivo = i;

    raise notice 'valorOtrosServicios: %s' , valorOtrosServicios;
	valorJson = valorJson ||' '||valorOtrosServicios;
	raise notice 'contador: %s' , contador;
    raise notice 'Detalle JSON valorOtrosServicios ACUMULADO: %s' , valorJson;
	contador := contador +1;

	end if;

	   if (tipo = 'NOTA CREDITO') then 

		SELECT '{"codPrestador": '|| '"' || otros."codPrestador" || '"' 
	   ||',"numAutorizacion": '|| '"' || CASE WHEN trim(otros."numAutorizacion") is null THEN 'null' ELSE otros."numAutorizacion"  END || '"'		
  		',"idMIPRES": ' || '"'   ||CASE WHEN trim(otros."idMIPRES") is null THEN 'null'  WHEN trim(otros."idMIPRES") = null THEN 'null' WHEN trim(otros."idMIPRES") = '' THEN 'null'  ELSE otros."idMIPRES"  END|| '"'  
	||',"fechaSuministroTecnologia": '|| '"' || substring(cast(otros."fechaSuministroTecnologia" as text), 1,16) || '"'  
	 	||',"tipoOs": '|| '"' ||ripsTipo.codigo || '"'	
		||',"codTecnologiaSalud": '|| '"' || ripsCums.cum || '"'	
		||',"nomTecnologiaSalud": '|| '"' ||otros."nomTecnologiaSalud"  || '"'	
	   ||',"cantidadOS": '||  otros."cantidadOS" ||''
	||',"tipoDocumentoIdentificacion": '|| '"' || ripsTiposDoc.codigo  || '"'		
	||',"numDocumentoIdentificacion":  '|| '"' || CASE WHEN trim(otros."numDocumentoIdentificacion") is null THEN 'null' ELSE otros."numDocumentoIdentificacion"  END  || '"'		
	||',"vrUnitOS": '|| otros."vrUnitOS"   || ''		
	||',"vrServicio": '|| otros."notasCreditoOtras"   || ''		
	||',"tipoPagoModerador": '|| '"' || case when modera.codigo is null then 'null' else modera.codigo end   || '"'		
	||',"valorPagoModerador": '||  CASE WHEN trim(cast(otros."valorPagoModerador" as text)) is null THEN 0 ELSE otros."valorPagoModerador"  END  || ''
	||',"numFEVPagoModerador": '|| '"' || otros."numFEVPagoModerador" || '"'
	||',"consecutivo": '||  otros."consecutivo" ||'	},'
	INTO valorOtrosServicios
	from rips_ripstransaccion ripstra
	inner join rips_ripsotrosservicios otros on (otros."ripsTransaccion_id" = ripstra.id and otros."numFEVPagoModerador" = cast(ripstra."numFactura" as text) and cast(ripstra."numFactura" as integer) = notaFacturaId)
	left join rips_ripscums ripsCums on (ripsCums.id = otros."codTecnologiaSalud_id" )
	inner join rips_ripstipootrosservicios ripsTipo on (ripsTipo.id = otros."tipoOS_id" ) 
	left join rips_ripstipospagomoderador modera on (modera.id=otros."tipoPagoModerador_id")
	inner join rips_ripstiposdocumento ripsTiposDoc on (ripsTiposDoc.id = otros."tipoDocumentoIdentificacion_id" )		   
    where  ripstra."ripsEnvio_id" = envioRipsId AND ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" = cast(facturaId as text) AND  otros.consecutivo = i;

    raise notice 'valorOtrosServicios: %s' , valorOtrosServicios;
	valorJson = valorJson ||' '||valorOtrosServicios;
	raise notice 'contador: %s' , contador;
    raise notice 'Detalle JSON valorOtrosServicios ACUMULADO: %s' , valorJson;
	contador := contador +1;

	end if;

	end loop;

	mide := length(valorJson);
	RAISE NOTICE 'mide = %s' , mide ;
	SELECT SUBSTRING(valorJson,1, mide-1) INTO valorJson;	
	valorJson = valorJson || ']' ;

else
	 valorJson = valorJson || ']' ; 
end if;

RAISE NOTICE 'VALOR OTROS SERVICIOS = %s' ,valorOtrosServicios ;

raise notice 'Va TOTAL JSON OTROS SERVICIOS: %s' , valorJson;

-- Fin Rips Otros servicios

valorJson = valorJson ||'}}],';
 
 END LOOP;

mide := length(valorJson);
	RAISE NOTICE 'mide = %s' , mide ;
	SELECT SUBSTRING(valorJson,1, mide-1) INTO valorJson;	
valorJson = valorJson ||'}]';
	
	SELECT REPLACE (valorJson, '""', '')
	into valorJson;

	SELECT REPLACE (valorJson, '"null"', 'null')
	into valorJson;

   RETURN valorJson ;
END 
$BODY$;

ALTER FUNCTION public.generaenvioripsjson1(numeric, character varying)
    OWNER TO postgres;




-- segunda function

-- FUNCTION: public.generafacturajsonbak1(numeric, numeric, character varying, numeric)

-- DROP FUNCTION IF EXISTS public.generafacturajsonbak1(numeric, numeric, character varying, numeric);

CREATE OR REPLACE FUNCTION public.generafacturajsonbak1(
	envioripsid numeric,
	facturaid numeric,
	tipo character varying,
	transaccionid numeric)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
 
DECLARE valorJson character(50000);
		mide integer := 0;

	    valorTransaccionYusuarios character(50000);
	    valorProcedimientos character(50000) :='';
		valorHospitalizacion character(50000):='';
		valorUrgencias character(50000):='';
		valorRecienNacidos character(50000):='';
	    valorOtrosServicios character(50000):='';
	    valorMedicamentos character(50000):='';
		valorConsultas character(50000):='';
		totalUrgencias integer := 0;
		totalHospitalizacion integer := 0;
		totalProcedimientos integer := 0;
		totalMedicamentos integer := 0; 
		totalRecienNacidos integer := 0;
		totalOtrosServicios integer := 0;
		contador integer := 1;
		tabla RECORD;
		consecutivos integer[] ;

BEGIN
	
	valorJson= '[{';

if (tipo = 'FACTURA') then 
	
SELECT '"numDocumentoIdObligado": "' || "numDocumentoIdObligado" ||'",' || '"numFactura": ""' || "numFactura" || '"", "TipoNota": null,"numNota": null,"usuarios": [{'
		||'"tipoDocumentoIdentificacion": '|| '"' ||tiposDoc.codigo || '",'||'"numDocumentoIdentificacion": '|| '"' || u."numDocumentoIdentificacion" || '",'
		||'"tipoUsuario": '|| '"' || CASE WHEN trim(u."tipoUsuario") is null THEN 'null' ELSE u."tipoUsuario"  END    || '",'||'"fechaNacimiento": '|| '"' || u."fechaNacimiento" || '",'
		||'"codSexo": '|| '"' || u."codSexo" || '",'||'"codPaisResidencia": '|| '"' || pais.codigo || '",'||'"codMunicipioResidencia": '|| '"' ||
	CASE WHEN trim(ripsMuni.codigo) is null THEN 'null' ELSE ripsMuni.codigo  END
	|| '",'	
		||'"codZonaTerritorialResidencia": '|| '"' ||CASE WHEN trim(zona.codigo) is null THEN 'null' ELSE zona.codigo  END || '",'||'"incapacidad": '|| '"' || u."incapacidad" || '",'
		||'"consecutivo": '|| u."consecutivo" || ',' ||'"codPaisOrigen": '|| '"' ||  pais.codigo
	|| '"' DATO1
INTO valorTransaccionYusuarios
	from rips_ripstransaccion ripstra
	inner join  rips_ripsusuarios u on (u."ripsTransaccion_id" = ripstra.id)
	left join  rips_ripspaises pais on (pais.id =  u."codPaisResidencia_id")
	left join  sitios_municipios muni on ( muni.id = u."codMunicipioResidencia_id")	
	left join  rips_ripsmunicipios ripsMuni on ( ripsMuni.id = muni."ripsMunicipios_id")
--	inner join usuarios_tiposDocumento tipoDocUsu on (tipoDocUsu.id = cast(u."tipoDocumentoIdentificacion" as integer))
	 inner join rips_ripstiposdocumento tiposDoc on (tiposDoc.id = cast(u."tipoDocumentoIdentificacion" as integer))
	left join rips_ripszonaterritorial zona on (zona.id = cast(u."codZonaTerritorialResidencia_id" as integer))
where  ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" = cast(facturaId as text)  and u."ripsTransaccion_id" = ripstra.id  ;

valorJson = valorJson ||' ' || valorTransaccionYusuarios;

end if;

if (tipo = 'GLOSA') then 
	
SELECT '"numDocumentoIdObligado": "' || "numDocumentoIdObligado" ||'",' || '"numFactura": "' || 'null' || '", "TipoNota":'|| '"' ||tipnot.codigo||'","numNota": ' || ripstra."numNota" || ',"usuarios": [{'
		||'"tipoDocumentoIdentificacion": '|| '"' ||tiposDoc.codigo || '",'||'"numDocumentoIdentificacion": '|| '"' || u."numDocumentoIdentificacion" || '",'
		||'"tipoUsuario": '|| '"' || CASE WHEN trim(u."tipoUsuario") is null THEN 'null' ELSE u."tipoUsuario"  END    || '",'||'"fechaNacimiento": '|| '"' || u."fechaNacimiento" || '",'
		||'"codSexo": '|| '"' || u."codSexo" || '",'||'"codPaisResidencia": '|| '"' || pais.codigo || '",'||'"codMunicipioResidencia": '|| '"' ||
	CASE WHEN trim(ripsMuni.codigo) is null THEN 'null' ELSE ripsMuni.codigo  END
	|| '",'	
		||'"codZonaTerritorialResidencia": '|| '"' ||CASE WHEN trim(zona.codigo) is null THEN 'null' ELSE zona.codigo  END || '",'||'"incapacidad": '|| '"' || u."incapacidad" || '",'
		||'"consecutivo": '|| u."consecutivo" || ',' ||'"codPaisOrigen": '|| '"' ||  pais.codigo
	|| '"' DATO1
INTO valorTransaccionYusuarios
	from rips_ripstransaccion ripstra
	inner join  rips_ripsusuarios u on (u."ripsTransaccion_id" = ripstra.id)
	left join  rips_ripspaises pais on (pais.id =  u."codPaisResidencia_id")
	left join  sitios_municipios muni on ( muni.id = u."codMunicipioResidencia_id")	
	left join  rips_ripsmunicipios ripsMuni on ( ripsMuni.id = muni."ripsMunicipios_id")
--	inner join usuarios_tiposDocumento tipoDocUsu on (tipoDocUsu.id = cast(u."tipoDocumentoIdentificacion" as integer))
	 inner join rips_ripstiposdocumento tiposDoc on (tiposDoc.id = cast(u."tipoDocumentoIdentificacion" as integer))
	left join rips_ripszonaterritorial zona on (zona.id = cast(u."codZonaTerritorialResidencia_id" as integer))
	inner join rips_ripstiposnotas tipnot on (tipnot.id = ripstra."tipoNota_id")	
where  ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" = cast(facturaId as text)  and u."ripsTransaccion_id" = ripstra.id  and ripstra.id=transaccionid;

valorJson = valorJson ||' ' || valorTransaccionYusuarios;

end if;

if (tipo = 'NOTA CREDITO') then 
	
SELECT '"numDocumentoIdObligado": "' || "numDocumentoIdObligado" ||'",' || '"numFactura": "' || 'null' || '", "TipoNota":'|| '"' ||tipnot.codigo||'","numNota": ' || ripstra."numNota" || ',"usuarios": [{'
		||'"tipoDocumentoIdentificacion": '|| '"' ||tiposDoc.codigo || '",'||'"numDocumentoIdentificacion": '|| '"' || u."numDocumentoIdentificacion" || '",'
		||'"tipoUsuario": '|| '"' || CASE WHEN trim(u."tipoUsuario") is null THEN 'null' ELSE u."tipoUsuario"  END    || '",'||'"fechaNacimiento": '|| '"' || u."fechaNacimiento" || '",'
		||'"codSexo": '|| '"' || u."codSexo" || '",'||'"codPaisResidencia": '|| '"' || pais.codigo || '",'||'"codMunicipioResidencia": '|| '"' ||
	CASE WHEN trim(ripsMuni.codigo) is null THEN 'null' ELSE ripsMuni.codigo  END
	|| '",'	
		||'"codZonaTerritorialResidencia": '|| '"' ||CASE WHEN trim(zona.codigo) is null THEN 'null' ELSE zona.codigo  END || '",'||'"incapacidad": '|| '"' || u."incapacidad" || '",'
		||'"consecutivo": '|| u."consecutivo" || ',' ||'"codPaisOrigen": '|| '"' ||  pais.codigo
	|| '"' DATO1
INTO valorTransaccionYusuarios
	from rips_ripstransaccion ripstra
	inner join  rips_ripsusuarios u on (u."ripsTransaccion_id" = ripstra.id)
	left join  rips_ripspaises pais on (pais.id =  u."codPaisResidencia_id")
	left join  sitios_municipios muni on ( muni.id = u."codMunicipioResidencia_id")	
	left join  rips_ripsmunicipios ripsMuni on ( ripsMuni.id = muni."ripsMunicipios_id")
--	inner join usuarios_tiposDocumento tipoDocUsu on (tipoDocUsu.id = cast(u."tipoDocumentoIdentificacion" as integer))
	 inner join rips_ripstiposdocumento tiposDoc on (tiposDoc.id = cast(u."tipoDocumentoIdentificacion" as integer))
	left join rips_ripszonaterritorial zona on (zona.id = cast(u."codZonaTerritorialResidencia_id" as integer))
	inner join rips_ripstiposnotas tipnot on (tipnot.id = ripstra."tipoNota_id")	
where  ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" = cast(facturaId as text)  and u."ripsTransaccion_id" = ripstra.id  and ripstra.id=transaccionid;

valorJson = valorJson ||' ' || valorTransaccionYusuarios;

end if;

raise notice 'Va esto en el JSON ENCABEZADO : %s' , valorJson;
	
-- Procedimientos

if (tipo = 'FACTURA') then 
	
	totalProcedimientos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsprocedimientos proc where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and proc."ripsTransaccion_id" = ripstra.id and cast("numNota" as float)  = 0  );

	contador = 1;
	   	FOR tabla IN select * from rips_ripstransaccion ripstra, rips_ripsprocedimientos proc where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and proc."ripsTransaccion_id" = ripstra.id 
		LOOP 
          consecutivos[contador] := tabla.consecutivo;
          contador := contador + 1;
		--raise notice 'consecutivos : %' , consecutivos[contador];
		--raise notice 'contador : %' , contador;
		END LOOP;
end if;

if (tipo = 'GLOSA') then 
	totalProcedimientos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsprocedimientos proc where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and proc."ripsTransaccion_id" = ripstra.id  and ripstra.id=transaccionid);	
	
	
	contador = 1;
	   	FOR tabla IN select * from rips_ripstransaccion ripstra, rips_ripsprocedimientos proc where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and proc."ripsTransaccion_id" = ripstra.id
		LOOP 
          consecutivos[contador] := tabla.consecutivo;
          contador := contador + 1;
		--raise notice 'consecutivos : %' , consecutivos[contador];
		END LOOP;

end if;

if (tipo = 'NOTA CREDITO') then 
	totalProcedimientos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsprocedimientos proc where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and proc."ripsTransaccion_id" = ripstra.id AND (proc."notasCreditoOtras" > 0 or proc."notasCreditoOtras" is not null) and ripstra.id=transaccionid);	
	
	
	contador = 1;
	   	FOR tabla IN select * from rips_ripstransaccion ripstra, rips_ripsprocedimientos proc where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and proc."ripsTransaccion_id" = ripstra.id
		LOOP 
          consecutivos[contador] := tabla.consecutivo;
          contador := contador + 1;
		--raise notice 'consecutivos : %' , consecutivos[contador];
		END LOOP;

end if;

RAISE NOTICE 'ENTRE TOTAL totalProcedimientos = %s', totalProcedimientos;
valorJson = valorJson ||',"servicios": { "procedimientos" : [' ;
	  raise notice 'Detalle JSON PROCED SERVICIOS: %s' , valorJson;

if (totalProcedimientos> 0) then

	contador :=1 ;

   for i in 1..totalProcedimientos 
	loop

	   if (tipo = 'FACTURA') then 
	
	 SELECT '{"codPrestador": '|| '"' || proc."codPrestador" || '",'  ||'"fechaInicioAtencion": '|| '"' || substring(cast(proc."fechaInicioAtencion" as text), 1,16) || '",'  
	 	  '"idMIPRES": ' || '"'   ||CASE WHEN trim(proc."idMIPRES") is null THEN 'null'  WHEN trim(proc."idMIPRES") = null THEN 'null' WHEN trim(proc."idMIPRES") = '' THEN 'null'  ELSE proc."idMIPRES"  END|| '"'  
	   ||',"numAutorizacion": '|| '"' || CASE WHEN trim(proc."numAutorizacion") is null THEN 'null' ELSE proc."numAutorizacion"  END || '"'	
	||',"codProcedimiento": '|| '"' || exa."codigoCups" || '",'	
		||'"viaIngresoServicioSalud": '|| '"' ||proc."viaIngresoServicioSalud_id"  || '",'	
	--	||'"modalidadGrupoServicioTecSal": '|| '"' || proc."modalidadGrupoServicioTecSal_id"  || '",'	
		||'"grupoServicios": '|| '"' ||ripsGrupoServ.codigo || '",'	
	   	||'"codServicio": '||ripsServicios.codigo || ','	
		||'"finalidadTecnologiaSalud": '|| '"' ||CASE WHEN trim(cast(ripsFinalidadConsulta.codigo as text)) is null THEN 'null' ELSE ripsFinalidadConsulta.codigo  END  || '",'			   
	||'"tipoDocumentoIdentificacion": '|| '"' || ripsTiposDoc.codigo  || '"'	
	||',"numDocumentoIdentificacion":  '|| '"' || CASE WHEN trim(proc."numDocumentoIdentificacion") is null THEN 'null' ELSE proc."numDocumentoIdentificacion"  END  || '",'	
	||'"codDiagnosticoPrincipal": '|| '"' || CASE WHEN trim(cast(diag1.cie10 as text)) is null THEN 'null' ELSE diag1.cie10  END || '",'	
	||'"codDiagnosticoRelacionado": '|| '"' ||  CASE WHEN trim(cast(diag2.cie10 as text)) is null THEN 'null' ELSE diag2.cie10  END    || '",'	
	||'"codComplicacion": '|| '"' ||CASE WHEN trim(cast(diag3.cie10 as text)) is null THEN 'null' ELSE diag3.cie10 END   || '",'
	||'"vrServicio": '|| proc."vrServicio"   || ','		
	 ||'"conceptoRecaudo": '|| '"' || ripsRecaudo.codigo   || '",'		
	||'"valorPagoModerador": '||  CASE WHEN trim(cast(proc."valorPagoModerador" as text)) is null THEN 0 ELSE proc."valorPagoModerador"  END  || ','	
	||'"numFEVPagoModerador": '|| '"' || proc."numFEVPagoModerador" || '",'
	||'"consecutivo": '||  proc."consecutivo" ||'	},'
	INTO valorProcedimientos
	from rips_ripstransaccion ripstra
	inner join rips_ripsprocedimientos proc on (proc."ripsTransaccion_id" = ripstra.id)
	inner join clinico_examenes exa on (exa.id = proc."codProcedimiento_id" )   
	left join clinico_diagnosticos diag1 on (diag1.id=proc."codDiagnosticoPrincipal_id")   
	left join clinico_diagnosticos diag2 on (diag2.id=proc."codDiagnosticoRelacionado_id")   
	left join clinico_diagnosticos diag3 on (diag3.id=proc."codComplicacion_id")  
	left  join rips_ripsviasingresosalud ripsIngresoSalud ON (ripsIngresoSalud.id = proc."viaIngresoServicioSalud_id")   
	left  join rips_ripsgruposervicios ripsGrupoServ ON (ripsGrupoServ.id = proc."grupoServicios_id")
--	left  join rips_ripsmodalidadgruposerviciosTecSalud  ripsModalidadGrupoServ ON (ripsModalidadGrupoServ.id = proc."modalidadGrupoServicioTecSal_id")
	left  join rips_ripsservicios ripsServicios ON (ripsServicios.id = proc."codServicio_id")
	left  join rips_ripsfinalidadconsulta ripsFinalidadConsulta ON (ripsFinalidadConsulta.id = proc."finalidadTecnologiaSalud_id")	   
	inner join rips_ripstiposdocumento ripsTiposDoc on (ripsTiposDoc.id = proc."tipoDocumentoIdentificacion_id" )
	left join rips_RipsConceptoRecaudo ripsRecaudo on (ripsRecaudo.id = proc."conceptoRecaudo_id")
	   where  ripstra."ripsEnvio_id" = envioRipsId AND  ripstra."numFactura" = cast(facturaId as text) AND  proc.consecutivo = i; 

    raise notice 'valorProcedimientos TUQUITUQUI:  %s' , valorProcedimientos;
	valorJson = valorJson ||' '||valorProcedimientos;
	raise notice 'contador: %s' , contador;
    raise notice 'Detalle JSON PROCED ACUMULADO PARCIAL: %s' , valorJson;
	contador := contador +1;

	end if;

	   if (tipo = 'GLOSA') then 
	SELECT '{"codPrestador": '|| '"' || proc."codPrestador" || '",'  ||'"fechaInicioAtencion": '|| '"' || substring(cast(proc."fechaInicioAtencion" as text), 1,16) || '",'  
	 	  '"idMIPRES": ' || '"'   ||CASE WHEN trim(proc."idMIPRES") is null THEN 'null'  WHEN trim(proc."idMIPRES") = null THEN 'null' WHEN trim(proc."idMIPRES") = '' THEN 'null'  ELSE proc."idMIPRES"  END|| '"'  
	   ||',"numAutorizacion": '|| '"' || CASE WHEN trim(proc."numAutorizacion") is null THEN 'null' ELSE proc."numAutorizacion"  END || '"'	
	||',"codProcedimiento": '|| '"' || exa."codigoCups" || '",'	
		||'"viaIngresoServicioSalud": '|| '"' ||proc."viaIngresoServicioSalud_id"  || '",'	
	--	||'"modalidadGrupoServicioTecSal": '|| '"' || proc."modalidadGrupoServicioTecSal_id"  || '",'	
		||'"grupoServicios": '|| '"' ||ripsGrupoServ.codigo || '",'	
	   	||'"codServicio": '||ripsServicios.codigo || ','	
		||'"finalidadTecnologiaSalud": '|| '"' ||CASE WHEN trim(cast(ripsFinalidadConsulta.codigo as text)) is null THEN 'null' ELSE ripsFinalidadConsulta.codigo  END  || '",'			   
	||'"tipoDocumentoIdentificacion": '|| '"' || ripsTiposDoc.codigo  || '"'	
	||',"numDocumentoIdentificacion":  '|| '"' || CASE WHEN trim(proc."numDocumentoIdentificacion") is null THEN 'null' ELSE proc."numDocumentoIdentificacion"  END  || '",'	
	||'"codDiagnosticoPrincipal": '|| '"' || CASE WHEN trim(cast(diag1.cie10 as text)) is null THEN 'null' ELSE diag1.cie10  END || '",'	
	||'"codDiagnosticoRelacionado": '|| '"' ||  CASE WHEN trim(cast(diag2.cie10 as text)) is null THEN 'null' ELSE diag2.cie10  END    || '",'	
	||'"codComplicacion": '|| '"' ||CASE WHEN trim(cast(diag3.cie10 as text)) is null THEN 'null' ELSE diag3.cie10 END   || '",'
	||'"vrServicio": '|| CASE WHEN proc."notasCreditoGlosa" is null then 0  ELSE proc."notasCreditoGlosa" end   || ','		
	 ||'"conceptoRecaudo": '|| '"' || ripsRecaudo.codigo   || '",'		
	||'"valorPagoModerador": '||  CASE WHEN trim(cast(proc."valorPagoModerador" as text)) is null THEN 0 ELSE proc."valorPagoModerador"  END  || ','	
	||'"numFEVPagoModerador": '|| '"' || proc."numFEVPagoModerador" || '",'
	||'"consecutivo": '||  proc."consecutivo" ||'	},'
	INTO valorProcedimientos
	from rips_ripstransaccion ripstra
	inner join rips_ripsprocedimientos proc on (proc."ripsTransaccion_id" = ripstra.id)
	inner join clinico_examenes exa on (exa.id = proc."codProcedimiento_id" )   
	left join clinico_diagnosticos diag1 on (diag1.id=proc."codDiagnosticoPrincipal_id")   
	left join clinico_diagnosticos diag2 on (diag2.id=proc."codDiagnosticoRelacionado_id")   
	left join clinico_diagnosticos diag3 on (diag3.id=proc."codComplicacion_id")  
	left  join rips_ripsviasingresosalud ripsIngresoSalud ON (ripsIngresoSalud.id = proc."viaIngresoServicioSalud_id")   
	left  join rips_ripsgruposervicios ripsGrupoServ ON (ripsGrupoServ.id = proc."grupoServicios_id")
--	left  join rips_ripsmodalidadgruposerviciosTecSalud  ripsModalidadGrupoServ ON (ripsModalidadGrupoServ.id = proc."modalidadGrupoServicioTecSal_id")
	left  join rips_ripsservicios ripsServicios ON (ripsServicios.id = proc."codServicio_id")
	left  join rips_ripsfinalidadconsulta ripsFinalidadConsulta ON (ripsFinalidadConsulta.id = proc."finalidadTecnologiaSalud_id")	   
	inner join rips_ripstiposdocumento ripsTiposDoc on (ripsTiposDoc.id = proc."tipoDocumentoIdentificacion_id" )
	left join rips_RipsConceptoRecaudo ripsRecaudo on (ripsRecaudo.id = proc."conceptoRecaudo_id")	   
	where  ripstra."ripsEnvio_id" = envioRipsId AND ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" = cast(facturaId as text) AND ripstra.id=transaccionid  and proc.consecutivo = i;

    raise notice 'valorProcedimientos: %s' , valorProcedimientos;
	valorJson = valorJson ||' '||valorProcedimientos;
	raise notice 'contador: %s' , contador;
    raise notice 'Detalle JSON PROCED ACUMULADO: %s' , valorJson;
	contador := contador +1;

	end if;

	if (tipo = 'NOTA CREDITO') then 
	SELECT '{"codPrestador": '|| '"' || proc."codPrestador" || '",'  ||'"fechaInicioAtencion": '|| '"' || substring(cast(proc."fechaInicioAtencion" as text), 1,16) || '",'  
	 	  '"idMIPRES": ' || '"'   ||CASE WHEN trim(proc."idMIPRES") is null THEN 'null'  WHEN trim(proc."idMIPRES") = null THEN 'null' WHEN trim(proc."idMIPRES") = '' THEN 'null'  ELSE proc."idMIPRES"  END|| '"'  
	   ||',"numAutorizacion": '|| '"' || CASE WHEN trim(proc."numAutorizacion") is null THEN 'null' ELSE proc."numAutorizacion"  END || '"'	
	||',"codProcedimiento": '|| '"' || exa."codigoCups" || '",'	
		||'"viaIngresoServicioSalud": '|| '"' ||proc."viaIngresoServicioSalud_id"  || '",'	
	--	||'"modalidadGrupoServicioTecSal": '|| '"' || proc."modalidadGrupoServicioTecSal_id"  || '",'	
		||'"grupoServicios": '|| '"' ||ripsGrupoServ.codigo || '",'	
	   	||'"codServicio": '||ripsServicios.codigo || ','	
		||'"finalidadTecnologiaSalud": '|| '"' ||CASE WHEN trim(cast(ripsFinalidadConsulta.codigo as text)) is null THEN 'null' ELSE ripsFinalidadConsulta.codigo  END  || '",'			   
	||'"tipoDocumentoIdentificacion": '|| '"' || ripsTiposDoc.codigo  || '"'	
	||',"numDocumentoIdentificacion":  '|| '"' || CASE WHEN trim(proc."numDocumentoIdentificacion") is null THEN 'null' ELSE proc."numDocumentoIdentificacion"  END  || '",'	
	||'"codDiagnosticoPrincipal": '|| '"' || CASE WHEN trim(cast(diag1.cie10 as text)) is null THEN 'null' ELSE diag1.cie10  END || '",'	
	||'"codDiagnosticoRelacionado": '|| '"' ||  CASE WHEN trim(cast(diag2.cie10 as text)) is null THEN 'null' ELSE diag2.cie10  END    || '",'	
	||'"codComplicacion": '|| '"' ||CASE WHEN trim(cast(diag3.cie10 as text)) is null THEN 'null' ELSE diag3.cie10 END   || '",'
	||'"vrServicio": '|| CASE WHEN proc."notasCreditoOtras" is null then 0  ELSE proc."notasCreditoOtras" end   || ','		
	 ||'"conceptoRecaudo": '|| '"' || ripsRecaudo.codigo   || '",'		
	||'"valorPagoModerador": '||  CASE WHEN trim(cast(proc."valorPagoModerador" as text)) is null THEN 0 ELSE proc."valorPagoModerador"  END  || ','	
	||'"numFEVPagoModerador": '|| '"' || proc."numFEVPagoModerador" || '",'
	||'"consecutivo": '||  proc."consecutivo" ||'	},'
	INTO valorProcedimientos
	from rips_ripstransaccion ripstra
	inner join rips_ripsprocedimientos proc on (proc."ripsTransaccion_id" = ripstra.id)
	inner join clinico_examenes exa on (exa.id = proc."codProcedimiento_id" )   
	left join clinico_diagnosticos diag1 on (diag1.id=proc."codDiagnosticoPrincipal_id")   
	left join clinico_diagnosticos diag2 on (diag2.id=proc."codDiagnosticoRelacionado_id")   
	left join clinico_diagnosticos diag3 on (diag3.id=proc."codComplicacion_id")  
	left  join rips_ripsviasingresosalud ripsIngresoSalud ON (ripsIngresoSalud.id = proc."viaIngresoServicioSalud_id")   
	left  join rips_ripsgruposervicios ripsGrupoServ ON (ripsGrupoServ.id = proc."grupoServicios_id")
--	left  join rips_ripsmodalidadgruposerviciosTecSalud  ripsModalidadGrupoServ ON (ripsModalidadGrupoServ.id = proc."modalidadGrupoServicioTecSal_id")
	left  join rips_ripsservicios ripsServicios ON (ripsServicios.id = proc."codServicio_id")
	left  join rips_ripsfinalidadconsulta ripsFinalidadConsulta ON (ripsFinalidadConsulta.id = proc."finalidadTecnologiaSalud_id")	   
	inner join rips_ripstiposdocumento ripsTiposDoc on (ripsTiposDoc.id = proc."tipoDocumentoIdentificacion_id" )
	left join rips_RipsConceptoRecaudo ripsRecaudo on (ripsRecaudo.id = proc."conceptoRecaudo_id")	   
	where  ripstra."ripsEnvio_id" = envioRipsId AND ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" = cast(facturaId as text) AND ripstra.id=transaccionid  and proc.consecutivo = i;

    raise notice 'valorProcedimientos: %s' , valorProcedimientos;
	valorJson = valorJson ||' '||valorProcedimientos;
	raise notice 'contador: %s' , contador;
    raise notice 'Detalle JSON PROCED ACUMULADO: %s' , valorJson;
	contador := contador +1;

	end if;

	end loop;

	mide := length(valorJson);
	RAISE NOTICE 'mide = %s' , mide ;
	SELECT SUBSTRING(valorJson,1, mide-1) INTO valorJson;	
	valorJson = valorJson || ']' ;

else
	 valorJson = valorJson || ']' ; 
end if;

RAISE NOTICE 'VALOR PROCEDIMIENTOS TIQUI TUQUI FINAL = %s' ,valorProcedimientos ;

raise notice 'Va TOTAL JSON PROCED FINAL QUE PASA : %s' , valorJson;

-- Hospitalizacion

valorJson = valorJson || ', "hospitalizacion":' ;

if (tipo = 'FACTURA') then 

totalHospitalizacion  = (select count(*) from rips_ripstransaccion ripstra, rips_ripshospitalizacion hosp where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and hosp."ripsTransaccion_id" = ripstra.id and cast("numNota" as float)  = 0);

end if;

if (tipo = 'GLOSA') then 
totalHospitalizacion  = (select count(*) from rips_ripstransaccion ripstra, rips_ripshospitalizacion hosp where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and hosp."ripsTransaccion_id" = ripstra.id and ripstra.id=transaccionid);
end if;	

if (tipo = 'NOTA CREDITO') then 
totalHospitalizacion  = (select count(*) from rips_ripstransaccion ripstra, rips_ripshospitalizacion hosp where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and hosp."ripsTransaccion_id" = ripstra.id and ripstra.id=transaccionid);
end if;

if (totalHospitalizacion> 0) then

	RAISE NOTICE 'ENTRE TOTAL totalHospitalizacion = %s', totalHospitalizacion;

if (tipo = 'FACTURA') then 

SELECT '[{"codPrestador": ' ||'"'  ||   hosp."codPrestador"|| '",'  ||
	   '"viaIngresoServicioSalud": ' || '"'  ||hosp."viaIngresoServicioSalud_id"|| '",'  ||
	    '"fechaInicioAtencion": ' || '"'  ||substring(CAST( hosp."fechaInicioAtencion"  as text),1,16) || '",'  || 
		 '"numAutorizacion": ' || '"'  ||CASE WHEN trim(cast(hosp."numAutorizacion" as text)) is null THEN 'null' WHEN trim(cast(hosp."numAutorizacion" as text)) = '' THEN 'null' ELSE hosp."numAutorizacion"  END|| '",'   || 
	 '"causaMotivoAtencion": ' || '"'  ||cauext.codigo|| '",'   || 
	 '"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '",'   || 
		  '"codDiagnosticoPrincipalE": ' || '"'  ||dxppale.cie10|| '",'    ||
   '"codDiagnosticoRelacionadoE1": ' || '"'  ||CASE WHEN trim(cast(dxrel1.cie10 as text)) is null THEN 'null' WHEN trim(cast(dxrel1.cie10 as text)) = '' THEN 'null' ELSE dxrel1.cie10  END|| '",'   || 	
   '"codDiagnosticoRelacionadoE2": ' || '"'  ||CASE WHEN trim(cast(dxrel2.cie10  as text)) is null THEN 'null' WHEN trim(cast(dxrel2.cie10 as text)) = '' THEN 'null' ELSE dxrel2.cie10  END|| '",'   || 	
   '"codDiagnosticoRelacionadoE3": ' || '"'  ||CASE WHEN trim(cast(dxrel3.cie10  as text)) is null THEN 'null' WHEN trim(cast(dxrel3.cie10 as text)) = '' THEN 'null' ELSE dxrel3.cie10  END|| '",'   || 	
	'"codComplicacion": ' || '"'  ||'null'|| '",'  ||
		 '"condicionDestinoUsuarioEgreso": ' || '"'  ||cauext.codigo|| '",'   || 
		'"codDiagnosticoMuerte": ' || '"'  ||'null'|| '",'  ||
		 '"fechaEgreso": ' || '"'  ||case when hosp."fechaEgreso" is null then 'null' else substring(cast(hosp."fechaEgreso" as text),1,16) end|| '",'   || 
	'"consecutivo": ' || hosp.consecutivo|| '}]'
INTO valorHospitalizacion
from rips_ripstransaccion
	left join rips_ripshospitalizacion hosp on (hosp."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join rips_ripscausaexterna cauext on (cauext.id =hosp."causaMotivoAtencion_id" )
	left join clinico_diagnosticos dxppal on (dxppal.id =hosp."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxppale on (dxppale.id =hosp."codDiagnosticoPrincipalE_id")
	left join clinico_diagnosticos dxrel1 on (dxrel1.id = hosp."codDiagnosticoRelacionadoE1_id")
	left join clinico_diagnosticos dxrel2 on (dxrel2.id =  hosp."codDiagnosticoRelacionadoE2_id")
	left join clinico_diagnosticos dxrel3 on (dxrel3.id =  hosp."codDiagnosticoRelacionadoE3_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = hosp."condicionDestinoUsuarioEgreso_id" )
where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numFactura" =cast(facturaId as text) ;
	valorJson = valorJson ||' ' ||  valorHospitalizacion;
end if;	

if (tipo = 'GLOSA') then 

SELECT '[{"codPrestador": ' ||'"'  ||   hosp."codPrestador"|| '",'  ||
	   '"viaIngresoServicioSalud": ' || '"'  ||hosp."viaIngresoServicioSalud_id"|| '",'  ||
	    '"fechaInicioAtencion": ' || '"'  ||substring(CAST( hosp."fechaInicioAtencion"  as text),1,16) || '",'  || 
		 '"numAutorizacion": ' || '"'  ||CASE WHEN trim(cast(hosp."numAutorizacion" as text)) is null THEN 'null' WHEN trim(cast(hosp."numAutorizacion" as text)) = '' THEN 'null' ELSE hosp."numAutorizacion"  END|| '",'   || 
	 '"causaMotivoAtencion": ' || '"'  ||cauext.codigo|| '",'   || 
	 '"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '",'   || 
		  '"codDiagnosticoPrincipalE": ' || '"'  ||dxppale.cie10|| '",'    ||
   '"codDiagnosticoRelacionadoE1": ' || '"'  ||CASE WHEN trim(cast(dxrel1.cie10 as text)) is null THEN 'null' WHEN trim(cast(dxrel1.cie10 as text)) = '' THEN 'null' ELSE dxrel1.cie10  END|| '",'   || 	
   '"codDiagnosticoRelacionadoE2": ' || '"'  ||CASE WHEN trim(cast(dxrel2.cie10  as text)) is null THEN 'null' WHEN trim(cast(dxrel2.cie10 as text)) = '' THEN 'null' ELSE dxrel2.cie10  END|| '",'   || 	
   '"codDiagnosticoRelacionadoE3": ' || '"'  ||CASE WHEN trim(cast(dxrel3.cie10  as text)) is null THEN 'null' WHEN trim(cast(dxrel3.cie10 as text)) = '' THEN 'null' ELSE dxrel3.cie10  END|| '",'   || 	
	'"codComplicacion": ' || '"'  ||'null'|| '",'  ||
		 '"condicionDestinoUsuarioEgreso": ' || '"'  ||cauext.codigo|| '",'   || 
		'"codDiagnosticoMuerte": ' || '"'  ||'null'|| '",'  ||
		 '"fechaEgreso": ' || '"'  ||case when hosp."fechaEgreso" is null then 'null' else substring(cast(hosp."fechaEgreso" as text),1,16) end|| '",'   || 
	'"consecutivo": ' || hosp.consecutivo|| '}]'
INTO valorHospitalizacion
from rips_ripstransaccion
	left join rips_ripshospitalizacion hosp on (hosp."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join rips_ripscausaexterna cauext on (cauext.id =hosp."causaMotivoAtencion_id" )
	left join clinico_diagnosticos dxppal on (dxppal.id =hosp."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxppale on (dxppale.id =hosp."codDiagnosticoPrincipalE_id")
	left join clinico_diagnosticos dxrel1 on (dxrel1.id = hosp."codDiagnosticoRelacionadoE1_id")
	left join clinico_diagnosticos dxrel2 on (dxrel2.id =  hosp."codDiagnosticoRelacionadoE2_id")
	left join clinico_diagnosticos dxrel3 on (dxrel3.id =  hosp."codDiagnosticoRelacionadoE3_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = hosp."condicionDestinoUsuarioEgreso_id" )
where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numNota" =cast(facturaId as text) and rips_ripstransaccion.id=transaccionid;

valorJson = valorJson ||' ' ||  valorHospitalizacion;
end if;	

if (tipo = 'NOTA CREDITO') then 

SELECT '[{"codPrestador": ' ||'"'  ||   hosp."codPrestador"|| '",'  ||
	   '"viaIngresoServicioSalud": ' || '"'  ||hosp."viaIngresoServicioSalud_id"|| '",'  ||
	    '"fechaInicioAtencion": ' || '"'  ||substring(CAST( hosp."fechaInicioAtencion"  as text),1,16) || '",'  || 
		 '"numAutorizacion": ' || '"'  ||CASE WHEN trim(cast(hosp."numAutorizacion" as text)) is null THEN 'null' WHEN trim(cast(hosp."numAutorizacion" as text)) = '' THEN 'null' ELSE hosp."numAutorizacion"  END|| '",'   || 
	 '"causaMotivoAtencion": ' || '"'  ||cauext.codigo|| '",'   || 
	 '"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '",'   || 
		  '"codDiagnosticoPrincipalE": ' || '"'  ||dxppale.cie10|| '",'    ||
   '"codDiagnosticoRelacionadoE1": ' || '"'  ||CASE WHEN trim(cast(dxrel1.cie10 as text)) is null THEN 'null' WHEN trim(cast(dxrel1.cie10 as text)) = '' THEN 'null' ELSE dxrel1.cie10  END|| '",'   || 	
   '"codDiagnosticoRelacionadoE2": ' || '"'  ||CASE WHEN trim(cast(dxrel2.cie10  as text)) is null THEN 'null' WHEN trim(cast(dxrel2.cie10 as text)) = '' THEN 'null' ELSE dxrel2.cie10  END|| '",'   || 	
   '"codDiagnosticoRelacionadoE3": ' || '"'  ||CASE WHEN trim(cast(dxrel3.cie10  as text)) is null THEN 'null' WHEN trim(cast(dxrel3.cie10 as text)) = '' THEN 'null' ELSE dxrel3.cie10  END|| '",'   || 	
	'"codComplicacion": ' || '"'  ||'null'|| '",'  ||
		 '"condicionDestinoUsuarioEgreso": ' || '"'  ||cauext.codigo|| '",'   || 
		'"codDiagnosticoMuerte": ' || '"'  ||'null'|| '",'  ||
		 '"fechaEgreso": ' || '"'  ||case when hosp."fechaEgreso" is null then 'null' else substring(cast(hosp."fechaEgreso" as text),1,16) end|| '",'   || 
	'"consecutivo": ' || hosp.consecutivo|| '}]'
INTO valorHospitalizacion
from rips_ripstransaccion
	left join rips_ripshospitalizacion hosp on (hosp."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join rips_ripscausaexterna cauext on (cauext.id =hosp."causaMotivoAtencion_id" )
	left join clinico_diagnosticos dxppal on (dxppal.id =hosp."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxppale on (dxppale.id =hosp."codDiagnosticoPrincipalE_id")
	left join clinico_diagnosticos dxrel1 on (dxrel1.id = hosp."codDiagnosticoRelacionadoE1_id")
	left join clinico_diagnosticos dxrel2 on (dxrel2.id =  hosp."codDiagnosticoRelacionadoE2_id")
	left join clinico_diagnosticos dxrel3 on (dxrel3.id =  hosp."codDiagnosticoRelacionadoE3_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = hosp."condicionDestinoUsuarioEgreso_id" )
where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numNota" =cast(facturaId as text) and rips_ripstransaccion.id=transaccionid;

valorJson = valorJson ||' ' ||  valorHospitalizacion;
end if;	
	valorJson = valorJson || ' ' ;
else
	valorJson = valorJson || '[]' ;

 end if;

raise notice 'Va esto en el JSON HOSP: %s' , valorJson;

-- Urgencias

totalUrgencias  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsurgenciasobservacion urg where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and urg."ripsTransaccion_id" = ripstra.id);

if (tipo = 'FACTURA') then 

totalUrgencias  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsurgenciasobservacion urg where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and urg."ripsTransaccion_id" = ripstra.id and cast("numNota" as float)  = 0 ) ;

end if;

if (tipo = 'GLOSA') then 

totalUrgencias  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsurgenciasobservacion urg where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and urg."ripsTransaccion_id" = ripstra.id and ripstra.id=transaccionid);

end if;	

if (tipo = 'NOTA CREDITO') then 

totalUrgencias  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsurgenciasobservacion urg where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and urg."ripsTransaccion_id" = ripstra.id and ripstra.id=transaccionid);

end if;	

	RAISE NOTICE 'ANTES DE URGENCIAS';
RAISE NOTICE 'TOTAL URGENCIAS = %s', totalUrgencias;
valorJson = valorJson || ',"urgencias":' ;

if (totalUrgencias> 0) then

	RAISE NOTICE 'eNTRE uRGENCIAS';

	if (tipo = 'FACTURA') then 
	
	 SELECT '[{"codPrestador": ' ||  '"' || urg."codPrestador"|| '",'  ||
	   	    '"fechaInicioAtencion": ' || '"'  ||substring(cast(urg."fechaInicioAtencion" as text),1,16)|| '",'  || 	
			 '"causaMotivoAtencion": ' || '"'  ||cauext.codigo|| '",'   || 
	 		'"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '",'   || 
		  '"codDiagnosticoPrincipalE": ' || '"'  ||dxppale.cie10|| '",'    ||
			'"codDiagnosticoRelacionadoE1": ' || '"'  ||coalesce(dxrel1.cie10,'null')|| '",'  ||
		 	'"codDiagnosticoRelacionadoE2": ' || '"'  ||coalesce(dxrel2.cie10,'null')|| '",'  ||
			'"codDiagnosticoRelacionadoE3": ' || '"'  ||coalesce(dxrel3.cie10,'null')|| '",'  ||
		 	'"condicionDestinoUsuarioEgreso": ' || '"'  ||cauext.codigo|| '",'   || 
			'"codDiagnosticoCausaMuerte": ' || '"'  ||coalesce(dxMuerte.cie10,'null')|| '",'  ||
		 	'"fechaEgreso": ' || '"'  ||substring(cast(urg."fechaEgreso"  as text),1,16)|| '",'   || 
		'"consecutivo": ' ||urg.consecutivo|| 	'}]'
	INTO valorUrgencias
	from rips_ripstransaccion
	left join rips_ripsurgenciasobservacion urg on (urg."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join rips_ripscausaexterna cauext on (cauext.id =urg."causaMotivoAtencion_id" )
	left join clinico_diagnosticos dxppal on (dxppal.id =urg."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxppale on (dxppale.id =urg."codDiagnosticoPrincipalE_id")
	left join clinico_diagnosticos dxrel1 on (dxrel1.id = urg."codDiagnosticoRelacionadoE1_id")
	left join clinico_diagnosticos dxrel2 on (dxrel2.id =  urg."codDiagnosticoRelacionadoE2_id")
	left join clinico_diagnosticos dxrel3 on (dxrel3.id =  urg."codDiagnosticoRelacionadoE3_id")
	left join clinico_diagnosticos dxMuerte on (dxMuerte.id =  urg."codDiagnosticoCausaMuerte_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = urg."condicionDestinoUsuarioEgreso_id" )
	where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numFactura" =cast(facturaId as text);
	valorJson = valorJson ||' ' || valorUrgencias;
    end if;

if (tipo = 'GLOSA') then 
		
	 SELECT '[{"codPrestador": ' ||  '"' || urg."codPrestador"|| '",'  ||
	   	    '"fechaInicioAtencion": ' || '"'  ||substring(cast(urg."fechaInicioAtencion" as text),1,16)|| '",'  || 	
			 '"causaMotivoAtencion": ' || '"'  ||cauext.codigo|| '",'   || 
	 		'"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '",'   || 
		  '"codDiagnosticoPrincipalE": ' || '"'  ||dxppale.cie10|| '",'    ||
			'"codDiagnosticoRelacionadoE1": ' || '"'  ||coalesce(dxrel1.cie10,'null')|| '",'  ||
		 	'"codDiagnosticoRelacionadoE2": ' || '"'  ||coalesce(dxrel2.cie10,'null')|| '",'  ||
			'"codDiagnosticoRelacionadoE3": ' || '"'  ||coalesce(dxrel3.cie10,'null')|| '",'  ||
		 	'"condicionDestinoUsuarioEgreso": ' || '"'  ||cauext.codigo|| '",'   || 
			'"codDiagnosticoCausaMuerte": ' || '"'  ||coalesce(dxMuerte.cie10,'null')|| '",'  ||
		 	'"fechaEgreso": ' || '"'  ||substring(cast(urg."fechaEgreso"  as text),1,16)|| '",'   || 
		'"consecutivo": ' ||urg.consecutivo|| 	'}]'
	INTO valorUrgencias
	from rips_ripstransaccion
	left join rips_ripsurgenciasobservacion urg on (urg."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join rips_ripscausaexterna cauext on (cauext.id =urg."causaMotivoAtencion_id" )
	left join clinico_diagnosticos dxppal on (dxppal.id =urg."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxppale on (dxppale.id =urg."codDiagnosticoPrincipalE_id")
	left join clinico_diagnosticos dxrel1 on (dxrel1.id = urg."codDiagnosticoRelacionadoE1_id")
	left join clinico_diagnosticos dxrel2 on (dxrel2.id =  urg."codDiagnosticoRelacionadoE2_id")
	left join clinico_diagnosticos dxrel3 on (dxrel3.id =  urg."codDiagnosticoRelacionadoE3_id")
	left join clinico_diagnosticos dxMuerte on (dxMuerte.id =  urg."codDiagnosticoCausaMuerte_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = urg."condicionDestinoUsuarioEgreso_id" )
	where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numNota" =cast(facturaId as text) and rips_ripstransaccion.id=transaccionid;
	valorJson = valorJson ||' ' || valorUrgencias;
    end if;

if (tipo = 'NOTA CREDITO') then 
		
	 SELECT '[{"codPrestador": ' ||  '"' || urg."codPrestador"|| '",'  ||
	   	    '"fechaInicioAtencion": ' || '"'  ||substring(cast(urg."fechaInicioAtencion" as text),1,16)|| '",'  || 	
			 '"causaMotivoAtencion": ' || '"'  ||cauext.codigo|| '",'   || 
	 		'"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '",'   || 
		  '"codDiagnosticoPrincipalE": ' || '"'  ||dxppale.cie10|| '",'    ||
			'"codDiagnosticoRelacionadoE1": ' || '"'  ||coalesce(dxrel1.cie10,'null')|| '",'  ||
		 	'"codDiagnosticoRelacionadoE2": ' || '"'  ||coalesce(dxrel2.cie10,'null')|| '",'  ||
			'"codDiagnosticoRelacionadoE3": ' || '"'  ||coalesce(dxrel3.cie10,'null')|| '",'  ||
		 	'"condicionDestinoUsuarioEgreso": ' || '"'  ||cauext.codigo|| '",'   || 
			'"codDiagnosticoCausaMuerte": ' || '"'  ||coalesce(dxMuerte.cie10,'null')|| '",'  ||
		 	'"fechaEgreso": ' || '"'  ||substring(cast(urg."fechaEgreso"  as text),1,16)|| '",'   || 
		'"consecutivo": ' ||urg.consecutivo|| 	'}]'
	INTO valorUrgencias
	from rips_ripstransaccion
	left join rips_ripsurgenciasobservacion urg on (urg."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join rips_ripscausaexterna cauext on (cauext.id =urg."causaMotivoAtencion_id" )
	left join clinico_diagnosticos dxppal on (dxppal.id =urg."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxppale on (dxppale.id =urg."codDiagnosticoPrincipalE_id")
	left join clinico_diagnosticos dxrel1 on (dxrel1.id = urg."codDiagnosticoRelacionadoE1_id")
	left join clinico_diagnosticos dxrel2 on (dxrel2.id =  urg."codDiagnosticoRelacionadoE2_id")
	left join clinico_diagnosticos dxrel3 on (dxrel3.id =  urg."codDiagnosticoRelacionadoE3_id")
	left join clinico_diagnosticos dxMuerte on (dxMuerte.id =  urg."codDiagnosticoCausaMuerte_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = urg."condicionDestinoUsuarioEgreso_id" )
	where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numNota" =cast(facturaId as text) and rips_ripstransaccion.id=transaccionid;
	valorJson = valorJson ||' ' || valorUrgencias;
    end if;
	--mide := length(valorJson);
	RAISE NOTICE 'mide = %s' , mide ;
	--SELECT SUBSTRING(valorJson,1, mide-1) INTO valorJson;	

else
	valorJson = valorJson || '[]' ;

END IF;

raise notice 'Va esto en el JSON URGE: %s' , valorJson;

totalMedicamentos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsmedicamentos ripsmed where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and ripsmed."ripsTransaccion_id" = ripstra.id);

if (tipo = 'FACTURA') then 

totalMedicamentos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsmedicamentos ripsmed where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and ripsmed."ripsTransaccion_id" = ripstra.id );

end if;

if (tipo = 'GLOSA') then 

totalMedicamentos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsmedicamentos ripsmed where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and ripsmed."ripsTransaccion_id" = ripstra.id and ripstra.id=transaccionid);

end if;	

if (tipo = 'NOTA CREDITO') then 

totalMedicamentos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsmedicamentos ripsmed where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and ripsmed."ripsTransaccion_id" = ripstra.id and ripstra.id=transaccionid);

end if;	

RAISE NOTICE 'ANTES DE totalMedicamentos';
	RAISE NOTICE 'TOTAL totalMedicamentos = %s', totalMedicamentos;
valorJson = valorJson ||' ,"medicamentos" : [' ;

if (totalMedicamentos> 0) then

	RAISE NOTICE 'ENTRE TOTAL totalMedicamentos = %s', totalMedicamentos;
   
	for i in 1..totalMedicamentos
	loop   

			if (tipo = 'FACTURA') then 
		
	 SELECT	'{"codPrestador": ' ||  '"' ||med."codPrestador"|| '",'   ||		
	   	    '"numAutorizacion": ' || '"'  ||CASE WHEN trim(med."numAutorizacion") is null THEN 'null' ELSE med."numAutorizacion"  END|| '",'   || 	
	 	  '"idMIPRES": ' || '"'   ||CASE WHEN trim(med."idMIPRES") is null THEN 'null'  WHEN trim(med."idMIPRES") = null THEN 'null' WHEN trim(med."idMIPRES") = '' THEN 'null'  ELSE med."idMIPRES"  END|| '",'  || 	
		'"fechaDispensAdmon": ' || '"'  ||substring(cast(med."fechaDispensAdmon" as text),1,16) || '",'     || 	
	  '"codDiagnosticoPrincipal": ' || '"'  ||CASE WHEN trim(diag1.cie10) is null THEN 'null' ELSE diag1.cie10  END|| '",'  || 	
	'"codDiagnosticoRelacionado": ' || '"'  ||CASE WHEN trim(diag2.cie10) is null THEN 'null' ELSE diag2.cie10  END|| '",' 	  || 	
	'"tipoMedicamento": ' || '"'  ||CASE WHEN trim(tipmed.codigo) is null THEN 'null' ELSE tipmed.codigo  END|| '",'   || 	
	'"codTecnologiaSalud": ' || '"'  ||  CASE WHEN trim(ripscums.cum) is null THEN 'null' ELSE ripscums.cum  END           || '",'  || 	
	'"nomTecnologiaSalud": ' || '"'  ||   CASE WHEN trim(med."nomTecnologiaSalud") is null THEN 'null' ELSE med."nomTecnologiaSalud"  END               || '",'  || 	
	'"concentracionMedicamento": ' || '"'  || CASE WHEN trim(med."concentracionMedicamento") is null THEN 'null' ELSE med."concentracionMedicamento"  END  || '",'    || 		
	'"unidadMedida": ' ||  CASE WHEN ripsumm.codigo is null THEN 'null' WHEN ripsumm.codigo = 'null' THEN 'null' ELSE ripsumm.codigo  END|| ','  || 	
	'"formaFarmaceutica": ' || '"'  ||  CASE WHEN trim(ripsfarma.codigo) is null THEN 'null' ELSE ripsfarma.codigo  END  || '",'  || 	
	'"unidadMinDispensa": ' || CASE WHEN trim(ripsupr.codigo) is null THEN 'null' WHEN trim(ripsupr.codigo) = 'null' THEN 'null' ELSE ripsupr.codigo  END || ','  || 	
	'"cantidadMedicamento": ' || case when med."cantidadMedicamento" is null then 0 else  med."cantidadMedicamento" end   || ','    || 	
	'"diasTratamiento": ' ||   case when med."diasTratamiento" is null then 0 else  med."diasTratamiento" end   || ','   || 		
	'"tipoDocumentoldentificacion": ' || '"'  || CASE WHEN trim(ripstipdoc.codigo) is null THEN 'null' ELSE ripstipdoc.codigo  END   || '",'  || 	
	'"numDocumentoIdentificacion": ' || '"'  || CASE WHEN trim(med."numDocumentoIdentificacion") is null THEN 'null' ELSE med."numDocumentoIdentificacion"  END     || '",'  || 	
		'"vrUnitMedicamento": ' || med."vrUnitMedicamento" || ','  || 	
		'"vrServicio": ' || med."vrServicio"|| ','  || 	
		'"conceptoRecaudo": ' || '"'  ||CASE WHEN trim(recaudo.codigo) is null THEN 'null' ELSE recaudo.codigo  END|| '",'  || 	
		'"tipoPagoModerador": ' || '"'  ||  CASE WHEN trim( ripstipopago.codigo) is null THEN 'null' ELSE  ripstipopago.codigo  END || '",'  || 	
	'"valorPagoModerador": ' || med."valorPagoModerador" || ','  || 				
	'"numFEVPagoModerador": ' || '"'  || CASE WHEN trim(med."numFEVPagoModerador") is null THEN 'null' ELSE  med."numFEVPagoModerador"  END|| '",'   || 	
	'"consecutivo": ' || med.consecutivo || '},'
		INTO valorMedicamentos
	from rips_ripstransaccion
	inner join rips_ripsenvios  env on (env."sedesClinica_id" = rips_ripstransaccion."sedesClinica_id" and env.id = rips_ripstransaccion."ripsEnvio_id" )
	inner join rips_ripsmedicamentos med on (med."ripsTransaccion_id" = rips_ripstransaccion.id)
	inner join sitios_sedesclinica sed on (sed.id = env."sedesClinica_id" )
	inner join rips_ripsdetalle det on (det."ripsEnvios_id" = env.id and det."numeroFactura_id" = cast(rips_ripstransaccion."numFactura" as numeric))
	inner join facturacion_facturacion fac on (fac.id = det."numeroFactura_id" )
	inner join facturacion_facturaciondetalle facdet on (facdet."facturacion_id" = fac.id and facdet."cums_id" is not null  and facDet."consecutivoFactura" = med."itemFactura")
	inner join facturacion_suministros sum  on (sum.id = facdet.cums_id )
	left join rips_ripstipomedicamento tipmed on (tipmed.id =sum."ripsTipoMedicamento_id" )
	left join rips_ripscums ripscums on (ripscums.id = med."codTecnologiaSalud_id")	
	left join rips_ripsumm ripsumm on (ripsumm.id = sum."ripsUnidadMedida_id")	
	left join rips_RipsFormaFarmaceutica ripsfarma on (ripsfarma.id = sum."ripsFormaFarmaceutica_id")	
	left join rips_ripsunidadupr ripsupr on (ripsupr.id = sum."ripsUnidadUpr_id")	
    left join rips_ripsconceptorecaudo recaudo on (recaudo.id = med."conceptoRecaudo_id")		
	inner join  rips_RipsTiposDocumento ripstipdoc on (ripstipdoc.id = med."tipoDocumentoIdentificacion_id")
	left join cartera_pagos pagos on (pagos."tipoDoc_id" =  fac."tipoDoc_id"  and pagos.documento_id = fac.documento_id and pagos.consec = fac."consecAdmision")	
	left join cartera_formaspagos formaspagos on (formaspagos.id = pagos."formaPago_id")		
	left join rips_ripstipospagomoderador ripstipopago on (cast(ripstipopago."codigoAplicativo" as numeric) = formaspagos.id and cast(ripstipopago."codigoAplicativo" as numeric) in ('3','4') )	
	left join clinico_diagnosticos diag1 on (diag1.id = med."codDiagnosticoPrincipal_id")	
	left join clinico_diagnosticos diag2 on (diag2.id = med."codDiagnosticoRelacionado_id")	
	where rips_ripstransaccion."ripsEnvio_id" = envioRipsId and rips_ripstransaccion."ripsEnvio_id" = env.id  and cast(rips_ripstransaccion."numFactura" as numeric) = fac.id	and rips_ripstransaccion."numFactura" =cast(facturaId as text ) and med.consecutivo = i;

	valorJson = valorJson ||' ' ||  valorMedicamentos;

    end if;

	if (tipo = 'GLOSA') then 

		RAISE NOTICE 'ENTRE GLOSA %s' , valorJson ;
		RAISE NOTICE 'ENTRE GLOSA  envioRipsId %s' , envioRipsId ;
		RAISE NOTICE 'ENTRE GLOSA  facturaId %s' , facturaId ;
		RAISE NOTICE 'ENTRE GLOSA i =  %s' , i ;

		
	 SELECT	'{"codPrestador": ' ||  '"' ||med."codPrestador"|| '",'   ||		
	   	    '"numAutorizacion": ' || '"'  ||CASE WHEN trim(med."numAutorizacion") is null THEN 'null' ELSE med."numAutorizacion"  END|| '",'   || 	
	 	  '"idMIPRES": ' || '"'   ||CASE WHEN trim(med."idMIPRES") is null THEN 'null'  WHEN trim(med."idMIPRES") = null THEN 'null' WHEN trim(med."idMIPRES") = '' THEN 'null'  ELSE med."idMIPRES"  END|| '",'  || 	
		'"fechaDispensAdmon": ' || '"'  ||substring(cast(med."fechaDispensAdmon" as text),1,16) || '",'     || 	
	  '"codDiagnosticoPrincipal": ' || '"'  ||CASE WHEN trim(diag1.cie10) is null THEN 'null' ELSE diag1.cie10  END|| '",'  || 	
	'"codDiagnosticoRelacionado": ' || '"'  ||CASE WHEN trim(diag2.cie10) is null THEN 'null' ELSE diag2.cie10  END|| '",' 	  || 	
	'"tipoMedicamento": ' || '"'  ||CASE WHEN trim(tipmed.codigo) is null THEN 'null' ELSE tipmed.codigo  END|| '",'   || 	
	'"codTecnologiaSalud": ' || '"'  ||  CASE WHEN trim(ripscums.cum) is null THEN 'null' ELSE ripscums.cum  END           || '",'  || 	
	'"nomTecnologiaSalud": ' || '"'  ||   CASE WHEN trim(med."nomTecnologiaSalud") is null THEN 'null' ELSE med."nomTecnologiaSalud"  END               || '",'  || 	
	'"concentracionMedicamento": ' || '"'  || CASE WHEN trim(med."concentracionMedicamento") is null THEN 'null' ELSE med."concentracionMedicamento"  END  || '",'    || 		
	'"unidadMedida": ' ||  CASE WHEN ripsumm.codigo is null THEN 'null' WHEN ripsumm.codigo = 'null' THEN 'null' ELSE ripsumm.codigo  END|| ','  || 	
	'"formaFarmaceutica": ' || '"'  ||  CASE WHEN trim(ripsfarma.codigo) is null THEN 'null' ELSE ripsfarma.codigo  END  || '",'  || 	
	'"unidadMinDispensa": ' || CASE WHEN trim(ripsupr.codigo) is null THEN 'null' WHEN trim(ripsupr.codigo) = 'null' THEN 'null' ELSE ripsupr.codigo  END || ','  || 	
	'"cantidadMedicamento": ' || med."cantidadMedicamento"  || ','    || 	
	'"diasTratamiento": ' ||    med."diasTratamiento"   || ','   || 		
	'"tipoDocumentoldentificacion": ' || '"'  || CASE WHEN trim(ripstipdoc.codigo) is null THEN 'null' ELSE ripstipdoc.codigo  END   || '",'  || 	
	'"numDocumentoIdentificacion": ' || '"'  || CASE WHEN trim(med."numDocumentoIdentificacion") is null THEN 'null' ELSE med."numDocumentoIdentificacion"  END     || '",'  || 	
		'"vrUnitMedicamento": ' || med."vrUnitMedicamento" || ','  || 	
		'"vrServicio": ' || CASE WHEN med."notasCreditoGlosa" is null then 0  ELSE med."notasCreditoGlosa" end|| ','  || 	
		'"conceptoRecaudo": ' || '"'  ||CASE WHEN trim(recaudo.codigo) is null THEN 'null' ELSE recaudo.codigo  END|| '",'  || 	
		'"tipoPagoModerador": ' || '"'  ||  CASE WHEN trim( ripstipopago.codigo) is null THEN 'null' ELSE  ripstipopago.codigo  END || '",'  || 	
	'"valorPagoModerador": ' || med."valorPagoModerador" || ','  || 				
	'"numFEVPagoModerador": ' || '"'  || CASE WHEN trim(med."numFEVPagoModerador") is null THEN 'null' ELSE  med."numFEVPagoModerador"  END|| '",'   || 	
	'"consecutivo": ' || med.consecutivo || '},'
	INTO valorMedicamentos
	from rips_ripstransaccion
	inner join rips_ripsenvios  env on (env."sedesClinica_id" = rips_ripstransaccion."sedesClinica_id" and env.id = rips_ripstransaccion."ripsEnvio_id" )
	inner join rips_ripsmedicamentos med on (med."ripsTransaccion_id" = rips_ripstransaccion.id)
	inner join sitios_sedesclinica sed on (sed.id = env."sedesClinica_id" )
	inner join rips_ripsdetalle det on (det."ripsEnvios_id" = env.id and det."numeroFactura_id" = cast(rips_ripstransaccion."numFactura" as numeric))
	inner join facturacion_facturacion fac on (fac.id = det."numeroFactura_id" )
	inner join facturacion_facturaciondetalle facdet on (facdet."facturacion_id" = fac.id and facdet."cums_id" is not null and facDet."consecutivoFactura" = med."itemFactura")
	inner join facturacion_suministros sum  on (sum.id = facdet.cums_id )
	left join rips_ripstipomedicamento tipmed on (tipmed.id =sum."ripsTipoMedicamento_id" )
	left join rips_ripscums ripscums on (ripscums.id = med."codTecnologiaSalud_id")	
	left join rips_ripsumm ripsumm on (ripsumm.id = sum."ripsUnidadMedida_id")	
	left join rips_RipsFormaFarmaceutica ripsfarma on (ripsfarma.id = sum."ripsFormaFarmaceutica_id")	
	left join rips_ripsunidadupr ripsupr on (ripsupr.id = sum."ripsUnidadUpr_id")	
    left join rips_ripsconceptorecaudo recaudo on (recaudo.id = med."conceptoRecaudo_id")		
	inner join  rips_RipsTiposDocumento ripstipdoc on (ripstipdoc.id = med."tipoDocumentoIdentificacion_id")
	left join cartera_pagos pagos on (pagos."tipoDoc_id" =  fac."tipoDoc_id"  and pagos.documento_id = fac.documento_id and pagos.consec = fac."consecAdmision")	
	left join cartera_formaspagos formaspagos on (formaspagos.id = pagos."formaPago_id")		
	left join rips_ripstipospagomoderador ripstipopago on (cast(ripstipopago."codigoAplicativo" as numeric) = formaspagos.id and cast(ripstipopago."codigoAplicativo" as numeric) in ('3','4') )	
	left join clinico_diagnosticos diag1 on (diag1.id = med."codDiagnosticoPrincipal_id")	
	left join clinico_diagnosticos diag2 on (diag2.id = med."codDiagnosticoRelacionado_id")	
    where rips_ripstransaccion."ripsEnvio_id" = envioRipsId and rips_ripstransaccion."ripsEnvio_id" = env.id  and cast(rips_ripstransaccion."numNota" as numeric) = det.glosa_id	and rips_ripstransaccion."numNota" =cast(facturaId as text ) and rips_ripstransaccion.id=transaccionid and med.consecutivo = i and rips_ripstransaccion.id is not null;

	valorJson = valorJson ||' ' || valorMedicamentos;
	RAISE NOTICE 'FIN GLOSA MEDICAMENTOS %s' , valorJson ;
	RAISE NOTICE 'FIN GLOSA valorMedicamentos %s' , valorMedicamentos ;
    end if;

	if (tipo = 'NOTA CREDITO') then 

		RAISE NOTICE 'ENTRE CREDITO %s' , valorJson ;
		RAISE NOTICE 'ENTRE CREDITO  envioRipsId %s' , envioRipsId ;
		RAISE NOTICE 'ENTRE CREDITO  facturaId %s' , facturaId ;
		RAISE NOTICE 'ENTRE CREDITO i =  %s' , i ;

		
	 SELECT	'{"codPrestador": ' ||  '"' ||med."codPrestador"|| '",'   ||		
	   	    '"numAutorizacion": ' || '"'  ||CASE WHEN trim(med."numAutorizacion") is null THEN 'null' ELSE med."numAutorizacion"  END|| '",'   || 	
	 	  '"idMIPRES": ' || '"'   ||CASE WHEN trim(med."idMIPRES") is null THEN 'null'  WHEN trim(med."idMIPRES") = null THEN 'null' WHEN trim(med."idMIPRES") = '' THEN 'null'  ELSE med."idMIPRES"  END|| '",'  || 	
		'"fechaDispensAdmon": ' || '"'  ||substring(cast(med."fechaDispensAdmon" as text),1,16) || '",'     || 	
	  '"codDiagnosticoPrincipal": ' || '"'  ||CASE WHEN trim(diag1.cie10) is null THEN 'null' ELSE diag1.cie10  END|| '",'  || 	
	'"codDiagnosticoRelacionado": ' || '"'  ||CASE WHEN trim(diag2.cie10) is null THEN 'null' ELSE diag2.cie10  END|| '",' 	  || 	
	'"tipoMedicamento": ' || '"'  ||CASE WHEN trim(tipmed.codigo) is null THEN 'null' ELSE tipmed.codigo  END|| '",'   || 	
	'"codTecnologiaSalud": ' || '"'  ||  CASE WHEN trim(ripscums.cum) is null THEN 'null' ELSE ripscums.cum  END           || '",'  || 	
	'"nomTecnologiaSalud": ' || '"'  ||   CASE WHEN trim(med."nomTecnologiaSalud") is null THEN 'null' ELSE med."nomTecnologiaSalud"  END               || '",'  || 	
	'"concentracionMedicamento": ' || '"'  || CASE WHEN trim(med."concentracionMedicamento") is null THEN 'null' ELSE med."concentracionMedicamento"  END  || '",'    || 		
	'"unidadMedida": ' ||  CASE WHEN ripsumm.codigo is null THEN 'null' WHEN ripsumm.codigo = 'null' THEN 'null' ELSE ripsumm.codigo  END|| ','  || 	
	'"formaFarmaceutica": ' || '"'  ||  CASE WHEN trim(ripsfarma.codigo) is null THEN 'null' ELSE ripsfarma.codigo  END  || '",'  || 	
	'"unidadMinDispensa": ' || CASE WHEN trim(ripsupr.codigo) is null THEN 'null' WHEN trim(ripsupr.codigo) = 'null' THEN 'null' ELSE ripsupr.codigo  END || ','  || 	
	'"cantidadMedicamento": ' || med."cantidadMedicamento"  || ','    || 	
	'"diasTratamiento": ' ||    med."diasTratamiento"   || ','   || 		
	'"tipoDocumentoldentificacion": ' || '"'  || CASE WHEN trim(ripstipdoc.codigo) is null THEN 'null' ELSE ripstipdoc.codigo  END   || '",'  || 	
	'"numDocumentoIdentificacion": ' || '"'  || CASE WHEN trim(med."numDocumentoIdentificacion") is null THEN 'null' ELSE med."numDocumentoIdentificacion"  END     || '",'  || 	
		'"vrUnitMedicamento": ' || med."vrUnitMedicamento" || ','  || 	
		'"vrServicio": ' || CASE WHEN med."notasCreditoOtras" is null then 0  ELSE med."notasCreditoOtras" end|| ','  || 	
		'"conceptoRecaudo": ' || '"'  ||CASE WHEN trim(recaudo.codigo) is null THEN 'null' ELSE recaudo.codigo  END|| '",'  || 	
		'"tipoPagoModerador": ' || '"'  ||  CASE WHEN trim( ripstipopago.codigo) is null THEN 'null' ELSE  ripstipopago.codigo  END || '",'  || 	
	'"valorPagoModerador": ' || med."valorPagoModerador" || ','  || 				
	'"numFEVPagoModerador": ' || '"'  || CASE WHEN trim(med."numFEVPagoModerador") is null THEN 'null' ELSE  med."numFEVPagoModerador"  END|| '",'   || 	
	'"consecutivo": ' || med.consecutivo || '},'
	INTO valorMedicamentos
	from rips_ripstransaccion
	inner join rips_ripsenvios  env on (env."sedesClinica_id" = rips_ripstransaccion."sedesClinica_id" and env.id = rips_ripstransaccion."ripsEnvio_id" )
	inner join rips_ripsmedicamentos med on (med."ripsTransaccion_id" = rips_ripstransaccion.id)
	inner join sitios_sedesclinica sed on (sed.id = env."sedesClinica_id" )
	inner join rips_ripsdetalle det on (det."ripsEnvios_id" = env.id and det."numeroFactura_id" = cast(rips_ripstransaccion."numFactura" as numeric))
	inner join facturacion_facturacion fac on (fac.id = det."numeroFactura_id" )
	inner join facturacion_facturaciondetalle facdet on (facdet."facturacion_id" = fac.id and facdet."cums_id" is not null and facDet."consecutivoFactura" = med."itemFactura" )
	inner join facturacion_suministros sum  on (sum.id = facdet.cums_id )
	left join rips_ripstipomedicamento tipmed on (tipmed.id =sum."ripsTipoMedicamento_id" )
	left join rips_ripscums ripscums on (ripscums.id = med."codTecnologiaSalud_id")	
	left join rips_ripsumm ripsumm on (ripsumm.id = sum."ripsUnidadMedida_id")	
	left join rips_RipsFormaFarmaceutica ripsfarma on (ripsfarma.id = sum."ripsFormaFarmaceutica_id")	
	left join rips_ripsunidadupr ripsupr on (ripsupr.id = sum."ripsUnidadUpr_id")	
    left join rips_ripsconceptorecaudo recaudo on (recaudo.id = med."conceptoRecaudo_id")		
	inner join  rips_RipsTiposDocumento ripstipdoc on (ripstipdoc.id = med."tipoDocumentoIdentificacion_id")
	left join cartera_pagos pagos on (pagos."tipoDoc_id" =  fac."tipoDoc_id"  and pagos.documento_id = fac.documento_id and pagos.consec = fac."consecAdmision")	
	left join cartera_formaspagos formaspagos on (formaspagos.id = pagos."formaPago_id")		
	left join rips_ripstipospagomoderador ripstipopago on (cast(ripstipopago."codigoAplicativo" as numeric) = formaspagos.id and cast(ripstipopago."codigoAplicativo" as numeric) in ('3','4') )	
	left join clinico_diagnosticos diag1 on (diag1.id = med."codDiagnosticoPrincipal_id")	
	left join clinico_diagnosticos diag2 on (diag2.id = med."codDiagnosticoRelacionado_id")	
    where rips_ripstransaccion."ripsEnvio_id" = envioRipsId and rips_ripstransaccion."ripsEnvio_id" = env.id  and cast(rips_ripstransaccion."numNota" as numeric) = det."notaCredito_id"	and rips_ripstransaccion."numNota" =cast(facturaId as text ) and rips_ripstransaccion.id=transaccionid and med.consecutivo = i and rips_ripstransaccion.id is not null;

	valorJson = valorJson ||' ' || valorMedicamentos;
	RAISE NOTICE 'FIN GLOSA MEDICAMENTOS %s' , valorJson ;
	RAISE NOTICE 'FIN GLOSA valorMedicamentos %s' , valorMedicamentos ;
    end if;

	end loop;

	mide := length(valorJson);
	RAISE NOTICE 'mide = %s' , mide ;
	SELECT SUBSTRING(valorJson,1, mide-1) INTO valorJson;	
	valorJson = valorJson || ']' ;
		
else
	valorJson = valorJson || ']' ;

 END IF;

	

raise notice 'Va esto en el JSON MEDICAMENTOS: %s' , valorJson;

--	totalRecienNacidos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsreciennacido ripsnac where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and ripsnac."ripsTransaccion_id" = ripstra.id);

if (tipo = 'FACTURA') then 

totalRecienNacidos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsreciennacido ripsnac where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and ripsnac."ripsTransaccion_id" = ripstra.id);

end if;

if (tipo = 'GLOSA') then 

totalRecienNacidos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsreciennacido ripsnac where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and ripsnac."ripsTransaccion_id" = ripstra.id and ripstra.id=transaccionid);

end if;	

if (tipo = 'NOTA CREDITO') then 

totalRecienNacidos  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsreciennacido ripsnac where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and ripsnac."ripsTransaccion_id" = ripstra.id and ripstra.id=transaccionid);

end if;	

RAISE NOTICE 'ANTES DE totalRecienNacidos';
valorJson = valorJson ||' , "recienNacidos": [' ;
RAISE NOTICE 'TOTAL totalRecienNacidos = %s', totalRecienNacidos;

if (totalRecienNacidos> 0) then

	if (tipo = 'FACTURA') then 

	SELECT '{"codPrestador": ' ||  '"' || nac."codPrestador"|| '",'  ||
	   	    '"tipoDocumentoIdentificacion": ' || '"'  ||tipoDoc.codigo|| '",'  || 	
			 '"numDocumentoIdentificacion": ' || '"'  ||nac."numDocumentoIdentificacion"|| '",'   || 
	 		'"fechaNacimiento": ' || '"'  ||substring(CAST( nac."fechaNacimiento"  as text),1,16)|| '",'    
	 ||'"edadGestacional": '|| CASE WHEN trim(nac."edadGestacional") is null THEN 'null' WHEN trim(nac."edadGestacional") = '' THEN 'null' ELSE nac."edadGestacional"  END 
	 ||',"numConsultasCPrenatal": '|| CASE WHEN trim(nac."numConsultasCPrenatal") is null THEN 'null' WHEN trim(nac."numConsultasCPrenatal") = '' THEN 'null'  ELSE nac."numConsultasCPrenatal"  END 		
	 ||',"codSexoBiologico": '|| '"' || CASE WHEN trim(nac."codSexoBiologico") is null THEN 'null'  WHEN trim(nac."codSexoBiologico") = '' THEN 'null' ELSE nac."codSexoBiologico"  END || '"'		
	 ||',"peso": '|| CASE WHEN trim(nac."peso") is null THEN 'null' WHEN trim(nac."peso") = '' THEN 'null'  ELSE nac."peso"  END 		
	 ||',"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '"'   
	 ||',"condicionDestino": '|| '"' || CASE WHEN trim(egreso.codigo) is null THEN 'null' ELSE egreso.codigo END || '"'		
	 	',"codDiagnosticoCausaMuerte": ' || '"'  ||dxMuerte.cie10|| '",'   || 
		'"fechaEgreso": ' || '"'  ||substring(cast(nac."fechaEgreso" as text),1,16)|| '",'   || 
		'"consecutivo": ' ||nac.consecutivo|| 
		'},'
	INTO valorRecienNacidos
	from rips_ripstransaccion
	left join rips_ripsreciennacido nac on (nac."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join clinico_diagnosticos dxppal on (dxppal.id =nac."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxMuerte on (dxMuerte.id =  nac."codDiagnosticoCausaMuerte_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = nac."condicionDestinoUsuarioEgreso_id" )
	left join rips_ripstiposdocumento tipoDoc on (tipoDoc.id = nac."tipoDocumentoIdentificacion_id" )
	where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numFactura" =cast(facturaId as text);

	valorJson = valorJson ||' ' || valorRecienNacidos;

end if;

	if (tipo = 'GLOSA') then 

	SELECT '{"codPrestador": ' ||  '"' || nac."codPrestador"|| '",'  ||
	   	    '"tipoDocumentoIdentificacion": ' || '"'  ||tipoDoc.codigo|| '",'  || 	
			 '"numDocumentoIdentificacion": ' || '"'  ||nac."numDocumentoIdentificacion"|| '",'   || 
	 		'"fechaNacimiento": ' || '"'  ||substring(CAST( nac."fechaNacimiento"  as text),1,16)|| '",'    
	 ||'"edadGestacional": '|| CASE WHEN trim(nac."edadGestacional") is null THEN 'null' WHEN trim(nac."edadGestacional") = '' THEN 'null' ELSE nac."edadGestacional"  END 
	 ||',"numConsultasCPrenatal": '|| CASE WHEN trim(nac."numConsultasCPrenatal") is null THEN 'null' WHEN trim(nac."numConsultasCPrenatal") = '' THEN 'null'  ELSE nac."numConsultasCPrenatal"  END 		
	 ||',"codSexoBiologico": '|| '"' || CASE WHEN trim(nac."codSexoBiologico") is null THEN 'null'  WHEN trim(nac."codSexoBiologico") = '' THEN 'null' ELSE nac."codSexoBiologico"  END || '"'		
	 ||',"peso": '|| CASE WHEN trim(nac."peso") is null THEN 'null' WHEN trim(nac."peso") = '' THEN 'null'  ELSE nac."peso"  END 		
	 ||',"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '"'   
	 ||',"condicionDestino": '|| '"' || CASE WHEN trim(egreso.codigo) is null THEN 'null' ELSE egreso.codigo  END || '"'		
	 	',"codDiagnosticoCausaMuerte": ' || '"'  ||dxMuerte.cie10|| '",'   || 
		'"fechaEgreso": ' || '"'  ||substring(cast(nac."fechaEgreso" as text),1,16)|| '",'   || 
		'"consecutivo": ' ||nac.consecutivo|| 
		'},'
	INTO valorRecienNacidos
	from rips_ripstransaccion
	left join rips_ripsreciennacido nac on (nac."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join clinico_diagnosticos dxppal on (dxppal.id =nac."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxMuerte on (dxMuerte.id =  nac."codDiagnosticoCausaMuerte_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = nac."condicionDestinoUsuarioEgreso_id" )
	left join rips_ripstiposdocumento tipoDoc on (tipoDoc.id = nac."tipoDocumentoIdentificacion_id" )
	where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numNota" =cast(facturaId as text) and rips_ripstransaccion.id=transaccionid;

	valorJson = valorJson ||' ' || valorRecienNacidos;

end if;

	if (tipo = 'NOTA CREDITO') then 

	SELECT '{"codPrestador": ' ||  '"' || nac."codPrestador"|| '",'  ||
	   	    '"tipoDocumentoIdentificacion": ' || '"'  ||tipoDoc.codigo|| '",'  || 	
			 '"numDocumentoIdentificacion": ' || '"'  ||nac."numDocumentoIdentificacion"|| '",'   || 
	 		'"fechaNacimiento": ' || '"'  ||substring(CAST( nac."fechaNacimiento"  as text),1,16)|| '",'    
	 ||'"edadGestacional": '|| CASE WHEN trim(nac."edadGestacional") is null THEN 'null' WHEN trim(nac."edadGestacional") = '' THEN 'null' ELSE nac."edadGestacional"  END 
	 ||',"numConsultasCPrenatal": '|| CASE WHEN trim(nac."numConsultasCPrenatal") is null THEN 'null' WHEN trim(nac."numConsultasCPrenatal") = '' THEN 'null'  ELSE nac."numConsultasCPrenatal"  END 		
	 ||',"codSexoBiologico": '|| '"' || CASE WHEN trim(nac."codSexoBiologico") is null THEN 'null'  WHEN trim(nac."codSexoBiologico") = '' THEN 'null' ELSE nac."codSexoBiologico"  END || '"'		
	 ||',"peso": '|| CASE WHEN trim(nac."peso") is null THEN 'null' WHEN trim(nac."peso") = '' THEN 'null'  ELSE nac."peso"  END 		
	 ||',"codDiagnosticoPrincipal": ' || '"'  ||dxppal.cie10|| '"'   
	 ||',"condicionDestino": '|| '"' || CASE WHEN trim(egreso.codigo) is null THEN 'null' ELSE egreso.codigo  END || '"'		
	 	',"codDiagnosticoCausaMuerte": ' || '"'  ||dxMuerte.cie10|| '",'   || 
		'"fechaEgreso": ' || '"'  ||substring(cast(nac."fechaEgreso" as text),1,16)|| '",'   || 
		'"consecutivo": ' ||nac.consecutivo|| 
		'},'
	INTO valorRecienNacidos
	from rips_ripstransaccion
	left join rips_ripsreciennacido nac on (nac."ripsTransaccion_id" = rips_ripstransaccion.id)
	left join clinico_diagnosticos dxppal on (dxppal.id =nac."codDiagnosticoPrincipal_id")
	left join clinico_diagnosticos dxMuerte on (dxMuerte.id =  nac."codDiagnosticoCausaMuerte_id")
	left join rips_ripsDestinoEgreso egreso on (egreso.id = nac."condicionDestinoUsuarioEgreso_id" )
	left join rips_ripstiposdocumento tipoDoc on (tipoDoc.id = nac."tipoDocumentoIdentificacion_id" )
	where  rips_ripstransaccion."ripsEnvio_id" = envioRipsId and   rips_ripstransaccion."numNota" =cast(facturaId as text) and rips_ripstransaccion.id=transaccionid;

	valorJson = valorJson ||' ' || valorRecienNacidos;

end if;

  	mide := length(valorJson);
	RAISE NOTICE 'mide = %s' , mide ;
	SELECT SUBSTRING(valorJson,1, mide-1) INTO valorJson;	
	valorJson = valorJson || ']' ;

else
	valorJson = valorJson || ']' ;

end if;

raise notice 'Va esto en el JSON RECIEN NACIDOS : %s' , valorJson;

-- Desde aquip RipsOtrosServicios

if (tipo = 'FACTURA') then 

totalOtrosServicios  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsotrosservicios ripsOtros where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numFactura" =cast(facturaId as text ) and ripsOtros."ripsTransaccion_id" = ripstra.id);

end if;

if (tipo = 'GLOSA') then 

totalOtrosServicios  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsotrosservicios ripsOtros where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and ripsOtros."ripsTransaccion_id" = ripstra.id and ripstra.id=transaccionid);

end if;	

if (tipo = 'NOTA CREDITO') then 

totalOtrosServicios  = (select count(*) from rips_ripstransaccion ripstra, rips_ripsotrosservicios ripsOtros where ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" =cast(facturaId as text ) and ripsOtros."ripsTransaccion_id" = ripstra.id and ripstra.id=transaccionid);

end if;	

RAISE NOTICE 'ENTRE TOTAL totalOtrosServicios = %s', totalOtrosServicios;
valorJson = valorJson ||',"otrosServicios" : [' ;
	  raise notice 'Detalle JSON PROCED totalOtrosServicios: %s' , valorJson;

if (totalOtrosServicios> 0) then

	contador :=1 ;

   for i in 1..totalOtrosServicios 
	loop

	   if (tipo = 'FACTURA') then 
	   
		SELECT '{"codPrestador": '|| '"' || otros."codPrestador" || '"' 
	   ||',"numAutorizacion": '|| '"' || CASE WHEN trim(otros."numAutorizacion") is null THEN 'null' ELSE otros."numAutorizacion"  END || '"'		
  		',"idMIPRES": ' || '"'   ||CASE WHEN trim(otros."idMIPRES") is null THEN 'null'  WHEN trim(otros."idMIPRES") = null THEN 'null' WHEN trim(otros."idMIPRES") = '' THEN 'null'  ELSE otros."idMIPRES"  END|| '"'  
	||',"fechaSuministroTecnologia": '|| '"' || substring(cast(otros."fechaSuministroTecnologia" as text), 1,16) || '"'  
	 	||',"tipoOs": '|| '"' ||ripsTipo.codigo || '"'	
		||',"codTecnologiaSalud": '|| '"' || ripsCums.cum || '"'	
		||',"nomTecnologiaSalud": '|| '"' ||substring(otros."nomTecnologiaSalud",1,60)  || '"'	
	   ||',"cantidadOS": '||  otros."cantidadOS" ||'	'
	||',"tipoDocumentoIdentificacion": '|| '"' || ripsTiposDoc.codigo  || '"'		
	||',"numDocumentoIdentificacion":  '|| '"' || CASE WHEN trim(otros."numDocumentoIdentificacion") is null THEN 'null' ELSE otros."numDocumentoIdentificacion"  END  || '"'		
	||',"vrUnitOS": '|| otros."vrUnitOS"   || ''		
	||',"vrServicio": '|| otros."vrServicio"   || ''		
	||',"tipoPagoModerador": '|| '"' || case when modera.codigo is null then 'null' else modera.codigo end   || '"'		
	||',"valorPagoModerador": '||  CASE WHEN trim(cast(otros."valorPagoModerador" as text)) is null THEN 0 ELSE otros."valorPagoModerador"  END  || ''
	||',"numFEVPagoModerador": '|| '"' || otros."numFEVPagoModerador" || '"'
	||',"consecutivo": '||  otros."consecutivo" ||'	},'
	INTO valorOtrosServicios
	from rips_ripstransaccion ripstra
	inner join rips_ripsotrosservicios otros on (otros."ripsTransaccion_id" = ripstra.id)
	left join rips_ripscums ripsCums on (ripsCums.id = otros."codTecnologiaSalud_id" )
	inner join rips_ripstipootrosservicios ripsTipo on (ripsTipo.id = otros."tipoOS_id" ) 
	left join rips_ripstipospagomoderador modera on (modera.id=otros."tipoPagoModerador_id")
	inner join rips_ripstiposdocumento ripsTiposDoc on (ripsTiposDoc.id = otros."tipoDocumentoIdentificacion_id" )
	   where  ripstra."ripsEnvio_id" = envioRipsId AND  ripstra."numFactura" = cast(facturaId as text) AND (otros."valorGlosado" > 0 or otros."valorGlosado" is null) and otros.consecutivo = i; 

    raise notice 'valorOtrosServicios: %s' , valorOtrosServicios;
	valorJson = valorJson ||' '||valorOtrosServicios;
	raise notice 'contador: %s' , contador;
    raise notice 'Detalle JSON OTROS_SERVICIOS ACUMULADO: %s' , valorJson;
	contador := contador +1;

	end if;

	   if (tipo = 'GLOSA') then 

		SELECT '{"codPrestador": '|| '"' || otros."codPrestador" || '"' 
	   ||',"numAutorizacion": '|| '"' || CASE WHEN trim(otros."numAutorizacion") is null THEN 'null' ELSE otros."numAutorizacion"  END || '"'		
  		',"idMIPRES": ' || '"'   ||CASE WHEN trim(otros."idMIPRES") is null THEN 'null'  WHEN trim(otros."idMIPRES") = null THEN 'null' WHEN trim(otros."idMIPRES") = '' THEN 'null'  ELSE otros."idMIPRES"  END|| '"'  
	||',"fechaSuministroTecnologia": '|| '"' || substring(cast(otros."fechaSuministroTecnologia" as text), 1,16) || '"'  
	 	||',"tipoOs": '|| '"' ||ripsTipo.codigo || '"'	
		||',"codTecnologiaSalud": '|| '"' || ripsCums.cum || '"'	
		||',"nomTecnologiaSalud": '|| '"' ||otros."nomTecnologiaSalud"  || '"'	
	   ||',"cantidadOS": '||  otros."cantidadOS" ||''
	||',"tipoDocumentoIdentificacion": '|| '"' || ripsTiposDoc.codigo  || '"'		
	||',"numDocumentoIdentificacion":  '|| '"' || CASE WHEN trim(otros."numDocumentoIdentificacion") is null THEN 'null' ELSE otros."numDocumentoIdentificacion"  END  || '"'		
	||',"vrUnitOS": '|| otros."vrUnitOS"   || ''		
	||',"vrServicio": '|| CASE WHEN otros."notasCreditoGlosa" is null then 0  ELSE otros."notasCreditoGlosa" end  || ''		
	||',"tipoPagoModerador": '|| '"' || case when modera.codigo is null then 'null' else modera.codigo end   || '"'		
	||',"valorPagoModerador": '||  CASE WHEN trim(cast(otros."valorPagoModerador" as text)) is null THEN 0 ELSE otros."valorPagoModerador"  END  || ''
	||',"numFEVPagoModerador": '|| '"' || otros."numFEVPagoModerador" || '"'
	||',"consecutivo": '||  otros."consecutivo" ||'	},'
	INTO valorOtrosServicios
	from rips_ripstransaccion ripstra
	inner join rips_ripsotrosservicios otros on (otros."ripsTransaccion_id" = ripstra.id)
	left join rips_ripscums ripsCums on (ripsCums.id = otros."codTecnologiaSalud_id" )
	inner join rips_ripstipootrosservicios ripsTipo on (ripsTipo.id = otros."tipoOS_id" ) 
	left join rips_ripstipospagomoderador modera on (modera.id=otros."tipoPagoModerador_id")
	inner join rips_ripstiposdocumento ripsTiposDoc on (ripsTiposDoc.id = otros."tipoDocumentoIdentificacion_id" )		   
    where  ripstra."ripsEnvio_id" = envioRipsId AND ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" = cast(facturaId as text)  and ripstra.id=transaccionid    and otros.consecutivo = i;

    raise notice 'valorOtrosServicios: %s' , valorOtrosServicios;
	valorJson = valorJson ||' '||valorOtrosServicios;
	raise notice 'contador: %s' , contador;
    raise notice 'Detalle JSON valorOtrosServicios ACUMULADO: %s' , valorJson;
	contador := contador +1;

	end if;

	   if (tipo = 'NOTA CREDITO') then 

		SELECT '{"codPrestador": '|| '"' || otros."codPrestador" || '"' 
	   ||',"numAutorizacion": '|| '"' || CASE WHEN trim(otros."numAutorizacion") is null THEN 'null' ELSE otros."numAutorizacion"  END || '"'		
  		',"idMIPRES": ' || '"'   ||CASE WHEN trim(otros."idMIPRES") is null THEN 'null'  WHEN trim(otros."idMIPRES") = null THEN 'null' WHEN trim(otros."idMIPRES") = '' THEN 'null'  ELSE otros."idMIPRES"  END|| '"'  
	||',"fechaSuministroTecnologia": '|| '"' || substring(cast(otros."fechaSuministroTecnologia" as text), 1,16) || '"'  
	 	||',"tipoOs": '|| '"' ||ripsTipo.codigo || '"'	
		||',"codTecnologiaSalud": '|| '"' || ripsCums.cum || '"'	
		||',"nomTecnologiaSalud": '|| '"' ||otros."nomTecnologiaSalud"  || '"'	
	   ||',"cantidadOS": '||  otros."cantidadOS" ||''
	||',"tipoDocumentoIdentificacion": '|| '"' || ripsTiposDoc.codigo  || '"'		
	||',"numDocumentoIdentificacion":  '|| '"' || CASE WHEN trim(otros."numDocumentoIdentificacion") is null THEN 'null' ELSE otros."numDocumentoIdentificacion"  END  || '"'		
	||',"vrUnitOS": '|| otros."vrUnitOS"   || ''		
	||',"vrServicio": '||  CASE WHEN otros."notasCreditoOtras" is null then 0  ELSE otros."notasCreditoOtras" end || ''		
	||',"tipoPagoModerador": '|| '"' || case when modera.codigo is null then 'null' else modera.codigo end   || '"'		
	||',"valorPagoModerador": '||  CASE WHEN trim(cast(otros."valorPagoModerador" as text)) is null THEN 0 ELSE otros."valorPagoModerador"  END  || ''
	||',"numFEVPagoModerador": '|| '"' || otros."numFEVPagoModerador" || '"'
	||',"consecutivo": '||  otros."consecutivo" ||'	},'
	INTO valorOtrosServicios
	from rips_ripstransaccion ripstra
	inner join rips_ripsotrosservicios otros on (otros."ripsTransaccion_id" = ripstra.id and otros."numFEVPagoModerador" = cast(ripstra."numFactura" as text))
	left join rips_ripscums ripsCums on (ripsCums.id = otros."codTecnologiaSalud_id" )
	inner join rips_ripstipootrosservicios ripsTipo on (ripsTipo.id = otros."tipoOS_id" ) 
	left join rips_ripstipospagomoderador modera on (modera.id=otros."tipoPagoModerador_id")
	inner join rips_ripstiposdocumento ripsTiposDoc on (ripsTiposDoc.id = otros."tipoDocumentoIdentificacion_id" )		   
    where  ripstra."ripsEnvio_id" = envioRipsId AND ripstra."ripsEnvio_id" = envioRipsId and ripstra."numNota" = cast(facturaId as text) and ripstra.id=transaccionid AND  otros.consecutivo = i;

    raise notice 'valorOtrosServicios: %s' , valorOtrosServicios;
	valorJson = valorJson ||' '||valorOtrosServicios;
	raise notice 'contador: %s' , contador;
    raise notice 'Detalle JSON valorOtrosServicios ACUMULADO: %s' , valorJson;
	contador := contador +1;

	end if;

	end loop;

	mide := length(valorJson);
	RAISE NOTICE 'mide = %s' , mide ;
	SELECT SUBSTRING(valorJson,1, mide-1) INTO valorJson;	
	valorJson = valorJson || ']' ;

else
	 valorJson = valorJson || ']' ; 
end if;

RAISE NOTICE 'VALOR OTROS SERVICIOS = %s' ,valorOtrosServicios ;

raise notice 'Va TOTAL JSON OTROS SERVICIOS: %s' , valorJson;

-- Fin Rips Otros servicios

valorJson = valorJson ||'}}]}]';
 
	SELECT REPLACE (valorJson, '""', '')
	into valorJson;

	SELECT REPLACE (valorJson, '"null"', 'null')
	into valorJson;

   RETURN valorJson ;
END 

$BODY$;

ALTER FUNCTION public.generafacturajsonbak1(numeric, numeric, character varying, numeric)
    OWNER TO postgres;


-- tercera function




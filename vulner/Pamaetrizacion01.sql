select * from triage_triage;
select * from seguridad_perfilesgralusu
select * from seguridad_perfilesusu
select * from seguridad_perfilesclinica order by id
select * from seguridad_modulos
select * from clinico_servicios
select * from contratacion_convenios
	select  * from sitios_sedesclinica;
select * from sitios_serviciossedes
select * from sitios_subserviciossedes

delete  from sitios_serviciossedes
select * from rips_ripstipousuario;
select * from usuarios_tiposusuario
INSERT INTO usuarios_tiposusuario (nombre,"fechaRegistro","estadoReg") values ('PACIENTE COMUN','2025-12-22 00:00:00','A')	
INSERT INTO usuarios_tiposusuario (nombre,"fechaRegistro","estadoReg") values ('HABITANTE DE CALLE','2025-12-22 00:00:00','A')	
INSERT INTO usuarios_tiposusuario (nombre,"fechaRegistro","estadoReg") values ('RECLUIDO EN CENTRO','2025-12-22 00:00:00','A')	
INSERT INTO usuarios_tiposusuario (nombre,"fechaRegistro","estadoReg") values ('POBLACION INDIGENA','2025-12-22 00:00:00','A')	
INSERT INTO usuarios_tiposusuario (nombre,"fechaRegistro","estadoReg") values ('POBLACION DESPLAZADA','2025-12-22 00:00:00','A')	
INSERT INTO usuarios_tiposusuario (nombre,"fechaRegistro","estadoReg") values ('MAYORES DE 60 AÑOS','2025-12-22 00:00:00','A')	
INSERT INTO usuarios_tiposusuario (nombre,"fechaRegistro","estadoReg") values ('GESTANTES','2025-12-22 00:00:00','A')	


select * from usuarios_usuarios
select * from contratacion_convenios
select * from tarifarios_tipostarifaproducto order by id
select * from tarifarios_tipostarifa order by id
select * from tarifarios_tarifariosprocedimientos;
select * from tarifarios_tarifariossuministros;

select * from facturacion_conceptos

select * from tarifarios_tarifariosdescripcion  where "tiposTarifa_id" = 4;

delete from tarifarios_tarifariosdescripcion
select * from tarifarios_tipostarifaproducto

select tarproc.id id, tiptar.nombre tipoTarifa, exa."codigoCups" cups, tarproc."codigoHomologado" codigoHomologado, exa.nombre exaNombre, tarproc."colValorBase", tarproc."colValor1", tarproc."colValor2" , tarproc."colValor3" , tarproc."colValor4"    , tarproc."colValor5"   , tarproc."colValor6"   , tarproc."colValor7"   , tarproc."colValor8"    , tarproc."colValor9" , tarproc."colValor10" from tarifarios_tipostarifaProducto tarprod, tarifarios_tipostarifa tiptar, tarifarios_TarifariosDescripcion tardes, tarifarios_tarifariosprocedimientos tarproc, clinico_examenes exa where tarprod.id = tiptar."tiposTarifaProducto_id" and tiptar.id = tardes."tiposTarifa_id" and tarproc."tiposTarifa_id" = tiptar.id and tardes.columna='colValorBase' and exa.id = tarproc."codigoCups_id" and tarproc."tiposTarifa_id" ='6'

select * from clinico_examenes order by id
select * from clinico_tiposexamen order by id
select * from facturacion_conceptos order by id;

select * from clinico_tiposradiologia
delete from clinico_examenes where id>= '4'
select * from tarifarios_estancias;

select * from clinico_especialidades;
select * from clinico_frecuenciasaplicacion
select * from clinico_formasfarmaceuticas

select * from planta_planta
select * from clinico_especialidadesmedicos
select * from clinico_medicos

SELECT particular,* FROM CONTRATACION_CONVENIOS
UPDATE CONTRATACION_CONVENIOS SET particular='S' where id=2

select * from clinico_historia;

select * from facturacion_suministros order by id

select * from tarifarios_tipostarifaproducto order by id
select * from tarifarios_tipostarifa order by id
	
select * from tarifarios_tarifariossuministros
select * from tarifarios_tarifariosdescripcion
select * from tarifarios_tarifariosdescripcion 
delete from tarifarios_tarifariosdescripcion where id=20

select * from clinico_historia
select * from contratacion_convenios

select * from enfermeria_enfermeriatipoorigen
	select * from enfermeria_enfermeriatipomovimiento
	select * from facturacion_liquidacion
select "tipoDoc_id", documento_id, "consecAdmision",  * from facturacion_liquidacion	
	select examen_id,* from facturacion_liquidaciondetalle
	select * from clinico_examenes where id=113

select * from farmacia_farmacia
select * from contratacion_convenios
select * from tarifarios_tarifariosdescripcion
	select * from facturacion_conveniospacienteingresos
	

SELECT conv.convenio_id id ,exa.cums cums, sum."colValorBase" tarifaValor 
FROM facturacion_conveniospacienteingresos conv, tarifarios_tarifariosdescripcion des, tarifarios_tarifariossuministros sum,
	facturacion_suministros exa, contratacion_convenios conv1 , tarifarios_tipostarifa tiptar
WHERE conv."tipoDoc_id" = '4' AND conv.documento_id = '1' AND conv."consecAdmision" = '0' 
	AND conv.convenio_id = conv1.id AND des.id = conv1."tarifariosDescripcionSum_id" AND sum."codigoCum_id" = exa.id 
	And exa.id = '113' AND des."tiposTarifa_id" = tiptar.id and sum."tiposTarifa_id" = tiptar.id


-- particular

	select * from tarifarios_tarifariossuministros where "codigoCum_id" = 113
select * from clinico_examenes where id = 113
	select * from farmacia_farmaciadetalle
	select * from farmacia_farmaciadespachos
	SELECT * FROM facturacion_suministros where id = 2909
	select * from tarifarios_tarifariossuministros where "codigoCum_id" = 2909
	SELECT * FROM tarifarios_tipostarifa
	SELECT * FROM tarifarios_tarifariosdescripcion ORDER BY ID
SELECT * FROM contratacion_convenios
	UPDATE contratacion_convenios SET "tarifariosDescripcionSum_id" = 27  where id=2
	
SELECT conv1.id id ,exa.cums cums, sum."colValorBase" tarifaValor , sum."tiposTarifa_id" , tiptar.id
FROM tarifarios_tarifariosdescripcion des, tarifarios_tarifariossuministros sum,
	facturacion_suministros exa, contratacion_convenios conv1 , tarifarios_tipostarifa tiptar
WHERE conv1.id = '2'   AND des.id = conv1."tarifariosDescripcionSum_id" AND sum."codigoCum_id" = exa.id 
	And exa.id = '2909' AND des."tiposTarifa_id" = tiptar.id and sum."tiposTarifa_id" = tiptar.id

SELECT * FROM CLINICO_tiposexamen	
SELECT "TiposExamen_id",* FROM CLINICO_EXAMENES where "TiposExamen_id" = 1

SELECT * FROM sitios_serviciossedes
SELECT * FROM sitios_SUBserviciossedes

	select * from clinico_servicios

SELECT sub.id id ,sub.nombre nombre 
	FROM sitios_serviciosSedes sed ,sitios_subserviciossedes sub , clinico_servicios serv
	Where sed."sedesClinica_id" = '1' and sed."sedesClinica_id" = sub."sedesClinica_id" and sed.id = sub."serviciosSedes_id" 
	and serv.id = '2' and sub."serviciosSedes_id" = sed.id and serv.id = sed.servicios_id
 
select * from clinico_historia
	select * from sitios_historialdependencias
select * from rips_ripsDestinoUsuarioEgresoRecienNacido
	- faltas estas dos
select * from rips_ripsdestinoegreso
select * from rips_ripscausaexterna

select * from clinico_servicios
select * from admisiones_ingresos

	select * from clinico_tiposexamen
select * from clinico_examenes where nombre like ('%ANDROSTERONA%')
	select * from clinico_examenes order by id

select * from tarifarios_tipostarifa
select * from facturacion_conceptos

select * from tarifarios_tarifariosprocedimientos order by id desc
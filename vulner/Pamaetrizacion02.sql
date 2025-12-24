select * from cartera_tiposglosas;
select * from cartera_tipospagos
select * from cartera_tiposnotascredito;
select * from cartera_motivosglosas;
select * from cartera_estadosglosas;
select * from cartera_formaspagos
select * from basicas_tiposfamilia
select m.id id, m.nombre nombre , m.nomenclatura nomenclatura, m.logo logo, modeledef.nombre nombreOpcion ,elemen.nombre nombreElemento
	from seguridad_modulos m, seguridad_perfilesgralusu gral, planta_planta planta, seguridad_perfilesclinica perfcli, 
	seguridad_perfilesclinicaopciones perfopc, seguridad_perfilesusu perfdet, seguridad_moduloselementosdef modeledef,
	seguridad_moduloselementos elemen
	where planta.id= 1 and  planta.id = gral."plantaId_id" and gral."perfilesClinicaId_id" = perfcli.id and
	perfcli."modulosId_id" = m.id and gral.id = perfdet."plantaId_id" and perfdet."perfilesClinicaOpcionesId_id" = perfopc.id
	and perfopc."perfilesClinicaId_id" =perfcli.id and  perfopc."modulosElementosDefId_id" = modeledef.id and
	elemen.id = modeledef."modulosElementosId_id"  and planta.documento = '19465673' AND
	gral."plantaId_id"=planta.id AND planta."sedesClinica_id"='1'


	select * from "Administracion_imhotep_sedesreportes"
	
select * from sitios_sedesclinica
select usuarios.cod_usuario  as usuario 
from "Administracion_mae_repusuarios" usuarios, "Administracion_imhotep_sedesreportes" sedes
where  usuarios.estadoReg =  'A' and  usuarios.cod_usuario = '19465673' and usuarios.cod_sede_id = sedes.id
	and sedes.codreg_sede = '1'

	select * from "Administracion_mae_repusuarios"
	select * from "Administracion_mae_reportes"

select usuarios.cod_usuario  as usuario 
from "Administracion_mae_repusuarios" usuarios, sitios_sedesclinica sedes
where  usuarios.estadoReg =  'A' and  usuarios.cod_usuario = '19465673' and usuarios.cod_sede_id = sedes.id
	and sedes.id = '1'

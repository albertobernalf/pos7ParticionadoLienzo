0. Se debe borrar pos7Particionado Actual
1. Crear Maquina Virtual pos7Particionado
2. activar mq virtual msdos
3. requeriments.bat
4. CreaAplicativoDjango.bat
5. CreaAplicativoDjangoChivos.bat
6. copia carpetas static/templates/media/JSONCLINICA	
7. crea bd vulner7Particionado
8. copy vulner/settings.py, url.py pos7Particionado
9. python manage.py makemigrations
10. python manage.py migrate
11. create superusuario admin
12. ejecuta /import_datos_global_1	
13. ejecutar insert NO APLICA
14. ejecuta /import_datos_global_2
15. adiciones	
16. Crear Funciones CARPETA:C:\EntornosPython\pos7ParticionadoLienzo\vulner\Funciones

	
-- ADICIONES:	
-- INSERT NO APLICA
select * from clinico_grupos	

insert into clinico_grupos (grupo,nombre,"fechaRegistro","estadoReg") values (1,'NO APLICA','2025-12-11','A');
insert into clinico_subgrupos (nombre,"fechaRegistro","estadoReg", grupo_id) values ('NO APLICA','2025-12-11','A',1);
insert into rips_ripsdci (codigo,nombre) values ('No', 'NO APLICA')
insert into clinico_tiposexamen (nombre,"estadoReg") values ('CONSULTAS','A');
insert into rips_ripstiposdocumento (codigo, nombre) values ('RC','REGISTRO CIVIL');
insert into rips_ripstiposdocumento (codigo, nombre) values ('NI','NIT');
insert NO APLICA A TABLA clinico_MedicamentosDci, hacerlo por admin de django 

-- FIN INSERT NO APLICA

-- pendiente subir clinico_examenes
-- cuando cree de nuevo la instancia volver a pulir data hasta dejar impecable OBJETIVO	
-- Se deben parametrizar los serviciossedes, subserviciosesdes, dependencias, seguridadperfilesclinica(creo), perfilesgralusu, salas (de pronto) , Tarifariosprocedimientos y tarifariosuministros, debe haber
  algo mas basico que tambien sea necesadio subir

	
-- seguimos con seguridad
select * from sitios_sedesclinica
select * from seguridad_modulos
select * from seguridad_moduloselementos
select * from seguridad_perfiles
	select *from sitios_dependencias


select * from seguridad_moduloselementosdef
select * from seguridad_perfilesclinica
select * from seguridad_perfilesgralusu
select * from seguridad_perfilesopciones
select * from seguridad_perfilesusu
	select * from sitios_departamentos

select * from sitios_ciudades
select * from usuarios_usuarioscontacto

-- DERSDE AQUIP

select * from sitios_bodegas
select * from sitios_centros
select * from sitios_dependencias
select * from sitios_dependenciastipo
select * from sitios_localidades
select * from sitios_salas
select * from sitios_serviciosadministrativos
select * from sitios_serviciossedes
select * from sitios_tipossalas
select * from sitios_ubicaciones
 select * from clinico_examenes where id in (4027,4028,4029,4030,4031,4032)
select * from tarifarios_estancias
select * from tarifarios_gruposqx 
select * from tarifarios_minimoslegales
select * from tarifarios_tablahonorariosiss
select * from tarifarios_tablahonorariossoat
select * from tarifarios_tablamaterialsuturacuracion
select * from tarifarios_tablamaterialsuturacuracioniss
	
select * from tarifarios_tablasalasdecirugia
select * from tarifarios_tablasalasdecirugiaiss
select * from tarifarios_tarifariosdescripcion
	
select * from tarifarios_tarifariosdescripcionhonorarios
select * from tarifarios_estancias
	
select * from tarifarios_tarifariosprocedimientos
select * from tarifarios_tarifariosprocedimientoshonorarios
select * from tarifarios_tarifariossuministros
select * from tarifarios_tarifariostipohonorarios

	
select * from tarifarios_tipostarifa
select * from tarifarios_tipostarifaproducto
select * from clinico_servicios
select * from sitios_sedesclinica
	select * from sitios_paises
select * from sitios_dependenciastipo

select * from tarifarios_tablahonorariosiss
select * from tarifarios_tablahonorariossoat

 select * from tarifarios_tarifariosprocedimientoshonorarios

select * from sitios_ubicaciones
select * from sitios_departamentos
select * from rips_ripsmunicipios
select * from sitios_ciudades
select * from clinico_examenes
select * from clinico_tiposexamen
select * from facturacion_conceptos
select * from tarifarios_gruposqx
select * from tarifarios_tiposhonorarios
select * from clinico_tiposradiologia
select * from clinico_tiposexamen
select * from facturacion_tipossuministro
delete from clinico_examenes
select * from clinico_examenes
select * from facturacion_conceptos
--delete from facturacion_conceptos
select * from clinico_nivelesregimenes
select * from clinico_regimenes
delete from clinico_nivelesregimenes
	select * from facturacion_tiposempresa
select * from facturacion_empresas

select * from rips_ripstiposdocumento
SELECT * FROM USUARIOS_TIPOSDOCUMENTO
SELECT * FROM SITIOS_DEPARTAMENTOS
SELECT * FROM SITIOS_municipios



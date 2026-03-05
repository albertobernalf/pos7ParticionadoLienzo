
2. No eta UPDATE /INSERT de ls campos manilla, acompanatete, responsable remitido ips 
                         contactoAcompanante_id = contactoAcompanante,
                         contactoResponsable_id = contactoResponsable,
3. Ojo recuerda los permisos punuales DESACTIVAR / INACTIVAR Botones
Tablas = tblhcl_ingresos ( es la parte clinica del accidente)
Tablas= tbl_furips ( Es como la parte legal de datos)
Podria ser FuripsClinico, FuripsLegal
6. algo pasda con el grid de revsion de sistemas/historia clinica
   ojo calcular numero dias en incapacidad y solo readonly el campo numDIas
  -- Procesos de Calculo para Tarifas (Se debe crear aplicativo, que actualize en tabla Tarifas , LiquidacionHonorarios)

        La tabla TarifasSuministros creo desaparece


	a) Se consulta el convenio del paciente y el tipo de tarifa que maneja el convenio del paciente
        b) Se va al detalle del convenio, se consulta el CUPS A calcular
           b) Si es SOAT

              Es cirugia : El liquidacionHonorarios se buscan los tiposhonorarios: medico,anestesiologo,audante
			   Se liquidan los Derechos de Sala
			   Se liquidan los materilaes de SUTURA
			   

	      No es cirugia: se busca en examenes el gruppoqx, se ubica en la tabla tarifas y en examenes se busca el grupoQx se actualzian salmingel minlegaño y valorSoat

	      Se liquidan los medicamentos
	      Se liquida el oxigeno
	
				 
 	   c) Si es ISS2001

	     Es cirugia : De acuerdo tabla HonorariosIss creo

                        Se liquidan el Honorario Profesional,, de acuerdo a la tabla HonorariosIss
			Se liquida el honorario Anestesilogo ,, de acuerdo a la tabla HonorariosIss
 			Se liquida el honorario Ayudante ,, de acuerdo a la tabla HonorariosIss
			Se liquidan Derechos de Sala, creo tabla liquidacionHonorarios
			Se liquida los materiales de sutura y curacion creo tabla de acuerdo a la tabla HonorariosIss y se graban en la tabla LiquidacionHonorarios
			Se liquida oxigeno  ??? Crear esto como un honorario

	    No es Cirugia, es Procedimiento

			Crea en la tabla Tarifas se consulta, se crea alli creo.-

 			  (Se busca en la tabla examenes, el codigoCups_id 
			   y se compara la cantidad de uvr del proced con minUvr, maxUvr de la tabla TarifasIss
                           y de acuerdo a cada tipo de honorario, se extracta el valor en uvr * el valoruvrAño y
                          de acuerdo a cada tipo de honorario y yap y se guarda en liquidacionHonorarios)



           Se liquidan los medicamentos , creo en la tabla Tarifas, pues sacamosTarifasSuministros
	   Se liquida el oxigeno, estop de donde ????



	   d) Particular


	      Si es cirugia

			 Es Honorario Profesional
			 Es honorario anestesiologo
			 Es honoraro ayudante
			 Es material de sautura y/o curacion
			 Es sala de Cirugia
			
			(Se busca en la tabla LiquidacionHonorarios el codigoCups_id de acuerdo a la tabla examenes
                        y ser guarda en liquidacionHonorarios y de acuerdo al tipo de honorario)
	     Si no es cirugia
			  (Se busca en la tabla tarifas.Tarifas el valorPropio)
                       
	   e) Propias

  			 Es Honorario Profesional
			 Es material de sautura y/o curacion
			 Es sala de Cirugia

			(Se busca en la tabla LiquidacionHonorarios el codigoCups_id de acuerdo a la tabla examenes
                         y de acuerdo al Valor se liquida y de acuerdo al tipo de honorario)

		  Si No existe Grupo Qx, o hay un valorPropio en la tabla Tarifas para el Cups en cuestion:	

			  (Se busca en la tabla tarifas.Tarifas el valorPropio)                  

  -- Procesos de Calculo para traer convenio - tarifa (Aqui ya esta todo calculado, solo es leer ele valor)

  -- Orden Procesos de Tarifacion , convenios , Soat, Iss

     -- ops al anular una liquidaciondetalle no me actualizar totalLiquidacion, nip ValorApagar

-----------------------------------------------------------------------------------------------------------------------
--  GLOSAS
-----------------------------------------------------------------------------------------------------------------------
IDEAS MODULOS SUBSIGUIENTES:
En admisiones, autorizacion para el manejop de datos . CLausulas

Modulos:
	CERO MODULO
	Generacion de factura
        Impresion de factura
	Generacion de xml
	Generacion de pronto JSON
	Generacion y envio a la DIAN

        PRIMER MODULO:
        Rips sobre Facturas APROBADAS POR LA DIAN , (entregas querys automaticos)
	Se pueblan las tablas de RIPS con los datos de las Facturas
        Generacion JSON conjunto de RIPS para el ministeriop de salud  a partir de la Facturacion
        Recepcion repuesta JSON RIPS del ministerio de salud  a partir de la Facturacion

        SEGUNDO MODULO:
	Radicacion de la factura APROBADA POR LA DIAN y con RIPS se rtadican ante el pagador  (son con base en las facturas de la clinica .Lista Radicaciones,Crea Radicacion, adhiere Facturas a las Radic, es el envio de Facturas)

        TERCER MODULO:
	Las glosas son las observaciones que se realizan a los RIPS
	Entonces parece ahora las glosas vienen inspiradas en las tablas de RIPS
        Creo debe haber un modulo o un flag en la factura si esta ACEPTADA o no ACEPTADA por la DIAN y CUFE o algo asi
        Glosas 
        Recepcion Glosa 
	Encabezado glosa : (crea la glosa es el encabezado a partir de la radicacion y proveniente de una EPS), Estas glosas las envias las EPS , se recepcionana NORMALITO 
        Detalle Glosa : Se detalla cada item del RIPS ENVIADO AL MINISTERIO .

        CUARTO MODULO:
        NotasDebito ( Por ejemplo iutems de factura No cobrados . creo nuevas generarla, crearlas)
        NotasCredito por Glosas vienen de las glosas de las EPS
        NotasCredito por Otras notas que no son rips u Glosas

        Creacion Nota Credito de Acuerdo a la Glosa emitida por la EPS
        Las notas credito van solo por valores supongo ??? o con detalle  ???

        Generacion JSON de la Nota Credito para enviar al Ministerio de salud
        Recepcion respuesta JSON notas credito del ministerio de salud

   
    	QUINTO MODULO:
       --> Cartera, (Consultas, reportes)

        Todo lo voy a aterrizar a JSON y XML : RIPS Y Facturacion respectivamente
        A partir de aqui si debo poner a trabajar las solicitudes del Minsterio de salud y l DIAN los cuales se deben manejar comotemas aparte
        Se que hay JSON de Envio
                 JSON de respuesta
                 XML de Envio
                 XML de respuesta
        Los JSON y XML de respuesta ni an se sabe  NOOO es tema inicial. Orden por favor o si no ñucas.

	IDEAS : Todo de pronto bajo el programa de RIPS

	-- Pantalla Generacion de XML , facturacion electronica para la DIAN   PENDIENTE

        -- Pantalla crea envios : Muestra envios existentes / Crea Envios a partir de Facturas sin rips
	-- Pantalla Envio de Rips al ministerio de Salud. Puebla las tablas de Rips y Genera JSON-RIPS (Facturas-Notas Credito)
        -- Pantalla Recepcion de rips ( Respuesta de Rips)

	-- Pantalla Creacion de Glosas a partir de Rips
	-- Pantalla Recepcion de Glosas a nivel de cada Rips-Factura-Item
	-- Pantalla captura de Otras Notas credito
        -- Pantalla captura de Notas Debito


GLOSA RECEPCION
CAPTURA CABEZOTE GLOSA  Selecciona Empresa / Selecciona Envio Rips

---------------------

CAPTURA DETALLE GLOSA: Muestra seleccion de :  Muestra Facturas con rips de la Empresa --> selecciona Factura --> Selecciona RipsTipos --> Selecciona Rips-items

------------
------------
------------
------------
IGUAL CON NOTAS CREDITO
NOTAS DEBITO NOSE EXACTAMENTE

digamos el valor d ela factura inicial nop cambia y los daso de los detalle pueden estar en Faturacion y glosas y notas credito. Mejor no llevarlas desde los RIPS No CREE ?


-----------------------------------------------------------------------------------------------------------------------
--  RIPS 
-----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
--  RADICACIONES
-----------------------------------------------------------------------------------------------------------------------

      -- Radica con FEC y FEV documentos ante los pagadores  de salud (EPS-Entes territoriales, etc)



-- OJJO PARA SELECCIONAR LA PRIMER FILA DE UN TABLE/ PROBAR EN ADMISIONES Y HCLINICA	var $row = $(this).closest('table').children('tr:first');	


// Selecciona el checkbox dentro de la primera fila (suponiendo que está dentro de una celda 'td')
$(primeraFila).find('td input[type="checkbox"]').prop('checked', true);  // Marca el checkbox con jquery

-- creo que tengo erorres en empresa_id en contratacion_convenios, facturacion_facturacion, ripsenvios, verificar


-- ojooooooo OBLIGAR A GUARDAR MUNICIPIO, LOCALIDAD, PAIS DESDE ADMISIONES, TRIAGE  (Ops estop lo veo bien PROBAR DE NUEVO)

-- OJO CREAR CONTROL que borre si el rips esta creado y volverlo a crear
-- ojo crear control si ya esta ENVIADO EL RIPS , no dejarlos enviar nuevamente

--> ojo verificar de nuevo no me gusta ver la empresa por elos conveios de contratacion, deberia ser por admisiones_ingresos en lel campp empresa_id , cambiar esto VERIFICAR

-- ojo mañana no me libero la cama
-- ojo lunes marzo, seguir verificar todop el proceso con RIPS envio ,factura, JSON con datos de paciente de prueba astrid bernal 
   validaciones, autorizaciomes, medicamentos, mipres, (6) rips  , HISTORIA CLINICA

-- OJAZO CUANDO GUARDFE UNA HOSPIATIZACION y vuine a crear urgencias no me mostro muchos combos
-- ojazo cuando formula en hisotira clinica debe resetaear los controles de la dosis tiodos toditos
-- ojazo creo no cayeron las terapias desde hc a la facturacion_liquidaciondetalle
-- ojazo lunes no se que paso con folio de papa, con fluconazol y terapia. Problema con autorizaiones de medicamento con una terapia junta
-- ops NO ME MUESTRA NI POR EL CHIRAS EN RIPS LA FACTURA QUE ACABO DE HACER DE ASTRID , DE QUE EMPRESA ES ???

        --  En facturacion_facturacion no funciona los fiultro de busqueda por fecha o por nro de factyra
	-- Crear boton modificar envio / Borrar envio

--OJOP en desde clinico.views al enviar Autorizacioines esta rutina revisarla por que creo pailas mete das las autorizacxiones en una sola no se siesta bien
-- OJOPOJOPOJOPOJOP  que paso habia una intruccion para ordenar por todas las columnas que paso =? filtros en tossa QUE LO HIZO M buscalo
--ojo cuando factura debe hacer un refres h a facturacon_facturacion y facturacion_liquidacuioib y quedar en la pantalla facturacion_liquidacion NO CREE ?
-- ojo hay que programar con estadoReg = 'A' solo tome estas en el modulo d efacturtacion y para rips etc. de cuidado ...

PARON 1 SEMANA PENDIENTE
 1. BUSQUEDA POR COLUMNAS JQUERY DATATABLE

$(document).ready(function() {
    var table = $('#example').DataTable();
    
    // Buscar en múltiples columnas
    $('#search').on('keyup', function() {
        table.columns([0, 1, 2])  // Especificar las columnas que quieres filtrar
            .search(this.value)    // Realizar la búsqueda con el valor de input
            .draw();               // Actualizar la tabla
    });
});

// mas avanzado

$(document).ready(function() {
    var table = $('#example').DataTable();
    
    $('#search').on('keyup', function() {
        var searchValue = this.value.split(' '); // Supongamos que los términos de búsqueda están separados por espacios
        
        // Aplica la búsqueda en diferentes columnas
        table
            .columns([0]) // Filtra en la primera columna
            .search(searchValue[0]) // Primer término de búsqueda
            .draw();
        
        table
            .columns([1]) // Filtra en la segunda columna
            .search(searchValue[1]) // Segundo término de búsqueda
            .draw();
    });
});

 2. VENTANAS BOOSTRAP MODAL ELEGANTES
  3. SEGUIR CLINICO.HTML  NUEVOS DATATABLES

-- ops que pasa si deja crearuna glosa sin rips , PAILANDER , ERROR ??? Averiguar
---------------------------
------- tips IMPORTANTE PARA MODULOS DE CONSULTA EXTERNA, AMBULATORIO, INVENTARIOS, FACTURACION------------- LA REUNION FUE BENEFICIOSA PARA MY PROGRAM
------------------------------
1. Bodega virtual inventarios
2. Ingresos citas medicas , ambulatorios. los ingresos son para urgencias hosp generen estancias
3. Tarifas: proced, son pocos SOAT, ISS, PARTICULAR LAS DEMAS SON POR PORCEMNTAGES

   Insumos -- > condiciones una gsas deopende del tamaño de la factuyra etc
4.SISTEMA DE ALERTAS son tareas programadas querys que envian mensajes por correo o wwhtasapp cuando se cumple ago. de prnto usarfunciones
5. descripcion Qx, automatica OPS
6. Ojo el termino FACTURABLE No FACTURABLE
7. que es hoja de gasto
8. oJO RADICAR UN ENVIO es coocar una fecha y yap
9. COmenzar a visualizar hacia el futuro como va a funcionar la aplicacion en cuianto a velocidad, con datos ociosos no usarlos o volverlos HISTORICOS
10. Como inactivar tarifarios. Solo trabajar con los activos. OJOP por la vigencia
--------------------------------
---------------------------------
------------------------------

El lunes 31 de marzo seguir detalle de RIPS

  a) Enviar un rips, colocar usuario y fecha de envio
  b) Radicar un rips , colocar fecha u usuario de radicacion
  c) Un rips enviado y radicado No se puede volver a generar RIPS INTOCABLE
  e) Rips No enviado No es posible glosarlo
  f) Rips Enviado de glosas No se puede modificar

-- Ojo tocar verificar los LOAD_DATA de rips pero en el cartera modulo glosas
-- Una vez haber hecho lo anterior, crear un paciente de ceros y hacerle traza completa
-- OPS creo que me queda faltando algo en generafacturaJSON y envioFacturaJson en cuanto "valorGlosaDo" > 0 en las GLOSAS, algo me late chococlate
--------------------

-- OJO quira en los modelos de roips el default = 0 y quitarlos d elas funciones RIPS generaFacturaJSON y generaEnvioJSON(9

-- DATOS DE REUNION CLUB EL NOGAL

	a) INVENTARIOS: bodegas virtuales
        b) CUPS -INSUMOS : Facturables - No facturable,, Hojas de gasto
	c) SISTEMA DE ALERTAS : Crear con tareas programadas, whatsapp, correos
	d) Particionamiento postgresql 12 --> de acuerdo a EXPLAIN si funciona me imagino pues el costo es diferente, supongo que en la transaccionalidad, bloqueos en conjunto velocidad. Por si solo los vi como iguales 
						a No estar particionado . PROBAR MAS
	e) Tarifarios nuevo programa
	f) falta algo mas ???

---------------
---------- WORK -----
------------------

-- Honorarios: cups.anestesia,cirujano, instriuentador, vias de acceso etc investigar
-- INSERT tarifasprocedimientos x programa, desde excel
-- Crear tarifas variads
-- Como subir aRCHIVOS A TABLÑAS EXCEL desde ´python a tabla tarifariosprocedimientos etc

import pandas as pd
import psycopg2

##############################


import pandas as pd
import psycopg2
from django.db import transaction, DatabaseError

  # Aqui Rutina carga archivo Excel

    archivo_excel = 'c:\\Entornospython\\Pos3\\vulner\\JSONCLINICA\\CargaProcedimientos\\datos1.xlsx'
    df = pd.read_excel(archivo_excel)

    miConexion3 = psycopg2.connect(host="192.168.79.133", database="vulner2", port="5432", user="postgres",  password="123456")
    cur3 = miConexion3.cursor()


    # Crear una sentencia INSERT (ajustar según la estructura de la tabla)

    try:
    for index, row in df.iterrows():
        query = 'INSERT INTO tarifarios_tarifariosprocedimientos ("codigoHomologado", "colValorBase", "fechaRegistro", "estadoReg"  ,"codigoCups_id"  , concepto_id,    "tiposTarifa_id"  ) VALUES (%s, %s, %s, %s, %s, %s, %s)'
        valores = (row["codigoHomologado"], row["colValorBase"], row["fechaRegistro"],row["estadoReg"], row["codigoCups_id"] , row["concepto_id"] ,  row["tiposTarifa_id"] )  
        cur3.execute(query, valores)
   	miConexion3.commit()
    except DatabaseError as e:
	transaction.rollback()

    # Cerrar la conexión
    cur3.close()
    miConexion3.close()

    

	for index, row in df.iterrows():




##################################

# Leer el archivo Excel

archivo_excel = 'c:\entornospython\Pos3\vulner\JSONCLINICA\CargaProcedimientos\datos.xlsx'
archivo_excel = 'c:\\Entornospython\\Pos3\\vulner\\JSONCLINICA\\CargaProcedimientos\\datos1.xlsx'

df = pd.read_excel(archivo_excel)

# Conectar a PostgreSQL
conexion = psycopg2.connect(
    host="localhost",
    database="tu_basededatos",
    user="tu_usuario",
    password="tu_contraseña"
)
cursor = conexion.cursor()

# Crear una sentencia INSERT (ajustar según la estructura de la tabla)
for index, row in df.iterrows():
    query = "INSERT INTO nombre_tabla (columna1, columna2, columna3) VALUES (%s, %s, %s)"
    valores = (row['columna1'], row['columna2'], row['columna3'])  # Ajusta las columnas según tu archivo
    cursor.execute(query, valores)

# Confirmar los cambios
conexion.commit()

# Cerrar la conexión
cursor.close()
conexion.close()

print("Datos subidos correctamente.")


-- Ojo en la sabana de creacion de tarifarios---> proc,sum,hono el valorBase debe venr con valñor
-- Crear contratacion- procedimientos, suministros honorarios de CONSULTA
-- Crearv tarifario -- honorarios --> operacion
-- Tablas  a particionar : factutacion, facturaciondetalle, Farmacia, Enfermeria etc
-- A arreglar probar pantañña de tarifas sin MENU Tarifas+ + grande  que quepa info.

-- Actualizar pantalla convenio.
Actualizar SQL FacturacionDetalle  ?? umm cual es este..
BIBLIOGRAFIA:
--Postgresql: particionamiento de tablas usando campos de tipos definidos por el usuario
-- Particion de postgresql    en dyango
-- postgresql particiones en django
--  Mejorar el rendimiento d ela base de datos:partivcionamiento d etablas en dyango y
-- django-postgres-extra
-- crear indices simultaneos en una tabla particionada
-- Las tablas de consulta externa, crean en admisiones_ingresos, el consecutivo = numero de la cita, pasas a liquidacion, liqudaciondetalle, facturacion, facturaciondetalle.
-- trabajar pantallas convenio en facturacion y admisiones

----------------------------------------------------------- PARTICIONES -----------------------------------------------------------------

-- Creo aqui sin utilizar pgmakemigratIons sino NORMALITO
-- Crear tabla particionada maestra
CREATE TABLE mi_tabla_particionada (
    ...
) PARTITION BY RANGE (fecha);

-- Crear particiones individuales
CREATE TABLE mi_tabla_particionada_2023 PARTITION OF mi_tabla_particionada
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE mi_tabla_particionada_2024 PARTITION OF mi_tabla_particionada
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- En Django, se puede modelar con modelos normales
# models.py
from django.db import models

class MiTablaParticionada(models.Model):
    # Define campos aquí
    campo1 = models.CharField(max_length=100)
    fecha = models.DateField()

    class Meta:
        abstract = True # Esto es para no crear una tabla física con este nombre

class MiTablaParticionada2023(MiTablaParticionada):
    pass

class MiTablaParticionada2024(MiTablaParticionada):
    pass


----------------------------------------------------------- FIN PARTICIONES -----------------------------------------------------------------

LINK MIGRACIONES

-- 1. https://medium.com/@akshatgadodia/enhancing-database-performance-table-partitioning-in-django-and-postgresql-using-569ae085ef6a
-- 2. https://www.google.com/search?q=ejemplos+completos+migraciones+de+particiones++en+django&sca_esv=aa650d13515d1176&rlz=1C1CHBF_esCO999CO999&sxsrf=AE3TifOni_VZR5ZcI8Z7tHRibECV-y2WjQ%3A1764598282523&ei=CqItadTYH6CWwbkPgr2qoQQ&ved=0ahUKEwjUhbTuyJyRAxUgSzABHYKeKkQQ4dUDCBE&uact=5&oq=ejemplos+completos+migraciones+de+particiones++en+django&gs_lp=Egxnd3Mtd2l6LXNlcnAiOGVqZW1wbG9zIGNvbXBsZXRvcyBtaWdyYWNpb25lcyBkZSBwYXJ0aWNpb25lcyAgZW4gZGphbmdvMggQABiABBiiBDIFEAAY7wUyCBAAGIAEGKIEMggQABiABBiiBDIFEAAY7wVI7BxQsQdYxBtwAXgAkAEAmAG6AaAByxOqAQQwLjE3uAEDyAEA-AEBmAILoAK5C8ICCxAAGIAEGLADGKIEwgILEAAYsAMYogQYiQXCAgQQIxgnwgIIECEYoAEYwwTCAgoQIRigARjDBBgKwgIEECEYCpgDAIgGAZAGA5IHBDEuMTCgB9VFsgcEMC4xMLgHtwvCBwUxLjguMsgHGA&sclient=gws-wiz-serp
-- 3. https://pganalyze.com/blog/postgresql-partitioning-django  OJOOOOO LA QUE MEDIO HA FUINCIONADO
-- 4. https://pganalyze.com/blog/postgresql-partitioning-django#:~:text=Recuerde%20que%20una%20tabla%20particionada,nombres%20descriptivos%20a%20las%20tablas.&text=Como%20puede%20ver%2C%20los%20registros,se%20encuentran%20en%20cada%20partici%C3%B3n.
      ojo para crear particiones con las migraciones ASI SE HACE OJOPg
-- 5. carga masiva video : https://www.youtube.com/watch?v=D0JxuiVw8j4
-- 6. https://django-postgres-extra.readthedocs.io/en/master/table_partitioning.html
-- 7. https://www.google.com/search?q=no+me+funcionan+tablas+particionadas+con+django+en+postgres+que+otra+opcion+hay&rlz=1C1CHBF_esCO999CO999&oq=no+me+funcionan+tablas+particionadas+con+django+en+postgres+que+otra+opcion+hay&gs_lcrp=EgZjaHJvbWUyBggAEEUYOdIBCjIwMDUwajBqMTWoAgmwAgHxBdBxowMnUMtt&sourceid=chrome&ie=UTF-8
      ojo probar esta opcion el dia diciembre 9 del 2025
-- 8 . django consults lentas:
       https://www.google.com/search?q=no+me+funcionan+tablas+particionadas+con+django+en+postgres+que+otra+opcion+hay&rlz=1C1CHBF_esCO999CO999&gs_lcrp=EgZjaHJvbWUyBggAEEUYOdIBCjIwMDUwajBqMTWoAgmwAgHxBdBxowMnUMtt&sourceid=chrome&ie=UTF-8&udm=50&ved=2ahUKEwiA-fePtqaRAxXvVTABHa88Jk8Q0NsOegQIAxAB&aep=10&ntc=1&mstk=AUtExfDGBx5II2RCaPgUwWspXHUIfIwPEsgF19ZSqh5-Ve72eBr-lcD7PY-QTQwVLYks_9ejeSFQSNukkQ5HgXY9ikxY4oiiO5CodUwtnZJQCgTsua9uYRCoVpfTRQ0YyJ38PmY-BdCRHTSUqijjUt3rw1Ak8wPh5XyNYbO3R6iwHUTewdg6zek8uRyu81M-2Pd_HtFmhs8iB7K7x3WP2LTy3VXHxlgqzRb8BUh1r2lC3HvyeT4yYGFcv77kpsAZvirWSoXMO4yKs_vg5Uu3wbtBwbuS79_QzpPTiVS49TcG6ZIEiqHIBbwqGKsUGbqUmn77KqoQl6u6xZoT7A&csuir=1&mtid=S80yaZWkFJiIwbkP8PvrwQo


--------------------------------------

------------- FIN WORK ---------------
--------------------------------------
-- Ojo validar que al borrar de tarifarios_tarifariosprocedimientos no haya un
   tipostarifa_id relacionado en tarifarios_tarifariosdescripcion
   -- si esta relacionado Nop dejar borrar por que se pierden los
      apuntadores de la tabla contratacion_convenios


-- ojo sanson son diferentes lod querys de admisiones ingresos el que ingresa al que graba una nuevo ingreso OJOOO UNIFICAR   -- PENDIENTE
-- ops en admisiones no sirve crear convenios UNA VEZ CREADA UNA ADMISION , me toco salirme y volver  aentrar para acceder al comBo de convenios ojo
-- Ops ME ESTA DUPLICANDO LÑOS abonos DE CUANDO A CA Y PORTUE


-- mañana 11 / abril
-- 1. No acualizo  anular items de liquidacionDetalle al final del traslado
-- 3. Hacer pruebas d etraslados de suministros que no habian para el caso no recuerdo el motivo VERIFICAR.
-- 4. Todo esto en el supuesto que no hay nada en el nuevo conveio, o sea esta en blmaco. Que pasa si yahay cupscreados allip
-- 7. finalmente ver terminar rips PROBAR 
-- 10 alertas: # e abonos y si o No convenio en admisiones
-- Ojo en las consuiltas d efactyuras por fchar o numeros, como va a hacer con tablas particionadas ???
-- Ojo hay que verificar todos los REFESH cuando hace acciones en toda las pantallas
-- ojo COLOCAR LOS COMODIMTES D ERUTA DEL MODELO PARAMTERO EN : CARGARIPS, CARGAPROCEDIMIENTOS, CARGASUMINISTROS


   - ME mamo gallo y no sep portque en contratacion datatble procprocedimeitnos displaya MAL el valor y5 columnas que pasa weys
  -- ya borre todas las tablas LISTO PARA PRUEBAS MAS COMPLEJAS
      Recuerda facturacionbusquedas-- tablas particionados no por rango de faturas
     - Hay pantallas que estan por vers mas bonitas, pero pailas por mi conocimeintos .css bootsprtyrap html, dejarasi seguir adelante


-- Para el dia Lunes 21 de Abril :

  -- Seguir puesta ba punta historia clinica : Transaccionalidad, velocidad, datatables pequeños,excel izquiera,etc

- OJO al editar una dmision hay erorres por ejemplo si no toca responsables o acompanates los blanquea

-- OPS-REOPS -REOP ERRORES:
	-- CuAndo  pasa de traiage a admision no quita la modal
        -- Cuando pasa de triage a modal se desaparece de la pantalla de facturacion y que va a pasar con los cargos de esa cuenta ??/ Porque esta en la tabla facturacion_liquidacion y liquidcion detalle
                       (YA SE HAY QUE LEVAR LOS CARGOS de la cuenta triage  a la cuenta de habitacion) es ..) facturacion_liquidacion/facturacion_liquidaciondetalle y de pronto carterapagos y crteop convenios
                            Es como un INSERT UN DELETE, y UPDATE PARA ABONOS Y CONVENIOS QUE NO TENGAN NADA APLICADO
            -- anton crea una nueva cuenta ver so es posible por trsalados de cargos
            -- Contemplar un traslado de cargos de una cuenta sin convenio a una cuenta con convenio 
	-- Ojo cuando va a hacer un traslado y no encuentra una descripcion saca erro ver como escribirlo y decirlo a l usuario final que se debe crear el tarifario nuevo a donde se va a trasladar
        -- Ojo el total de los nuevos suministros, proced, liqui a pagar son los del nuevo tarifario OPS ERroR GRAVISSISMOI REVISAR YA ARREGLADO
         -- ops si un paciente tiene dos convenios y al dar salida clinica a una ya no puede facturar la segunda cuenta (colocar control pero a donde OPS)
        -- Al hacer una factura debe dejar en la primera pantallaliquidacion y mostrar el nro de la factura jay que limipiar liquidacion/ abonos/ y traslados
      -- Que pasa con los baono de un lado aotro yo diria se anulan de ua y se pasan alotro ??
     -- ops al facturar a eumelia con dos convenios se le dio salida clinca, pero despues me la saco de la apantalla de liquidacion y no pude facturar la cuneta de compensar COMO LE PARECE GRAVISSISIMO
---  en creacion de usuarios en crear admision debe obligar a llenar 
-- OPS no me trae el amompañamte y el reonsable de la cuenta en paciente sede americas OJOOOOOOOO
  -- en sede americas meti una moderadora aunque mero la cuota moderadora nop actualizo el valor recibido
-- ojo el historial de dependencias fechaLiberacion siempre tiene fecha ALGO PASA esta mal VERIFICAR

-- oJO CUANDO CREA UNA aDMISION LOS indicadores NO LOS TRAE SE PIERDEN
-- AL REFACTURAR como se tratan los abonos SE ANULAN ? Se restaura PENSAR COMO HACER CON ESTO y la ADMISION INGRESO QUE PASA YA NO SE VE ?? O SEA NO VOY A 
-- En contratacion la modal crear convenio crear mensaje de erro modal de la ventana, ver en elmain
-- en glosas falta actualizar el saldo de la factura en la glosa, y enviar la data a glosasdetalle

-- OJO involucrar en todo lados serviciosadministrativos
-- en tarifario ver ventanas modales
-- el comobo servicioisadministrativos en clinico no sale no funciona ??? FALTA AUN, terapeutico (Probar es duro de pelar), autorizaciones, tarifas, contratacion
-- No hay boton para borrar una glosa maluca..--> crearlo
--

-- DOCUMENTOS DE INVENTARIOS : (Factura der compra, Remisiones, Devoluciones, Aprovechamiento, Donaciones, Traslados, Notas Debito, Inventarios) (Notas credito, despacho a servicios , hoja de gastos)
-- ENFERMERIA YO CREO ELLAS CREAN FOLIO por HC y debe habier un modulo para: 1) Mostart pacientes hosp,urge,amb, 2) pantalla m,uestra todos los estidos delapciente, medicamen,paraclini,notas, etc
  -- 3) pantalla para Aplicar medicamentos, pantalla devolucion de insumos y medicamentos a farmacia)


 -- CONSULTA EXTERNA : Modulos: Citas medicas (Agendas Medicas, consultorios, Programacion de citas)
                       TABLAS: agendasMedicas(Para asignar medicos a consultorios por dias, medico,especialidad,dia,hora,duracion_cita), Consultorios ( para crear dispoibilidad por dias en consul), citasMedicas (cabezote citas medicas,
			Fecha-Hora de reserva, Fecha-Hora solicitada, fecha-hora-atencion-fecha hora cancelada,  agendamedica_id, estadoCita
, citasMedicasDetalle (citamedica_id, codigoCups_id), EstadosCitasMedicas (Reservada,Confirmada,Atendida,Facturada,Cancelada)
				EstadosConsultorios (Por Asignar, Asignado, Mantenimiento)
				Utilizar medicosEspecialidad, creo se llama , relaciona con planta_id , especialidad_id
			       programacionCitasMedicas (dia,nes.año,consultorio,agenda_id), historicoCitasMedicas(tipodoc,documento_id,consecAdmision, citamedica, factura, agenda_id,estado)
				TrasladosCitasMedicas()
				admisiones.ingresos se realiza el ingreso comenzando citaNo 1000000
				Por el modulo de Historia Clinica se evoluciones paciente
				Cuando se atinede cae a la facturacion el cups de la cita medica) o al medio dia en la noche se cancela la cita medica.
				El medico de consulta externa permisoa Historia Clinicas y Consulta Externa(aparecena las citas medicas del dia asignadas para el medico)


-- En cirugia: cuando sale error de horario sala verificar :
  -- colocar la fecha en los calkendarios
 --  debe validar tosad las cirugias expto la corriente
 -- No me gusta el color rojo del error
  - no me gusta que no cierra la ventana


-- Ojo no debe dejar crear mas de una programacion de cirugia para el mismo ingreso. CONTROLAR ???? COMO HACER ESTE PUNTO
-- OJO colocar mañana los iconos de cambiar estados : programacion y cirugia, hacer modales y funciones que graben 
-- agregar campo folio en cirugia_cirugias donde quede el folio cuando es creada desde folio del paciente

-- OJO revizar toda la traza clinica de medico-especialidad, debe haber errores- combos etc.

-- Para generar estanciass automaticas el dia de ingreso cuenta pero el de salida no cuenta, por lo tanto se crea un dia de estancia
   -- o por wwue ingreso o un dia anterior asumisndo que el dia de hoy o actual va a salir de la clincia o egreso clinico

-- Hay un error en participanmtesInforme, porque no selecIndex=0 NOP funciona, para que no asocia con otro que no sea cirujano y guarde en blanco el honorario
-- ops eumelia documento_id = 16, esta con salida clinica y fecha de salida y no sale en ADMISIOENS pero si me dejo CREARLE UNA CIRUGIA QUE PASO ALLI´??? el query de INGRESOS EN CLINICA DESDE CIRUGIA ÁRA VER CANDIDATOS A CREARSOLICITUDES DE CIRUGIA
  -- TENGO LIO ALLI VERIFICAR EL LUNES 19/mayo ,, OPS AHORA ME SALNE DOBLE VALIDAR
-- OJO EL LUNES 19, TRABAJAR DES LIQUIDACION SALAS DE CIRUGIA/MATERIALES ISS Y LUEGO SI SEGUIR CON SOAT, acercamientos


-- se liquidan los materialesqx + sutura y se sube unoa a uno liquidaiondetalle
-- solo un valor total de derechos de sala por la cirugia
-- ojo que pasa con el numero de la factuyra ejemplo FACTURA DE VENTA: TOB15851. Simplemente le agrego dos campos : prefijo y FacturaNo para la DIAN, eso es todo en la tabla facturacion_liquidacion
-- Ops pero entonces en cirugiasmatertialesqx estan ambsos curacion-suturas y qx , por que como por un lado se suman y ppor el otro se detallan , como hacer estop ?
--  Colocar el tipo de honorario en la consulta facturacion_liquidaciondetalle --> de la 175
-- OPs no sale el total a pagar ni valor liquiacoio que pasa ?????? yo creo ques desde la cirugia es mejor actualizar totales que le parece sera posible ??
- No cuadran sumatorias suministyros mas sumatorias procedimeintdo vakires a liquidar y a pagar


21/05/2025 19/08/2025
CLINICA MEDICAL S.A.S.
N.I.T. 830507718-8
19/05/2025 Calle 36 Sur No. 77 - 33 Tel.: 744 2565
5,00
Favor NO efectuar retención de Industria y Comercio e IVA - Somos agentes retenedores de IVA
Gran Contribuyente Res. 0012220 de 26-12-2022 - Actividad económica 8610
AUTORETENEDOR EN RENTA RESOLUCION 151 DEL 14-01-2016

Cufe: daeeb9343955c6037479b2e1b7bb485526f7524e5b085b4a5eb6e64298b22873bd6ef35b929221

- Aqui en adelante nueva etapa ENFERMERIA/FARMACIA .ALTO TURMEQUE PAPABEROL

-- El boton refrecar en factuyracion esta muy grande
-- ojo toca mejporar las pántallas en darmacia y enfemeria algo pasa
- ojo los mensajes de satisfactorio en azul y de error en rojo primero hay que borrarlos y despues si escribir o sio quedan montados

ojo pendiente en aplicacion de medicamentos arreglar cuando aplica la modal no pasa el enfemeriarecibeid a load_dataplaneacionenfermeria
-- ops no entiendo por que no me inicializa combos en las dietas que pasar
-- ops no se por que no refresca la grilla de dietas
-- ojo que pasa con el servicio administrativo en toda la planeacion y la aplicacion de medicamentos
-- falta algo cuandose recibe la devolucion desde enfermeria, es como conbtar reconmteo de unidades verificar

-- ojo tan solo cuando farmacia reciba la devolucion se actualiza cantidadDevuelta en enfermeriarecibe,, corregir no cuando enfereria devuelve que asi esta y eso esta mal. VERIFICAR

- ojo en Agosto 4
  -- hacer  no qx, cirugia, revx sstemas, sigmnops vitales etc
  --  crear formatos, ingresos admisioones, furips,accidente de transito, accidente de trabajo etc
  -- ojo en Histporia clinica hay que crear espacio para crear ordenes de control - proxima cita de control, especialista

   crear modelos referneica/contrareferencia

      -- seguiir probando la actualziadion editar admision desde admsiion
     -- ops los formatos estan iniciados y hay que revizarlos a fondop


-- los combos sin seleccion de rips despues de que se crea un admison estan con inicio en blanco
-- ojo en tarifarios, paramettizar la ruta de crague de procedimientos, suminis, honoraro en tabla parametros

-- op el lio es el conscuivoAdmision que se deb actulizar al momento de pasar lel triage al convenio
    -- primero si no existe convenio crea particular con el nvo consecutivo
    --- segundo actualiza elconsecutivo

-- ojo verificar cuando se crea admision desde triage si hay consec=0 de conveno parricular lo pase a consec=1 en pacientesconveniosIngresos

-- OPS ESTABA EN ABONOS Y ME INSERTO UN liquidacion_detalle,, de mi papa LUIS ERBNESTO BERNAL,

-- cosas por hacer
  -- los abonos pistear totally
  -- facturar, pistear abonos
  -- los filtros de las busqueda de facturas por fechas o numero de factura nop funciona
  -- ojo se crea la carpeta jsonclinic/rips, enrutar
  -- como es el lio de la facturacion de una cirugia
  -- la pantalla de farmacia no refrescxa bien cuan hace despacho
  -- como es eso de tx--> rollback criticos ni permitir basira
 -- no se en qiue lado mecreo un cabezote
  -- y el repporteaor que pasa ?
  -- Lo ultimo ultimo es tablas particionadas ver cuales. Umm yp creo la gran mayoria.


3. hacer traslados
4. indicadores
7. mirar desde autorizaciones los cups que caen a liquidaciondetalle, actualizaen TOTALES
 --	OJO PARA EL 8 DE SEPTIEMBRE:

10. ojo el guery load_dataliquidacion me mosytro 2 veces a nataly y no tiene sisno una solo convenio OPS de pronto es popr que tiene otro conevio al refacturar y activarla quedan activos los
    eSTO DE ARRIBA REVIZARLO EN LA PUESTA A PUNTA
  dos conveno REVISAR SOSS. es complejo pero si hay que miraralo  .. eSTO DE ARRIBA REVIZARLO EN LA PUESTA A PUNTA
  ME HIZO EL TRASLADO PERO FALO EN EL TOTAL DEL TRASLADO INICIAL
11 . CUANDO HAGO TRASLADOS ME SUMA  EN TOTALPROCEDIMIENTO, TOTALSUMINISTROS ESTA BIEN PERO EN TOTALLIQUIDACION O VALORAPAGAR ESTAN CON VALORES HYA QUE ACTUALIZAR DESDE EL TRASLADO
  -- OJO UNA VEZ SOLUCIONADO EL DE EUMELIA, DARLE SALIDA CLINICA Y FACTURAR .. OPS SE PERDIO LA FACTYRA DE EUMELIA
   ------ OJOOOOOOOOOOO OJOOOOOOOOOOOO  OJOOOOOOOOO
 -- creo que no me esta actualizando el dxActual VRIFICAR CON ENFEREMRA
 -- ops hacer notas de enfermeria desde la HC como desde enfermeria

--------------------------------------------------------------------------------------
-- TRAZA De combate ,, Puesta a punto Nro 2: oJOOOOOOOOOOOOOOOOOOOOOO
-------------------------------------------------------------------------------------
	1. combo localidades en actualizar usuaro de triage NO FUNCIONa, CREO QUE EN ADMISIONES TAMPOCO
	3. ops crre un servicio admon y no aparece en dependencia ???
        11. OJO TOCO EN TARIFARIOS update tarifarios_TarifariosDescripcion set columna = 'colValorBase' where id=36 AL MOMENTO DE CREAR UNA DESCRICOPMN  ES MEJOPR SOLO DESDE "ColValorBase"

--------------------
LUNES 15-SEPTIEMBRE: Ademas de revizar lo de arriba: ver acomodar columnas grades word-wrap en historia clinica , ordenes medica etc
			seguir con la pacienmte, traslados, facturar, refacturar etc
                        ops cirugia cursor cerrado OPS
			Colocar sin gastar pantalla boton REFRESCAR en pantallas escogidas
			Colocar boton REFRESCAR en block Indicadores
			Crear orden de Interconsulta .pdf y em historia Clinica
			pdf.multi_cell(0, 10, long_text, border=0, align='J', fill=Fals  para lineas grandes que verraquera VER IA (probar con la HC)

--------------------
        

2. main : modal, Error , sucess
3. templates : modal, message
4. viewd. try, catch,finaly
5. css: span message size, color
6. pdf : multicell
8. modales antigiuas vs nuevas
8. hoistoria: try, catch GLOBAL TABS
10. usuarios de bases de datos probar
11.  hacer exp todo imhoteps conm cpomandos SQL como en vulnerx
-- permisos OPCIONMESg
--falta impresion NoQx
-- Ojo en cirugias que pasas si es triage debe salir mensaje, debe estar hospitalizado o en urgnecia para que pueda hacer la solicitud
-- Ops no he desarrollado autorizaciones de cirugia OPS

--EL DIA LUNES 22 DE SEPTIEMBRE


-- OJO HACER IMPRESION DE ORDENES E IMPRESION DE FOLIOS EN HCLINICA
-- ojo hau que hacer un refres a farmaciades´pachos
-- ops notengo devolucionmes por triage, hay que incluirlasen el query load_datadevolucones
-- ops en farmacia las devolucones ARREGLAR el em
-- OJO MAÑANA VER PORQUE NO DEJA CAMBIAR DE STADO A NO DESPACHADO EN PANTALLAFARMACIA, YA LOHIZO PERO TIENE PROBLEMA CON EL FARMACIA_ID A VECES LO COGE A VECES NOP
-- Toca cuadrar las unidades devueltas desde enfermria no dejar devolver mas de la cuenta
-- creo que tengo un error en los pedidos de nefermeria de o paciente
-- ops al refacturar una cuenta cuto paciente tenia 2 convenios el select de liqudcionsaca dos registros ER OJOO
-- no graba el servicioadministrativo desde la refacturacion
-- ojo en farmacia--> dispensaciongeneral muestra despachos de dias pasados
-- ops en enfermeria me muestra las devolucones de antes, se supone estan facturados o fue porque hice una factura manual o borre cargos manuales ??
-- falta concebir una autorizacion aun triage OJO HACERLO -- ops creo que ya esta hecho verificar
-- ojo que es eso de que cuando cro un folio hc de paciente triage no guarda motivo,analis,plan,medico,depemdncia etc???
-- ojo  en enfermeria las devoluciiones y consulta gral devol mal muestra cosas pasadas
-- la pantalla de farmacia dispensaacion que debe tener
-- ops cuando ingreso revision x sistemas me descuadra la grilla
-- cuando yo autorizo no se desaparece de la pantalla de autorizaciones ver esop

-- 1que pasa con los calendarios son complñicado sno son muy funcinales que digamso
-- ops la ventana rips revizar(creo no trae mensajes de eroor y otras)
-- ops error aparece el paciente ambulatorio que ya se le dio salida ERO ojo, no coloco fecha de salida, el nro de lqa factura no ,o coloco
  la tabla facturacion_conveniospacienteingresos (fue al momento de facturar) creo un registro de mas a l ambulatorio error, ops no desocupo la habitacion, tampoco desocupo la cama al historialdependencias


-- lunes 6 de octubre

-- tengo un problema serio al facturar una refactura lo toima como factura OJO y no compo refactura error
-- tengo 2 erores cuando refacturo request.post(tipoingreso)   d['triageId']
-- LO MEJOR ES coger o arrancar de ceros nuevo caso crearlo, con dos conveios, 1. sin traslados. 2. con traslados a ver donde esta el error .OJO paso a paso
--  es mejor trabaja rcon estilops los textarea, para no tener que repetir en caso de cambio de style


 -- TIPS CONSULTA EXTERNA

-- Las agendas son independientes solo competen con medicos, especialidades y horarios de atencon: AgendasMedicas--> menuaAgenda, panelAgenda
-- Consultorios solo compete disponibilidad de los consultyaros. se asignan dinamicamet a o medicos: Consultorios, Calendario
-- Mismomdelo
   -- Tabla ingresos, creo se pued emantener un consecutivo nortmal que hosp.urge, amb
  --  se creat ciatMedicas, citasMedicasDetalle-- para los datos de la cita como tal con consecuticpo propio: CitasMedicas, CitasMedicasDetalle--> menuCitasMedicas , panelCitasMedicas
  -- lA HCLINICA JALADA DE LA QUE HAY PERO S ETRASQUILAN MUCHAS COSAS...

Calendario:

class Calendario(models.Model):
    STATUS_CHOICES = [
        ('A', 'Activo'),
        ('I', 'Inactivo'),
        ]
    id = models.AutoField(primary_key=True)
    sedesClinica = models.ForeignKey('sitios.SedesClinica',   blank=True,null= True, on_delete=models.PROTECT ,related_name ='sedesClinica301')
    fechaDia =
    nombre = models.CharField(max_length=30, default="" , null = False)
    fechaRegistro = models.DateTimeField(default=now, editable=False)
    usuarioRegistro = models.ForeignKey('planta.Planta',  blank=True, null=True, editable=True, on_delete=models.PROTECT,related_name ='usuarioRegistroPlanta')
    estadoReg = models.CharField(max_length=1, choices=STATUS_CHOICES,default='A', editable=False)


    def __integer__(self):
        return self.dependencia



Consultorios

class Consultorios(models.Model):
    STATUS_CHOICES = [
        ('A', 'Activo'),
        ('I', 'Inactivo'),
        ],
    ESTADO_CONSULTORIO = [
        ('D', 'Disponible'),
        ('N', 'No Disponible'),
        ('M', 'Mantenimiento'),
        ],
    DURACION_CITA = [
        ('Veinte', '20 Minutos'),
        ('Quince', '15 Minutos'),
        ]
    id = models.AutoField(primary_key=True)
    sedesClinica = models.ForeignKey('sitios.SedesClinica',   blank=True,null= True, on_delete=models.PROTECT ,related_name ='sedesClinica301')
    dependencia  = models.ForeignKey('sitios.Dependencias',   blank=True,null= True, on_delete=models.PROTECT ,related_name ='dependencia109')
    consultorio  =  models.ForeignKey('citasmedicas.Consultorios',   blank=True,null= True, on_delete=models.PROTECT ,related_name ='consul01')
    nombre = models.CharField(max_length=30, default="" , null = False)
    dia  = models.Date(default=now, editable=True)
    duracion = models.CharField(max_length=1, choices=DURACION_CITA,default='A', editable=False)
    fechaRegistro = models.DateTimeField(default=now, editable=False)
    usuarioRegistro = models.ForeignKey('planta.Planta',  blank=True, null=True, editable=True, on_delete=models.PROTECT,related_name ='usuarioRegistroPlanta')
    estadoReg = models.CharField(max_length=1, choices=STATUS_CHOICES,default='A', editable=False)


    def __integer__(self):
        return self.dependencia

agendasMedicas:
class AgendasMedicas(models.Model):
    STATUS_CHOICES = [
        ('A', 'Activo'),
        ('I', 'Inactivo'),
        ]
    id = models.AutoField(primary_key=True)
    sedesClinica = models.ForeignKey('sitios.SedesClinica',   blank=True,null= True, on_delete=models.PROTECT ,related_name ='sedesClinica301')
    especialidad = models.ForeignKey('clinico.Especialidades', blank=True,null= True, on_delete=models.PROTECT, null=False)
    especialidadesMedicos = models.ForeignKey('clinico.EspecialidadesMedicos',blank=True,null= True, on_delete=models.PROTECT, null=False)
    atiendeDesde = models.DateTimeField(default=now, editable=False)
    atiendeHasta = models.DateTimeField(default=now, editable=False)
    fechaRegistro = models.DateTimeField(default=now, editable=False)
    usuarioRegistro = models.ForeignKey('planta.Planta',  blank=True, null=True, editable=True, on_delete=models.PROTECT,related_name ='usuarioRegistroPlanta')
    estadoReg = models.CharField(max_length=1, choices=STATUS_CHOICES,default='A', editable=False)


    def __integer__(self):
        return self.dependencia



programacionCitasMedicas:

class ProgramacionCitasMedicas(models.Model):
    STATUS_CHOICES = [
        ('A', 'Activo'),
        ('I', 'Inactivo'),
        ]
    id = models.AutoField(primary_key=True)
    sedesClinica = models.ForeignKey('sitios.SedesClinica',   blank=True,null= True, on_delete=models.PROTECT ,related_name ='sedesClinica301')
    especialidad = models.ForeignKey('clinico.Especialidades',blank=True,null= True, on_delete=models.PROTECT, null=False)
    consultorio =  models.ForeignKey('agendasmedicas.Consultorios',   blank=True,null= True, on_delete=models.PROTECT ,related_name ='consul102')
    especialidadesMedicos = models.ForeignKey('clinico.EspecialidadesMedicos', blank=True,null= True, on_delete=models.PROTECT, null=False)
    agendasMedicas = = models.ForeignKey('citasmedicas.AgendasMedicas',   blank=True,null= True, on_delete=models.PROTECT ,related_name ='agendas001')
    desde = models.DateTimeField(default=now, editable=True)
    hasta = models.DateTimeField(default=now, editable=True)
    usuario = models.ForeignKey('usuarios.Usuarios',blank=True,null= True, on_delete=models.PROTECT, null=False)
    convenio = models.ForeignKey('contratacion.Convenios',blank=True,null= True,  on_delete=models.PROTECT, null=False)
    fechaRegistro = models.DateTimeField(default=now, editable=False)
    usuarioRegistro = models.ForeignKey('planta.Planta',  blank=True, null=True, editable=True, on_delete=models.PROTECT,related_name ='usuarioRegistroPlanta')
    estadoReg = models.CharField(max_length=1, choices=STATUS_CHOICES,default='A', editable=False)


    def __integer__(self):
        return self.dependencia


--- FIN TIPS


-- OPS REOJO. AL SACAR rips de procedimiento de pacientes clinico con autorizacion l campo consecutivoliquidcion no es adecuado porque no es posible hacerlos
  onmordar conm el consecutivofacturab de una factura que le parece. Complicado RESOLVER

 - ops tengo un erro como grave pero no mencontre donde es la cantiadaOrdenada y los diasdetratamiento estan iveritos en clinico_historiamediamentos,
   fe por un  proceso de autporizacion de mediamentos , en cambio el rips si estarria bien. Mirar el martes 14de oct

-- martes 14 de octubre:

-- crear la pestaña -- Auditoria Rips vs facturacion items
-- pruebas de rips con abonos
-- armar el json de envio y que impriema a partir del jsonFacturas
-- crear parametros de ruta para almacenar archivos json y toda la facturacion electronica

-- TIPS BOLIVIA
  	-- Solo admisiones admisiona No triage
	-- los diagnosticos no estan al ingreso d ela admsion
	
--  FIN TIPS BOLIVIA

-- RIPS
  -- COMO se hace con los ambulatorios
   -- quedo quemado el miuniciiop en ripsusuarios ?

-- ojo veriicar en ripsprocedimientos, el recaudo_id, el prorrateo de los pagos,los campos "null", null
-- no se porque ripshOspitalizacion no ingresa la factura 142 hospitalziados
-- revizar de nuevo ripsreciennacidos
-- hacer ripmedicamentos , hay mucho null por cua. (En el suministro debe estar parametrizado todos los datos de acuerdo  a toidas las tablas rips
-- OPS OJO CUANDO HICO EL MEDIAMENTO D EMARIA PAULA NO COLOCO EL NHUMERO DE HISTORIAMEDIAMENTO, SUPONGO FARMACIA AL DISPENSAR OPSREOPS
-- esta pendiente--> mas info para ripsmedicamentos
-- verificar ripsreciennacidos de acuredo mingov.vo

-- falto mirar el detalle de los rips medicamentos, unidades, formasfarmaceuticas, etc
-- ojo en facturacion-- traslados debe actualizar a cero el valor de os procedimikentos en la tarifa desde y actulizar totales a la nueva cuneta
-- OJo ver en sesion aparte la liquidacion puntual ISS y SOAT en detalle
-- revisar traslados - los items anulados
-- donde rayos coloco 'A' en columna anulkado de facturacion_liquidacion

-- El lunes 4 de Novielmre

  -- Valiar los RPS de una cirugia - honorario AVERIGUAR MANUALES RIPS MINISTERIO SI HAY ALGO ESPECIAL
  -- Practicas PUESTA A PUNTA
  -- Por ratos mejorar reportes y/o crear nuevos REPORTES
  -- Ops medical*Report ACTUVARLO
-- Falta los rips_otrosservcios, ripsconsulta


  -- INICIAR CONSULTA EXTERNA


------------------------------------------------------------------------------------------------------------------------------------------------
 --------------------- INICIOS PUESTA A PUNTO SOFTWARE (Detalle y Complejidad) FASE INICIAL LA MAS DURA DEL PROYECTO ---------------------------
-------- ES EL RESULTADO REAL DEL AÑO Y MEDIO DE PROYECTO.. Ojo las Facturas y Los rips Puros sin errores
-------- ENFOQUES DE PUESTA A PUNTO: 1.- Acceder de cualquier forma 2.- Los datos correctos como debe ser . 3. Creo es una puesta apunta de facturtacion: abonos, totales , tot facturas CORREGIR
------------------------------------------------------------------------------------------------------------------------------------------------

  -- (.. ok validar)  Los combos desde HC, domnde solicita cirugia para el paciente estan corn error str() + !! ??
 -- Apenas aplico-grabo un abono no refresca saldo ( OJO SOLO EL refresh de las pantallas, liquidaciondetalle, porque si grabo bien los totales en liquidacion
	(LO UNICO ES QUE HAYA UN ERROR SE VE QUE REFRESCA)
 -- Cuando uno refresca en liquidacindetalle la cuenta, no refresca la cabecera, por ejemplo si tengo cambio de cama no lo refresca, sinmo solo hasta que selecciono de nuevo la cuenta
 -- ops cuando uno selecciona en farmaciafarmaciadetalle un medicamento y lo señala y despacha por uno de ellos pasa que al seleccionar uno y no muetra despacho alguno, pero si seleciona el 
   -- otro muestra amos. ALGO PASA ALLI VERIFICAR (OPS CREO ESTA BIEN )
  -- (.. ok validar) ops colocar el codigo cups en la pantalla liquidaciondetalle para mejor entendimiento
-- alaplicar un meiamento la nefermera no refresca ell datatable o no cordina los datatable y no lo muestra aunque si guarda la a plicacion

-- cuando uno autoriza un medicamento y sale de la pantalla autorizaciondetalle si no quedan mas autorizaciones pendientes se debe colocar en el cabezote de la autortizacion=autorizado
   --(..ok validar)  para que desaparezca tambien de la pantalla

-- ojo en todas las pantallas donde se calcule total copagos,moderadoras etc es con valorEnCurso no valor

-- cuando uno selecione en farmacia en la primera pantalla actualizar la pantalla farmaciadetalle de acuerdo a seleccion. oseas lo que no he podido seleccionar un radio de un datatable

-- ojo la pantallade farmacia depachos debe mostrat si y solo si el codigo CUPS y adems no muestran cantidades IMPORTATIDIMO
-- como hacer para que los combos muestre los empleados d cada area o depto (desarrollo loco) en farmacia despachosppor ejemplo. se me ocurre en el 
	model de planta seleccionar creo el area o serv-admon


-- VEO MUY LENTO ELMODULO TARIFARIO PARA AGREAR CREAR TARIFAS

-- (.. ok validar) OPS PERSISTE EL ERROR DE QUE CUANDO CREA UNA CIRUGIA EN LA TABLA PROGRAMACION DE CIRUGIA NO CREA EL CIRUGIA_ID. // OJO ESTO NO SE HIZO DESDE LA HC VERIFICAR
-- la disponinbilidd de salas de cirugia no funciona aun
-- ojo PONER control de fechas  en las fechas de quirofanos cirugias (ok..Validar...)
-- (ok.. validar)ops al generar el totala pagar esta mal eror en generarliquidcaon dese cirugia-.. UUUYY NOO comoasi que totalproceimientos = 2200 re-maluco -- ops relocoo la pantalla no me muestra lo
   que esta grabado en tablas como asi????? socorro ?? auxilio ERRROOR remaluco. son dos cosas uno lo que guarda elgeneralliquiacion de cirugia y otro el que selecciona lacuenta
-- ojooo pendiente arreglar en facturacion la funcion : PostConsultaLiquidacion, en cuanto mlode convenio y que cea cabezotes PAILAS no debe crear nada 

-- TODAVIA FALTA DEFINIR CUALES SON LOS MATERIALES TIPO HONORARIO Y CULAES SON MATERIALES QX . AHORA BIEN LA TARIFA DE LOS MATERIALES VIENE DE CIRUGIA O ES DEL TARIFARIO ??

-- ops el saldo de la cuotamoderadora , totalrecibido lo paso en ceros ta mal debe colocar lo que estaba en liquidacion. Que paso papaberol donde puede ser el error OP -RE OPS - OPS QUe proceso blanqueo estos saldos ???
   -- MAL TOTALAPAGAR, TOTALRECIBIDO, VALOR CUOTA MOPDERADORA OPS,, FUE PRODUCTO DE UN ROLLBACK YY QUE PASOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO

------------------------
------ Sda puesta apunta
----------------------
 
-- Poner cie10 en diagnosticos . (.. VALIDAR)
-- cuando creo un triage e inmediatamente voy a crear la admision se pierden los default valores de rips
-- al crear admision desde triage l combo de dx debe traer el cie10 (.. VALIDAR)
-- por cua al seleccionar la empresa de compensa r no tyrae conevnio, hay dque jugar opara que lo traiga
-- por que al coloar el rips de recien nacido , se arregla el erroo de los ripsegreeo ???????????????
-- hay problemas con el checkbox de material de cirugia cuando off no graba sale error
-- ojo creo que problemas en historiamedicamentos cuado se autoriza u med que tuee mas de un item en el folio o sea mas de un medicamento
-- no aparece la cantidassolicitada en farmacia detalle creop (creo esta a la derecha)

-- OJO hay que verificar quep cuando se factura una cirugia cambi a FACTURADO para que salga de la programacion de cirugias

-- ojo no me actualizo desde farmacia los totales d eliquidacion (validar de nuevo)
-- ops desarrollar crear el folio clinico de lacirugia cuando se realiza (Validar ..)
-- ops crear autorizacin de la cirugia cuando se crea un proced
-- opos crear la autorizacion de la ciru no cae en liquidaciondetalle. , sololasa utroizadas caen las otras nop
-- ops crear ripsotrosservicios de :insumos y material, honrario y estancias
-- ops que pasa con el consecutivo de la factura
-- hay un bonche barvaro en los ripsotrosservicios respecto asl cups o cum en unos casos cums (insumos) en otros casos cups (honorarios, estancias) =?? como arreglar mejorqar
-- Notas credito, notas debito RIPS de pronto no es tan compleo, complcado sacar mas adelante tiempito, son cosas de cuadre TUNNIG DE OPERATION
-- Los RIPS , GLOSAS, CIRUGIA, son una prueba muy grande, imaginese hay que cuadrar la money el dinero los $, que cuadre como asi modeardoa , cuando se prorratea ES TENAZ
  - hasta alla hay que llegar
-- Y que me dice de REFACTURAR una cuenta, hacer gtrasalados añadir y quira items factyura de nuevo la cirugia. y como se reporta la ANULADA
-   -- pos hay todavia camino para recorrer. PERO TODO BIEN COMO EL PIBE.MUY PERO MUY BIEN CASI EXCELENTE. FELICITACIONES ...
-- CUANDO SE FACTURA LA CIRUGIA TAMBIEN CAMBIA EL ESTADO DE LA PROGRAMACION A realizada

-- DEFINITIVAMENTE hay que aterrizar el tema insumos, qx, dispo medicos, honorarios etc. Es un saperongo, y en otros servicios ni se diga papaberol

-- Que paso con ... / que desde TRIAGE coloco anulkado = 'A' en facturacion_liquidacion OPS

-- Diciembre 22 

  Toca crear los perfiles clinica y perfilesgralusu, sedesserviciosclinica, sedessubserviciosclinica, dependencias , habitaciones, tarifarios
  ojo arreglar que pasa cuando en el convenio no mesta definido el tipo de tarifa proced y/o suministros , debe ir a buscar las particulares . Hace esto

-- Diciembre 23

	-- El deber ser volver a estudoar , repasar para seguir afianzar conceptros tecnicos, globales etc
        -- ojo el corte carga parametrizacion inicial + parmetrizacion : tarifarios, conceptos, examenes, suministros ,sitios, etc crea la visualizacion del triunfo del software
           coordinar bien , adecuadamente esta parametrizacion base
        -- El cargue de clinico_examenes debe ser bien parametrizado y total, al igual que el de facturacion_suministros

-- Diciembre 24

   Este es el ultimo mopdeloPrueba ACTIVO. Tips

	-- Crear parametrizacion de tarifarios SOAT, ISS, (salas,honorarios,insumos, materiales de curacion, etc)
        -- dejar FULL parametrizacion Examenes, Suministros
        -- Ver que falta de la parametrizacion RIPS


   Recuerda el PROCESO
   En Entornospython/pos7ParticionadoLienzo. Es como la trama, la sabana donde a parti de alli se crea todo.Hay .bat que crean
   En el archivo Adiciones de esta carpeta esta detallado el proceso
   
	
   En que va todo el proceso

	1. Se esta probando todo el cargue de data + las parametrizaciones de aranque + casos de uso pacientes todo desde triage hasta rips COMPLETO,
           o sea una super-puesta a punta
        2. Crear hacer de ceros modulo de consulta externa
        3. Crear reportes, mejorar los existentes
        4. Crear modulo medicalReport (Reporteador) . En views.admisiones (crearadmisionDef) esta lo base para request de variables hidden (usernamE.id) crear context y pasar
            al views.reportes, donde se necesite. hacer esto el 27 de Diciembre. Creando un nuevo liezo de ceros creop
	    y que pasa si copi a pos7Particionado todo el software: administracio, Reportes y template/reportes para probar mas rapido, puede ser una opcion para no reparamtrizar todos los
            Modulos
        5. Trabajar Tablas particionadas (Ojo en primera instancia no puede , toca con migraciones parciales)

	6. A grandes modos FIN PRIMERA PARTE PROYECTO
	7. Inicio segunda parte proyecto (Inteligencia artificial + Electronica-robotica)


Puesta a Punta :

        ojo que pasa con los botones de la izquierda ver el html por que no tienen cabeceras o titulos    esto en paneladmisiones.html
	Ojo verificar en tarifarioviews, no crear el servi¿cioadministrativo en cargarsuministros ?? PORCUA 
	El boton refrescar de admisones. No refresca INDICADORES
        Al crear la admision desde triage, no dice que combo de rips hace falta seleccionar controlar eso con javascript VERIFICAR
	se pierde el nombre de la Aplicacion al crear admision desde triag VERIFICAR
	Ojo cuando borro un medicamento en farmacia, al grabar lp topma de nuevo error .No debe guardar
	PENDIENTE Devouciones tanto de Enfermeria como de Farmacia
        Pantalla apoyo terapeuitoc pailas-ñucas PENDIENTE DE MEJORA
	PENDIENTE impresion despachos de farmacia
	cuando aplica abono no refresca la pantala liquidaciondetalle para reflejar el monot. pero ojo primero refrescar liquidacion, luego liquidacion detalle y luego seleccionar ops
          como hacer ello?
	PREOCUPANTE la demora para hacer un folio clinico de cualquier paciente desde un cliente
	fijate que el header de fromular no se extendio hacia la derecha en el cliente .224. 

	
	REVISIONES. PUESTA A PUNTO MODULOS (15 Modulos) Ademas de: Planta, Usuarios, Medicos, 

	Triage-Admisiones-HistoriaClinica-Farmacia-Enfermeria-  oK
	Contratacion-Tarifarios       				-- Verificar
	ApoyoTerapeutico  -- Hacer
	Facturacion-Glosas-Rips-Cirugia-Autorizaciones-Cartera -- Probar
	ConsultaExterna (UNICO MODULO FALTANTE POR DESARROLLAR) -- No desarrollado

	
FEB 16:

	Ops cuando creo un Triage me quita la ventana Crear TRiag GRAVISISSIMO ,, ops esta relacionado con los permisos TRIAG	verificar
	Cuando hace un triage No lo imprime
	La impresion de la HC. super - recontra lenta
	OPS imprimio una hoja de admision aun paciente en urgencias ???
	No esta hecho nada en autorizaciones cirugia
	Ojo hay que quitarle los avisos main.js a facturacion y a autoriaciones etc
	Seguir en la tarde con el wrap del data table o el truncate renderizando el campo truncado INVESTIGAS // Gacturar cuen
	Como hacer para que cunado se autoriza y no hay mas pendientes si desaparece de aut, pero
	No esta desapareciendo de autDet (la bendita vaina de no poder seleccionar una fila del datatable)
	cuando uno esta creando un laboratoio no se ven las observa
        OJO HAY QUE CREAR TODA LAS FUNCIONES EN LA PARAMETRIZACION, fcaturas, rips,json etc, VER CUALES ESTAN ACTIVAS ULTIMA VERSION OJO
	ops no me grabo lo de nota aclaratoria
	ojo hay un error al dar salida cliica al paciente si no hay complicacion-dx no guarda NULL PROBAR
	cuando interpreta un examen, debe blanquear la plantilla  hacer quiery a los ordenados al primero que quede en pantalla
	La elaboracion de factura debe imprimir la factura OJO
	
FEB 20:
OJO EL 23 DE FEBRERO TRANAJAR TODO LO DE CIRUGIA Y CARTERA PENDIENTE VERIFICAR ABAJO Y ARRIBA DE ESTE DOCUMENTO

	Ops no me cuadro la liquidacion de la cuenta con la ciruguia algo pasa.. VERIFICAR. Puesta a punta
	OPS hay algo que no entiendo al realzar la cirugia primero no me creo el folio en clinico_historialcirugias y despues sip
	OPS como se ANULA una solicitud de cirugia
	OJO con las edades me esan mamando gallo en la pantalla de solicitud
	OPS no me dejo cancelar una programacion de cirugias
	OPS creo que hay un problema de diseño al no permitir mas de una cirugia para un mismo paciente en el mismo ingreso VERIFICAR
	OPS el convenio solo falta cunado desde HC hacen la solciitud debe haber algo para actualziar el convenio vERIFICAR
	OPS en cirugia el tab Ocupacion salas muestra LIBRE buna OCUPADA CORREGIR
	OPS LOS paraclinicos en ENFERMERIA NO MUESTRA CIRUGIAS ??
	Terminar, probar cartera
	mañana crear una cirugia , ver impresion HC y facturarla, seguimiento
	Luego si RIPS y GLOSAS

Ver FEB 26:
	no refresca localidad solo cuando se le da la gana en crear admision
	ops, verifica mas a fondo dispo salas cirugia en cambio de dia
	ops CARTERA arreglar mas bonito mas fluido...

	DESPUES DE TODO ESTO, comenzar Consulta Externa
	Tablas particionadas
	Frurips, devoluciones d farmacia
	Mejorar, crear reportes a la lata
	Instalar Clinica*Report

FEB 27:
	ops en rips al generar y los json hay codigos quemados sera bueno verificar
	parametrizar

	Tips:
	
		No aceptar pagos de empresas sin rips enviados
		Al enviar un rips que pasa ? que fecha se actualizan?
		Una glos se acepta bsi hay una factura con rips
		Eventos --> 1. Rips Enviado
			    2. Factura enviada a la dyan
			    3. Rips Radicado al Ministerio
			    4. Rips Respuesta
			    5. Dyan respuesta
			    6. Recepcion de glosa
			     7. rips de glosa


luner 02 marzo

	ojo probar:

https://www.baulphp.com/datatables-small-size/
https://www.google.com/search?q=como+seleccionar+la+primera+fila+con+javascript+un+checkbox+en+un+datatable+jquery+al+cargar+una+pagina&sca_esv=3d646b66db581d96&rlz=1C1CHBF_esCO999CO999&biw=1210&bih=528&ei=mwOiadL5L_aZwbkPrNSF-Q8&ved=0ahUKEwiSs7-cxvqSAxX2TDABHSxqIf8Q4dUDCBE&uact=5&oq=como+seleccionar+la+primera+fila+con+javascript+un+checkbox+en+un+datatable+jquery+al+cargar+una+pagina&gs_lp=Egxnd3Mtd2l6LXNlcnAiZ2NvbW8gc2VsZWNjaW9uYXIgbGEgcHJpbWVyYSBmaWxhIGNvbiBqYXZhc2NyaXB0IHVuIGNoZWNrYm94IGVuIHVuIGRhdGF0YWJsZSBqcXVlcnkgYWwgY2FyZ2FyIHVuYSBwYWdpbmFIAFAAWABwAHgAkAEAmAEAoAEAqgEAuAEDyAEA-AEBmAIAoAIAmAMAkgcAoAcAsgcAuAcAwgcAyAcAgAgA&sclient=gws-wiz-serp
ojo checkbox en datattab{
PROBAR


marter 03 de marzo INONSIKTNAS

	La disponiblidad de crugias pailas cuando no encuentra datos se alta el CURSO que pasa ?
	La factuarcion no me carga que pasa ?
	Los rips de una cirugia no sale la hospitalizacion, ni los procedimientos creop por otros serviicios VERIFICAR
	La descripcion qx algo pasa con las ora mnuto segundos suas
	
	OPS cuando se crea un folio clinico automatico por una cirugia, No crea la causaExterna , ni ningun diagnostico corregir 


	OPS cuando se genera el RIPS se debe colocar el codigo en ripsotrosservcicios del ripscums y ripscups en teconologiasalud_id y renconologiasaludups_id

		SELECT '{"codPrestador": '|| '"' || otros."codPrestador" || '"' 
	   ||',"numAutorizacion": '|| '"' || CASE WHEN trim(otros."numAutorizacion") is null THEN 'null' ELSE otros."numAutorizacion"  END || '"'		
  		',"idMIPRES": ' || '"'   ||CASE WHEN trim(otros."idMIPRES") is null THEN 'null'  WHEN trim(otros."idMIPRES") = null THEN 'null' WHEN trim(otros."idMIPRES") = '' THEN 'null'  ELSE otros."idMIPRES"  END|| '"'  
	||',"fechaSuministroTecnologia": '|| '"' || substring(cast(otros."fechaSuministroTecnologia" as text), 1,16) || '"'  
	 	||',"tipoOs": '|| '"' ||ripsTipo.codigo || '"'	
		--||',"codTecnologiaSalud": '|| '"' || ripsCums.cum || '"'	
		--||',"nomTecnologiaSalud": '|| '"' ||substring(otros."nomTecnologiaSalud",1,60)  || '"'	
	  		||',"codTecnologiaSalud": '|| '"' || case when "codTecnologiaSalud_id" is not null then  sum.cums else case when ("codTecnologiaSalud_id" is null or "codTecnologiaSalud_id" = "null" )  then exa."codigoCups" end   end  || '"'		
		||',"nomTecnologiaSalud": '|| '"' ||case when  "nomTecnologiaSalud" is not null then  substring(otros."nomTecnologiaSalud",1,60)   when  "nomTecnologiaSaludCups" is not null then  substring(otros."nomTecnologiaSaludCups",1,60) end || '"'		   
 	   ||',"cantidadOS": '||  otros."cantidadOS" ||'	'
	||',"tipoDocumentoIdentificacion": '|| '"' || ripsTiposDoc.codigo  || '"'		
	||',"numDocumentoIdentificacion":  '|| '"' || CASE WHEN trim(otros."numDocumentoIdentificacion") is null THEN 'null' ELSE otros."numDocumentoIdentificacion"  END  || '"'		
	||',"vrUnitOS": '|| otros."vrUnitOS"   || ''		
	||',"vrServicio": '|| otros."vrServicio"   || ''		
	||',"tipoPagoModerador": '|| '"' || case when modera.codigo is null then 'null' else modera.codigo end   || '"'		
	||',"valorPagoModerador": '||  CASE WHEN trim(cast(otros."valorPagoModerador" as text)) is null THEN 0 ELSE otros."valorPagoModerador"  END  || ''
	||',"numFEVPagoModerador": '|| '"' || otros."numFEVPagoModerador" || '"'
	||',"consecutivo": '||  otros."consecutivo" ||'	},'
	--INTO valorOtrosServicios
	from rips_ripstransaccion ripstra
	inner join rips_ripsotrosservicios otros on (otros."ripsTransaccion_id" = ripstra.id)
	left join clinico_examenes exa on (exa.id = otros."codTecnologiaSalud_id" )
	left join facturacion_suministros sum on (sum.id = otros."codTecnologiaSalud_id" )
	
	inner join rips_ripstipootrosservicios ripsTipo on (ripsTipo.id = otros."tipoOS_id" ) 
	left join rips_ripstipospagomoderador modera on (modera.id=otros."tipoPagoModerador_id")
	inner join rips_ripstiposdocumento ripsTiposDoc on (ripsTiposDoc.id = otros."tipoDocumentoIdentificacion_id" )
	   where  ripstra."ripsEnvio_id" = '2' AND  ripstra."numFactura" = cast('8' as text) AND otros.consecutivo >= 1; 

	OPs ojo los ripsconsultas casos son para el uso de ambulatorios aquip, faltas las de consulta externa
 	OPS Faltan hacer los rips d GLOSA/NOta credito de CONSULTA RIPS/RIPS OTROSSERVICIOS tanto en generajson rips y enviojsonrips
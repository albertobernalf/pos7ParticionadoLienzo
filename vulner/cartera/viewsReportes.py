import json
from django import forms
import cv2
import numpy as np
from fpdf import FPDF
from PyPDF2 import PdfReader
import webbrowser
import psycopg2
import json
import datetime

# import onnx as onnx
# import onnxruntime as ort
import pyttsx3
import speech_recognition as sr
from django.core.serializers import serialize
from django.db.models.functions import Cast, Coalesce
from django.utils.timezone import now
from django.db.models import Avg, Max, Min
#from .forms import historiaForm, historiaExamenesForm
from datetime import datetime
from clinico.models import Historia, HistoriaExamenes, Examenes, TiposExamen, EspecialidadesMedicos, Medicos, Especialidades, TiposFolio, CausasExterna, EstadoExamenes, HistorialAntecedentes, HistorialDiagnosticos, HistorialInterconsultas, EstadosInterconsulta, HistorialIncapacidades,  HistoriaSignosVitales, HistoriaRevisionSistemas, HistoriaMedicamentos, Regimenes
from sitios.models import Dependencias
from planta.models import Planta
from facturacion.models import Liquidacion, LiquidacionDetalle, Suministros, TiposSuministro
#from contratacion.models import Procedimientos
from usuarios.models import Usuarios, TiposDocumento
from cartera.models  import Pagos
from autorizaciones.models import Autorizaciones,AutorizacionesDetalle, EstadosAutorizacion
from contratacion.models import Convenios
from cirugia.models import EstadosCirugias, EstadosProgramacion
from tarifarios.models import TarifariosDescripcion, TarifariosProcedimientos, TarifariosSuministros
from clinico.forms import  IncapacidadesForm, HistorialDiagnosticosCabezoteForm, HistoriaSignosVitalesForm
from django.db.models import Avg, Max, Min , Sum
from usuarios.models import Usuarios, TiposDocumento
from admisiones.models import Ingresos
from farmacia.models import Farmacia, FarmaciaDetalle, FarmaciaEstados
from enfermeria.models import Enfermeria, EnfermeriaDetalle
from facturacion.models import ConveniosPacienteIngresos

from django.contrib import messages
from django.shortcuts import render, get_object_or_404, redirect, HttpResponse, HttpResponseRedirect
from django.core.exceptions import ValidationError
from django.urls import reverse, reverse_lazy
# from django.core.urlresolvers import reverse_lazy
from django.views.generic import ListView, CreateView, TemplateView
from django.http import JsonResponse
import MySQLdb
import pyodbc
import psycopg2
import json
import datetime
import cgi
from django.db import transaction

import os
import requests
import urllib
from django.http import FileResponse
from io import BytesIO
import io



class PDFNotasCredito(FPDF):
    def __init__(self, tipoDocId, documentoId, consec,ingresoId,  *args, **kwargs):
    #def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.tipoDocId = tipoDocId
        self.documentoId = documentoId
        self.consec = consec
        self.ingresoId = ingresoId


    def header(self):
        # Move to the right
        # self.cell(12)

        ## CURSOR PARA LEER ENCABEZADO
        #
        miConexiont = psycopg2.connect(host="192.168.79.133", database="vulner7Particionado", port="5432", user="postgres",
                                       password="123456")

        curt = miConexiont.cursor()

        comando = 'select ' + "'" + str('Paciente en trauma') + "'" + ' seInforma, substring(cast(current_Helveticatamp as text),1,10) fecha , substring(cast(current_time as text), 1,5) as time,emp.nombre nombreEmpresa, substring(sed.nit,1,9) nit, substring(sed.nit,9,1) nitVerificacion, sed."codigoHabilitacion" habilita,emp.direccion direccionPrestador, emp.telefono telefonoPrestador, dep.nombre departamentoPrestador, dep."departamentoCodigoDian" codigoDepartamentoPrestador, mun.nombre municipioPrestador FROM facturacion_empresas emp INNER JOIN sitios_sedesclinica sed ON (sed.id=1) INNER JOIN sitios_departamentos dep ON (dep.id=emp.departamento_id) INNER JOIN sitios_municipios mun ON (mun.id = emp.municipio_id) WHERE emp. nombre like (' + "'" + str('%MEDICAL%') + "')"

        curt.execute(comando)
        print(comando)

        historia = []

        for seInforma, fecha, time, nombreEmpresa, nit, nitVerificacion, habilita, direccionPrestador, telefonoPrestador, departamentoPrestador, codigoDepartamentoPrestador, municipioPrestador in curt.fetchall():
            historia.append(
                {'seInforma': seInforma, 'fecha': fecha, 'time': time, 'nombreEmpresa': nombreEmpresa,
                 'nit': nit, 'nitVerificacion': nitVerificacion, 'habilita': habilita,
                 'direccionPrestador': direccionPrestador, 'telefonoPrestador': telefonoPrestador,
                 'departamentoPrestador': departamentoPrestador,
                 'codigoDepartamentoPrestador': codigoDepartamentoPrestador, 'municipioPrestador': municipioPrestador})

        miConexiont.close()

        ## FIN CURSOR

        # Title
        #
        self.set_font('Helvetica', 'B', 8)
        # Define el ancho de línea
        self.set_line_width(0.4)
        # Dibuja el borde
        self.rect(5.0, 18.0, 200.0, 30.0)  # Coordenadas x, y, ancho, alto
        self.ln(3)
        # Arial bold 15
        self.set_font('Helvetica', 'B', 8)
        self.cell(180, 10, historia[0]['nombreEmpresa'], 0, 0, 'C')
        self.cell(10, 10, 'NIT: ', 0, 0, 'L')
        self.cell(20, 10, historia[0]['nit'], 0, 0, 'L')
        self.ln(3)
        # Logo
        self.image('C:/EntornosPython/Pos7Particionado/vulner/static/img/MedicalFinal.jpg', 7, 19, 11, 11)
        self.cell(80, 15, 'NOTA CREDITO ', 0, 0, 'C')
        self.cell(20, 15, 'NC ', 0, 0, 'L')
        self.set_font('Helvetica', ' ', 8)
        self.cell(20, 10, notas[0]['numero'], 0, 0, 'L')
        self.ln(2)
        self.set_font('Helvetica', 'B', 8)
        self.cell(105, 15, 'FECHA ', 0, 0, 'L')
        self.set_font('Helvetica', ' ', 8)
        self.cell(20, 10, notas[0]['fecha'], 0, 0, 'L')
        self.ln(2)
        self.set_font('Helvetica', 'B', 8)
        self.cell(105, 15, 'CIUDAD ', 0, 0, 'L')
        self.set_font('Helvetica', ' ', 8)
        self.cell(20, 10, notas[0]['ciudad'], 0, 0, 'L')
        self.ln(2)
        self.set_font('Helvetica', 'B', 8)
        self.cell(105, 15, 'VALOR ', 0, 0, 'L')
        self.set_font('Helvetica', ' ', 8)
        self.cell(20, 10, notas[0]['valor'], 0, 0, 'L')
        self.ln(5)
        # Line break
        self.ln(5)


def ImprimirNotasCredito(request):
    # Instantiation of inherited class

    tipo = request.POST["tipo"]
    numero = request.POST["numero"]

    ingresoId = request.POST["ingresoId"]
    print("ingresoId2 = ", ingresoId)
    print("Entre ImprimirAtencionInicialUrgencias ", ingresoId)

    ingresoPaciente = Ingresos.objects.get(id=ingresoId)
    tipoDocId = ingresoPaciente.tipoDoc_id
    print("tipoDocId = ", tipoDocId)
    documentoId = ingresoPaciente.documento_id
    print("documentoId = ", documentoId)
    consec =  ingresoPaciente.consec
    print ("consec = ",consec)
    pacienteId = Usuarios.objects.get(id=documentoId)
    print("documentoPaciente = ", pacienteId.documento)

    pdf = PDFNotasCredito(tipoDocId, documentoId, consec, ingresoId)
    pdf.alias_nb_pages()
    pdf.set_margins(left=10, top=5, right=5)
    pdf.add_page()
    pdf.set_font('Helvetica', 'B', 8)


    
    # Cursor lee datos e la Glosa y/o Nota credito

    miConexiont = psycopg2.connect(host="192.168.79.133", database="vulner7Particionado", port="5432", user="postgres",
                                   password="123456")
    curt = miConexiont.cursor()


    comando = 'SELECT usu."primerNombre"  primerNombre, usu."segundoNombre"  segundoNombre, usu."primerApellido"  primerApellido, usu."segundoApellido" segundoApellido , usu."tipoDoc_id" tipoDoc ,usu.documento documento , usu."fechaNacio" fechaNacimiento, usu.direccion direccion, usu.telefono telefono,  dep.nombre departamentoPaciente, mun.nombre municipioPaciente, regimen.nombre regimen FROM admisiones_ingresos ing INNER JOIN usuarios_usuarios usu ON (usu."tipoDoc_id"=ing."tipoDoc_id" AND usu.id=ing.documento_id) INNER JOIN sitios_departamentos dep ON (dep.id=usu.departamentos_id) INNER JOIN sitios_municipios mun ON (mun.id = usu.municipio_id) INNER JOIN clinico_servicios servicios on ( servicios.id=ing."serviciosActual_id") LEFT JOIN clinico_regimenes regimen ON (regimen.id = ing.regimen_id) WHERE ing.id = ' + "'" + str(ingresoId) + "'" + ' AND servicios.NOMBRE LIKE (' + "'" + str('%URGENC%') + "')" + ' group by usu."primerNombre", usu."segundoNombre", usu."primerApellido", usu."segundoApellido", usu."tipoDoc_id",usu.documento, usu."fechaNacio" , usu.direccion , usu.telefono , dep.nombre , mun.nombre, regimen.nombre'

    curt.execute(comando)

    print(comando)

    pdf.ln(3)
    pdf.set_line_width(0.3)
    #pdf.rect(5.0, 98.0, 200.0, 3.0)  # Coordenadas x, y, ancho, alto
    pdf.set_font('Helvetica', 'B', 8)


    miConexiont = psycopg2.connect(host="192.168.79.133", database="vulner7Particionado", port="5432", user="postgres",
                                   password="123456")
    curt = miConexiont.cursor()

    comando = 'select ext.id id ,ext.nombre causa from admisiones_ingresos ing inner join clinico_causasexterna ext on (ext.id=ing."causasExterna_id") where ing.id= ' + "'" + str(ingresoId) + "'"


    curt.execute(comando)

    print(comando)

    notaCredito = []

    for id, cude, cliente, identificacion, factura, descripcion, valorEnLetras curt.fetchall():
        notaCredito.append(
            {'id': id, 'cude':cude, 'cliente': cliente, 'identificacion':identificacion, 'factura':factura, 'descripcion':descripcion, 'valorEnLetras':valorEnLetras})
    miConexiont.close()

    pdf.set_font('Helvetica', 'b', 8)
    pdf.cell(20, 30, 'CUDE:', 0, 0, 'l')
    pdf.set_font('Helvetica', '', 8)
    self.cell(200, 30, notaCredito[0]['cude'], 0, 0, 'L')
    pdf.ln(3)

    pdf.rect(5.0, 50.0, 200.0, 30.0)  # Coordenadas x, y, ancho, alto
    pdf.set_font('Helvetica', 'B', 8)
    pdf.cell(10, 35, 'Cliente:', 0, 0, 'L')
    pdf.set_font('Helvetica', '', 8)
    self.cell(80, 35, notaCredito[0]['cliente'], 0, 0, 'L')
    pdf.set_font('Helvetica', 'B', 8)
    pdf.cell(10, 35, 'Identificacion:', 0, 0, 'L')
    pdf.set_font('Helvetica', '', 8)
    self.cell(50, 35, notaCredito[0]['identificacion'], 0, 0, 'L')
    pdf.ln(2)
    pdf.set_font('Helvetica', 'B', 8)
    pdf.cell(10, 37, 'Factura #:', 0, 0, 'L')
    pdf.set_font('Helvetica', '', 8)
    self.cell(80, 37, notaCredito[0]['factura'], 0, 0, 'L')

    pdf.ln(3)
    pdf.set_font('Helvetica', 'B', 8)
    pdf.cell(10, 39, 'Concepto de la Nota:', 0, 0, 'L')
    pdf.set_font('Helvetica', '', 8)
    self.cell(80, 39, notaCredito[0]['descripcion'], 0, 0, 'L')


    pdf.ln(10)
    pdf.set_font('Helvetica', 'B', 8)
    pdf.cell(10, 40, 'Valor en Letras:', 0, 0, 'L')
    pdf.set_font('Helvetica', '', 8)
    self.cell(80, 40, notaCredito[0]['valorEnLetras'], 0, 0, 'L')


    #pdf.output('C:/EntornosPython/temporal/temporal/atencionInicialUrgencias.pdf', 'F')

    linea = linea + 3
    pdf.ln(3)

    carpeta = 'C:\EntornosPython\Pos7Particionado\vulner\JSONCLINICA\Notas\'
    print("carpeta = ", carpeta)

    archivo = carpeta + '' + str(notaCredito[0]['numero']) + '_' + 'NotaCredito.pdf'
    print("archivo =", archivo)

    pdf.output(archivo, 'F')

    try:
        # Intenta abrir el archivo directamente
        # webbrowser.open(archivo)

        buff = BytesIO()
        buff.name = archivo
        #Genera el archivo el el servidor

        pdf.output(archivo, 'F')


        # 2. Abrir el archivo PDF y leerlo
        with open(archivo, 'rb') as f:
            pdf_data = f.read()
            # 3. Escribir los datos en el buffer
            buff.write(pdf_data)

        buff.seek(0)

        return FileResponse(
            buff,
            as_attachment=True,  # Cambiar a False para verlo en navegador
            filename=archivo,
            content_type='application/pdf'
        )


    except FileNotFoundError:
        print(f"Error: Archivo no encontrado en {archivo}")
    except Exception as e:
        print(f"Error al abrir el archivo: {e}")

    return JsonResponse({'success': True, 'message': 'Atencion Inicial de Urgencias impresa!'})



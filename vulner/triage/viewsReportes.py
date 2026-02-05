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
from clinico.models import Historia, HistoriaExamenes, Examenes, TiposExamen, EspecialidadesMedicos, Medicos, Especialidades, TiposFolio, CausasExterna, EstadoExamenes, HistorialAntecedentes, HistorialDiagnosticos, HistorialInterconsultas, EstadosInterconsulta, HistorialIncapacidades,  HistoriaSignosVitales, HistoriaRevisionSistemas, HistoriaMedicamentos , Regimenes
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
from triage.models import Triage

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

import os
import requests
import urllib
from django.http import FileResponse
from io import BytesIO
import io
from django.http import FileResponse


class PDFTriage(FPDF):
    def __init__(self, tipoDocId, documentoId, consec, triageId,  *args, **kwargs):
    #def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.tipoDocId = tipoDocId
        self.documentoId = documentoId
        self.consec = consec
        self.triageId = triageId


    def header(self):
        # Move to the right
        # self.cell(12)

        ## CURSOR PARA LEER ENCABEZADO
        #

        # Line break
        self.ln(10)



class PDFAtencionInicialUrgencias(FPDF):
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

        comando = 'select ' + "'" + str('Paciente en trauma') + "'" + ' seInforma, substring(cast(current_timestamp as text),1,10) fecha , substring(cast(current_time as text), 1,5) as time,emp.nombre nombreEmpresa, substring(sed.nit,1,9) nit, substring(sed.nit,9,1) nitVerificacion, sed."codigoHabilitacion" habilita,emp.direccion direccionPrestador, emp.telefono telefonoPrestador, dep.nombre departamentoPrestador, dep."departamentoCodigoDian" codigoDepartamentoPrestador, mun.nombre municipioPrestador FROM facturacion_empresas emp INNER JOIN sitios_sedesclinica sed ON (sed.id=1) INNER JOIN sitios_departamentos dep ON (dep.id=emp.departamento_id) INNER JOIN sitios_municipios mun ON (mun.id = emp.municipio_id) WHERE emp. nombre like (' + "'" + str('%MEDICAL%') + "')"

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
        self.ln(4)
        self.set_font('Times', 'B', 7)
        self.cell(180, 1, 'ANEXO TECNICO No. 2345678', 0, 0, 'C')
        self.ln(1)
        self.cell(180, 11, 'INFORME DE LA ATENCION INICIAL DE URGENCIAS: ', 0, 0, 'C')
        self.set_font('Times', '', 7)

        # Define el ancho de línea
        self.set_line_width(0.4)
        # Dibuja el borde
        self.rect(5.0, 18.0, 200.0, 185.0)  # Coordenadas x, y, ancho, alto
        self.ln(3)
        # Logo
        self.image('C:/EntornosPython/Pos7Particionado/vulner/static/img/MedicalFinal.jpg', 7, 19, 11, 11)
        # Arial bold 15
        self.set_font('Times', 'B', 7)
        self.ln(3)
        self.cell(180, 11, 'MINISTERIO DE LA PROTECCION SOCIAL: ', 0, 0, 'C')
        self.ln(3)
        self.cell(180, 11, 'INFORME DE LA ATENCION INICIAL DE URGENCIAS: ', 0, 0, 'C')
        self.ln(6)
        self.set_font('Times', 'B', 7)
        self.cell(80, 11, 'INFORMACION DEL PRESTADOR: ', 0, 0, 'L')

        self.cell(45, 11, 'NUMERO DE ATENCION: ', 0, 0, 'L')
        self.set_font('Times', '', 7)
        self.set_line_width(0.3)
        #self.rect(135.0, 29.0, 13.0, 3.0)  # Coordenadas x, y, ancho, alto

        #self.cell(15, 11, '527733', 0, 0, 'L')
        self.cell(15, 11, str(self.ingresoId), 0, 0, 'L')
        self.set_font('Times', 'B', 7)
        self.cell(10, 11, 'Fecha: ', 0, 0, 'L')
        self.set_font('Times', '', 7)
        self.cell(25, 11, historia[0]['fecha'], 0, 0, 'L')
        self.set_font('Times', 'B', 7)
        self.cell(10, 11, 'Hora: ', 0, 0, 'L')
        self.set_font('Times', '', 7)
        self.cell(25, 11, historia[0]['time'], 0, 0, 'L')
        self.ln(1)
        self.set_line_width(0.3)
        self.rect(5.0, 36.0, 120.0, 3.0)  # Coordenadas x, y, ancho, alto
        self.cell(120, 23, historia[0]['nombreEmpresa'], 0, 0, 'L')
        self.rect(130.0, 36.0, 70.0, 3.0)  # Coordenadas x, y, ancho, alto
        self.cell(25, 23, 'Nit: ', 0, 0, 'L')
        self.cell(25, 23, 'X', 0, 0, 'L')
        self.cell(20, 23, historia[0]['nit'], 0, 0, 'L')
        self.rect(200.0, 36.0, 5.0, 3.0)  # Coordenadas x, y, ancho, alto
        self.cell(20, 23, historia[0]['nitVerificacion'], 0, 0, 'L')
        self.cell(25, 23, 'CC', 0, 0, 'L')
        self.cell(25, 23, 'Numero', 0, 0, 'L')
        self.cell(25, 23, 'DV', 0, 0, 'L')
        self.ln(3)
        self.set_line_width(0.3)
        #self.rect(5.0, 39.0, 200.0, 6.0)  # Coordenadas x, y, ancho, alto

        self.cell(25, 23, 'Codigo:', 0, 0, 'L')
        self.cell(25, 23, historia[0]['habilita'], 0, 0, 'L')
        self.cell(25, 23, 'Direccion Prestador:', 0, 0, 'L')
        self.cell(25, 23, historia[0]['direccionPrestador'], 0, 0, 'L')
        self.ln(3)
        self.cell(25, 23, 'Telefono:', 0, 0, 'L')
        self.cell(25, 23, historia[0]['telefonoPrestador'], 0, 0, 'L')
        self.ln(3)
        self.set_line_width(0.3)
        self.rect(5.0, 39.0, 200.0, 15.0)  # Coordenadas x, y, ancho, alto
        self.cell(25, 23, 'Indicativo:', 0, 0, 'L')
        self.cell(25, 23, 'Numero:', 0, 0, 'L')
        self.cell(25, 23, 'Departamento:', 0, 0, 'L')
        self.cell(25, 23, historia[0]['departamentoPrestador'], 0, 0, 'L')
        self.cell(25, 23, historia[0]['codigoDepartamentoPrestador'], 0, 0, 'L')
        self.cell(25, 23, 'Municipio:', 0, 0, 'L')
        self.cell(25, 23, historia[0]['municipioPrestador'], 0, 0, 'L')
        self.ln(3)
        self.cell(85, 23, 'Entidad a ala que se le informa (Pagador):', 0, 0, 'L')
        self.cell(25, 23, historia[0]['seInforma'], 0, 0, 'L')
        self.cell(25, 23, 'Codigo):', 0, 0, 'L')
        self.ln(3)

        # Line break
        self.ln(10)


class PDFHojaAdmision(FPDF):
    def __init__(self, tipoDocId, documentoId, consec, ingresoId,  *args, **kwargs):
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

        # Line break
        self.ln(10)

class PDFManilla(FPDF):
    def __init__(self, tipoDocId, documentoId, consec, ingresoId,  *args, **kwargs):
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

        # Line break
        self.ln(10)



def ImprimirAtencionInicialUrgencias(ingresoId2):
    # Instantiation of inherited class
    print("Entre ImprimirAtencionInicialUrgencias ", ingresoId2)


    #ingresoId = request.POST["ingresoId"]
    print("ingresoId2 = ", ingresoId2)
    ingresoId = ingresoId2

    ingresoPaciente = Ingresos.objects.get(id=ingresoId)
    tipoDocId = ingresoPaciente.tipoDoc_id
    print("tipoDocId = ", tipoDocId)
    documentoId = ingresoPaciente.documento_id
    print("documentoId = ", documentoId)
    consec = ingresoPaciente.consec
    print("consec = ", consec)
    pacienteId = Usuarios.objects.get(id=documentoId)
    print("documentoPaciente = ", pacienteId.documento)

    pdf = PDFAtencionInicialUrgencias(tipoDocId, documentoId, consec, ingresoId)
    # pdf = PDFAtencionInicialUrgencias()
    pdf.alias_nb_pages()
    pdf.set_margins(left=10, top=5, right=5)
    pdf.add_page()
    pdf.set_font('Times', '', 8)
    pdf.ln(1)
    linea = 7

    # El propgrama debe preguntar desde que Folio hasta cual Y/O desde que fecha y hasta cual fecha

    # Cursor recorre Laboratorios

    miConexiont = psycopg2.connect(host="192.168.79.133", database="vulner7Particionado", port="5432", user="postgres",
                                   password="123456")
    curt = miConexiont.cursor()

    # comando ='SELECT substring(usu.nombre,1,(position(' + "' '" +  ' in usu.nombre))) primerNombre,substring(usu.nombre, position(' + "' '" +  ' in usu.nombre),10) segundoNombre, 0  primerApellido, 0  segundoApellido , usu."tipoDoc_id" tipoDoc ,usu.documento documento , usu."fechaNacio" fechaNacimiento, usu.direccion direccion, usu.telefono telefono,  dep.nombre departamentoPaciente, mun.nombre municipioPaciente FROM clinico_historia his INNER JOIN admisiones_ingresos ing ON (ing."tipoDoc_id"=his."tipoDoc_id" AND ing.documento_id=his.documento_id and ing.consec=his."consecAdmision") INNER JOIN usuarios_usuarios usu ON (usu."tipoDoc_id"=his."tipoDoc_id" AND usu.id=his.documento_id) INNER JOIN sitios_departamentos dep ON (dep.id=usu.departamentos_id) INNER JOIN sitios_municipios mun ON (mun.id = usu.municipio_id) INNER JOIN clinico_servicios servicios on ( servicios.id=ing."serviciosActual_id") WHERE ing.id = ' + "'" + str(50137) + "'" + ' AND servicios.NOMBRE LIKE (' + "'" + str('%URGENC%') + "')" + ' group by primerNombre, segundoNombre, usu."tipoDoc_id",usu.documento, usu."fechaNacio" , usu.direccion , usu.telefono , dep.nombre , mun.nombre'

    comando = 'SELECT usu."primerNombre"  primerNombre, usu."segundoNombre"  segundoNombre, usu."primerApellido"  primerApellido, usu."segundoApellido" segundoApellido , usu."tipoDoc_id" tipoDoc ,usu.documento documento , usu."fechaNacio" fechaNacimiento, usu.direccion direccion, usu.telefono telefono,  dep.nombre departamentoPaciente, mun.nombre municipioPaciente, regimen.nombre regimen FROM admisiones_ingresos ing INNER JOIN usuarios_usuarios usu ON (usu."tipoDoc_id"=ing."tipoDoc_id" AND usu.id=ing.documento_id) INNER JOIN sitios_departamentos dep ON (dep.id=usu.departamentos_id) INNER JOIN sitios_municipios mun ON (mun.id = usu.municipio_id) INNER JOIN clinico_servicios servicios on ( servicios.id=ing."serviciosActual_id") LEFT JOIN clinico_regimenes regimen ON (regimen.id = ing.regimen_id) WHERE ing.id = ' + "'" + str(
        ingresoId) + "'" + ' AND servicios.NOMBRE LIKE (' + "'" + str(
        '%URGENC%') + "')" + ' group by usu."primerNombre", usu."segundoNombre", usu."primerApellido", usu."segundoApellido", usu."tipoDoc_id",usu.documento, usu."fechaNacio" , usu.direccion , usu.telefono , dep.nombre , mun.nombre, regimen.nombre'

    curt.execute(comando)

    print(comando)

    atencionUrgencias = []

    for primerNombre, segundoNombre, primerApellido, segundoApellido, tipoDoc, documento, fechaNacimiento, direccion, telefono, departamentoPaciente, municipioPaciente, regimen in curt.fetchall():
        atencionUrgencias.append(
            {'primerNombre': primerNombre, 'segundoNombre': segundoNombre, 'primerApellido': primerApellido,
             'segundoApellido': segundoApellido, 'tipoDoc': tipoDoc, 'documento': documento,
             'fechaNacimiento': fechaNacimiento, 'direccion': direccion, 'telefono': telefono,
             'departamentoPaciente': departamentoPaciente, 'municipioPaciente': municipioPaciente, 'regimen': regimen})
    miConexiont.close()

    tipoDocumento = TiposDocumento.objects.get(id=atencionUrgencias[0]['tipoDoc'])
    regimenes = Regimenes.objects.get(nombre=atencionUrgencias[0]['regimen'])

    print("atencionUrgencias = ", atencionUrgencias)
    pdf.set_line_width(0.3)
    # pdf.rect(5.0, 50.0, 200.0, 3.0)  # Coordenadas x, y, ancho, alto

    pdf.set_font('Times', 'B', 7)
    pdf.cell(180, 9, 'DATOS DEL PACIENTE:', 0, 0, 'C')
    pdf.set_font('Times', '', 7)
    pdf.ln(3)
    print("pase_1 con data", atencionUrgencias[0]['primerApellido'])
    pdf.set_line_width(0.3)
    pdf.rect(5.0, 58.0, 50.0, 4.0)  # Coordenadas x, y, ancho, alto
    pdf.cell(50, 11, str(atencionUrgencias[0]['primerApellido']), 0, 0, 'L')
    pdf.rect(55.0, 58.0, 50.0, 4.0)  # Coordenadas x, y, ancho, alto
    pdf.cell(50, 11, str(atencionUrgencias[0]['segundoApellido']), 0, 0, 'L')
    pdf.rect(105.0, 58.0, 50.0, 4.0)  # Coordenadas x, y, ancho, alto
    pdf.cell(50, 11, str(atencionUrgencias[0]['primerNombre']), 0, 0, 'L')
    pdf.rect(155.0, 58.0, 50.0, 4.0)  # Coordenadas x, y, ancho, alto
    pdf.cell(50, 11, str(atencionUrgencias[0]['segundoNombre']), 0, 0, 'L')

    pdf.ln(3)
    pdf.cell(50, 12, 'primerApellido', 0, 0, 'L')
    pdf.cell(50, 12, 'segundorApellido', 0, 0, 'L')
    pdf.cell(50, 12, 'primerNombre', 0, 0, 'L')
    pdf.cell(50, 12, 'segundoNombre', 0, 0, 'L')
    pdf.ln(4)
    pdf.cell(25, 13, 'Tipo Documento Identificacion', 0, 0, 'L')
    pdf.ln(3)
    if tipoDocumento.abreviatura == 'RC':
        pdf.cell(5, 14, 'X', 0, 0, 'L')
    pdf.cell(50, 14, 'Registro Civil', 0, 0, 'L')
    if tipoDocumento.abreviatura == 'PA':
        pdf.cell(5, 14, 'X', 0, 0, 'L')
    pdf.cell(50, 14, 'Pasaporte', 0, 0, 'L')
    # pdf.rect(100.0, 70.0, 40.0, 4.0)  # Coordenadas x, y, ancho, alto
    pdf.cell(25, 14, str(atencionUrgencias[0]['documento']), 0, 0, 'L')
    if tipoDocumento.abreviatura == 'TI':
        pdf.cell(5, 15, 'X', 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(50, 15, 'Tarjeta de Identidad', 0, 0, 'L')
    if tipoDocumento.abreviatura == 'NN':
        pdf.cell(5, 15, 'X', 0, 0, 'L')
    pdf.cell(50, 15, 'Adulto sin Identificacion', 0, 0, 'L')
    pdf.cell(25, 15, 'Numero de Documento de Identificacion', 0, 0, 'L')
    pdf.ln(3)
    if tipoDocumento.abreviatura == 'CC':
        pdf.cell(5, 16, 'X', 0, 0, 'L')
    pdf.cell(50, 16, 'Cedula de ciudadania', 0, 0, 'L')
    if tipoDocumento.abreviatura == 'NN':
        pdf.cell(5, 16, 'X', 0, 0, 'L')
    pdf.cell(50, 16, 'Menor sin identificacion', 0, 0, 'L')
    pdf.ln(3)
    if tipoDocumento.abreviatura == 'CE':
        pdf.cell(5, 17, 'X', 0, 0, 'L')
    pdf.cell(120, 17, 'Cedula de extranjeria', 0, 0, 'L')
    pdf.cell(25, 17, 'Fecha de nacimiento', 0, 0, 'L')
    pdf.cell(35, 17, str(atencionUrgencias[0]['fechaNacimiento']), 0, 0, 'L')

    # pdf.cell(25, 14, 'Numero de Documento de Identificacion', 0, 0, 'L')

    # pdf.rect(5.0, 65.0, 200.0, 4.0)  # Coordenadas x, y, ancho, alto
    pdf.ln(3)
    pdf.cell(35, 18, 'Direccion de residencia habitual', 0, 0, 'L')
    pdf.cell(100, 18, str(atencionUrgencias[0]['direccion']), 0, 0, 'L')
    pdf.cell(25, 18, 'Telefono', 0, 0, 'L')
    pdf.cell(25, 18, str(atencionUrgencias[0]['telefono']), 0, 0, 'L')
    # pdf.rect(150.0, 58.0, 58.0, 4.0)  # Coordenadas x, y, ancho, alto
    pdf.ln(3)
    pdf.cell(60, 20, 'Departamento', 0, 0, 'L')
    pdf.cell(25, 20, str(atencionUrgencias[0]['departamentoPaciente']), 0, 0, 'L')
    pdf.cell(25, 20, 'Municipio', 0, 0, 'L')
    pdf.cell(25, 20, str(atencionUrgencias[0]['municipioPaciente']), 0, 0, 'L')
    pdf.ln(3)
    pdf.set_line_width(0.3)
    # pdf.rect(5.0, 85.0, 200.0, 10.0)  # Coordenadas x, y, ancho, alto
    pdf.rect(5.0, 95.0, 200.0, 12.0)  # Coordenadas x, y, ancho, alto
    pdf.ln(3)
    pdf.cell(35, 23, 'Cobertura en salud', 0, 0, 'L')
    pdf.ln(3)
    if regimenes.nombre == 'CONTRIBUTIVO':
        pdf.cell(5, 26, 'X', 0, 0, 'L')
    pdf.cell(35, 26, 'Regimen Contributtivo', 0, 0, 'L')
    if regimenes.nombre == 'SUBSIDIADO':
        pdf.cell(5, 26, 'X', 0, 0, 'L')
    pdf.cell(35, 26, 'Regimen subsidiado parcial', 0, 0, 'L')
    pdf.cell(65, 26, 'Poblacion pobre No asegurada con sisben', 0, 0, 'L')
    pdf.cell(35, 26, 'Plan adicional en salud', 0, 0, 'L')
    pdf.ln(3)
    if regimenes.nombre == 'SUBSIDIADO':
        pdf.cell(5, 27, 'X', 0, 0, 'L')
    pdf.cell(35, 27, 'Regimen subsidiado total', 0, 0, 'L')
    pdf.cell(65, 27, 'Poblacion pobre No asegurada sin sisben', 0, 0, 'L')
    pdf.cell(45, 27, 'Desplazado', 0, 0, 'L')
    if (regimenes.nombre != 'SUBSIDIADO' or regimenes.nombre != 'CONTRIBUTIVO' or regimenes.nombre != 'VINCULADO'):
        pdf.cell(5, 27, 'X', 0, 0, 'L')
    pdf.cell(35, 27, 'Otro', 0, 0, 'L')
    pdf.ln(3)
    pdf.set_line_width(0.3)
    # pdf.rect(5.0, 98.0, 200.0, 3.0)  # Coordenadas x, y, ancho, alto
    pdf.set_font('Times', 'B', 7)

    miConexiont = psycopg2.connect(host="192.168.79.133", database="vulner7Particionado", port="5432", user="postgres",
                                   password="123456")
    curt = miConexiont.cursor()

    comando = 'select ext.id id ,ext.nombre causa from admisiones_ingresos ing inner join clinico_causasexterna ext on (ext.id=ing."causasExterna_id") where ing.id= ' + "'" + str(
        ingresoId) + "'"

    curt.execute(comando)

    print(comando)

    externaUrgencias = []

    for id, causa in curt.fetchall():
        externaUrgencias.append(
            {'id': id, 'causa': causa})
    miConexiont.close()

    miConexiont = psycopg2.connect(host="192.168.79.133", database="vulner7Particionado", port="5432", user="postgres",
                                   password="123456")
    curt = miConexiont.cursor()

    comando = 'select tri.id id ,tri."clasificacionTriage_id" triage from triage_triage tri WHERE tri."tipoDoc_id" = ' + "'" + str(
        tipoDocId) + "'" + ' and tri.documento_id = ' + "'" + str(
        documentoId) + "'" + ' and tri."consecAdmision" = ' + "'" + str(consec) + "'"

    curt.execute(comando)

    print(comando)

    triageUrgencias = []

    for id, triage in curt.fetchall():
        triageUrgencias.append(
            {'id': id, 'triage': triage})

    print("triageUrgencias = ", triageUrgencias)
    miConexiont.close()

    pdf.cell(200, 30, 'INFORMACION DE LA ATENCION', 0, 0, 'C')
    pdf.set_font('Times', '', 7)
    pdf.ln(3)

    pdf.rect(5.0, 115.0, 200.0, 14.0)  # Coordenadas x, y, ancho, alto
    pdf.set_font('Times', 'B', 7)
    pdf.cell(25, 32, 'Origen de la atencion', 0, 0, 'L')
    pdf.ln(2)
    pdf.set_font('Times', '', 7)
    pdf.ln(3)
    pdf.cell(25, 34, 'Enfermedad General', 0, 0, 'L')
    if externaUrgencias[0]['causa'] == 'ENFERMEDAD GENERAL':
        pdf.cell(34, 27, 'X', 0, 0, 'L')
    if externaUrgencias[0]['causa'] == 'ACCIDENTE DE TRABAJO':
        pdf.cell(34, 27, 'X', 0, 0, 'L')
    pdf.cell(25, 34, 'Accidente de trabajo', 0, 0, 'L')
    if externaUrgencias[0]['causa'] == 'EVENTO CATASTROFICO':
        pdf.cell(27, 34, 'X', 0, 0, 'L')
    pdf.cell(30, 34, 'Evento Catastrofico', 0, 0, 'L')
    if triageUrgencias[0]['triage'] == '1':
        pdf.cell(5, 27, 'X', 0, 0, 'L')
    pdf.cell(40, 27, '', 0, 0, 'L')
    pdf.cell(15, 27, '1. Rojo', 0, 0, 'L')
    pdf.ln(3)

    pdf.cell(25, 35, 'Enfermedad Profesional', 0, 0, 'L')
    if externaUrgencias[0]['causa'] == 'ENFERMEDAD PROFESIONAL':
        pdf.cell(25, 35, 'X', 0, 0, 'L')

    pdf.cell(25, 35, 'Accidente de transito', 0, 0, 'L')
    if externaUrgencias[0]['causa'] == 'ACCIDENTE DE TRANSITO':
        pdf.cell(27, 35, 'X', 0, 0, 'L')

    if externaUrgencias[0]['causa'] == 'OTROS':
        pdf.cell(27, 35, 'X', 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(70, 35, 'Otro tipo de accidente', 0, 0, 'L')

    pdf.cell(40, 30, '', 0, 0, 'L')
    pdf.cell(15, 28, '2. Naranja', 0, 0, 'L')
    if triageUrgencias[0]['triage'] == '2':
        pdf.cell(137, 28, 'X', 0, 0, 'L')
    pdf.ln(1)
    pdf.cell(70, 29, '', 0, 0, 'L')
    pdf.cell(40, 29, 'Clasificacion Triage', 0, 0, 'L')
    pdf.cell(10, 29, '3. Amarillo', 0, 0, 'L')
    if triageUrgencias[0]['triage'] == '3':
        pdf.cell(137, 29, 'X', 0, 0, 'L')
    pdf.ln(1)
    pdf.cell(120, 30, '', 0, 0, 'L')
    pdf.cell(15, 30, '4. Verde', 0, 0, 'L')
    if triageUrgencias[0]['triage'] == '4':
        pdf.cell(137, 30, 'X', 0, 0, 'L')
    pdf.ln(1)
    pdf.cell(120, 31, '', 0, 0, 'L')
    pdf.cell(15, 31, '5. Azul', 0, 0, 'L')
    if triageUrgencias[0]['triage'] == '5':
        pdf.cell(137, 31, 'X', 0, 0, 'L')

    pdf.set_line_width(0.3)
    # pdf.rect(5.0, 105.0, 200.0, 3.0)  # Coordenadas x, y, ancho, alto
    pdf.rect(5.0, 130.0, 200.0, 14.0)  # Coordenadas x, y, ancho, alto
    pdf.ln(3)
    pdf.cell(35, 37, 'Ingreso a Urgencias', 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(15, 38, 'Fecha', 0, 0, 'L')
    pdf.cell(10, 38, 'Hora', 0, 0, 'L')
    pdf.cell(35, 38, 'Paciente viene Remitido', 0, 0, 'L')
    pdf.cell(5, 38, 'Si', 0, 0, 'L')
    pdf.cell(35, 38, 'Paciente viene Remitido', 0, 0, 'L')
    pdf.ln(3)
    pdf.set_line_width(0.3)
    # pdf.rect(5.0, 107.0, 200.0, 3.0)  # Coordenadas x, y, ancho, alto
    pdf.cell(55, 39, 'Nombre del prestador de servicios que remite:', 0, 0, 'L')
    pdf.cell(5, 39, 'Codigo:', 0, 0, 'L')

    pdf.ln(3)
    pdf.set_line_width(0.3)
    # pdf.rect(5.0, 109.0, 200.0, 3.0)  # Coordenadas x, y, ancho, alto
    # pdf.cell(200, 40, 'Motivo de consulta', 0, 0, 'C')
    pdf.set_line_width(0.3)
    pdf.rect(5.0, 112.0, 200.0, 3.0)  # Coordenadas x, y, ancho, alto
    pdf.ln(4)
    pdf.rect(5.0, 147.0, 200.0, 10.0)  # Coordenadas x, y, ancho, alto
    pdf.cell(200, 42, 'Examen Fisico', 0, 0, 'C')
    pdf.ln(2)

    pdf.cell(20, 44, 'Signos Vitales', 0, 0, 'L')
    pdf.cell(5, 44, 'FC', 0, 0, 'L')
    pdf.cell(15, 44, 'FR', 0, 0, 'L')
    pdf.cell(15, 44, 'TA', 0, 0, 'L')
    pdf.cell(15, 44, 'TA', 0, 0, 'L')
    pdf.cell(15, 44, 'Glasgow', 0, 0, 'L')
    pdf.cell(15, 44, 'Temp:', 0, 0, 'L')
    pdf.cell(15, 44, 'Peso:', 0, 0, 'L')
    pdf.ln(3)
    pdf.set_line_width(0.3)
    # pdf.rect(5.0, 105.0, 200.0, 20.0)  # Coordenadas x, y, ancho, alto
    pdf.ln(3)

    pdf.set_line_width(0.3)
    # pdf.rect(5.0, 150.0, 200.0, 12.0)  # Coordenadas x, y, ancho, alto
    pdf.cell(35, 47, 'Impresion Diagnostica', 0, 0, 'L')
    pdf.cell(15, 47, 'Codigo', 0, 0, 'L')
    pdf.cell(25, 47, 'Descripcion', 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(15, 48, 'Diagnostico Principal', 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(15, 49, 'Relacionado 1', 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(15, 50, 'Relacionado 2', 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(15, 51, 'Relacionado 3', 0, 0, 'L')
    pdf.set_line_width(0.3)
    # pdf.rect(5.0, 143.0, 200.0, 8.0)  # Coordenadas x, y, ancho, alto
    pdf.ln(3)
    pdf.rect(5.0, 177.0, 200.0, 9.0)  # Coordenadas x, y, ancho, alto
    pdf.cell(15, 54, 'Destino del paciente', 0, 0, 'L')
    pdf.set_font('Times', '', 7)
    pdf.ln(2)
    pdf.cell(45, 56, 'Domicilio', 0, 0, 'L')
    pdf.cell(45, 56, 'Internacion', 0, 0, 'L')
    pdf.cell(45, 56, 'ContraRemision', 0, 0, 'L')
    pdf.ln(2)
    pdf.cell(45, 58, 'Observacion', 0, 0, 'L')
    pdf.cell(45, 58, 'Remision', 0, 0, 'L')
    pdf.cell(45, 58, 'Otro', 0, 0, 'L')
    pdf.set_line_width(0.3)
    # pdf.rect(5.0, 125.0, 200.0, 10.0)  # Coordenadas x, y, ancho, alto
    pdf.ln(3)
    pdf.set_font('Times', 'B', 7)
    pdf.cell(200, 62, 'INFORMACION DE LA PERSONA QUE INFORMA', 0, 0, 'C')
    pdf.set_font('Times', '', 7)
    pdf.ln(3)
    pdf.cell(75, 63, 'Nombre de quien informa', 0, 0, 'L')
    pdf.cell(35, 63, 'Telefono', 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(35, 63, 'Indicativo', 0, 0, 'L')
    pdf.cell(35, 63, 'Numero', 0, 0, 'L')
    pdf.cell(35, 63, 'Extension', 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(35, 64, 'Cargo o Actividad', 0, 0, 'L')
    pdf.cell(35, 64, 'Telefono Celular', 0, 0, 'L')

    # pdf.output('C:/EntornosPython/temporal/temporal/atencionInicialUrgencias.pdf', 'F')

    linea = linea + 3
    pdf.ln(3)

    carpeta = 'C:\\EntornosPython\\Pos7Particionado\\vulner\\JSONCLINICA\\HistoriasClinicas\\'
    print("carpeta = ", carpeta)

    archivo = carpeta + '' + str(pacienteId.documento) + '_' + 'AtencionInicialUrgencias.pdf'
    print("archivo =", archivo)

    pdf.output(archivo, 'F')

    try:
        # Intenta abrir el archivo directamente
        #webbrowser.open(archivo)


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


def ImprimirHojaAdmision(ingresoId):
    # Instantiation of inherited class

    print("ingresoId = ", ingresoId)

    print("Entre ImprimirHojaAdmision ", ingresoId)
    #ingresoId = request.POST["ingresoId"]

    ingresoPaciente = Ingresos.objects.get(id=ingresoId)
    tipoDocId = ingresoPaciente.tipoDoc_id
    print("tipoDocId = ", tipoDocId)
    documentoId = ingresoPaciente.documento_id
    print("documentoId = ", documentoId)
    consec = ingresoPaciente.consec
    print("consec = ", consec)
    pacienteId = Usuarios.objects.get(id=documentoId)
    print("documentoPaciente = ", pacienteId.documento)

    pdf = PDFHojaAdmision(tipoDocId, documentoId, consec, ingresoId)
    pdf.alias_nb_pages()
    pdf.set_margins(left=10, top=5, right=5)
    pdf.add_page()
    pdf.set_font('Times', '', 8)
    pdf.ln(1)
    linea = 7

    miConexiont = psycopg2.connect(host="192.168.79.133", database="vulner7Particionado", port="5432", user="postgres",
                                   password="123456")
    curt = miConexiont.cursor()

    comando = 'SELECT ing.id id , to_char(ing."fechaIngreso",' + "'" + str('YYYY-MM-DD') + "')" + ' fechaIngreso, to_char (ing."fechaIngreso" , ' + "'" + str('HH:MM:SS') + "')" + '  horaIngreso, dep.numero cama, serv.nombre servIngreso, ext.nombre causaExterna,ing."numManilla" manilla, usu.nombre nombrePaciente, tipDoc.nombre tipDoc, usu.documento documento, ocupa.nombre ocupacion, estCivil.nombre estadoCivil, regimen.nombre regimen, mun.nombre municipio,  local.nombre localidad,usu.direccion direccion ,usu.telefono telefono, usu.correo correo, diag.nombre diagnostico , to_char(usu."fechaNacio", ' + "'" + str('YYYY-MM-DD')  + "')" + ' nacio, cast((cast(now() as date)  - cast(usu."fechaNacio" as date)) as text)   edad, usu.genero sexo  FROM admisiones_ingresos ing INNER JOIN sitios_dependencias dep ON (dep."tipoDoc_id" = ing."tipoDoc_id" AND dep.documento_id = ing.documento_id AND ing.consec=dep.consec) INNER JOIN clinico_servicios serv ON (serv.id = ing."serviciosIng_id") LEFT JOIN clinico_causasexterna ext ON (ext.id = ing."causasExterna_id") INNER JOIN usuarios_usuarios usu ON (usu.id=ing.documento_id) LEFT JOIN usuarios_tiposdocumento tipDoc ON (tipDoc.id = ing."tipoDoc_id") LEFT JOIN basicas_ocupaciones ocupa ON (ocupa.id = usu.ocupacion_id) LEFT JOIN basicas_estadocivil estCivil ON (estCivil.id = usu."estadoCivil_id") LEFT JOIN clinico_regimenes regimen ON (regimen.id = ing.regimen_id)	LEFT JOIN sitios_municipios mun ON (mun.id=usu.municipio_id)	LEFT JOIN sitios_localidades local ON (local.id=usu.localidad_id) LEFT JOIN clinico_diagnosticos diag ON (diag.id=ing."dxIngreso_id") WHERE ing.id = ' + "'" + str(ingresoId) + "'"

    print(comando)

    curt.execute(comando)

    print(comando)

    hospitalizacion = []

    for id, fechaIngreso, horaIngreso, cama, servIngreso,causaExterna,manilla,nombrePaciente,tipDoc, documento, ocupacion, estadoCivil, regimen, municipio, localidad, direccion, telefono, correo, diagnostico ,nacio, edad, sexo in curt.fetchall():
        hospitalizacion.append(
            {'id':id, 'fechaIngreso': fechaIngreso, 'horaIngreso': horaIngreso,'cama':cama,'servIngreso':servIngreso,'causaExterna':causaExterna,
             'manilla': manilla,'nombrePaciente':nombrePaciente,'tipDoc':tipDoc,'documento':documento,  'ocupacion':ocupacion,'estadoCivil':estadoCivil,
             'regimen':regimen,'municipio':municipio, 'localidad':localidad,'direccion':direccion, 'telefono':telefono,'correo':correo,'diagnostico':diagnostico,
             'nacio':nacio, 'edad':edad,'sexo':sexo
             })

    miConexiont.close()
    print("hospitalizacion = ",hospitalizacion )


    # Define el ancho de línea
    pdf.set_line_width(0.4)
    # Dibuja el borde
    pdf.rect(5.0, 18.0, 200.0, 185.0)  # Coordenadas x, y, ancho, alto
    # Logo
    pdf.image('C:/EntornosPython/Pos7Particionado/vulner/static/img/MedicalFinal.jpg', 7, 19, 11, 11)
    # Arial bold 15
    pdf.set_font('Times', 'B', 9)
    pdf.ln(3)
    pdf.cell(200, 25, 'HOJA DE ADMISION DEL PACIENTE', 0, 0, 'C')
    pdf.set_font('Times', '', 7)
    pdf.ln(1)

    pdf.cell(15, 25, 'Admision:', 0, 0, 'L')
    pdf.cell(15, 25, str(hospitalizacion[0]['id']), 0, 0, 'L')

    pdf.ln(3)
    #pdf.rect(5.0, 102.0, 200.0, 30.0)  # Coordenadas x, y, ancho, alto
    pdf.set_font('Times', 'B', 7)
    #pdf.cell(25, 25, 'Admision:', 0, 0, 'L')
    #pdf.ln(3)
    #pdf.rect(200.0, 26, 200.0, 15.0)  # Coordenadas x, y, ancho, alto
    pdf.cell(30, 26, 'Fecha Ingreso:', 0, 0, 'L')
    pdf.cell(15, 26, hospitalizacion[0]['fechaIngreso'], 0, 0, 'L')

    pdf.cell(20, 26, 'Hora Ingreso:', 0, 0, 'L')
    pdf.cell(15, 26, hospitalizacion[0]['horaIngreso'], 0, 0, 'L')
    pdf.cell(20, 26, 'Servicio:', 0, 0, 'L')
    pdf.cell(35, 26, hospitalizacion[0]['servIngreso'], 0, 0, 'L')

    pdf.cell(15, 26, 'Cama:', 0, 0, 'L')
    pdf.cell(25, 26, hospitalizacion[0]['cama'], 0, 0, 'L')
    pdf.ln(3)
    pdf.set_font('Times', '', 7)
    #pdf.rect(200.0, 27, 200.0, 15.0)  # Coordenadas x, y, ancho, alto
    pdf.cell(25, 28, 'Via Ingreso:', 0, 0, 'L')
    pdf.cell(20, 28, 'Causa Externa:', 0, 0, 'L')
    pdf.cell(80, 28, hospitalizacion[0]['causaExterna'], 0, 0, 'L')
    pdf.cell(230, 28, 'Manilla de Identificacion#:', 0, 0, 'L')
    pdf.cell(20, 28, hospitalizacion[0]['manilla'], 0, 0, 'L')
    pdf.set_font('Times', 'B', 7)
    pdf.ln(3)
    #pdf.rect(200.0, 29, 200.0, 50.0)  # Coordenadas x, y, ancho, alto

    pdf.cell(30, 29, 'Apellidos y Nombres:', 0, 0, 'L')
    pdf.cell(100, 29, hospitalizacion[0]['nombrePaciente'], 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(50, 30, 'Historia Clinica:', 0, 0, 'L')
    pdf.cell(30, 30, hospitalizacion[0]['tipDoc'], 0, 0, 'L')
    pdf.cell(20, 30, hospitalizacion[0]['documento'], 0, 0, 'L')
    pdf.ln(3)
    pdf.image('C:/EntornosPython/Pos7Particionado/vulner/static/img/CIRUGIAFINAL.JPG', 140, 45, 30, 30)
    pdf.cell(50, 31, 'Fecha de Nacimiento:', 0, 0, 'L')
    pdf.cell(20, 31, hospitalizacion[0]['nacio'], 0, 0, 'L')
    pdf.cell(8, 31, 'Edad:', 0, 0, 'L')
    pdf.cell(5, 31, hospitalizacion[0]['edad'], 0, 0, 'L')
    pdf.cell(8, 31, 'Sexo:', 0, 0, 'L')
    pdf.cell(5, 31, hospitalizacion[0]['sexo'], 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(50, 32, 'Ocupacion:', 0, 0, 'L')
    pdf.cell(30, 32, str(hospitalizacion[0]['ocupacion']), 0, 0, 'L')
    pdf.cell(15, 32, 'Estado Civil:', 0, 0, 'L')
    pdf.cell(30, 32, str(hospitalizacion[0]['estadoCivil']), 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(100, 33, 'SEGURIDAD SOCIAL:', 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(50, 34, 'Regimen:', 0, 0, 'L')
    pdf.cell(20, 34, hospitalizacion[0]['regimen'], 0, 0, 'L')
    pdf.cell(50, 34, 'Usuario:', 0, 0, 'L')
    pdf.cell(10, 34, '', 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(50, 34, 'Nivel:', 0, 0, 'L')
    pdf.cell(50, 35, 'Poblacion especial:', 0, 0, 'L')

    ## ENTIDADES RESPONSABLE

    miConexiont = psycopg2.connect(host="192.168.79.133", database="vulner7Particionado", port="5432", user="postgres",
                                   password="123456")
    curt = miConexiont.cursor()


    comando = 'SELECT conv.nombre convenio FROM admisiones_ingresos ing LEFT JOIN facturacion_conveniospacienteingresos convPac ON (convPac."tipoDoc_id" = ing."tipoDoc_id" AND convPac.documento_id = ing.documento_id AND convPac."consecAdmision" = ing.consec) LEFT JOIN contratacion_convenios conv ON (conv.id = convPac.convenio_id) WHERE ing.id= ' + "'" + str(ingresoId) + "'"

    curt.execute(comando)

    print(comando)

    entidadesResponsables = []

    for convenio  in curt.fetchall():
        entidadesResponsables.append(
            {'convenio': convenio })

    miConexiont.close()

    pdf.ln(12)
    pdf.cell(50, 36, 'ENTIDADES RESPONSABLES:', 0, 0, 'L')
    pdf.cell(50, 37, '1.-', 0, 0, 'L')
    #pdf.cell(10, 37, entidadesResponsables[0]['convenio'], 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(50, 38, '2.-', 0, 0, 'L')
    #pdf.cell(10, 38, entidadesResponsables[0]['convenio'], 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(50, 39, '3.-', 0, 0, 'L')
    #pdf.cell(10, 39, entidadesResponsables[0]['convenio'], 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(50, 40, '4.-', 0, 0, 'L')
    #pdf.cell(10, 40, entidadesResponsables[0]['convenio'], 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(30, 41, 'Direccion del sitio de vivienda:', 0, 0, 'L')
    pdf.cell(30, 41, hospitalizacion[0]['direccion'], 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(20, 41, 'Telefono:', 0, 0, 'L')
    pdf.cell(30, 41, hospitalizacion[0]['telefono'], 0, 0, 'L')
    pdf.cell(30, 41, 'Municipio:', 0, 0, 'L')
    pdf.cell(30, 41, hospitalizacion[0]['municipio'], 0, 0, 'L')
    pdf.cell(30, 41, 'Zona:', 0, 0, 'L')
    pdf.cell(30, 41, hospitalizacion[0]['localidad'], 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(100, 42, 'Localidad:', 0, 0, 'L')
    pdf.cell(30, 42, hospitalizacion[0]['localidad'], 0, 0, 'L')
    pdf.cell(20, 43, 'Correo Electronico:', 0, 0, 'L')
    pdf.cell(30, 43, str(hospitalizacion[0]['correo']), 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(100, 45, 'DATOS DEL ACCIDENTE:', 0, 0, 'L')
    pdf.cell(100, 46, 'Direccion del accidente', 0, 0, 'L')
    pdf.cell(100, 47, 'Municipio del accidente', 0, 0, 'L')
    pdf.cell(100, 47, 'Condiciones del accidentado', 0, 0, 'L')
    pdf.cell(100, 48, 'Descripcion del accidente', 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(30, 50, 'Impresion Dx comentada', 0, 0, 'L')
    pdf.cell(100, 50, hospitalizacion[0]['diagnostico'], 0, 0, 'L')
    pdf.cell(30, 51, 'Servicio solicitado', 0, 0, 'L')
    pdf.ln(2)

    miConexiont = psycopg2.connect(host="192.168.79.133", database="vulner7Particionado", port="5432", user="postgres",
                                   password="123456")
    curt = miConexiont.cursor()

    comando = 'SELECT usuContacto.nombre nombre, usuContacto.direccion direccion,usuContacto.telefono telefono,tiposFamilia.nombre tiposFamilia  FROM admisiones_ingresos ing LEFT JOIN usuarios_usuarioscontacto usuContacto ON (usuContacto.id = ing."contactoResponsable_id") LEFT JOIN basicas_tiposfamilia tiposFamilia ON (tiposFamilia.id = usuContacto."tiposFamilia_id") WHERE ing.id= ' + "'" + str(ingresoId) + "'"
    print(comando)
    curt.execute(comando)


    responsablePaciente = []

    for nombre, direccion, telefono, tiposFamilia in curt.fetchall():
        responsablePaciente.append(
            {'nombre': nombre,'direccion':direccion,'telefono':telefono, 'tiposFamilia':tiposFamilia  })

    miConexiont.close()

    pdf.cell(100, 53, 'Responsable del paciente', 0, 0, 'L')
    #pdf.cell(10, 53, responsablePaciente[0]['nombre'], 0, 0, 'L')
    pdf.cell(100, 53, 'L.D', 0, 0, 'L')
    pdf.cell(100, 53, 'Parentesco', 0, 0, 'L')
    #pdf.cell(10, 53, responsablePaciente[0]['tiposFamilia'], 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(100, 54, 'Direccion:', 0, 0, 'L')
    #pdf.cell(10, 54, responsablePaciente[0]['direccion'], 0, 0, 'L')
    pdf.cell(100, 54, 'Telefono:', 0, 0, 'L')
    #pdf.cell(10, 54, responsablePaciente[0]['telefono'], 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(100, 55, 'Usuario Capitado:', 0, 0, 'L')
    pdf.cell(100, 55, 'Responsable Admision:', 0, 0, 'L')
    pdf.ln(8)
    #pdf.rect(200.0, 49, 200.0, 100.0)  # Coordenadas x, y, ancho, alto

    pdf.set_font('Times', 'B', 9)


    textoImpresion1 = '(Ley 1438 del 2011 Art. 143 Según Circular externa 0000033 de 2011 del MINISTERIO DE LA PROTECCION SOCIAL y Resolución 1915 del 2008). La informacion aquí registrada del evento catalogado como accidente de transito, es declarada bajo la gravedad de juramento por el usuario: con documento de identificación numero:'
    textoImpresion2 = 'quien reside en la dirección: '
    textoImpresion3 = 'Barrio: '
    textoImpresion4 = 'Municipio de: '
    textoImpresion5 = 'en calidad de paciente y/o acudiente del paciente:___________________________ con documento de identificación numero:_______________, '
    textoImpresion6 = 'donde resulto afectado por vehiculo automotor en movimiento.: - Mediante la firma de esta declaración, confirma la veracidad y exactitud de las declaraciones que formula y , manifestando que nada ha ocultado ,omitido o alterado y se da por enterado que esta declaración constituye para la Compañía prestadora de servcicios en salud información determinante del siniestro , provocándolo intencionalmente, presentándolo ante el asegurador como ocurrido por causas o en circunstancias distintas a las verdaderas, ocultando la cosa asegurada o aumentando fraudulentamente las pérdidas efectivamente sufridas, incurre en el delito de fraude al seguro establecido en el artículo 470, número 10 del código final.g o en mi representacion __________________________________________ identificado con ___________________ '
    textoImpresion7 = 'Declaro que la informacion y/o documentacion aportada y consignada en el presente formato es cierta, veraz y verificable; razón por la cual autorizo su posterior verificacion por parte de la aseguradora y de la misma institucion. Teniendo en cuenta el artículo 9 de la Ley 1581 de 2012 “Por la cual se dictan disposiciones generales para la proteccion de datos personales”, autorizo expresamente a la Clínica Medical S.A.S. a divulgar la informacion aqui reposada tanto internamente como a EPS, aseguradoras, entes de control y demas entidades que la requieran y que esten autorizadas para tal fin, siempre y cuando dicha divulgacion este relacionada con los motivos por los cuales recibí tratamiento en esta Institucion prestadora de salud. De igual'

    pdf.multi_cell(w=0, h=4, txt=textoImpresion1, border=0, align='J', fill=False)           
    pdf.ln(2)
    pdf.multi_cell(w=0, h=4, txt=textoImpresion2, border=0, align='J', fill=False)      
    # Aqui va la direccion del paciente
    pdf.ln(2)
    pdf.multi_cell(w=0, h=4, txt=textoImpresion3, border=0, align='J', fill=False)      
    # Aqui va el barrio
    pdf.multi_cell(w=0, h=4, txt=textoImpresion4, border=0, align='J', fill=False)      
    # Aqui va el municipio
    pdf.ln(2)
    pdf.multi_cell(w=0, h=4, txt=textoImpresion5, border=0, align='J', fill=False)      
    pdf.ln(2)
    pdf.multi_cell(w=0, h=4, txt=textoImpresion6, border=0, align='J', fill=False)      
    pdf.ln(7)
    pdf.multi_cell(w=0, h=4, txt=textoImpresion7, border=0, align='J', fill=False)      
    pdf.ln(4)
    pdf.cell(30, 68,
             'Nombre Completo:',
             0, 0, 'L')
    pdf.cell(40, 68, hospitalizacion[0]['nombrePaciente'], 0, 0, 'L')

    pdf.ln(4)
    pdf.cell(30, 69,
             'Identificacion:',
             0, 0, 'L')
    pdf.cell(40, 69, hospitalizacion[0]['documento'], 0, 0, 'L')

    pdf.ln(4)
    pdf.cell(30, 70,
             'Parentesco:',
             0, 0, 'L')
    pdf.cell(40, 70, 'PACIENTE', 0, 0, 'L')

    #pdf.output('C:/EntornosPython/temporal/temporal/hojaAdmision.pdf', 'F')

    linea = linea + 3
    pdf.ln(5)

    #carpeta = 'C:\EntornosPython\Pos7Particionado\vulner\JSONCLINICA\HistoriasClinicas\'
    carpeta = 'C:\\EntornosPython\\Pos7Particionado\\vulner\\JSONCLINICA\\HistoriasClinicas\\'
    print("carpeta = ", carpeta)

    archivo = carpeta + '' + str(pacienteId.documento) + '_' + 'HojaAdmision.pdf'
    print("archivo =", archivo)

    pdf.output(archivo, 'F')

    try:
        # Intenta abrir el archivo directamente
        #webbrowser.open(archivo)


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

    return JsonResponse({'success': True, 'message': 'Hoja Admsision impresa!'})


def ImprimirManilla(ingresoId):
    # Instantiation of inherited class

    print("ingresoId = ", ingresoId)

    # ingresoId = request.POST["ingresoId"]

    ingresoPaciente = Ingresos.objects.get(id=ingresoId)
    tipoDocId = ingresoPaciente.tipoDoc_id
    print("tipoDocId = ", tipoDocId)
    documentoId = ingresoPaciente.documento_id
    print("documentoId = ", documentoId)
    consec = ingresoPaciente.consec
    print("consec = ", consec)
    pacienteId = Usuarios.objects.get(id=documentoId)
    print("documentoPaciente = ", pacienteId.documento)

    miConexiont = psycopg2.connect(host="192.168.79.133", database="vulner7Particionado", port="5432", user="postgres",
                                   password="123456")


    curt = miConexiont.cursor()

    comando = 'SELECT tipo.abreviatura abrev, usu.documento documento, usu."primerNombre",usu."segundoNombre",usu."primerApellido", usu."segundoApellido", cast((cast(now() as date)  - cast(usu."fechaNacio" as date)) as text)   edad , usu.genero sexo, ing."fechaIngreso" fechaIngreso FROM admisiones_ingresos ing INNER JOIN usuarios_usuarios usu ON (usu.id=ing.documento_id) INNER JOIN usuarios_tiposdocumento tipo ON (tipo.id = usu."tipoDoc_id") WHERE ing.id= ' + "'" + str(
        ingresoId) + "'"
    print(comando)

    curt.execute(comando)

    print(comando)

    manilla = []

    for abrev, documento, primerNombre, segundoNombre, primerApellido, segundoApellido, edad, sexo, fechaIngreso in curt.fetchall():
        manilla.append(
            {'abrev': abrev, 'documento': documento, 'primerNombre': primerNombre, 'segundoNombre': segundoNombre,
             'primerApellido': primerApellido, 'segundoApellido': segundoApellido,
             'edad': edad, 'sexo': sexo, "fechaIngreso": fechaIngreso})

    miConexiont.close()
    print("manilla = ", manilla)

    pdf = PDFManilla(tipoDocId, documentoId, consec, ingresoId)
    pdf.alias_nb_pages()
    pdf.set_margins(left=10, top=5, right=5)
    pdf.add_page()
    pdf.set_font('Times', '', 8)
    pdf.ln(1)
    linea = 7


    # Define el ancho de línea
    pdf.set_line_width(0.4)
    # Dibuja el borde
    pdf.rect(5.0, 15.0, 200.0, 50.0)  # Coordenadas x, y, ancho, alto

    pdf.set_font('Times', 'B', 9)
    pdf.ln(3)
    pdf.cell(5, 30, 'Nombres:', 0, 0, 'C')
    pdf.set_font('Times', '', 7)
    pdf.cell(25, 30, str(manilla[0]['primerNombre']), 0, 0, 'L')
    pdf.cell(25, 30, str(manilla[0]['segundoNombre']), 0, 0, 'L')
    pdf.cell(5, 30, 'Apellidos:', 0, 0, 'C')
    pdf.set_font('Times', '', 7)
    pdf.cell(25, 30, str(manilla[0]['primerApellido']), 0, 0, 'L')
    pdf.cell(35, 30, str(manilla[0]['segundoApellido']), 0, 0, 'L')
    pdf.set_font('Times', 'B', 9)
    pdf.cell(100, 30, 'Riesgo:', 0, 0, 'C')
    pdf.ln(3)
    pdf.cell(15, 33, 'Identificacion:', 0, 0, 'C')
    pdf.cell(15, 33, str(manilla[0]['documento']), 0, 0, 'L')
    pdf.cell(15, 33, str(manilla[0]['edad']), 0, 0, 'L')
    pdf.cell(15, 33, str(manilla[0]['sexo']), 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(30, 35, 'Fecha Hora de Ingreso:', 0, 0, 'C')
    pdf.cell(15, 35, str(manilla[0]['fechaIngreso']), 0, 0, 'L')
    pdf.ln(3)
    pdf.cell(5, 35, 'Alergias:', 0, 0, 'C')

    carpeta = 'C:\\EntornosPython\\Pos7Particionado\\vulner\\JSONCLINICA\\HistoriasClinicas\\'
    print("carpeta = ", carpeta)

    archivo = carpeta + '' + str(pacienteId.documento) + '_' + 'Manilla.pdf'
    print("archivo =", archivo)

    pdf.output(archivo, 'F')

    try:
        # Intenta abrir el archivo directamente
        #webbrowser.open(archivo)


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

    return JsonResponse({'success': True, 'message': 'Manilla impresa!'})




def ImprimirTriage(request):
    # Instantiation of inherited class
    triageId = request.POST["triageId"]
    print("triageId = ", triageId)


    ingresoPaciente = Triage.objects.get(id=triageId)
    tipoDocId = ingresoPaciente.tipoDoc_id
    print("tipoDocId = ", tipoDocId)
    documentoId = ingresoPaciente.documento_id
    print("documentoId = ", documentoId)
    consec = ingresoPaciente.consec
    print("consec = ", consec)
    pacienteId = Usuarios.objects.get(id=documentoId)
    print("documentoPaciente = ", pacienteId.documento)

    miConexiont = psycopg2.connect(host="192.168.79.133", database="vulner7Particionado", port="5432", user="postgres",
                                   password="123456")


    curt = miConexiont.cursor()

    comando = 'SELECT tipo.abreviatura abrev, usu.documento documento, usu."primerNombre",usu."segundoNombre",usu."primerApellido", usu."segundoApellido", cast((cast(now() as date)  - cast(usu."fechaNacio" as date)) as text)   edad , usu.genero sexo, ing."fechaIngreso" fechaIngreso FROM admisiones_ingresos ing INNER JOIN usuarios_usuarios usu ON (usu.id=ing.documento_id) INNER JOIN usuarios_tiposdocumento tipo ON (tipo.id = usu."tipoDoc_id") WHERE ing.id= ' + "'" + str(
        triageId) + "'"
    print(comando)

    curt.execute(comando)

    print(comando)

    manilla = []

    for abrev, documento, primerNombre, segundoNombre, primerApellido, segundoApellido, edad, sexo, fechaIngreso in curt.fetchall():
        manilla.append(
            {'abrev': abrev, 'documento': documento, 'primerNombre': primerNombre, 'segundoNombre': segundoNombre,
             'primerApellido': primerApellido, 'segundoApellido': segundoApellido,
             'edad': edad, 'sexo': sexo, "fechaIngreso": fechaIngreso})

    miConexiont.close()
    print("manilla = ", manilla)

    pdf = PDFTriage(tipoDocId, documentoId, consec, triageId)
    pdf.alias_nb_pages()
    pdf.set_margins(left=10, top=5, right=5)
    pdf.add_page()
    pdf.set_font('Times', '', 8)
    pdf.ln(1)
    linea = 7


    # Define el ancho de línea
    pdf.set_line_width(0.4)
    # Dibuja el borde
    pdf.rect(5.0, 15.0, 200.0, 50.0)  # Coordenadas x, y, ancho, alto

    pdf.set_font('Times', 'B', 9)
    pdf.ln(3)
    pdf.cell(100, 30, 'TRIAGE:', 0, 0, 'C')
    pdf.set_font('Times', '', 7)

    carpeta = 'C:\\EntornosPython\\Pos7Particionado\\vulner\\JSONCLINICA\\HistoriasClinicas\\'
    print("carpeta = ", carpeta)

    archivo = carpeta + '' + str(pacienteId.documento) + '_' + 'Triage.pdf'
    print("archivo =", archivo)

    pdf.output(archivo, 'F')

    try:
        # Intenta abrir el archivo directamente
        #webbrowser.open(archivo)


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

    return JsonResponse({'success': True, 'message': 'Autorizacion impresa!'})


def ImprimirTriageParametro(triageId):
    # Instantiation of inherited class

    print("triageId = ", triageId)


    ingresoPaciente = Triage.objects.get(id=triageId)
    tipoDocId = ingresoPaciente.tipoDoc_id
    print("tipoDocId = ", tipoDocId)
    documentoId = ingresoPaciente.documento_id
    print("documentoId = ", documentoId)
    consec = ingresoPaciente.consec
    print("consec = ", consec)
    pacienteId = Usuarios.objects.get(id=documentoId)
    print("documentoPaciente = ", pacienteId.documento)

    miConexiont = psycopg2.connect(host="192.168.79.133", database="vulner7Particionado", port="5432", user="postgres",
                                   password="123456")


    curt = miConexiont.cursor()

    comando = 'SELECT tipo.abreviatura abrev, usu.documento documento, usu."primerNombre",usu."segundoNombre",usu."primerApellido", usu."segundoApellido", cast((cast(now() as date)  - cast(usu."fechaNacio" as date)) as text)   edad , usu.genero sexo, ing."fechaIngreso" fechaIngreso FROM admisiones_ingresos ing INNER JOIN usuarios_usuarios usu ON (usu.id=ing.documento_id) INNER JOIN usuarios_tiposdocumento tipo ON (tipo.id = usu."tipoDoc_id") WHERE ing.id= ' + "'" + str(
        triageId) + "'"
    print(comando)

    curt.execute(comando)

    print(comando)

    manilla = []

    for abrev, documento, primerNombre, segundoNombre, primerApellido, segundoApellido, edad, sexo, fechaIngreso in curt.fetchall():
        manilla.append(
            {'abrev': abrev, 'documento': documento, 'primerNombre': primerNombre, 'segundoNombre': segundoNombre,
             'primerApellido': primerApellido, 'segundoApellido': segundoApellido,
             'edad': edad, 'sexo': sexo, "fechaIngreso": fechaIngreso})

    miConexiont.close()
    print("manilla = ", manilla)

    pdf = PDFTriage(tipoDocId, documentoId, consec, triageId)
    pdf.alias_nb_pages()
    pdf.set_margins(left=10, top=5, right=5)
    pdf.add_page()
    pdf.set_font('Times', '', 8)
    pdf.ln(1)
    linea = 7


    # Define el ancho de línea
    pdf.set_line_width(0.4)
    # Dibuja el borde
    pdf.rect(5.0, 15.0, 200.0, 50.0)  # Coordenadas x, y, ancho, alto

    pdf.set_font('Times', 'B', 9)
    pdf.ln(3)
    pdf.cell(100, 30, 'TRIAGE:', 0, 0, 'C')
    pdf.set_font('Times', '', 7)

    carpeta = 'C:\\EntornosPython\\Pos7Particionado\\vulner\\JSONCLINICA\\HistoriasClinicas\\'
    print("carpeta = ", carpeta)

    archivo = carpeta + '' + str(pacienteId.documento) + '_' + 'Triage.pdf'
    print("archivo =", archivo)

    pdf.output(archivo, 'F')

    try:
        # Intenta abrir el archivo directamente
        #webbrowser.open(archivo)


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

    return JsonResponse({'success': True, 'message': 'Autorizacion impresa!'})



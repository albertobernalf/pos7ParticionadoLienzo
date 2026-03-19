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
from facturacion.models import Liquidacion, LiquidacionDetalle, Suministros, TiposSuministro, Empresas
#from contratacion.models import Procedimientos
from usuarios.models import Usuarios, TiposDocumento
from cartera.models  import Pagos
from autorizaciones.models import Autorizaciones,AutorizacionesDetalle, EstadosAutorizacion
from contratacion.models import Convenios
from cirugia.models import EstadosCirugias, EstadosProgramacion, ProgramacionCirugias
from tarifarios.models import TarifariosDescripcion, TarifariosProcedimientos, TarifariosSuministros
from clinico.forms import  IncapacidadesForm, HistorialDiagnosticosCabezoteForm, HistoriaSignosVitalesForm, Historia
from autorizaciones.models import Autorizaciones
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

import os
import requests
import urllib
from django.http import FileResponse
from io import BytesIO
import io

class PDFConsentimientoInformado(FPDF):

    def __init__(self, tipoDocId, documentoId, consec, ingresoId2, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.tipoDocId = tipoDocId
        self.documentoId = documentoId
        self.consec = consec
        self.ingresoId = ingresoId2


    def header(self):

        self.ln(6)

    def footer(self):

        self.ln(6)



def ImprimirConsentimientoInformado(request):
    # Instantiation of inherited class
    print("Entre consentimientoInformado")

    programacionId = request.POST["programacionId"]
    print("programacionId = ", programacionId)
    programacion = ProgramacionCirugias.objects.get(id=programacionId)
    print ("programacion tipoDoc_id= " , programacion.tipoDoc_id)
    print("programacion codumento_id= ", programacion.documento_id)
    print("programacion consecAdmision= ", programacion.consecAdmision)


    if (programacion.consecAdmision == 0):
        print("es triage")
        flag='TRIAGE'
        triageId = Triage.objects.get(tipoDoc_id=programacion.tipoDoc_id, documento_id=programacion.documento_id, consec=programacion.consecAdmision)
        pacienteId = Usuarios.objects.get(id=triageId.documento_id)

        print("documentoPaciente = ", pacienteId.documento)

    else:
        print("es admision")
        flag='INGRESO'
        ingresoId = Ingresos.objects.get(tipoDoc_id=programacion.tipoDoc_id, documento_id=programacion.documento_id, consec=programacion.consecAdmision)
        print ("paso_1")
        pacienteId = Usuarios.objects.get(id=ingresoId.documento_id)
        print("paso_2", pacienteId  )
        print("paso_2", pacienteId.tipoDoc_id  )

    tipoDocId = TiposDocumento.objects.get(id=pacienteId.tipoDoc_id)
    print("tipoDocId = ", tipoDocId)

    # Datos de la empresa

   
    datosEmpresa = Empresas.objects.get(nombre='CLINICA MEDICAL S.A.S')
    print ("datosEmpresa =" , datosEmpresa)
    # Fin Datos de la empresa

    ## Datos del paciente

    miConexiont = psycopg2.connect(host="192.168.79.133", database="vulner7Particionado", port="5432", user="postgres",
                                   password="123456")


    curt = miConexiont.cursor()

    if (flag!='TRIAGE'):

	    comando = 'SELECT tipo.abreviatura abrev, usu.documento documento, usu."primerNombre",usu."segundoNombre",usu."primerApellido", usu."segundoApellido", cast((cast(now() as date)  - cast(usu."fechaNacio" as date)) as text)   edad , usu.genero sexo, ing."fechaIngreso" fechaIngreso FROM admisiones_ingresos ing INNER JOIN usuarios_usuarios usu ON (usu.id=ing.documento_id) INNER JOIN usuarios_tiposdocumento tipo ON (tipo.id = usu."tipoDoc_id") WHERE ing.id= ' + "'" + str(
        		ingresoId.id) + "'"
    else:
	    comando = 'SELECT tipo.abreviatura abrev, usu.documento documento, usu."primerNombre",usu."segundoNombre",usu."primerApellido", usu."segundoApellido", cast((cast(now() as date)  - cast(usu."fechaNacio" as date)) as text)   edad , usu.genero sexo, tri."fechaSolicitud" fechaIngreso FROM triage_triage tri INNER JOIN usuarios_usuarios usu ON (usu.id=tri.documento_id) INNER JOIN usuarios_tiposdocumento tipo ON (tipo.id = usu."tipoDoc_id") WHERE tri.id= ' + "'" + str(
        		triageId.id) + "'"

    print(comando)

    curt.execute(comando)

    datosPersonales = []

    for abrev, documento, primerNombre, segundoNombre, primerApellido, segundoApellido, edad, sexo, fechaIngreso in curt.fetchall():
        datosPersonales.append(
            {'abrev': abrev, 'documento': documento, 'primerNombre': primerNombre, 'segundoNombre': segundoNombre,
             'primerApellido': primerApellido, 'segundoApellido': segundoApellido,
             'edad': edad, 'sexo': sexo, "fechaIngreso": fechaIngreso})

    miConexiont.close()
    print("datosPersonales ULT= ", datosPersonales)

    #  Fin datos paciente

    ## Datos DE LA SOLICITUD
    #  Fin datos de quien solicita

    tipoDocId=tipoDocId.id
    print("tipoDocId", tipoDocId)
    documentoId = ingresoId.documento_id
    print("documentoId",documentoId )
    consec = ingresoId.consec
    print("consec", consec)
    ingresoId2 = ingresoId.id
    print("ingresoId",ingresoId2 )

    pdf = PDFConsentimientoInformado(tipoDocId,documentoId, consec, ingresoId2)
    print("pasePrueba")
    #pdf.alias_nb_pages()
    print("pasePrueba2")
    pdf.set_margins(left=10, top=5, right=5)
    print("pasePrueba3")
    pdf.add_page()
    pdf.set_font('Times', 'B', 8)
    print("pasePrueba4")

    # Define el ancho de línea
    print("pasePrueba5")
    pdf.set_line_width(0.4)
    # Dibuja el borde
    print("pasePrueba6")
    #pdf.rect(5.0, 15.0, 100.0, 50.0)  # Coordenadas x, y, ancho, alto
    print("pasePrueba7")
    #pdf.set_font('Times', 'B', 9)
    pdf.ln(3)
    print("pasePrueba8")
    pdf.cell(100, 30, 'CONSENTIMIENTO INFORMADO:', 0, 0, 'C')
    pdf.cell(30, 30, 'cuarta linea', 0, 0, 'C')
    pdf.set_font('Times', '', 7)
    print("antes de carpeta = ")

    carpeta = 'C:\\EntornosPython\\Pos7Particionado\\vulner\\JSONCLINICA\\HistoriasClinicas\\'
    print("carpeta = ", carpeta)

    archivo = carpeta + '' + str(pacienteId.documento) + '_' + 'Consentimiento.pdf'
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




import qrcode
from fpdf import FPDF
import hashlib
import xml.etree.ElementTree as ET
from datetime import datetime

# --- 1. DATOS DE LA FACTURA ---
data = {
    "num": "SETT1",
    "fecha": datetime.now().strftime("%Y-%m-%d"),
    "hora": datetime.now().strftime("%H:%M:%S-05:00"),
    "nit_emisor": "900123456",
    "nit_receptor": "800987654",
    "valor_total": "100000",
    "impuestos": "19000",
    "moneda": "COP"
}

# --- 2. GENERAR CUFE (Algoritmo SHA-384 simplificado) ---
# En producción se concatenan: Num + Fecha + Hora + Valor + NITs + ... + CLTecnica
raw_cufe = f"{data['num']}{data['fecha']}{data['hora']}{data['valor_total']}01{data['impuestos']}{data['nit_emisor']}{data['nit_receptor']}"
cufe = hashlib.sha384(raw_cufe.encode()).hexdigest()
print(f"CUFE Generado: {cufe}")

# --- 3. GENERAR CÓDIGO QR ---
url_dian = f"https://catalogo-vpfe.dian.gov.co/document/searchqr?documentkey={cufe}"
qr = qrcode.make(url_dian)
qr.save("qr_factura.png")

# --- 4. GENERAR XML (Estructura UBL 2.1 básica) ---
# Nota: La firma electrónica (signature) es obligatoria en producción.
root = ET.Element("Invoice", xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2")
ET.SubElement(root, "cbc:ID").text = data['num']
ET.SubElement(root, "cbc:UUID").text = cufe
# ... más etiquetas UBL2.1 obligatorias ...
tree = ET.ElementTree(root)
tree.write("factura.xml", encoding="UTF-8", xml_declaration=True)
print("XML Generado: factura.xml")

# --- 5. GENERAR PDF (Representación Gráfica) ---
class PDF(FPDF):
    def header(self):
        self.set_font('Arial', 'B', 12)
        self.cell(0, 10, 'FACTURA ELECTRÓNICA DE VENTA', 0, 1, 'C')

pdf = PDF()
pdf.add_page()
pdf.set_font("Arial", size=12)
pdf.cell(0, 10, f"Factura No: {data['num']}", 0, 1)
pdf.cell(0, 10, f"Fecha: {data['fecha']}", 0, 1)
pdf.cell(0, 10, f"Total: ${data['valor_total']}", 0, 1)
pdf.image("qr_factura.png", x=150, y=20, w=40)
pdf.output("factura.pdf")
print("PDF Generado: factura.pdf")
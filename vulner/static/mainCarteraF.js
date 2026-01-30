console.log('Hola Alberto Hi!')

let dataTable;
let dataTableA;
let dataTableB;
let dataTableC;
let dataTableD;
let dataTableF;
let dataTableG;
let dataTableH;

let dataTableCajaInitialized = false;


$(document).ready(function() {
    var table = $('#tablaCaja').DataTable();
    
       $('#search').on('keyup', function() {
        var searchValue = this.value.split(' '); // Supongamos que los términos de búsqueda están separados por espacios
        
        // Aplica la búsqueda en diferentes columnas
        table
            .columns([3]) // Filtra en la primera columna
            .search(searchValue[0]) // Primer término de búsqueda
            .draw();

	  table
            .columns([9]) // Filtra en la segunda columna
            .search(searchValue[1]) // Segundo término de búsqueda
            .draw();

        
        table
            .columns([14]) // Filtra en la segunda columna
            .search(searchValue[1]) // Segundo término de búsqueda
            .draw();
    });
});


function arrancaCartera(valorTabla,valorData)
{
    data = {}
    data = valorData;

    if (valorTabla == 1)
    {
        let dataTableOptionsCaja  ={
   dom: "<'row mb-1'<'col-sm-3'B><'col-sm-3'><'col-sm-6'f>>" + // B = Botones a la izquierda, f = filtro a la derecha
             "<'row'<'col-sm-12'tr>>" +
             "<'row mt-3'<'col-sm-5'i><'col-sm-7'p>>",
  buttons: [
    {
      extend: 'excelHtml5',
      text: '<i class="fas fa-file-excel"></i> ',
      titleAttr: 'Exportar a Excel',
      className: 'btn btn-success',
      messageTop: 'Caja' ,
    },
    {
      extend: 'pdfHtml5',
      text: '<i class="fas fa-file-pdf"></i> ',
      titleAttr: 'Exportar a PDF',
      className: 'btn btn-danger',
      messageTop: 'Caja' ,
    },
    {
      extend: 'print',
      text: '<i class="fa fa-print"></i> ',
      titleAttr: 'Imprimir',
      className: 'btn btn-info',
      messageTop: 'Caja' ,
    },
  ],
  lengthMenu: [2, 4, 15],
           processing: true,
            serverSide: false,
            scrollY: '275px',
	    scrollX: true,
	    scrollCollapse: true,
            paging:false,
            columnDefs: [
		{ className: 'centered', targets: [0, 1, 2, 3, 4, 5] },
	    { width: '10%', targets: [2,3] },

		{   
                    "targets": 17
               }
            ],
	 pageLength: 3,
	  destroy: true,
	  language: {
		    processing: 'Procesando...',
		    lengthMenu: 'Mostrar _MENU_ registros',
		    zeroRecords: 'No se encontraron resultados',
		    emptyTable: 'Ningún dato disponible en esta tabla',
		    infoEmpty: 'Mostrando registros del 0 al 0 de un total de 0 registros',
		    infoFiltered: '(filtrado de un total de _MAX_ registros)',
		    search: "<i class='fa fa-search'></i> Buscar: _INPUT_",
		    infoThousands: ',',
		    loadingRecords: 'Cargando...',
		    paginate: {
			      first: 'Primero',
			      last: 'Último',
			      next: 'Siguiente',
			      previous: 'Anterior',
		    }
			},


           ajax: {
                 url:"/load_dataCaja/" +  data,
                 type: "POST",
                 dataSrc: ""
            },
            columns: [
		{
		  "render": function ( data, type, row ) {
                        var btn = '';
        		     btn = btn + " <input type='radio' name='caja' class='miCaja form-check-input ' data-pk='"  + row.pk + "'>" + "</input>";
                       return btn;
                    },

		},

                { data: "fields.id"},
                { data: "fields.fecha"},
                { data: "fields.usuarioEntrega_id"},
                { data: "fields.totalEfectivo"},
                { data: "fields.totalTarjetasDebito"},
                { data: "fields.totalTarjetasCredito"},
                { data: "fields.totalCheques"},
                { data: "fields.total"},
                { data: "fields.usuarioRecibe_id"},
		{ data: "fields.usuarioSuperviza_id"},
		{ data: "fields.estadoCaja"},
                { data: "fields.totalEfectivoEsperado"},
                { data: "fields.totalTarjetasDebitoEsperado"},
                { data: "fields.totalTarjetasCreditoEsperado"},
                { data: "fields.totalChequesEsperado"},
                { data: "fields.totalEsperado"},
                { data: "fields.serviciosAdministrativos_id"},    
       ]
            }
	        dataTable = $('#tablaCaja').DataTable(dataTableOptionsCaja);
  }
}

const initDataTableCaja = async () => {
	if  (dataTableCajaInitialized)  {
		dataTable.destroy();

}
    	var sedeSeleccionada = document.getElementById("sedeSeleccionada").value;
        var username = document.getElementById("username").value;
        var nombreSede = document.getElementById("nombreSede").value;
    	var sede = document.getElementById("sede").value;
        var username_id = document.getElementById("username_id").value;
         var data =  {}   ;
        data['username'] = username;
        data['sedeSeleccionada'] = sedeSeleccionada;
        data['nombreSede'] = nombreSede;
        data['sede'] = sede;
        data['username_id'] = username_id;
	sedesClinica_id = sede;
	data['sedesClinica_id'] = sedesClinica_id
	data['facturaId'] = 1

        data = JSON.stringify(data);

         arrancaCartera(1,data);
	 dataTableCajaInitialized = true;


}

 // COMIENZA ONLOAD

window.addEventListener('load', async () => {
    await  initDataTableCaja();
	 

});


 /* FIN ONLOAD */


 $('#tablaCaja tbody').on('click', '.miCaja', function() {

        var post_id = $(this).data('pk');
        var cajaId = post_id;
	var row = $(this).closest('tr'); // Encuentra la fila

        var data =  {}   ;

 	var sedeSeleccionada = document.getElementById("sedeSeleccionada").value;
        var username = document.getElementById("username").value;
        var nombreSede = document.getElementById("nombreSede").value;
    	var sede = document.getElementById("sede").value;
        var username_id = document.getElementById("username_id").value;


        data['username'] = username;
        data['sedeSeleccionada'] = sedeSeleccionada;
        data['nombreSede'] = nombreSede;
        data['sede'] = sede;
        data['username_id'] = username_id;
	sedesClinica_id = sede;
	data['sedesClinica_id'] = sedesClinica_id

     $.ajax({
		data: {'cajaId':cajaId},
	        url: "/editarCaja/",
                type: "POST",
                dataType: 'json',
                success: function (info) {

		if (info.success == true)
			 {
			  document.getElementById("mensajes").value = data.Mensajes;
			 }
			else
			{
			document.getElementById("mensajesError").value = data.Mensajes;
			return;
			}


		$('#postFormCaja').trigger("reset");

			// $('#fecha').val(info[0].fields.fecha);
			document.getElementById("fecha").value = info[0].fields.fecha;
			 $('#usuarioEngrega_id').val(info[0].fields.usuarioEntrega_id);
			 $('#serviciosAdministrativos_id').val(info[0].fields.serviciosAdministrativos_id);



			$('#usuarioRecibe_id').val(info[0].fields.usuarioRecibe_id);
			$('#usuarioSuperviza_id').val(info[0].fields.usuarioSuperviza_id);
			$('#totalEfectivo').val(info[0].fields.totalEfectivo);
			$('#totalEfectivoEsperado').val(info[0].fields.totalEfectivoEsperado);
			$('#totalTarjetasDebito').val(info[0].fields.totalTarjetasDebito);
			$('#totalTarjetasDebitoEsperado').val(info[0].fields.totalTarjetasDebitoEsperado);
			$('#totalTarjetasCredito').val(info[0].fields.totalTarjetasCredito);
			$('#totalTarjetasCreditoEsperado').val(info[0].fields.totalTarjetasCreditoEsperado);
			$('#totalCheques').val(info[0].fields.totalCheques);
			$('#totalChequesEsperado').val(info[0].fields.totalChequesEsperado);
			$('#total').val(info[0].fields.total);
			$('#totalEsperado').val(info[0].fields.totalEsperado);
			$('#estadoCaja').val(info[0].fields.estadoCaja);
			$('#cajaId').val(cajaId);

	
		 $('#crearModelCaja').modal('show');
                },
          error: function (data) {
		
	document.getElementById("mensajesError").value =  data.responseText;

	   	    	}
            });
  });





function GuardarCaja()
{
	
		var sedeSeleccionada = document.getElementById("sedeSeleccionada").value;
	        var username = document.getElementById("username").value;
	        var nombreSede = document.getElementById("nombreSede").value;
	    	var sede = document.getElementById("sede").value;


            $.ajax({
                data: $('#postFormCaja').serialize(),
	        url: "/guardarCaja/",
                type: "POST",
                dataType: 'json',
                success: function (data2) {

		if (data2.success == true)
			 {
			  document.getElementById("mensajes").value = data.Mensajes;
			 }
			else
			{
			document.getElementById("mensajesError").value = data.Mensajes;
			return;
			}



		var data =  {}   ;
	        data['username'] = username;
		data['username_id'] = username_id;
	        data['sedeSeleccionada'] = sedeSeleccionada;
	        data['nombreSede'] = nombreSede;
	        data['sede'] = sede;
	        data['sedesClinica_id'] = sede;

		 $('#crearModelCaja').modal('hide');

	        data = JSON.stringify(data);

		 arrancaCartera(1,data);
	         dataTableCajanitialized = true;
	
                },
            error: function (data) {
		
	document.getElementById("mensajesError").value =  data.responseText;

	   	    	}
            });


}



$(document).ready(function() {
	// Click fuera de stickynote oculta el stickynote
	$(document).on('click', sticky_note_hide);
	$('#neo-sticky-note').on('click', function(e) {
		e.stopPropagation(); // Para evitar q el click se propague hasta el "document"
	});
	
	// Click en el control de stickynote abre stickynote
	$('#togglestickynote1').on('click', function(e) {
		e.stopPropagation(); // Para evitar q el click se propague hasta el "document"
		sticky_note_load();
	});
	
	// Cierre del sticky note lo oculta luego de cambiar a vista sólo lectura
	$('#neo-sticky-note-text-edit-delete').on('click', function() {
		$("#neo-sticky-note-text-edit").hide();
		$("#neo-sticky-note-text").show();
		sticky_note_hide();
	});

	// Click en el texto de sólo lectura cambia a modificación
	$('#neo-sticky-note-text').on('click', function() {
		$("#neo-sticky-note-text").hide();
		$("#neo-sticky-note-text-edit").show();
		sticky_note_count_chars();
	});
	
	// Escritura en el textarea cuenta los caracteres
	$('#neo-sticky-note-textarea').on('keyup', sticky_note_count_chars);
	
	// Botón de guardar mensaje stickynote
	$('#neo-submit-button').on('click', sticky_note_send);
});

function sticky_note_hide() { $("#neo-sticky-note").hide(); }
function sticky_note_show() { $("#neo-sticky-note").show(); }

function sticky_note_load()
{
	elastix_blockUI($('#get_note_label').val());
	request('index.php', {
		menu:		'_elastixutils',
		id_menu:	getCurrentElastixModule(),
		action:		'get_sticky_note',
		rawmode:	'yes'
	}, false, function(description, statusResponse, error) {
		$.unblockUI();
		if (statusResponse == "OK") {
			if (description == "no_data") return;
			$("#neo-sticky-note-textarea").val(description);
			if (description == '') description = $("#lbl_no_description").val();
		} else {
			if (error != "no_data") alert(error);
		}
		$("#neo-sticky-note-text").text(description);
		sticky_note_show();
	});
}

function sticky_note_count_chars()
{
	var charlimit        = 300;
	var textareacontent  = $('#neo-sticky-note-textarea').val();
	var charleft         = charlimit - textareacontent.length;
	if (charleft < 0) {
		$("#neo-sticky-note-textarea").val(textareacontent.substr(0,charlimit));
		charleft = 0;
	}
	$("#neo-sticky-note-text-char-count").text(charleft + " " + $("#amount_char_label").val());
}

function sticky_note_send()
{
	var description = $('#neo-sticky-note-textarea').val();
	elastix_blockUI($('#save_note_label').val());
    request('index.php', {
        menu:           '_elastixutils',
        id_menu:        getCurrentElastixModule(),
        action:         'save_sticky_note',
        description:    description,
        popup:          $('#neo-sticky-note-auto-popup').is(':checked') ? 1 : 0,
        rawmode:        'yes'
    }, false, function(arrData,statusResponse,error) {
        $.unblockUI();
        if (statusResponse != 'OK') {
            alert(dataResponse.error);
            return;
        }
    	$("#neo-sticky-note-text-edit").hide();
    	$("#neo-sticky-note-text").show();
        sticky_note_hide();
        $('#togglestickynote1').attr('src', 'themes/'+$('#elastix_theme_name').val()+'/images/' 
            + ((description != '') ? 'tab_notes_on.png' : 'tab_notes.png'));
    });
}

$(document).ready(function() {
    $('#btn_testpanel').button();
    $('#btn_testpanel').click(function() {
        $.get('index.php', {menu: module_name, action: 'testpanel_algo', rawmode: 'yes'}, function (respuesta) {
            verificar_error_session(respuesta);
            alert(respuesta.data);
        });
    });

});
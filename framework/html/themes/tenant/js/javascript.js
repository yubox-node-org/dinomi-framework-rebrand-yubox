$(document).ready(function() {
    $('i.elastix-notification-remove').click(function () {
        var id_noti = $(this).data('id');
        var li_noti = $(this).parents('li').first();

        alert(id_noti);
        li_noti.remove();
    });
});
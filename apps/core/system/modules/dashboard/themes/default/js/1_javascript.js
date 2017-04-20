$(document).ready(function() {
    $('.appletcolumn').sortable({
        connectWith: ".appletcolumn",
        forcePlaceholderSize: true,
        forceHelperSize: true,
        scroll: false,
        stop: function () {
            var appletlist_left = $('#applet_col_1 .appletwindow_content')
                .map(function() { return this.id; })
                .get();
            var appletlist_right = $('#applet_col_2 .appletwindow_content')
                .map(function() { return this.id; })
                .get();

            /* NOTA: el siguiente código codifica el orden de presentación de
             * los applets pero no indica exactamente en qué columna aparecerán.
             * Esto es consistente con la implementación anterior. */
            var appletlist = [];
            for (var i = 0; i < appletlist_left.length || i < appletlist_right.length; i++) {
                if (i < appletlist_left.length)
                    appletlist.push(appletlist_left[i]);
                if (i < appletlist_right.length)
                    appletlist.push(appletlist_right[i]);
            }

            //console.debug(appletlist);
            $.post('index.php', {
                menu: getCurrentElastixModule(),
                rawmode: 'yes',
                action: 'updateOrder',
                appletorder: appletlist
            }, function(respuesta) {
                if (respuesta.status == 'error') {
                    alert(respuesta.message);
                }
            });
        }
    });
    $('.appletrefresh').click(function() {
        $(this).parent().parent().next().map(function() { appletRefresh($(this));});
    });

    // Iniciar la carga de todos los applets
    $('.appletwindow_content').map(function() { appletRefresh($(this));});

    startGraphicMonitoringRT();
});

function appletRefresh(appletwindow_content)
{
    appletwindow_content.children('.appletwindow_fullcontent').hide().empty();
    appletwindow_content.children('.appletwindow_wait').show();
    $.get('index.php', {
        menu: getCurrentElastixModule(),
        rawmode: 'yes',
        applet: appletwindow_content.attr('id').substr(7), // para quitar 'Applet_'
        action: 'getContent'
    }, function(respuesta) {
        var fullcontent = appletwindow_content.children('.appletwindow_fullcontent');
        appletwindow_content.children('.appletwindow_wait').hide();
        if (respuesta.status == 'error') {
            fullcontent.text(respuesta.message);
        } else {
            fullcontent.html(respuesta.html);
        }
        fullcontent.show();
    });
}

var charts = [];
var monitorsocket;

function startGraphicMonitoringRT()
{
    charts.push({
        chartobj: c3.generate(createChartParams('#chart', '#3333aa', '% CPU Usage')),
        queuedpoints: []
    });
    charts.push({
        chartobj: c3.generate(createChartParams('#chart2', '#33aa33', '# Processes')),
        queuedpoints: []
    });
    charts.push({
        chartobj: c3.generate(createChartParams('#chart3', '#aa3333', '# Agents')),
        queuedpoints: []
    });

    monitorsocket = io.connect(window.location.protocol+'//'+window.location.host);

    monitorsocket.on('connect', function() {
/*
        if (conn_err){
            location.reload();
        }
*/
        $('div#dinomi-monitor-error').hide();
        $('div.dinomi-monitor-chart').show();

        //var conn_err = false;
    });
    monitorsocket.on('statistics1', function(v) { updateChartDataRT(0, v * 100.0); });
    monitorsocket.on('statistics2', function(v) { updateChartDataRT(1, v); });
    monitorsocket.on('statistics3', function(v) { updateChartDataRT(2, v); });

    monitorsocket.on('connect_error', function () {
        $('div.dinomi-monitor-chart').hide();
        $('div#dinomi-monitor-error').show();
        //var conn_err = true;
    });

}

function createChartParams(bindto, color, labeltxt)
{
    var chartParams = {
        bindto: bindto,
        padding: {
            left: 15,
            top: 0,
            bottom: 0
        },
        data: {
            x: 'x',
            xFormat: null,
            columns: [
                ['x', Date.now()],
                ['data1', 0.0],
            ],
            types: {
                data1: 'area',
            },
            axes: {
                data1: 'y2',
            },
            names: {
                data1: '',
            },
            colors: {
                data1: color
            }
        },
        legend: {
            show: false
        },
        size: {
            height: 120,
        },
        axis: {
            x: {
                type: 'timeseries',
                tick: {
                    format: '%H:%M:%S'
                }
            },
            y: {
                show: false,
            },
            y2: {
                show: true,
                tick: {
                    count: 4,
                    format: d3.format(".2f")
                },
                label: {
                    text: labeltxt,
                    position: 'outer-middle',
                }
            },
        },
        area: {
            zerobased: false
        },
        point: {
            show: true
        }
    };

    return chartParams;
}

function updateChartDataRT(idx, value)
{
    var ts_now = Date.now();
    var interval = 5 * 60 * 1000;

    if (charts[idx].queuedpoints.length <= 0) {
        charts[idx].queuedpoints.push([]);
        charts[idx].queuedpoints.push([]);
    }

    // Empujar al final valor más reciente, eliminar más antiguos, si existen
    charts[idx].queuedpoints[0].push(ts_now);
    charts[idx].queuedpoints[1].push(value);
    while (charts[idx].queuedpoints[0][0] < ts_now - interval) {
        charts[idx].queuedpoints[0].shift();
        charts[idx].queuedpoints[1].shift();
    }

    // Iniciar flow, si chart está libre
    if (!charts[idx].chartobj.internal.flowing) {
        var flowparams = {
            columns :   charts[idx].queuedpoints,
            to      :   ts_now - interval
        };
        charts[idx].queuedpoints = [];
        flowparams.columns[0].unshift('x');
        flowparams.columns[1].unshift('data1');

        // ¿Puedo agregar datos, o tengo que reemplazar todo?
        var currdata = charts[idx].chartobj.data();
        var currdatavals = currdata[0].values;
        if (currdatavals.length <= 0) {
            // Reemplazar todo el dataset
            charts[idx].chartobj.load({
                unload: true,
                columns: flowparams.columns
            });
        } else {
            var last_curr_t = currdatavals[currdatavals.length - 1].x;

            if (last_curr_t <= ts_now - interval) {
                // Reemplazar todo el dataset
                charts[idx].chartobj.load({
                    unload: true,
                    columns: flowparams.columns
                });
            } else {
                // Agregar puntos al gráfico actual
                charts[idx].chartobj.flow(flowparams);
            }
        }
    }
}

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

var chart, chart2, chart3;
var socket;

function startGraphicMonitoringRT()
{
    chart = c3.generate({
        bindto: '#chart',
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
                data1: '#3333aa'
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
                    text: '% CPU Usage',
                    position: 'outer-middle',
                }
            },
        },
        point: {
            show: false
        }
    });

    chart2 = c3.generate({
        bindto: '#chart2',
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
                data1: '#33aa33'
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
                    text: '# Processes',
                    position: 'outer-middle',
                }
            },
        },
        point: {
            show: false
        }
    });

    chart3 = c3.generate({
        bindto: '#chart3',
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
                    text: '# Agents',
                    position: 'outer-middle',
                }
            },
        },
        point: {
            show: false
        }
    });

    socket = io.connect(window.location.protocol+'//'+window.location.host);

    socket.on('connect', function Main(){
/*
        if (conn_err){
            location.reload();
        }
*/
        document.getElementById('info').style.display = 'none';

        socket.on('statistics1', function getCPUusage(cpuusage) {
          document.getElementById('chart').style.display = 'inline';
            var ts_now = Date.now();
            var ts_5mins_ago = ts_now - 300000;
            chart.flow({
                columns: [
                    ['x', ts_now],
                    ['data1', cpuusage*100],
                ],
                length: 2,
                to: ts_5mins_ago
            });
        });

        socket.on('statistics2', function getNumActvPrcss(services) {
          document.getElementById('chart2').style.display = 'inline';
            var ts_now = Date.now();
            var ts_5mins_ago = ts_now - 300000;
            chart2.flow({
                columns: [
                    ['x', ts_now],
                    ['data1', services],
                ],
                length: 2,
                to: ts_5mins_ago
            });
        });

        socket.on('statistics3', function getNumAgents(agents) {
          document.getElementById('chart3').style.display = 'inline';
            var ts_now = Date.now();
            var ts_5mins_ago = ts_now - 300000;
            chart3.flow({
                columns: [
                    ['x', ts_now],
                    ['data1', agents],
                ],
                length: 2,
                to: ts_5mins_ago
            });
        });

        //var conn_err = false;
    });

    socket.on('connect_error', function () {
        document.getElementById('chart').style.display = 'none';
        document.getElementById('chart2').style.display = 'none';
        document.getElementById('chart3').style.display = 'none';
        document.getElementById('info').style.display = 'block';
        //var conn_err = true;
    });

}

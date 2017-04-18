{if $USR_ADMIN}
    <div id="info" style="display:none; align:center;">NO INFO TO DISPLAY..... SERVER DOWN</div>
    <div id="chart"></div>
    <div id="chart2"></div>
    <div id="chart3"></div>
{/if}
<table width="80%" cellspacing="0" id="applet_grid" align="center">
<tr>
    <td class="appletcolumn" id="applet_col_1">
        {foreach from=$applet_col_1 item=applet}
        <div class='appletwindow' id='portlet-{$applet.code}'>
            <div class='appletwindow_topbar'>
                <div class='appletwindow_title' width='80%'><!-- <img src='modules/{$module_name}/applets/{$applet.applet}/images/{$applet.icon}' align='absmiddle' />&nbsp;-->{$applet.name}</div>
                <div class='appletwindow_widgets' align='right' width='10%'>
                    <a class='appletrefresh'>
                        <i class="fa fa-refresh" style="color:#aaa"></i>
                    </a>
                </div>
            </div>
            <div class='appletwindow_content' id='{$applet.code}'>
                <div class='appletwindow_wait'><i style="color:#aaa;" class="fa fa-spinner fa-3x fa-pulse"></i>&nbsp;{$LABEL_LOADING}</div>
                <div class='appletwindow_fullcontent'></div>
            </div>
        </div>
        {/foreach}
    </td>
    <td class="appletcolumn" id="applet_col_2">
        {foreach from=$applet_col_2 item=applet}
        <div class='appletwindow' id='portlet-{$applet.code}'>
            <div class='appletwindow_topbar'>
                <div class='appletwindow_title' width='80%'><!-- <img src='modules/{$module_name}/applets/{$applet.applet}/images/{$applet.icon}' align='absmiddle' />&nbsp;-->{$applet.name}</div>
                <div class='appletwindow_widgets' align='right' width='10%'>
                    <a class='appletrefresh'>
                        <i class="fa fa-refresh" style="color:#aaa"></i>
                    </a>
                </div>
            </div>
            <div class='appletwindow_content' id='{$applet.code}'>
                <div class='appletwindow_wait'><i style="color:#aaa;" class="fa fa-spinner fa-3x fa-pulse"></i>&nbsp;{$LABEL_LOADING}</div>
                <div class='appletwindow_fullcontent'></div>
            </div>
        </div>
        {/foreach}
    </td>
</tr>
</table>
<script>

var chart = c3.generate({
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

var chart2 = c3.generate({
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

var chart3 = c3.generate({
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

var socket = io.connect(window.location.protocol+'//'+window.location.host);

socket.on('connect', function Main(){

    if (conn_err){
        location.reload();
    }

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

    var conn_err = false;
});

socket.on('connect_error', function () {
    document.getElementById('chart').style.display = 'none';
    document.getElementById('chart2').style.display = 'none';
    document.getElementById('chart3').style.display = 'none';
    document.getElementById('info').style.display = 'block';
    var conn_err = true;
});

</script>
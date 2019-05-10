'use strict';

const os = require('os');
const fs = require('fs');
const http = require('http');
const mysql = require('mysql');
const Promise = require('promise');
const ECCP = require('dinomi-eccp');
const socketio = require('socket.io');

const remotecnf = '/etc/ccpro_dbremoteconfig.conf';
const elxcnf = '/etc/elastix.conf';
const dialerhost = 'localhost';

// Inicialización
var eccpconn = null;
var io = null;
var tasks = null;

var dbFile = "/var/lib/dinomi-monitor/myDataBase.json";
var JsonDB = require('node-json-db');

var numAgentesActivos = 0;

function loadKeys(path)
{
    var readFile = Promise.denodeify(fs.readFile);
    return readFile(path, 'utf8')
    .then((data) => {
        var conf = {};
        var rx_keyval = /^(\w+)\s*=\s*(.*)/;

        data.split("\n").map((s) => { return s.trim(); })
        .forEach((s) => {
            var regs;
            if ((regs = s.match(rx_keyval)) != null) conf[regs[1]] = regs[2];
        });

        return conf;
    });
}

function setupECCP()
{
    var eccplocal = null;
    if (eccpconn != null) return;

    // Se intenta leer claves de configuración remota
    loadKeys(remotecnf)
    .then((keys) => {
        if (keys.TYPE == 'local')
            throw new Error('Local configuration...');
        return {
            host    : keys.HOST,
            database: 'call_center_pro',
            user    : keys.USERNAME,
            password: keys.PASSWORD
        };
    }).catch((err) => {
        // En error al leer archivo remoto, o si indica local, se lee elastix.conf
        var dsn = {
            host    : 'localhost',
            database: 'call_center_pro',
            user    : 'asteriskuser',
            password: null,
        };
        return loadKeys(elxcnf)
        .then((keys) => {
            if (keys.astusrmysql == undefined)
                throw new Error('Password not found for local DINOMI database');
            dsn.password = keys.astusrmysql;
            return dsn;
        })
    })
    .then((dsn) => {

        dsn.insecureAuth = true;// <--- QUITAR, SOLO PARA PRUEBA

        // Conexión a MySQL con las claves de DB obtenidas
        var dbconn = mysql.createConnection(dsn);
        dbconn.connect();

        var cred = {
            host:       dialerhost,
            eccpuser:   'agentconsole',
            eccppass:   null
        }
        var sth_eccpuser = Promise.denodeify(dbconn.query)
        .bind(dbconn, 'SELECT md5_password FROM eccp_authorized_clients where username = ?');

        return sth_eccpuser([cred.eccpuser])
        .then((rs) => {
            dbconn.end();
            if (rs.length <= 0) {
                throw new Error('ECCP user not found: '+cred.eccpuser);
            }
            cred.eccppass = rs[0].md5_password;
            return cred;
        }, (e) => {
            dbconn.end();
            console.log('Error on database lookup: ');
            console.log(e);
            throw e;
        });
    })
    .then((eccpcred) => {
        // Conexión a ECCP con las claves leídas de la base de datos
        eccplocal = new ECCP();
        eccplocal.on('error', (err) => {
            console.log('Error in ECCP connection: ');
            console.log(err);
            eccpconn = null;
        });
        console.log('Connecting to eccp://'+eccpcred.eccpuser+'@'+eccpcred.host+' ...');
        return eccplocal.connect(eccpcred.eccpuser, eccpcred.eccppass, eccpcred.host);
    })
    .done(
        (r) => {
            console.log('Connection established to ECCP');
            eccpconn = eccplocal;

            // Contar número de agentes activos en este momento
            eccpconn.send_request(
                'getmultipleagentstatus', {
                    'agents' : {
                        'agent_number' : 'all'
                    },
                    'loadpauseinfo' : 0
            }).done(
                (r) => {
                    numAgentesActivos = (r.agents[0].agent == undefined)
                        ? 0
                        : r.agents[0].agent.filter((a) => { return (a.status != 'offline'); }).length;
                },
                (err) => {
                    console.log('getmultipleagentstatus failed: ');
                    console.log(err);
                    eccpconn = null;
                    setTimeout(() => {
                        setupECCP();
                    }, 5000);
                }
            );

            // Incrementar o decrementar contador de agentes activos
            eccpconn.on('agentloggedin', () => { numAgentesActivos++; });
            eccpconn.on('agentloggedout', () => { numAgentesActivos--; });
        },
        (err) => {
            console.log('ECCP connect failed: ');
            console.log(err);
        }
    );
}

function processCount()
{
    var readdir = Promise.denodeify(fs.readdir);
    return readdir('/proc', 'utf8')
    .then((files) => {
        // Count entirely numeric entries under /proc
        return files.filter((f) => { return (f.match(/^\d+$/)); }).length;
    }, (e) => {
        return 0;
    });
}

var prevsample = null;
function cpuLoad()
{
    var sample = {
        idle:   0,
        total:  0,
    };
    os.cpus().forEach((cpu) => {
        sample.idle += cpu.times.idle;
        sample.total += cpu.times.idle + cpu.times.nice + cpu.times.user + cpu.times.sys + cpu.times.irq;
    });

    var load = 0.0;
    if (prevsample != null) {
        load = 1.0 - ((sample.idle - prevsample.idle) / (sample.total - prevsample.total));
    }
    prevsample = sample;
    return Promise.resolve(load);
}

function dinomiLoggedInAgents()
{
    return Promise.resolve(numAgentesActivos);
}

function pushTrimmedData()
{
    // Trim all historic data older than 5 minutes
    var ts_trim = Date.now() - 5 * 60 * 1000;
    for (var k in data) {
        while (data[k].length > 0 && (data[k][0].length <= 0 || data[k][0][0] < ts_trim)) {
            data[k].shift();
        }
    }
    db.push('/', data, true);
}

var io_options = {
/*
    pingTimeout: 3000,
    pingInterval: 3000,
    transports: ['polling','websocket'],
    allowUpgrades: true,
    httpCompression: false,
*/
};

var db = new JsonDB(dbFile, true, true);
var data = null;
try {
    data = db.getData("/");
} catch(e) {
    console.log('ERROR: could not load historic data: '+e.message);
    console.log('ERROR: resetting data...');
    data = {
        data_cpu:   [],
        data_proc:  [],
        data_agnt:  []
    };
}
if (data.data_cpu == null) data.data_cpu = [];
if (data.data_proc == null) data.data_proc = [];
if (data.data_agnt == null) data.data_agnt = [];
pushTrimmedData();

setupECCP();
setInterval(() => {
    if (tasks != null) return;

    // Lista de promesas a resolver en paralelo
    tasks = [
        cpuLoad(),
        processCount(),
        dinomiLoggedInAgents()
    ];
    Promise.all(tasks).done((rs) => {
        tasks = null;

        // Emitir valores de la estadística a TODOS los clientes conectados
        var timeDate_stamp = Date.now();
        io.emit('statistics1', [rs[0], timeDate_stamp]);
        io.emit('statistics2', [rs[1], timeDate_stamp]);
        io.emit('statistics3', [rs[2], timeDate_stamp]);
        io.emit('time_server',  timeDate_stamp);

        data.data_cpu.push([ timeDate_stamp , rs[0] ]);
        data.data_proc.push([ timeDate_stamp , rs[1] ]);
        data.data_agnt.push([ timeDate_stamp , rs[2] ]);
        pushTrimmedData();
    });
}, 5000);

var server = http.createServer();
io = socketio(server, io_options);

io.on('connect', () => {
    io.emit('oncharged', true);
    io.emit('data_cpu', data.data_cpu);
    io.emit('data_proc', data.data_proc);
    io.emit('data_agnt', data.data_agnt);
});

server.listen(8080, '127.0.0.1');



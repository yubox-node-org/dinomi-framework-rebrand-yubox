'use strict';

const fs = require('fs');
const http = require('http');
const mysql = require('mysql');
const Promise = require('promise');
const ECCP = require('dinomi-eccp');
const ostoolbox = require('os-toolbox');
const socketio = require('socket.io');

const remotecnf = '/etc/ccpro_dbremoteconfig.conf';
const elxcnf = '/etc/elastix.conf';
const dialerhost = 'localhost';

// Inicialización
var eccpconn = null;
var io = null;

var dbFile = "/usr/lib/node_modules/dinomi-monitor/myDataBase.json";
var JsonDB = require('node-json-db');

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
        },
        (err) => {
            console.log('ECCP connect failed: ');
            console.log(err);
        }
    );
}

function dinomiLoggedInAgents()
{
    if (eccpconn == null) {
        console.log('No connection, initializing...');
        setupECCP();
        return Promise.resolve(0);
    }
    return eccpconn.send_request(
        'getmultipleagentstatus', {
            'agents' : {
                'agent_number' : 'all'
            },
            'loadpauseinfo' : 0
    }).then(
        (r) => {
            if (r.agents[0].agent == undefined) return 0;
            return r.agents[0].agent.filter((a) => { return (a.status != 'offline'); }).length;
        },
        (err) => {
            console.log('getmultipleagentstatus failed: ');
            console.log(err);
            return 0;
        }
    );
}

function snd_data_autopopulate(numpoints){
    var d1 = JSON.parse(JSON.stringify(db.getData("/data_cpu")));
    var new_d1 = d1.slice(Math.max(d1.length - numpoints, 1));
    var d2 = JSON.parse(JSON.stringify(db.getData("/data_proc")));
    var new_d2 = d2.slice(Math.max(d2.length - numpoints, 1));
    var d3 = JSON.parse(JSON.stringify(db.getData("/data_agnt")));
    var new_d3 = d3.slice(Math.max(d3.length - numpoints, 1));
    io.emit('data_cpu', new_d1);
    io.emit('data_proc', new_d2);
    io.emit('data_agnt', new_d3);
    /*
    console.log(new_d1);
    console.log(new_d2);
    console.log(new_d3);
    */
};

function countProperties(obj) {
    return Object.keys(obj).length;
};

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
try{
    var data = db.getData("/");    
}catch(e) {
    switch(e.message){
        case 'Can\'t Load Database':
            console.log('Oh no!, Enter to CLD error');
            var string = e.inner.toString(),
            substring = "Unexpected end of JSON input";
            var verif_1 = string.includes(substring);
            switch(verif_1){
                case true:
                    console.log('Oh no!, Enter to '+verif_1+' error');
                    fs.writeFile(dbFile, "{}", function(err) {
                    if(err) {
                        return console.log(err);
                    }
                    console.log("The file was fixed!");
                    }); 
                break;

                default:
                    console.log('Oh no!, nothing to do here.');
                break;
            };    
        break;

        default:
            console.log('Oh no!, an undeterminated error has been caught:\n' + e);
        break;
    };
}

setupECCP();
setInterval(() => {
    Promise.all([
        ostoolbox.cpuLoad().then((percent) => { return percent / 100.0; }),
        ostoolbox.currentProcesses().then((proclist) => { return proclist.length }),
        dinomiLoggedInAgents()
    ]).done((rs) => {
        // Emitir valores de la estadística a TODOS los clientes conectados
        io.emit('statistics1', rs[0]);
        io.emit('statistics2', rs[1]);
        io.emit('statistics3', rs[2]);

        db.push("/data_cpu[]", [ Date.now() , rs[0] ], true);
        db.push("/data_proc[]", [ Date.now() , rs[1] ], true);
        db.push("/data_agnt[]", [ Date.now() , rs[2] ], true);
        /*
        console.log('CPU valor: ' + rs[0]);
        console.log('Number of Active Process: ' + rs[1]);
        console.log('Number of Agents: ' + rs[2] + '\n');
        */
    });
}, 5000);

var server = http.createServer();
io = socketio(server, io_options);

io.on('connect', () => {
    if(countProperties(data) > 0){
        io.emit('oncharged', true);
        var content1 = db.getData("/data_cpu");
        var content2 = db.getData("/data_proc");
        var content3 = db.getData("/data_agnt");
        if ( countProperties(content2) === countProperties(content1) && countProperties(content2) === countProperties(content3) && countProperties(content2) !== null ){
            var content_glob = db.getData("/data_cpu");
            switch (true) {
                case countProperties(content_glob) > 0 && countProperties(content_glob) < 5:
                    snd_data_autopopulate(4);
                break;
                case countProperties(content_glob) > 5 && countProperties(content_glob) < 60:
                    snd_data_autopopulate(5);
                break;
                case countProperties(content_glob) > 60:
                    snd_data_autopopulate(60);
                break;
            };
        };
    }
});

server.listen(8080, '127.0.0.1');



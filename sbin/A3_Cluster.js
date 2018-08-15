"use strict";

var _ = require('lodash');
var capitalize = require('capitalize');
var Promise = require('bluebird');
var exec = require('child_process').exec;
var spawn = require('child_process').spawn;
var ip = require('ip');
var fs = require('fs');
var express = require('express');
var request = require('requestretry');
var bodyParser = require('body-parser');
var app = express();
var port = 9432;
var update_log_file = '/usr/local/pf/logs/a3_cluster_update.log'



app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies

function audit_log(msg) {
    var currdatetime = new Date();
    var data = '[' + currdatetime +']' + '\n' + msg + '\n'; 
    console.log(data);
    fs.appendFileSync(update_log_file, data, 'utf8');
}

app.get("/node/status", function(req, res){
    res.send("Health");
});

function system_call(cmd, opts) {
    return new Promise(function(resolve, reject){
        var proc = spawn(cmd,opts);
        proc.stdout.on('data', function(data){
	   audit_log(data);
         });
        proc.stdout.on('end', function(data){
	   audit_log('[--end executing spawn-- ]');
	   resolve('OK');
         });
        /*
	proc.stderr.on('data', function(data){
	  reject(data);
	});*/
	proc.on('error', function(err) {
	   audit_log(err);
	   reject(err);
        });

    });
}


app.post("/node/syscall", function(req, res){
    var cmd = req.body.cmd;
    var opts = req.body.opts;
    var others = req.body.others;
    res.setTimeout(3600000);
    audit_log("the cmd to run is "+cmd+ " "+opts);
    system_call(cmd, opts).then(function(resolve){
        res.json({'cmd': '1',
                  'opts': '2',
                  'return': 'SUCESS'});
      }).catch(function(rej){
        res.status(501);
        res.json({'return':rej});
      });
});


app.listen(port);

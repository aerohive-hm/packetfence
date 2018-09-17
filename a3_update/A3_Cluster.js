"use strict";

var _ = require('lodash');
var capitalize = require('capitalize');
var Promise = require('bluebird');
var exec = require('child_process').exec;
var spawn = require('child_process').spawn;
var ip = require('ip');
var fs = require('fs');
var ini = require('ini');
var express = require('express');
var request = require('requestretry');
var bodyParser = require('body-parser');
var app = express();
var port = 9432;
var update_log_file = '/usr/local/pf/logs/a3_cluster_update.log';
var pf_conf = '/usr/local/pf/conf/pf.conf';
var module_opts = ['-I/usr/local/pf/lib', '-Mpf::a3_cluster_update', '-e'];

const perl = '/bin/perl';
const pfcmd = '/usr/local/pf/bin/pfcmd';
const node = '/usr/local/pf/bin/cluster/node';
const systemctl = '/usr/bin/systemctl';
const sync = '/usr/local/pf/bin/cluster/sync';
const pf_mariadb = '/usr/local/pf/sbin/pf-mariadb';

app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies

var config = ini.parse(fs.readFileSync(pf_conf, 'utf-8'));
var api_user = config.webservices.user;
var api_passwd = config.webservices.pass;

function audit_log(msg) {
    var currdatetime = new Date();
    var data = '[' + currdatetime +']' + '\n' + msg + '\n'; 
    console.log(data);
    fs.appendFileSync(update_log_file, data, 'utf8');
}

app.get("/node/status", function(req, res){
    res.send("Health");
});

function assemble_opts(opt) {
    var opts=[];
    module_opts.forEach(function(item){
	opts.push(item);
    });
    opts.push(opt);
    return opts;
}

function system_call(cmd, opts) {
    return new Promise(function(resolve, reject){
        var proc = spawn(cmd,opts);
        proc.stdout.on('data', function(data){
	   data = data.toString();
	   audit_log(data);
         });
        proc.stdout.on('end', function(data){
	   audit_log('[--end executing spawn-- ]');
         });
	proc.stderr.on('error', function(data){
	  reject(data);
	});
        proc.on('close', (code) => {
	   audit_log('The return code for cmd '+cmd+' '+opts+' is ['+code+']');
           if (code == 0) {
                resolve("Success to execute cmd "+cmd+" " +opts);
           }else {
                reject("Failed to execute cmd "+cmd+" "+opts);
           }
        });
        /*
	proc.on('error', function(err) {
	   audit_log(err);
	   reject(err);
        });*/

    });
}

function verify_credential(username, passwd, res) {
    if ((api_user != username) || (api_passwd != passwd)) {
        console.log("failed to verify credential");
        res.status(401);
        res.json({'msg':'failed to verify credential'});
        return 1;
    }
    return 0;
}

function simple_promise_chain_call(cmd, opts, res) {
    system_call(cmd, opts).then(function(resolve){
            audit_log(resolve);
            res.json({'msg': 'Success'});
        }).catch(function(rej){
            audit_log(rej);
            res.status(501);
            res.json({'msg':rej});
        });
}

function get_post_params(req) {
    var ret = [];
    ret.push(req.body.username);
    ret.push(req.body.passwd);
    ret.push(req.body.opts);
    return ret;
}

app.post("/a3/health_check", function(req, res){
    var params = get_post_params(req);
    var opts = assemble_opts('pf::a3_cluster_update::health_check()');
    audit_log("the cmd to run is "+perl+" "+opts);
    var ret = verify_credential(params[0], params[1], res);
    if (ret == 0) {
	simple_promise_chain_call(perl, opts, res);
    }
}); 

app.post("/a3/data_backup", function(req, res){
    var params = get_post_params(req);
    var opts = assemble_opts('pf::a3_cluster_update::dump_app_db()');
    audit_log("the cmd to run is "+perl+" "+opts);
    var ret = verify_credential(params[0], params[1], res);
    if (ret == 0) {
	simple_promise_chain_call(perl, opts, res);
    }
});

app.post("/a3/disable_cluster_check", function(req, res){
    var params = get_post_params(req);
    var opts = ['service', 'pfmon', 'restart'];
    audit_log("the cmd to run is "+pfcmd+ " "+opts);
    var ret = verify_credential(params[0], params[1], res);
    if (ret == 0) {
	simple_promise_chain_call(pfcmd, opts, res);
    }
});


app.post("/a3/update_a3_app", function(req, res){
    var params = get_post_params(req);
    var opts = assemble_opts('pf::a3_cluster_update::update_system_app()');
    res.setTimeout(3600000);
    audit_log("the cmd to run is "+perl+" "+opts);
    var ret = verify_credential(params[0], params[1], res);
    if (ret == 0) {
	system_call(pfcmd, ['service', 'pf', 'stop']).then(function(resolve){
            audit_log(resolve);
        }).then(function(resolve){
            return system_call(perl, opts);
        }).then(function(resolve){
	    audit_log(resolve);
            res.json({'msg': 'Success'});
        }).catch(function(rej){
            audit_log(rej);
            res.status(501);
            res.json({'msg':rej});
        });
   }
});

app.post("/a3/node", function(req, res){
    var params = get_post_params(req);
    let opts = params[2];
    audit_log("the cmd to run is "+node+" "+opts);
    var ret = verify_credential(params[0], params[1], res);
    if (ret == 0) {
	simple_promise_chain_call(node, opts, res);
    }
});


app.post("/a3/pf_cmd", function(req, res){
    var params = get_post_params(req);
    var added_opts=['service'];
    res.setTimeout(3600000);
    let opts = params[2];
    audit_log("the cmd to run is "+pfcmd+" "+opts);
    params[2].forEach(function(item){
	added_opts.push(item);
    });
    var ret = verify_credential(params[0], params[1], res);
    if (ret == 0) {
	simple_promise_chain_call(pfcmd, added_opts, res);
    }
});

app.post("/a3/pf_config", function(req, res){
    var params = get_post_params(req);
    let opts = params[2];
    audit_log("the cmd to run is +systemctl"+" "+opts);
    opts = ['restart', 'packetfence-config'];
    var ret = verify_credential(params[0], params[1], res);
    if (ret == 0) {
	simple_promise_chain_call(systemctl, opts, res);
    }
});

app.post("/a3/sync_files", function(req, res){
    var params = get_post_params(req);
    var opts = ["--from="+params[2][0], "--api-user="+api_user, "--api-password="+api_passwd];
    audit_log("the cmd to run is sync "+opts);
    var ret = verify_credential(params[0], params[1], res);
    if (ret == 0) {
        system_call(systemctl,['restart', 'packetfence-config']).then(function(resolve){
	    return system_call(sync, opts);
	}).then(function(resolve){
            audit_log(resolve);
	    return system_call(pfcmd, ['configreload', 'hard']);
        }).then(function(resolve){
            audit_log(resolve);
            res.json({'msg': 'Success'});
        }).catch(function(rej){
            audit_log(rej);
            res.status(501);
            res.json({'msg':rej});
        });
   }
});


app.post("/a3/kill_force_cluster", function(req, res){
    var params = get_post_params(req);
    var opts = assemble_opts('pf::a3_cluster_update::kill_force_cluster()');
    audit_log("the cmd to run is "+perl+" "+opts);
    var ret = verify_credential(params[0], params[1], res);
    if (ret == 0) {
	simple_promise_chain_call(perl, opts, res);
    }
});

app.post("/a3/apply_db_schema", function(req, res){
    var params = get_post_params(req);
    var opts = assemble_opts('pf::a3_cluster_update::apply_db_update_schema()');
    audit_log("the cmd to run is "+perl+" "+opts);
    var ret = verify_credential(params[0], params[1], res);
    if (ret == 0) {
	simple_promise_chain_call(perl, opts, res);
    }
});

app.post("/a3/kill_force_cluster", function(req, res){
    var params = get_post_params(req);
    var opts = assemble_opts('pf::a3_cluster_update::kill_force_cluster()');
    audit_log("the cmd to run is "+perl+" "+opts);
    var ret = verify_credential(params[0], params[1], res);
    if (ret == 0) {
	simple_promise_chain_call(perl, opts, res);
    }
});

app.post("/a3/post_update", function(req, res){
    var params = get_post_params(req);
    var opts = assemble_opts('pf::a3_cluster_update::post_update()');
    audit_log("the cmd to run is "+perl+" "+opts);
    var ret = verify_credential(params[0], params[1], res);
    if (ret == 0) {
	simple_promise_chain_call(perl, opts, res);
    }
});

app.post("/a3/rollback_app", function(req, res){
    var params = get_post_params(req);
    var opts = assemble_opts('pf::a3_cluster_update::roll_back_app()');
    audit_log("the cmd to run is "+perl+" "+opts);
    var ret = verify_credential(params[0], params[1], res);
    if (ret == 0) {
	simple_promise_chain_call(perl, opts, res);
    }
});

app.post("/a3/rollback_db", function(req, res){
    var params = get_post_params(req);
    var opts = assemble_opts('pf::a3_cluster_update::roll_back_db()');
    audit_log("the cmd to run is "+perl+" "+opts);
    var ret = verify_credential(params[0], params[1], res);
    if (ret == 0) {
	simple_promise_chain_call(perl, opts, res);
    }
});

app.post("/a3/db", function(req, res){
    var params = get_post_params(req);
    let opts = params[2];
    audit_log("the cmd to run is db:"+params[2]);
    var ret = verify_credential(params[0], params[1], res);
    if (ret == 0) {
	if (opts[0] == 'stop') {
            system_call(systemctl, ['stop', 'packetfence-mariadb']).then(function(resolve){
        	audit_log(resolve);
        	res.json({'msg': 'Success'})}).catch(function(rej){
        	    audit_log(rej);
        	    res.status(501);
        	    res.json({'msg':rej});
		})
	}
	else if (opts[0] == 'restart') {
            system_call(systemctl, ['restart', 'packetfence-mariadb']).then(function(resolve){
        	audit_log(resolve);
        	res.json({'msg': 'Success'})}).catch(function(rej){
        	    audit_log(rej);
        	    res.status(501);
        	    res.json({'msg':rej});
		})
	}
	else if (opts[0] == 'new_cluster') {
            system_call(systemctl, ['stop', 'packetfence-mariadb']).then(function(resolve){	
		system_call(pfcmd, ['generatemariadbconfig']);
	    }).then(function(resolve){
		spawn(pf_mariadb, ['--force-new-cluster']);
	    }).then(function(resolve){
	        res.json({'msg': 'Success'});	
            }).catch(function(rej){
                audit_log(rej);
                res.status(501);
                res.json({'msg':rej});
	    })
        }
	else if (opts[0] == 'start') {
            system_call(systemctl, ['start', 'packetfence-mariadb']).then(function(resolve){
        	audit_log(resolve);
        	res.json({'msg': 'Success'})
	    }).catch(function(rej){
                audit_log(rej);
        	res.status(501);
        	res.json({'msg':rej});
	    })
	}
	else if (opts[0] == 'join') {
	    let opts = assemble_opts('pf::a3_cluster_update::delete_mysql_db_files()');
            system_call(systemctl, ['stop', 'packetfence-mariadb']).then(function(resolve){
		system_call(perl, opts);
	    }).then(function(resolve){	
		return system_call(systemctl, ['start', 'packetfence-mariadb']);
            }).then(function(resolve){
                res.json({'msg': 'Success'});
            }).catch(function(rej){
        	audit_log(rej);
        	res.status(501);
        	res.json({'msg':rej});
	    })
	}
        else {
            res.json({'msg': 'Success'});
       }
    }
});


app.listen(port);

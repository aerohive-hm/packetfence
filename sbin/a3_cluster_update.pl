#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use Readonly;
use POSIX;

use lib '/usr/local/pf/lib';
use pf::a3_cluster_update;

Readonly::Scalar my $A3_CLUSTER_UPDATE_LOG_FILE   => "/usr/local/pf/logs/a3_cluster_update.log";
open(UPDATE_CLUSTER_LOG,   '>>', $A3_CLUSTER_UPDATE_LOG_FILE)   || die "Unable to open update log file";

my ($ret, $first_node_ip_to_update, $first_node_hostname);
my (@all_nodes_ip, @all_nodes_hostname, @remains_nodes_ip_to_update, @remains_nodes_hostname);


sub commit_cluster_update_log {
  my $msg = shift @_;
  my $current_time = POSIX::strftime("%Y-%m-%d %H:%M:%S",localtime);
  print UPDATE_CLUSTER_LOG "[ $current_time ] $msg\n";
}

sub get_nodes_info {
  #get all nodes ip information
  @all_nodes_ip = pf::a3_cluster_update::get_all_nodes_ip_update();
  commit_cluster_update_log("The nodes in cluster are [@all_nodes_ip]");

  #get first and remaining node ip information
  $first_node_ip_to_update = pf::a3_cluster_update::get_first_node_ip_update();
  @remains_nodes_ip_to_update = pf::a3_cluster_update::get_remains_nodes_ip_update();
  commit_cluster_update_log("The first node in cluster to update is [$first_node_ip_to_update]");
  commit_cluster_update_log("The remain nodes in cluster to update are [@remains_nodes_ip_to_update]n");

  #get hostname related information
  $first_node_hostname = pf::a3_cluster_update::get_first_node_hostname();
  @remains_nodes_hostname = pf::a3_cluster_update::get_remains_nodes_hostname();
  commit_cluster_update_log("The first node hostname in cluster to update is [$first_node_hostname]");
  commit_cluster_update_log("The remain nodes hostname in cluster to update are [@remains_nodes_hostname]");

  @all_nodes_hostname = @remains_nodes_hostname;
  push @all_nodes_hostname, $first_node_hostname;

}

sub health_check {
  #health check before update
  for my $node_ip (@all_nodes_ip) {
    $ret = rest_module_call($node_ip, 'health_check');
    if ($ret != 0) {
      commit_cluster_update_log("Health check failed on node $node_ip, please check detail log on peer node");
      exit 1;
    }
  }
}

#backup db and app
sub data_backup {
  for my $node_ip (@all_nodes_ip) {
    rest_module_call($node_ip, 'dump_app_db');
    if ($ret != 0) {
      commit_cluster_update_log("Unable to backup on node $node_ip");
      exit 1;
    }
  }
}

#disable cluster check 
sub disable_cluster_check {
  pf::a3_cluster_update::disable_cluster_check();
  for my $node_ip (@all_nodes_ip) {
    rest_sys_call($node_ip, '/usr/local/pf/bin/pfcmd', 'service', 'pfmon', 'restart');
  }
}

sub rest_module_call {
  my ($ip, $action) = @_;
  my $ret = pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/bin/perl', 'opts'=>['-I/usr/local/pf/lib', '-Mpf::a3_cluster_update', '-e', "pf::a3_cluster_update::".$action."()"]});
  return $ret;
}

sub rest_sys_call {
  my ($ip, $cmd, @params) = @_;
  my $opts ;
  for my $param (@params) {
    $opts .= "'".$param."',";
  }
  #remove last ','
  chop $opts;
  my $ret = pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>"$cmd", 'opts'=>["$opts"]});

  commit_cluster_update_log("The cmd is $cmd and the opts is ".$opts);
  return $ret;
}

sub rest_sys_call_async {
  my ($ip, $cmd, @params) = @_;
  my $opts ;
  for my $param (@params) {
    $opts .= "'".$param."',";
  }
  #remove last ','
  chop $opts;
  my $ret = pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>"$cmd", 'opts'=>["$opts"], 'method'=>'async'});

  commit_cluster_update_log("The cmd is $cmd and the opts is ".$opts);
  return $ret;

}


#update A3 rpm on node
sub a3_app_update {
  my $ip = shift @_;
  rest_sys_call($ip, '/usr/local/pf/bin/pfcmd', 'service', 'pf', 'stop');
  $ret = rest_module_call($ip, "update_system_app");
  if ($ret != 0) {
    rest_module_call($ip, 'roll_back_app');
    rest_sys_call($ip, '/usr/local/pf/bin/pfcmd', 'service', 'pf', 'start');
    exit 1;
  }
}


#apply db migration schema 
sub apply_db_schema {
  my $ret = rest_module_call($first_node_ip_to_update, 'apply_db_update_schema');
  if ($ret != 0) {
    commit_cluster_update_log("start rollback for app and db on node $first_node_ip_to_update");
    rest_module_call($first_node_ip_to_update, 'roll_back_app');
    rest_module_call($first_node_ip_to_update, 'roll_back_db');
    #rejoin the cluster
    for my $ip (@remains_nodes_ip_to_update) {
      rest_sys_call($ip, '/usr/local/pf/bin/cluster/node', $first_node_hostname, 'enable');
      rest_sys_call($ip, '/usr/local/pf/bin/pfcmd', 'service', 'haproxy-db', 'restart');
      rest_sys_call($ip, '/usr/local/pf/bin/pfcmd', 'service', 'keepalived', 'restart');
    }
    for my $hostname (@remains_nodes_hostname) {
      rest_sys_call($first_node_ip_to_update, '/usr/local/pf/bin/cluster/node', $hostname, 'enable');
    }
    rest_sys_call($first_node_ip_to_update, '/usr/bin/systemctl', 'restart', 'packetfence-mariadb');
    commit_cluster_update_log("end rollback for app and db on node $first_node_ip_to_update");
    exit 1;
  }
}

sub sync_files_from_master {
  for my $ip (@remains_nodes_ip_to_update) {
    rest_sys_call($ip, '/usr/bin/systemctl', 'restart', 'packetfence-config');
    rest_sys_call($ip, '/usr/local/pf/bin/cluster/sync', "--from=$$first_node_ip_to_update", "--api-user=packet", "--api-password=fence");
    rest_sys_call($ip, '/usr/local/pf/bin/pfcmd', 'configreload', 'hard');
  }
}

sub galera_db_sync {
  rest_sys_call($first_node_ip_to_update, '/usr/bin/systemctl', 'stop', 'packetfence-mariadb');
  rest_sys_call($first_node_ip_to_update, '/usr/local/pf/bin/pfcmd', 'generatemariadbconfig');
  rest_sys_call_async($first_node_ip_to_update, '/usr/local/pf/sbin/pf-mariadb', '--force-new-cluster');

  #join db Galera cluster from remainging nodes
  for my $ip (@remains_nodes_ip_to_update) {
    rest_sys_call($ip, '/usr/bin/systemctl', 'stop', 'packetfence-mariadb');
  }

  for my $ip (@remains_nodes_ip_to_update) {
    pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/bin/perl', 'opts'=>['-I/usr/local/pf/lib', '-Mpf::a3_cluster_update', '-e', 'pf::a3_cluster_update::delete_mysql_db_files()']});
  }

  for my $ip (@remains_nodes_ip_to_update) {
    pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/bin/systemctl', 'opts'=>['start', 'packetfence-mariadb']});
  }

  #kill force cluster process
  rest_module_call($first_node_ip_to_update, 'kill_force_cluster');

  #wait mysql force cluster process to quit and start db service on first node
  sleep 10;
  rest_sys_call($first_node_ip_to_update, '/usr/bin/systemctl', 'start', 'packetfence-mariadb');

}

#restart of services on all nodes, VIP will float to the one with high priotiry value in keepalived.conf
sub restart_pf_all_services {
  for my $ip (@all_nodes_ip) {
    my $ret = rest_sys_call($ip, '/usr/local/pf/bin/pfcmd', 'service', 'pf', 'restart');
    if ($ret != 0) {
      commit_cluster_update_log("Service restart failed, please use join cluster process to continue!");
      exit 1;
    }
  }
}

sub disable_misc_services {
  #disable node and restart services on remaining nodes
  for my $ip (@remains_nodes_ip_to_update) {
    rest_sys_call($ip, '/usr/local/pf/bin/cluster/node', $first_node_hostname, 'disable');
    rest_sys_call($ip, '/usr/local/pf/bin/pfcmd', 'service', 'haproxy-db', 'restart');
    rest_sys_call($ip, '/usr/local/pf/bin/pfcmd', 'service', 'keepalived', 'restart');
  }

  #disable node on first node
  for my $hostname (@remains_nodes_hostname) {
    rest_sys_call($first_node_ip_to_update, '/usr/local/pf/bin/cluster/node', $hostname, 'disable');
  }
  #restart db on first node
  rest_sys_call($first_node_ip_to_update, '/usr/bin/systemctl', 'restart', 'packetfence-mariadb');
}

sub enable_nodes_after_update {
  #enable node on remaining nodes
  for my $hostname (@remains_nodes_hostname) {
    rest_sys_call($first_node_ip_to_update, '/usr/local/pf/bin/cluster/node', $hostname, 'enable');
  }

  #enable node on first node
  for my $ip (@remains_nodes_ip_to_update) {
    rest_sys_call($ip, '/usr/local/pf/bin/cluster/node', $first_node_hostname, 'enable');
  }
}

get_nodes_info();
health_check();
data_backup();
disable_cluster_check();
a3_app_update($first_node_ip_to_update);
disable_misc_services();


apply_db_schema();

#stop pf service and db service on remaining nodes
for my $ip (@remains_nodes_ip_to_update) {
  rest_sys_call($ip, '/usr/local/pf/bin/pfcmd', 'service', 'pf', 'stop');
  rest_sys_call($ip, '/usr/bin/systemctl', 'stop', 'packetfence-mariadb');
}

#post step on first node
rest_module_call($first_node_ip_to_update, 'post_update');

#start pf service on first node
rest_sys_call($first_node_ip_to_update, '/usr/local/pf/bin/pfcmd', 'service', 'pf', 'start');

#update A3 rpm on remaining nodes
for my $ip (@remains_nodes_ip_to_update) {
  a3_app_update($ip);
}

sync_files_from_master();

enable_nodes_after_update();
galera_db_sync();

restart_pf_all_services();

#Finsih update
print "\nThe whole update process finished, please resume the pf service!!\n";
commit_cluster_update_log("The whole update process finished, please resume the pf service!!");

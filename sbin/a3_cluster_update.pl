#!/usr/bin/perl
use strict;
use warnings;
use REST::Client;
use JSON;
use Readonly;
use POSIX;

use lib '/usr/local/pf/lib';
use pf::a3_cluster_update;

Readonly::Scalar my $A3_CLUSTER_UPDATE_LOG_FILE   => "/usr/local/pf/logs/a3_cluster_update.log";
open(UPDATE_CLUSTER_LOG,   '>>', $A3_CLUSTER_UPDATE_LOG_FILE)   || die "Unable to open update log file";

my $ret;

sub commit_cluster_update_log {
  my $msg = shift @_;
  my $current_time = POSIX::strftime("%Y-%m-%d %H:%M:%S",localtime);
  print UPDATE_CLUSTER_LOG "[ $current_time ] $msg\n";
}

#get all nodes ip information
my @all_nodes_ip = pf::a3_cluster_update::get_all_nodes_ip_update();
commit_cluster_update_log("The nodes in cluster are [@all_nodes_ip]");

#get first and remaining node ip information
my $first_node_ip_to_update = pf::a3_cluster_update::get_first_node_ip_update();
my @remains_nodes_ip_to_update = pf::a3_cluster_update::get_remains_nodes_ip_update();
commit_cluster_update_log("The first node in cluster to update is [$first_node_ip_to_update]");
commit_cluster_update_log("The remain nodes in cluster to update are [@remains_nodes_ip_to_update]n");

#get hostname related information
my $first_node_hostname = pf::a3_cluster_update::get_first_node_hostname();
my @remains_nodes_hostname = pf::a3_cluster_update::get_remains_nodes_hostname();
commit_cluster_update_log("The first node hostname in cluster to update is [$first_node_hostname]");
commit_cluster_update_log("The remain nodes hostname in cluster to update are [@remains_nodes_hostname]");

my @all_nodes_hostname = @remains_nodes_hostname;
push @all_nodes_hostname, $first_node_hostname;

#health check before update
for my $node_ip (@all_nodes_ip) {
  $ret=pf::a3_cluster_update::remote_api_call_post($node_ip, 'node/syscall',{'cmd'=>'/bin/perl', 'opts'=>['-I/usr/local/pf/lib', '-Mpf::a3_cluster_update', '-e', 'pf::a3_cluster_update::health_check()']});
  if ($ret != 0) {
    commit_cluster_update_log("Health check failed on node $node_ip, please check detail log on peer node");
    exit 1;
  }
}

#backup db and app
for my $node_ip (@all_nodes_ip) {
  pf::a3_cluster_update::remote_api_call_post($node_ip, 'node/syscall',{'cmd'=>'/bin/perl', 'opts'=>['-I/usr/local/pf/lib', '-Mpf::a3_cluster_update', '-e', 'pf::a3_cluster_update::dump_app_db()']});
}

#disable cluster check 
pf::a3_cluster_update::disable_cluster_check();
for my $node_ip (@all_nodes_ip) {
  pf::a3_cluster_update::remote_api_call_post($node_ip, 'node/syscall',{'cmd'=>'/usr/local/pf/bin/pfcmd', 'opts'=>['service', 'pfmon','restart']});
}

#stop pf service on first node to update
pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/pfcmd', 'opts'=>['service', 'pf','stop']});

#update A3 rpm on first node to update
$ret = pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/bin/perl', 'opts'=>['-I/usr/local/pf/lib', '-Mpf::a3_cluster_update', '-e', 'pf::a3_cluster_update::update_system_app()']});
if ($ret != 0) {
  commit_cluster_update_log("start rollback for app on node $first_node_ip_to_update");
  pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/bin/perl', 'opts'=>['-I/usr/local/pf/lib', '-Mpf::a3_cluster_update', '-e', 'pf::a3_cluster_update::roll_back_app()']});
  pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/pfcmd', 'opts'=>['service', 'pf','start']});
  commit_cluster_update_log("end rollback");
}


#disable node and restart services on remaining nodes
for my $ip (@remains_nodes_ip_to_update) {
  pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/cluster/node', 'opts'=>["$first_node_hostname", 'disable']});
  pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/pfcmd', 'opts'=>['service', 'haproxy-db','restart']});
  pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/pfcmd', 'opts'=>['service', 'keepalived','restart']});
}

#disable node on first node
for my $hostname (@remains_nodes_hostname) {
  pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/cluster/node', 'opts'=>["$hostname", 'disable']});
}

#restart db on first node
pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/usr/bin/systemctl', 'opts'=>['restart', 'packetfence-mariadb']});

#apply db migration schema on first node
$ret = pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/bin/perl', 'opts'=>['-I/usr/local/pf/lib', '-Mpf::a3_cluster_update', '-e', 'pf::a3_cluster_update::apply_db_update_schema()']});
if ($ret != 0) {
  commit_cluster_update_log("start rollback for app and db on node $first_node_ip_to_update");
  pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/bin/perl', 'opts'=>['-I/usr/local/pf/lib', '-Mpf::a3_cluster_update', '-e', 'pf::a3_cluster_update::roll_back_app()']});
  #rejoin the cluster
  for my $ip (@remains_nodes_ip_to_update) {
    pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/cluster/node', 'opts'=>["$first_node_hostname", 'enable']});
    pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/pfcmd', 'opts'=>['service', 'haproxy-db','restart']});
    pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/pfcmd', 'opts'=>['service', 'keepalived','restart']});
  }
  for my $hostname (@remains_nodes_hostname) {
    pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/cluster/node','opts'=>["$hostname", 'enable']});
  }
  pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/usr/bin/systemctl', 'opts'=>['restart', 'packetfence-mariadb']});
  commit_cluster_update_log("end rollback for app and db on node $first_node_ip_to_update");
}

#stop pf service and db service on remaining nodes
for my $ip (@remains_nodes_ip_to_update) {
  pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/pfcmd', 'opts'=>['service', 'pf','stop']});
  pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/bin/systemctl', 'opts'=>['stop', 'packetfence-mariadb']});
}

#post step on first node
pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/bin/perl', 'opts'=>['-I/usr/local/pf/lib', '-Mpf::a3_cluster_update', '-e', 'pf::a3_cluster_update::post_update()']});


#start pf service on first node
pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/pfcmd', 'opts'=>['service', 'pf','start']});

#update A3 rpm on remaining nodes
for my $ip (@remains_nodes_ip_to_update) {
  $ret = pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/bin/perl', 'opts'=>['-I/usr/local/pf/lib', '-Mpf::a3_cluster_update', '-e', 'pf::a3_cluster_update::update_system_app()']});
  if ($ret != 0) {
    commit_cluster_update_log("Update system app on node $ip failed, please use join cluster process to continue!");
    exit 1;
  }
}

#restart pf config, sycn files, load configs on remaining nodes
for my $ip (@remains_nodes_ip_to_update) {
  pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/bin/systemctl', 'opts'=>['restart', 'packetfence-config']});
  pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/cluster/sync', 'opts'=>["--from=$first_node_ip_to_update", '--api-user=packet','--api-password=fence']});
  pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/pfcmd', 'opts'=>['configreload', 'hard']});
}

#enable node on remaining nodes
for my $hostname (@remains_nodes_hostname) {
  pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/cluster/node', 'opts'=>["$hostname", 'enable']});
}

#enable node on first node
for my $ip (@remains_nodes_ip_to_update) {
  pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/cluster/node', 'opts'=>["$first_node_hostname", 'enable']});
}

#force new cluster on first node
pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/usr/bin/systemctl', 'opts'=>['stop', 'packetfence-mariadb']});
pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/pfcmd', 'opts'=>['generatemariadbconfig']});
pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/usr/local/pf/sbin/pf-mariadb', 'opts'=>['--force-new-cluster'],'method'=>'async'});

#join db Galera cluster from remainging nodes
for my $ip (@remains_nodes_ip_to_update) {
  pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/bin/systemctl', 'opts'=>['stop', 'packetfence-mariadb']});
}

for my $ip (@remains_nodes_ip_to_update) {
  pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/bin/perl', 'opts'=>['-I/usr/local/pf/lib', '-Mpf::a3_cluster_update', '-e', 'pf::a3_cluster_update::delete_mysql_db_files()']});
}

for my $ip (@remains_nodes_ip_to_update) {
  pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/bin/systemctl', 'opts'=>['start', 'packetfence-mariadb']});
}

#kill force cluster process
pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/bin/perl', 'opts'=>['-I/usr/local/pf/lib', '-Mpf::a3_cluster_update', '-e', 'pf::a3_cluster_update::kill_force_cluster()']});

#wait mysql force cluster process to quit and start db service on first node
sleep 10;
pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'node/syscall', {'cmd'=>'/usr/bin/systemctl', 'opts'=>['start', 'packetfence-mariadb']});

#restart of services on all nodes, VIP will float to the one with high priotiry value in keepalived.conf
for my $ip (@all_nodes_ip) {
  $ret = pf::a3_cluster_update::remote_api_call_post($ip, 'node/syscall', {'cmd'=>'/usr/local/pf/bin/pfcmd', 'opts'=>['service', 'pf','restart']});
  if ($ret != 0) {
    commit_cluster_update_log("Service restart failed, please use join cluster process to continue!");
    exit 1;
  }
 
}

#Finsih update
print "\nThe whole update process finished, please resume the pf service!!\n";
commit_cluster_update_log("The whole update process finished, please resume the pf service!!");

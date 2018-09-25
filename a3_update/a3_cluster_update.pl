#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use REST::Client;
use Readonly;
use POSIX;

use lib '/usr/local/pf/lib';
use pf::a3_cluster_update;
use pf::config qw(%Config);

Readonly::Scalar my $A3_BASE_DIR                => '/usr/local/pf';
Readonly::Scalar my $A3_CLUSTER_UPDATE_LOG_FILE => "$A3_BASE_DIR/logs/a3_cluster_update.log";
Readonly::Scalar my $A3_PROGRESS_LOG_FILE       => "$A3_BASE_DIR/html/update/a3_update.progress";

open(UPDATE_CLUSTER_LOG, '>>', $A3_CLUSTER_UPDATE_LOG_FILE) || die "Unable to open update log file";
open(PROGRESS_LOG,       '>',  $A3_PROGRESS_LOG_FILE)       || die "Unable to open progress log file";

my ($ret, $first_node_ip_to_update, $first_node_hostname);
my (@all_nodes_ip, @all_nodes_hostname, @remains_nodes_ip_to_update, @remains_nodes_hostname);


sub commit_cluster_update_log {
  my $msg = shift @_;
  my $current_time = POSIX::strftime("%Y-%m-%d %H:%M:%S",localtime);
  print UPDATE_CLUSTER_LOG "[ $current_time ] $msg\n";
}

sub commit_progress_log_action_start {
  my $msg = shift @_;
  print PROGRESS_LOG "$msg... ";
}

sub commit_progress_log {
  my $msg = shift @_;
  print PROGRESS_LOG "$msg\n";
}

sub exit_success {
  commit_progress_log("Cluster update completed successfully.");
  exit 0;
}

sub exit_failure {
  my ($code) = @_;
  commit_progress_log("Cluster update was unsuccessful.");
  exit $code // 1;
}

sub get_nodes_info {
  commit_progress_log_action_start("Gathering cluster information");

  #get all nodes ip information
  @all_nodes_ip = pf::a3_cluster_update::get_all_nodes_ip_update();
  commit_cluster_update_log("The nodes in cluster are [@all_nodes_ip]");

  #get first and remaining node ip information
  $first_node_ip_to_update = pf::a3_cluster_update::get_first_node_ip_update();
  @remains_nodes_ip_to_update = pf::a3_cluster_update::get_remains_nodes_ip_update();
  commit_cluster_update_log("The first node in cluster to update is [$first_node_ip_to_update]");
  commit_cluster_update_log("The remaining nodes in cluster to update are [@remains_nodes_ip_to_update]");

  #get hostname related information
  $first_node_hostname = pf::a3_cluster_update::get_first_node_hostname();
  @remains_nodes_hostname = pf::a3_cluster_update::get_remains_nodes_hostname();
  commit_cluster_update_log("The first node hostname in cluster to update is [$first_node_hostname]");
  commit_cluster_update_log("The remaining node hostnamed in cluster to update are [@remains_nodes_hostname]");

  @all_nodes_hostname = @remains_nodes_hostname;
  push @all_nodes_hostname, $first_node_hostname;

  commit_progress_log("done!");
}

sub health_check {
  #health check before update
  commit_progress_log_action_start("Checking health of cluster nodes");

  for my $node_ip (@all_nodes_ip) {
    $ret = pf::a3_cluster_update::remote_api_call_post($node_ip, 'a3/health_check', {});
    if ($ret != 0) {
      commit_cluster_update_log("Health check failed on node $node_ip, please check detail log on peer node");
      commit_progress_log("error at $node_ip");
      exit_failure(1);
    }
  }

  commit_progress_log("done!");
}

#backup db and app
sub data_backup {
  commit_progress_log_action_start("Backing up cluster data");

  for my $node_ip (@all_nodes_ip) {
    my $ret = pf::a3_cluster_update::remote_api_call_post($node_ip, 'a3/data_backup', {});
    if ($ret != 0) {
      commit_cluster_update_log("Unable to backup on node $node_ip");
      commit_progress_log("error at $node_ip");
      exit_failure(1);
    }
  }

  commit_progress_log("done!");
}

#disable cluster check 
sub disable_cluster_check {
  commit_progress_log_action_start("Temporarily disabling cluster integrity checks");

  pf::a3_cluster_update::disable_cluster_check();
  for my $node_ip (@all_nodes_ip) {
    pf::a3_cluster_update::remote_api_call_post($node_ip, 'a3/disable_cluster_check', {});
  }

  commit_progress_log("done!");
}

#update A3 rpm on node
sub a3_app_update {
  my $ip = shift @_;

  commit_progress_log_action_start("Updating application software on $ip");

  $ret = pf::a3_cluster_update::remote_api_call_post($ip, 'a3/update_a3_app', {});
  if ($ret != 0) {
    #at later stage failing on other nodes, we using API to remove them from cluster
    if ($ip ne $first_node_ip_to_update) {
      remove_nodes_from_cluster();
      commit_progress_log("error at $ip");
      exit_failure(1);
    }
    pf::a3_cluster_update::remote_api_call_post($ip, 'a3/rollback_app', {});
    pf::a3_cluster_update::remote_api_call_post($ip, 'a3/pf_cmd', {'opts'=>['pf', 'start']});
    exit_failure(1);
  }

  commit_progress_log("done!");
}

sub rejoin_node_to_cluster {
  pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'a3/rollback_app', {});
  for my $hostname (@remains_nodes_hostname) {
    pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'a3/node', {'opts'=>["$hostname", 'enable']});
  }
  pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'a3/db', {'opts'=>['join']});
  for my $ip (@remains_nodes_ip_to_update) {
    pf::a3_cluster_update::remote_api_call_post($ip, 'a3/node', {'opts'=>["$first_node_hostname", 'enable']});
    pf::a3_cluster_update::remote_api_call_post($ip, 'a3/pf_cmd', {'opts'=>['haproxy-db', 'restart']});
    pf::a3_cluster_update::remote_api_call_post($ip, 'a3/pf_cmd', {'opts'=>['keepalived', 'restart']});
  }
  #pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'a3/db', {'opts'=>['restart']});
}

#apply db migration schema 
sub apply_db_schema {
  commit_progress_log_action_start("Applying database schema updates");

  my $ret = pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'a3/apply_db_schema', {});
  if ($ret != 0) {
    commit_progress_log("error");

    #once failure on this, we rejoin first node to cluster
    commit_cluster_update_log("start rejoin node $first_node_ip_to_update");
    rejoin_node_to_cluster();
    commit_cluster_update_log("end rejoin node $first_node_ip_to_update");

    exit_failure(1);
  }

  commit_progress_log("done!");
}

sub apply_conf_migration {
  my $ip = shift @_;
  commit_progress_log_action_start("Applying conf migration");

  my $ret = pf::a3_cluster_update::remote_api_call_post($ip, 'a3/apply_conf_migration', {});

  commit_progress_log("done!");
}

sub sync_files_from_master {
  commit_progress_log_action_start("Synchronizing cluster files");

  for my $ip (@remains_nodes_ip_to_update) {
    pf::a3_cluster_update::remote_api_call_post($ip, 'a3/sync_files', {'opts'=>["$first_node_ip_to_update"]});
  }

  commit_progress_log("done!");
}

sub galera_db_sync {
  commit_progress_log_action_start("Synchronizing cluster database");

  pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'a3/db', {'opts'=>['new_cluster']});

  for my $ip (@remains_nodes_ip_to_update) {
    pf::a3_cluster_update::remote_api_call_post($ip, 'a3/db', {'opts'=>['join']});
  }

  # wait for mysqld process is fully up on the one node cluster env, then kill it for belowing step  
  sleep 10;

  #kill force cluster process
  pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'a3/kill_force_cluster', {});

  #wait mysql force cluster process to quit and start db service on first node
  sleep 10;
  pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'a3/db', {'opts'=>['start']});

  commit_progress_log("done!");
}

#restart of services on all nodes, VIP will float to the one with high priotiry value in keepalived.conf
sub restart_pf_all_services {
  commit_progress_log_action_start("Restarting cluster services");

  for my $ip (@all_nodes_ip) {
    my $ret = pf::a3_cluster_update::remote_api_call_post($ip, 'a3/pf_cmd', {'opts'=>['pf', 'restart']});
    if ($ret != 0) {
      commit_progress_log("error at $ip");
      commit_cluster_update_log("Service restart failed, please use join cluster process to continue!");
      exit_failure(1);
    }
  }

  commit_progress_log("done!");
}

sub disable_misc_services {
  #disable node and restart services on remaining nodes
  for my $ip (@remains_nodes_ip_to_update) {
    commit_progress_log_action_start("Shutting down services on $ip");

    pf::a3_cluster_update::remote_api_call_post($ip, 'a3/node', {'opts'=>["$first_node_hostname", 'disable']});
    pf::a3_cluster_update::remote_api_call_post($ip, 'a3/pf_cmd', {'opts'=>['haproxy-db', 'restart']});
    pf::a3_cluster_update::remote_api_call_post($ip, 'a3/pf_cmd', {'opts'=>['keepalived', 'restart']});

    commit_progress_log("done!");
  }

  #disable node on first node
  commit_progress_log_action_start("Preparing first node to update");

  for my $hostname (@remains_nodes_hostname) {
    pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'a3/node', {'opts'=>["$hostname", 'disable']});
  }

  #restart db on first node
  pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'a3/db', {'opts'=>['restart']});

  commit_progress_log("done!");
}

sub enable_nodes_after_update {
  #enable node on remaining nodes
  for my $hostname (@remains_nodes_hostname) {
    pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'a3/node', {'opts'=>["$hostname", 'enable']});
  }

  #enable node on first node
  for my $ip (@remains_nodes_ip_to_update) {
    pf::a3_cluster_update::remote_api_call_post($ip, 'a3/node', {'opts'=>["$first_node_hostname", 'enable']});
  }
}


sub remove_nodes_from_cluster {
  my $url = "https://".$first_node_ip_to_update.":9999/api/v1/login";
  my $data = {};
  my $remove_nodes_list = [];

  my $client = REST::Client->new({timeout=>360});

  $client->addHeader('Content-Type', 'application/json');
  $client->addHeader('charset', 'UTF-8');
  $client->addHeader('Accept', 'application/json');
  
  
  $client->getUseragent()->ssl_opts(SSL_verify_mode => 'SSL_VERIFY_NONE');
  $client->getUseragent()->ssl_opts(verify_hostname => 0);
  my ($username, $passwd);
  $username = $Config{webservices}->{user};
  $passwd = $Config{webservices}->{pass};

  $data->{username} = $username;
  $data->{password} = $passwd;
 
  my $json_data = encode_json($data);
  $client->POST($url, $json_data);
  if( $client->responseCode() ne '200' ){
     commit_cluster_update_log("Unable to get token from $first_node_ip_to_update");
     exit 1;
  }
  
  my $res_data = decode_json($client->responseContent());
  my $token=$res_data->{'token'};

  commit_cluster_update_log("The token get from $first_node_ip_to_update is $token");
  
  $data = {};
  $url = "https://".$first_node_ip_to_update.":9999/a3/api/v1/configuration/cluster/remove";
  $client->addHeader('Authorization', "$token");

  foreach my $node (@remains_nodes_hostname) {
    push @$remove_nodes_list, $node;
  }

  $data->{'hostname'} = $remove_nodes_list;
  $json_data = encode_json($data);
  $client->POST($url, $json_data);

  if( $client->responseCode() ne '200' ){
     commit_cluster_update_log("Unable to remove node from $first_node_ip_to_update");
     exit 1;
  }
}

get_nodes_info();
health_check();
data_backup();
disable_cluster_check();
a3_app_update($first_node_ip_to_update);
disable_misc_services();

apply_db_schema();
apply_conf_migration($first_node_ip_to_update);

#stop pf service and db service on remaining nodes
for my $ip (@remains_nodes_ip_to_update) {
  pf::a3_cluster_update::remote_api_call_post($ip, 'a3/pf_cmd', {'opts'=>['pf', 'stop']});
  pf::a3_cluster_update::remote_api_call_post($ip, 'a3/db', {'opts'=>['stop']});
}

#post step on first node
pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'a3/post_update', {});

#start pf service on first node
pf::a3_cluster_update::remote_api_call_post($first_node_ip_to_update, 'a3/pf_cmd', {'opts'=>['pf', 'start']});

#update A3 rpm on remaining nodes
for my $ip (@remains_nodes_ip_to_update) {
  a3_app_update($ip);
}

sync_files_from_master();

enable_nodes_after_update();

#somehow db is up again after pkg upgrade, need investigate the reason for that
for my $ip (@remains_nodes_ip_to_update) {
  pf::a3_cluster_update::remote_api_call_post($ip, 'a3/db', {'opts'=>['stop']});
}
galera_db_sync();

# run conf migration on remaining nodes 
for my $ip (@remains_nodes_ip_to_update) {
  apply_conf_migration($ip);
}

# post action, like fix permission, write current-at file
for my $ip (@remains_nodes_ip_to_update) {
  pf::a3_cluster_update::remote_api_call_post($ip, 'a3/post_update', {});
}

# for customized modification after cluster update done, call this plugin
for my $node_ip (@all_nodes_ip) {
    $ret = pf::a3_cluster_update::remote_api_call_post($node_ip, 'a3/post_process', {});
    if ($ret != 0) {
      commit_cluster_update_log("Post process on node $node_ip, please check detail log on peer node");
      commit_progress_log("error at $node_ip");
    }
}

restart_pf_all_services();

#Finish update
print "\nThe whole update process finished, please resume the pf service!!\n";
commit_cluster_update_log("The whole update process finished, please resume the pf service!!");

exit_success();

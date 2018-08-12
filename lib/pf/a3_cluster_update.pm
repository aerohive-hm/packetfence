package pf::a3_cluster_update;

=head1 NAME

pf::a3_cluster_update Support functions for A3 software update across cluster

=head1 DESCRIPTION

Support functions for A3 software update across cluster

=cut

use strict;
use warnings;

use pf::log;
use pf::version;
use Readonly;
use POSIX ();
use Exporter;
use REST::Client;
use JSON;
use File::Slurp;

our ( @ISA, @EXPORT_OK );
@ISA = qw(Exporter);
@EXPORT_OK = qw(disable_cluster_check call_system_cmd);

Readonly::Scalar my $BIN_DIR                      => '/usr/bin';
Readonly::Scalar my $YUM_BIN                      => "$BIN_DIR/yum";
Readonly::Scalar my $A3_BASE_DIR                  => '/usr/local/pf';
Readonly::Scalar my $A3_DB_DIR                    => "$A3_BASE_DIR/db";
Readonly::Scalar my $A3_CONF_DIR                  => "$A3_BASE_DIR/conf";
Readonly::Scalar my $PF_MON_CONF                  => '$A3_CONF_DIR/pfmon.conf';
Readonly::Scalar my $PF_CLUSTER_CONF              => '$A3_CONF_DIR/cluster.conf';
Readonly::Scalar my $A3_LOG_DIR                   => "$A3_BASE_DIR/logs";
Readonly::Scalar my $A3_CLUSTER_UPDATE_LOG_FILE   => "$A3_LOG_DIR/a3_cluster_update.log";
Readonly::Scalar my $NODE_BIN 			  => "$A3_BASE_DIR/bin/cluster/node";
Readonly::Scalar my $A3_UPDATE_PATH_FILE          => "$A3_DB_DIR/a3-update-path";
Readonly::Scalar my $A3_BK_VER_FILE               => "/tmp/a3_bk_ver_file";

open(UPDATE_CLUSTER_LOG,   '>>', $A3_CLUSTER_UPDATE_LOG_FILE)   || die "Unable to open update log file";
my $a3_pkg = 'A3';

=head2 disable_cluster_check

Disable Cluster Check Task

=cut

sub disable_cluster_check {
  open PFMON, ">", $PF_MON_CONF or die "Unable to open pf monitor file!";

  print PFMON "[cluster_check]\n";
  print PFMON "status=disabled";

  close PFMON;
}


=head2 _commit_cluster_update_log

internal call for commit log

=cut

sub _commit_cluster_update_log {
  my $msg = shift @_;
  my $current_time = POSIX::strftime("%Y-%m-%d %H:%M:%S",localtime);
  print UPDATE_CLUSTER_LOG "[ $current_time ] $msg\n";
}

sub A3_Die {
  my $msg = shift;
  _commit_cluster_update_log($msg);
  die "$msg\n";
}


sub A3_Warn {
  my $msg = shift;
  _commit_cluster_update_log($msg);
  warn "$msg\n";

}

=head2 call_system_cmd

System Call

=cut

sub call_system_cmd {
  my $cmd = shift;

  _commit_cluster_update_log("call_system invoked with \"$cmd\"");

  my $ret       = system($cmd);
  my $exit_code = $ret >> 8;

  _commit_cluster_update_log("system() returned $ret, exit code is $exit_code");

  return $exit_code;
}

=head2 

System call with output

=cut

sub call_system_cmd_with_output {
  my $cmd = shift;

  _commit_cluster_update_log("call_system invoked with \"$cmd\"");

  my $output = `$cmd` or A3_Die("Execute $cmd failed with ".$!);
  _commit_cluster_update_log("output");
    
  _commit_cluster_update_log("call_system invoked with \"$cmd\" ends");

}


sub update_system_app {
  my @all_pkgs;
  my $cmd = "$YUM_BIN update ";
  #backup previous A3 version
  open my $fh, ">", "$A3_BK_VER_FILE";
  my $bk_ver = pf::version::version_get_current();
  print $fh "bk_version=$pre_ver";
  close $fh;
  open CMD, '-|',  "$YUM_BIN list $a3_pkg*    \\
                  | $SED_BIN '1,/Available/d' \\
                  | $AWK_BIN '{print \$1}'    \\
                  | $TEE_BIN -a $A3_UPDATE_LOG_FILE" or die $@;
  while (<CMD>) {
    chomp($_);
    push @all_pkgs, $_;
  }
  foreach (@all_pkgs) {
       $cmd .= $_ . " ";
  }
  $cmd .= " -y";
  _commit_cluster_update_log("Update pkg cmd is $cmd");

  if (call_system("$cmd >> $A3_CLUSTER_UPDATE_LOG_FILE 2>&1") != 0) {
    A3_Warn("Unable to update A3 packages, attempting to rollback changes");
  }
  
}


sub get_to_version {
  my $ava_version;
  open CMD, '-|', "$YUM_BIN list $a3_pkg available" or die $@;
  while (<CMD>) {
    if($_ =~ /Available Packages/) {
      next;
    }
    #this will be 1.1.1-0.20180611.el7 string value
    $ava_version = (split /(\s)+/, $_)[2];
  }
  my $to_version = (split /-/, $ava_version)[0];
  _commit_cluster_update_log("A3 target update version is $to_version");
  return $to_version;
}


sub generate_update_patch_list {
  my $to_version = get_to_version();
  my $current_version;
  my @update_path_list;
  my $content = do {
    open my $fh, '<', "$A3_BK_VER_FILE"  or die '...';
    local $/;
    <$fh>;
  };
  my $prev_version = (split /=/, $content)[1];
  _commit_cluster_update_log("A3 back version is $pre_version and A3 target update version is $to_version");
  
  open my $fh, '<', "$A3_UPDATE_PATH_FILE" or die "Unable to locate update path file, $!";
  my $count = 0;
  # get the update list from update path file (From to To only)
  while (<$fh>) {
    chomp $_;
    if ($prev_version eq $_) {
      $count++;
      push @update_path_list, $_;
      next;
    }elsif ($to_version eq $_) {
      push @update_path_list, $_;
      last;
    }

    if ($count == 0) {
      next;
    } else {
      push @update_path_list, $_;
    }
  }
  print 'The update path list is ' . join(',',@update_path_list);
  _commit_cluster_update_log('The update path is ' . join(',',@update_path_list));
}

sub remote_api_call_get {
  my ($IP, $URI, $data) = @_;
  my $url = "http://$IP/".$URL;
  my $client = REST::Client->new();
  $client->addHeader('Content-Type', 'application/json');
  $client->addHeader('charset', 'UTF-8');
  $client->addHeader('Accept', 'application/json'); 
  $client->GET($url);
  if( $client->responseCode() ne '200' ){
    A3_Warn("Unable to call remote with $url");
  }
}
  

sub remote_api_call_post {
  my ($IP, $URI, $data) = @_;
  my $url = "http://$IP/".$URL;
  my $client = REST::Client->new();
  $client->addHeader('Content-Type', 'application/json');
  $client->addHeader('charset', 'UTF-8');
  $client->addHeader('Accept', 'application/json'); 
  my $json_data = encode_json($data);
  $client->POST($url, $json_data);
  if( $client->responseCode() ne '200' ){
    A3_Warn("Unable to call remote with $url for $data");
  }

}

=head2 get_first_node_update

The last node  in cluster node file is the one to be update first

=cut

sub get_first_node_update {
  my $node_ip;
  open my $fh, "<", $PF_CLUSTER_CONF or A3_Die("Unable to find cluster file ".$!);;
  while (<$fh>) {
    chomp;
    next if /^(management_ip)=(.*)/;
    $node_ip = $2; 
  }
  close $fh;
  _commit_cluster_update_log("The first node to be update is $node_ip\n");
  return $node_ip;

}

=head2 get_remaining_nodes_update

The remaining nodes in cluster need to be updated

=cut

sub get_remains_nodes_update {
  my @nodes_ip, $node_ip;
  open my $fh, "<", $PF_CLUSTER_CONF or A3_Die("Unable to find cluster file ".$!);;
  while (<$fh>) {
    chomp;
    next if /^(management_ip)=(.*)/;
    $node_ip = $2; 
    push @nodes_ip, $node_ip;  
  }
  close $fh;
  # pop the last one as it will be the first node to be updated
  pop @nodes_ip;
  _commit_cluster_update_log("The remaining nodes to be update are @nodes_ip\n");
  return @nodes_ip;
}


sub get_first_node_hostname {
  my $ret = `$NODE_BIN|awk '{print \$2}'`;
  my @hosts = (split /\n/, $ret);
  my $first_host = pop @hosts;
  return $first_host; 
}

sub get_remains_node_hostname {
  my $ret = `$NODE_BIN|awk '{print \$2}'`;
  my @hosts = (split /\n/, $ret);
  pop @hosts;
  return @hosts; 
}




=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;

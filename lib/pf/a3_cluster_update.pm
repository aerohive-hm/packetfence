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
use Data::Dumper;
use pf::config qw(%Config);

our ( @ISA, @EXPORT_OK );
@ISA = qw(Exporter);
@EXPORT_OK = qw(disable_cluster_check call_system_cmd);

Readonly::Scalar my $BIN_DIR                      => '/usr/bin';
Readonly::Scalar my $YUM_BIN                      => "$BIN_DIR/yum";
Readonly::Scalar my $A3_BASE_DIR                  => '/usr/local/pf';
Readonly::Scalar my $A3_DB_DIR                    => "$A3_BASE_DIR/db";
Readonly::Scalar my $A3_BIN_DIR                   => "$A3_BASE_DIR/bin";
Readonly::Scalar my $A3_CONF_DIR                  => "$A3_BASE_DIR/conf";
Readonly::Scalar my $PF_MON_CONF                  => "$A3_CONF_DIR/pfmon.conf";
Readonly::Scalar my $PF_CLUSTER_CONF              => "$A3_CONF_DIR/cluster.conf";
Readonly::Scalar my $A3_DBINFO_FILE               => "$A3_CONF_DIR/dbinfo.A3";
Readonly::Scalar my $A3_LOG_DIR                   => "$A3_BASE_DIR/logs";
Readonly::Scalar my $A3_CLUSTER_UPDATE_LOG_FILE   => "$A3_LOG_DIR/a3_cluster_update.log";
Readonly::Scalar my $NODE_BIN 			  => "$A3_BASE_DIR/bin/cluster/node";
Readonly::Scalar my $A3_UPDATE_PATH_FILE          => "$A3_DB_DIR/a3-update-path";
Readonly::Scalar my $A3_BK_VER_FILE               => "/tmp/a3_bk_ver_file";
Readonly::Scalar my $PFCMD_BIN                    => "$A3_BIN_DIR/pfcmd";
Readonly::Scalar my $SYSTEMCTL_BIN                => "$BIN_DIR/systemctl";
Readonly::Scalar my $MYSQL_BIN                    => "$BIN_DIR/mysql";
Readonly::Scalar my $MYSQLDUMP_BIN                => "$BIN_DIR/mysqldump";
Readonly::Scalar my $AWK_BIN              	  => "$BIN_DIR/awk";
Readonly::Scalar my $SED_BIN              	  => "$BIN_DIR/sed";
Readonly::Scalar my $TEE_BIN              	  => "$BIN_DIR/tee";
Readonly::Scalar my $CAT_BIN                      => "$BIN_DIR/cat";
Readonly::Scalar my $CP_BIN                       => "$BIN_DIR/cp";
Readonly::Scalar my $CURL_BIN                     => "$BIN_DIR/curl";
Readonly::Scalar my $GREP_BIN                     => "$BIN_DIR/grep";
Readonly::Scalar my $HEAD_BIN                     => "$BIN_DIR/head";

open(UPDATE_CLUSTER_LOG,   '>>', $A3_CLUSTER_UPDATE_LOG_FILE)   || die "Unable to open update log file";
my $a3_pkg = 'A3';
my $a3_db = 'A3';
my $db_user = 'A3';
my $node_port = 9432;

=head2 disable_cluster_check

Disable Cluster Check Task

=cut

sub disable_cluster_check {
  open PFMON, ">", $PF_MON_CONF or die "Unable to open pf monitor file!";

  print PFMON "[cluster_check]\n";
  print PFMON "status=disabled\n";

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
  call_system_cmd("$YUM_BIN clean all >/dev/null; $YUM_BIN makecache fast >/dev/null");
  my $cmd = "$YUM_BIN update ";
  #backup previous A3 version
  open my $fh, ">", "$A3_BK_VER_FILE";
  my $bk_ver = pf::version::version_get_current();
  print $fh "bk_version=$bk_ver"."|";
  my $to_ver = get_to_version();
  print $fh "to_version=$to_ver\n";
  close $fh;
  open CMD, '-|',  "$YUM_BIN list \'$a3_pkg*\'    \\
                  | $SED_BIN '1,/Available/d' \\
                  | $AWK_BIN '{print \$1}'    \\
                  | $TEE_BIN -a $A3_CLUSTER_UPDATE_LOG_FILE" or die $@;
  while (<CMD>) {
    chomp($_);
    push @all_pkgs, $_;
  }
  foreach (@all_pkgs) {
       $cmd .= $_ . " ";
  }
  $cmd .= " -y";
  _commit_cluster_update_log("Update pkg cmd is $cmd");

  if (call_system_cmd("$cmd >> $A3_CLUSTER_UPDATE_LOG_FILE 2>&1") != 0) {
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

sub _check_db_schema_file {
  my @update_path_list = @_;
  my @db_schema_files;
  for (0..$#update_path_list-1) {
    push @db_schema_files, "a3-upgrade-".$update_path_list[$_]."-".$update_path_list[$_+1].".sql";
  }
  _commit_cluster_update_log('The database schema files that need to be applied are ' . join(',',@db_schema_files));
  foreach (@db_schema_files) {
    if (! -e $A3_DB_DIR."/".$_) {
      A3_Die("The database schema migration script for $_ does not exist, fatal!!");
    }
  }
  return @db_schema_files;
}

sub _generate_update_patch_list {
  my @update_path_list;
  my $content = do {
    open my $fh, '<', "$A3_BK_VER_FILE"  or die 'Error in open backup version file';
    local $/;
    <$fh>;
  };
  my $prev_version = (split /=/, (split /\|/, $content)[0])[1];
  my $to_version = (split /=/, (split /\|/, $content)[1])[1];
  chomp $to_version;
  _commit_cluster_update_log("A3 back version is $prev_version and A3 target update version is $to_version");
  
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
  #print 'The update path list is ' . join(',',@update_path_list);
  _commit_cluster_update_log('The update path is ' . join(',',@update_path_list));
  return @update_path_list;
}


sub _get_db_password {
  my $password;

  $password = $Config{database}->{pass};
  chomp $password;

  return $password;
}

sub apply_db_update_schema {
  my @update_path_list = _generate_update_patch_list();
  my @db_schema_files = _check_db_schema_file(@update_path_list);
  my $passwd = _get_db_password();
  foreach my $db_file (@db_schema_files) {
    my $ret = `$MYSQL_BIN -u $db_user -p$passwd $a3_db < $A3_DB_DIR/$db_file 2>&1`;
    if ($ret =~ /ERROR/i) {
      A3_Warn("Unable to apply database schema update $db_file: failed with error message \"$ret\"!");
    }
  }
  _commit_cluster_update_log("Finished applying database schema updates!");
}

sub post_update {
  my @post_cmd_list = ("$PFCMD_BIN fixpermissions",
                       "$PFCMD_BIN pfconfig clear_backend",
                       "$SYSTEMCTL_BIN restart packetfence-config",
                       "$CAT_BIN $A3_CONF_DIR/pf-release > $A3_CONF_DIR/currently-at");

  foreach my $cmd (@post_cmd_list) {
    if (call_system_cmd("$cmd >> $A3_CLUSTER_UPDATE_LOG_FILE 2>&1") != 0) {
      A3_Die("Post-update processing failed, please investigate!");
    }
  }

}

sub remote_api_call_get {
  my ($IP, $URI, $data) = @_;
  my $url = "http://$IP:$node_port/".$URI;
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
  my $url = "http://$IP:$node_port/".$URI;
  my $client = REST::Client->new({timeout=>3600});
  $client->addHeader('Content-Type', 'application/json');
  $client->addHeader('charset', 'UTF-8');
  $client->addHeader('Accept', 'application/json'); 
  my $json_data = encode_json($data);
  $client->POST($url, $json_data);
  if( $client->responseCode() ne '200' ){
    A3_Warn("Unable to call remote with $url for ".Dumper($data));
  }

}

=head2 get_first_node_update

The last node  in cluster node file is the one to be update first

=cut

sub get_first_node_ip_update {
  my $node_ip;
  open my $fh, "<", $PF_CLUSTER_CONF or A3_Die("Unable to find cluster file $PF_CLUSTER_CONF".$!);
  while (<$fh>) {
    chomp;
    if ($_ =~ /^(management_ip)=(.*)/) {
      $node_ip = $2; 
    }
  }
  close $fh;
  _commit_cluster_update_log("The first node to be update is $node_ip\n");
  return $node_ip;

}

=head2 get_remaining_nodes_update

The remaining nodes in cluster need to be updated

=cut

sub get_remains_nodes_ip_update {
  my (@nodes_ip, $node_ip);
  open my $fh, "<", $PF_CLUSTER_CONF or A3_Die("Unable to find cluster file ".$!);
  while (<$fh>) {
    chomp;
    if ($_ =~ /^(management_ip)=(.*)/) {
      $node_ip = $2; 
      push @nodes_ip, $node_ip;  
    }
  }
  close $fh;
  # pop the last and first one(it is management IP) as it will be the first node to be updated
  pop @nodes_ip;
  shift @nodes_ip;
  _commit_cluster_update_log("The remaining nodes to be update are @nodes_ip\n");
  return @nodes_ip;
}

=head2 get_all_nodes_ip_update

All nodes in cluster need to be updated

=cut

sub get_all_nodes_ip_update {
  my (@nodes_ip, $node_ip);
  open my $fh, "<", $PF_CLUSTER_CONF or A3_Die("Unable to find cluster file ".$!);
  while (<$fh>) {
    chomp;
    if ($_ =~ /^(management_ip)=(.*)/) {
      $node_ip = $2; 
      push @nodes_ip, $node_ip;  
    }
  }
  close $fh;
  # shift the lfirst one(it is management IP) as it will be the first node to be updated
  shift @nodes_ip;
  _commit_cluster_update_log("The remaining nodes to be update are @nodes_ip\n");
  return @nodes_ip;
}

sub get_first_node_hostname {
  my $ret = `$NODE_BIN|awk '{print \$2}'`;
  my @hosts = (split /\n/, $ret);
  my $first_host = pop @hosts;
  _commit_cluster_update_log("The first node to update hostname is $first_host\n");
  return $first_host; 
}

sub get_remains_nodes_hostname {
  my $ret = `$NODE_BIN|awk '{print \$2}'`;
  my @hosts = (split /\n/, $ret);
  pop @hosts;
  _commit_cluster_update_log("The remaining nodes to update hostname are @hosts\n");
  return @hosts; 
}

sub delete_mysql_db_files {
  my $db_folder = "/var/lib/mysql/"
  call_system_cmd("rm -rf $db_folder/*");
}


=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;

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
Readonly::Scalar my $RPM_BIN                      => "$BIN_DIR/rpm";
Readonly::Scalar my $A3_BASE_DIR                  => '/usr/local/pf';
Readonly::Scalar my $A3_DB_DIR                    => "$A3_BASE_DIR/db";
Readonly::Scalar my $A3_BIN_DIR                   => "$A3_BASE_DIR/bin";
Readonly::Scalar my $A3_CONF_DIR                  => "$A3_BASE_DIR/conf";
Readonly::Scalar my $A3_VAR_CONF_DIR              => "$A3_BASE_DIR/var/conf";
Readonly::Scalar my $PF_MON_CONF                  => "$A3_CONF_DIR/pfmon.conf";
Readonly::Scalar my $PF_CLUSTER_CONF              => "$A3_CONF_DIR/cluster.conf";
Readonly::Scalar my $A3_DBINFO_FILE               => "$A3_CONF_DIR/dbinfo.A3";
Readonly::Scalar my $A3_LOG_DIR                   => "$A3_BASE_DIR/logs";
Readonly::Scalar my $A3_CLUSTER_UPDATE_LOG_FILE   => "$A3_LOG_DIR/a3_cluster_update.log";
Readonly::Scalar my $NODE_BIN 			  => "$A3_BASE_DIR/bin/cluster/node";
Readonly::Scalar my $A3_UPDATE_PATH_FILE          => "$A3_DB_DIR/a3-update-path";
Readonly::Scalar my $TMP_DIR			  => "/tmp";
Readonly::Scalar my $A3_BK_VER_FILE               => "$TMP_DIR/a3_bk_ver_file";
Readonly::Scalar my $A3_UPDATE_DB_DUMP            => "$TMP_DIR/A3_db.sql";
Readonly::Scalar my $A3_UPDATE_APP_DUMP           => "$TMP_DIR/A3_app.tar.gz";
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
Readonly::Scalar my $PING_BIN                     => "$BIN_DIR/ping";
Readonly::Scalar my $RM_BIN                       => "$BIN_DIR/rm";
Readonly::Scalar my $SORT_BIN                     => "$BIN_DIR/sort";
Readonly::Scalar my $UNIQ_BIN                     => "$BIN_DIR/uniq";
Readonly::Scalar my $TAR_BIN                      => "$BIN_DIR/tar";


Readonly::Scalar my $CENTOS_BASE                  => 'mirrorlist.centos.org';

open(UPDATE_CLUSTER_LOG,   '>>', $A3_CLUSTER_UPDATE_LOG_FILE)   || die "Unable to open update log file";
my $a3_pkg = 'A3';
my $a3_db = 'A3';
my $db_user = 'root';
my $node_port = 9432;
my $fail_code = 1;

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

=head2
 
yum health check

=cut

sub check_yum_connectivity {

  if (call_system_cmd("$PING_BIN -c 3 $CENTOS_BASE >/dev/null 2>&1") != 0){
    _commit_cluster_update_log("Unable to connect to CentOS base yum repository!");
    return 1;
  }

  my @repo_hosts = `$YUM_BIN repolist -v                               \\
                  | $GREP_BIN -E Repo-baseurl.*aerohive                \\
                  | $AWK_BIN -F' : ' '{print \$2}'                     \\
                  | $SED_BIN -r 's/^(https?:\\/\\/[^/]+)\\/.*\$/\\1/g' \\
                  | $SORT_BIN                                          \\
                  | $UNIQ_BIN`;

  _commit_cluster_update_log("Found update servers: " . join(',', @repo_hosts));

  foreach my $host (@repo_hosts) {
    chomp $host;
    _commit_cluster_update_log("Checking connectivity to $host");

    my $status = `$CURL_BIN -s -I -m 60 -w %{http_code} -o /dev/null $host`;

    if ($status < 200 || $status >= 400) {
      _commit_cluster_update_log("Unable to connect to update server $host");

      print "Connect to Aerohive A3 yum repository at $host failed!\n";
      return 1;

    }
  }
  return 0;
}

=head2

overall health check

=cut

sub health_check {
  my $ret = check_yum_connectivity();
  if ($ret == 1) {
    exit $fail_code;
  }
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
    _commit_cluster_update_log("Unable to update A3 packages, attempting to rollback changes");
    exit $fail_code;
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
      _commit_cluster_update_log("The database schema migration script for $_ does not exist, fatal!!");
      exit $fail_code;
    }
  }
  return @db_schema_files;
}

sub get_versions {
  my $content = do {
    open my $fh, '<', "$A3_BK_VER_FILE"  or die 'Error in open backup version file';
    local $/;
    <$fh>;
  };

  my $prev_version = (split /=/, (split /\|/, $content)[0])[1];
  my $to_version = (split /=/, (split /\|/, $content)[1])[1];
  chomp $to_version;

  return ($prev_version, $to_version);
}

sub _generate_update_patch_list {
  my @update_path_list;
  my ($prev_version, $to_version) = get_versions();

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
  open DBINFO, "<", $A3_DBINFO_FILE || die "Unable to find the database information file";

  while (<DBINFO>) {
    if ($_ =~ /^dbroot_pass=(.*)$/) {
      $password = $1;
      last;
    }
  }

  close DBINFO;

  return $password;
}

sub apply_db_update_schema {
  my @update_path_list = _generate_update_patch_list();
  my @db_schema_files = _check_db_schema_file(@update_path_list);
  my $passwd = _get_db_password();
  foreach my $db_file (@db_schema_files) {
    my $ret = `$MYSQL_BIN -u $db_user -p$passwd $a3_db < $A3_DB_DIR/$db_file 2>&1`;
    if ($ret =~ /ERROR/i) {
      _commit_cluster_update_log("Unable to apply database schema update $db_file: failed with error message \"$ret\"!");
      exit $fail_code;
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
      A3_Warn("Post-update processing failed, please investigate!");
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
     _commit_cluster_update_log("Unable to call remote with $url for ".Dumper($data));
     return 1;
  }
  return 0;

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
  my $db_folder = "/var/lib/mysql/";
  call_system_cmd("rm -rf $db_folder/*");
}

sub kill_force_cluster {
   my $process = 'mysqld';
   call_system_cmd("pkill -9 $process");
}


=head2 dump_db

Dump Database

=cut

sub dump_db {
  _commit_cluster_update_log("Starting database backup");

  my $db_passwd = _get_db_password();

  if (call_system_cmd("$MYSQLDUMP_BIN --opt -u root -p$db_passwd $a3_db > $A3_UPDATE_DB_DUMP") != 0) {
    _commit_cluster_update_log("Unable to back up database: $!");
    exit $fail_code;
  }

  _commit_cluster_update_log("Database backup completed");
}
 
=head2 dump_app

Backup A3 app 

=cut

sub dump_app {
  _commit_cluster_update_log("Starting Application data backup");

  if (call_system_cm_cmd("$TAR_BIN -C /usr/local -czf $A3_UPDATE_APP_DUMP pf --exclude='pf/logs' --exclude='pf/var'") != 0) {
    commit_update_log("Unable to back up application data: $!");
    commit_progress_log("error");
    die "Application data backup failed!\n";
  }

  _commit_cluster_update_log("Application data backup completed");
}

=head2 unpack_app_back

unpack app tar pkg

=cut

sub unpack_app_back {
  if (call_system_cmd("$TAR_BIN xfz $A3_UPDATE_APP_DUMP -C $TMP_DIR") != 0) {
    A3_Die("Unable to unpack the application data backup file!");
  }
}


=head2 restore_conf_file

restore A3 conf files

=cut

sub restore_conf_file {
  my $app_dump_copy = $A3_UPDATE_APP_DUMP;
  #remove suffix
  $app_dump_copy =~ s/\..*$//;
  _commit_cluster_update_log("Restoring configuration files");
  call_system_cmd("$RM_BIN -rf $A3_CONF_DIR/*; $CP_BIN -rf $TMP_DIR/pf/conf/* $A3_CONF_DIR");
}


=head2 roll_back_db

roll back database

=cut

sub roll_back_db {
  if (! -e $A3_UPDATE_DB_DUMP) {
    A3_Die("Database backup file does not exist, unable to restore!!");
  }
  my $db_passwd = _get_db_password();
  if (call_system_cmd "$MYSQL_BIN -u root -p$db_passwd $a3_db < $A3_UPDATE_DB_DUMP" != 0) {
     _commit_cluster_update_log("Database restore has failed, please investigate!!");
     exit $fail_code;
  }
}


=head2 roll_back_app

roll back A3 application

=cut

sub roll_back_app {
  unpack_app_back();
  my $rpm_version = `$RPM_BIN -qa $a3_pkg | $AWK_BIN -F- '{print \$2}'`;
  chomp $rpm_version;
  #There are possible 3 situations after failure of yum update A3
  #1)old rpm is removed, and new rpm is not installed
  #2)old rpm is partially removed, and new rpm is not installed(probabyl we will not get there per rpm update mechanism)
  #3)new rpm is partially installed
  my ($prev_version, $to_version) = get_versions();
  commit_update_log("RPM version is $rpm_version and previous version before update is $prev_version");
  if (! $rpm_version) {
    if (call_system_cmd("$YUM_BIN install $a3_pkg."-".$prev_version -y | $TEE_BIN -a $A3_CLUSTER_UPDATE_LOG_FILE}") != 0) {
      A3_Die("Failed to roll back application, really Die!!");
    }
    #restore conf
    restore_conf_file();
  }
  elsif ($rpm_version eq $prev_version) {
    _commit_cluster_update_log("To be done more");
    restore_conf_file();
  }
  elsif ($rpm_version eq $to_version) {
    #my $history_id = `$YUM_BIN history 2>/dev/null   \\
    #                | $GREP_BIN -E '[[:digit:]]{4}-' \\
    #                | $AWK_BIN -F'|' '{print \$1}'   \\
    #                | $HEAD_BIN -1`;
    _commit_cluster_update_log("Start rolling back last update");
    #call_system_cmd("$YUM_BIN history undo $history_id -y | $TEE_BIN -a $A3_CLUSTER_UPDATE_LOG_FILE");
    my $A3_downgrd_pkg = "A3*$prev_version";
    call_system_cmd("$YUM_BIN clean all; $YUM_BIN makecache fast; $YUM_BIN downgrade $A3_downgrd_pkg -y | $TEE_BIN -a $A3_CLUSTER_UPDATE_LOG_FILE");
    _commit_cluster_update_log("Finished rolling back to last release");
    restore_conf_file();
  }
}



=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;

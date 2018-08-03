package pf::a3_cluster_update;

=head1 NAME

pf::a3_cluster_update Support functions for A3 software update across cluster

=head1 DESCRIPTION

Support functions for A3 software update across cluster

=cut

use strict;
use warnings;

use pf::log;
use Readonly;
use POSIX ();
use Exporter;
use REST::Client;
use JSON;

our ( @ISA, @EXPORT_OK );
@ISA = qw(Exporter);
@EXPORT_OK = qw(disable_cluster_check call_system_cmd);


Readonly::Scalar my $A3_BASE_DIR                  => '/usr/local/pf';
Readonly::Scalar my $A3_CONF_DIR                  => "$A3_BASE_DIR/conf";
Readonly::Scalar my $PF_MON_CONF                  => '$A3_CONF_DIR/pfmon.conf';
Readonly::Scalar my $A3_LOG_DIR                   => "$A3_BASE_DIR/logs";
Readonly::Scalar my $A3_CLUSTER_UPDATE_LOG_FILE   => "$A3_LOG_DIR/a3_cluster_update.log";

open(UPDATE_CLUSTER_LOG,   '>>', $A3_CLUSTER_UPDATE_LOG_FILE)   || die "Unable to open update log file";

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
  commit_cluster_update_log($msg);
  die "$msg\n";
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
  
}


sub remote_api_call {

}

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;

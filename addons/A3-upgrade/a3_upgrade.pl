#!/usr/bin/perl
use strict;
use warnings;

use POSIX ();

my $db_info = '/usr/local/pf/conf/dbinfo.A3';
my $debug = 1;
my $db_dump = '/tmp/packetfence_db.sql.gz';
my $app_dump = '/tmp/packetfence_app.tar.gz';
my $upgrade_log = '/tmp/a3_upgrade.log';

open my $log_fh, '>>', $upgrade_log;

sub read_passwd {
  die "Unable to find the db information file!" unless -e $db_info ;
  `cat $db_info|grep pass|awk -F= '{print \$2}'`;
  

}

sub commit_upgrade_log {
  my $msg = shift @_;
  my $current_time = POSIX::strftime("%Y/%m/%d/%H:%M:%S",localtime);
  print $log_fh "[ $current_time ] $msg\n";
}

sub dump_db {
  my $passwd = &read_passwd;
  chomp $passwd;
  if ($debug) {
    print "We have password $passwd\n";
  }
  commit_upgrade_log("Starting DB dump");
  my $ret = `mysqldump --opt -u root -p$passwd A3 | gzip > $db_dump ; echo  \${PIPESTATUS[0]}`;
  if ($ret != 0) {
    commit_upgrade_log('DB dump failed!!');
    die "DB dump failed!!\n";
  }
  commit_upgrade_log("Ending DB dump");
  
}

sub dump_app {
  my $cmd = "tar -C /usr/local -czf $app_dump pf --exclude='pf/logs' --exclude='pf/var'";
  unless (!system $cmd) {
    commit_upgrade_log("Unable to backup application");
    die "Application backup failed!!\n";
  }
  commit_upgrade_log("Application backup done");

}

sub stop_services {
  my @service_stop_cmd = ('/usr/local/pf/bin/pfcmd service pf stop', 'service packetfence-config stop');
  # We need to make sure config service is running, otherwise pfcmd will not able to do the stop job
  unless (!system 'systemctl status packetfence-config|grep Active|grep running') {
    commit_upgrade_log("Packetfence config service is not running");
    die "Packetfence config service is not running\n";
  }
  foreach (@service_stop_cmd) {
    unless(!system $_) {
      commit_upgrade_log("Unable to stop service $_");
      warn "Unable to stop services\n";
    }
  }
  commit_upgrade_log("Services stop done");
}

dump_db();
dump_app();
stop_services();

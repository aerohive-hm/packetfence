#!/usr/bin/perl
use strict;
use warnings;

use POSIX ();

my $db_info = '/usr/local/pf/conf/dbinfo.A3';
my $debug = 1;
my $db_dump = '/tmp/packetfence_db.sql.gz';
my $app_dump = '/tmp/packetfence_app.tar.gz';
my $upgrade_log = '/tmp/a3_upgrade.log';
my $a3_release = '/usr/local/pf/conf/pf-release';
my $a3_db_dir = '/usr/local/pf/db';
my $a3_upgrade_path = "$a3_db_dir/upgrade_path";
my $a3_pkg = 'A3';
my $a3_db = 'A3';
my $a3_and_dep_pkg = qw(A3 A3-config A3-pfcmd-suid);
my $current_version;
my $to_version;
my @upgrade_path_list;
my @db_schema_files;

open my $log_fh, '>>', $upgrade_log;

sub read_passwd {
  die "Unable to find the db information file!" unless -e $db_info ;
  `cat $db_info|grep pass|awk -F= '{print \$2}'`;
  

}

sub A3_Die {
  my $msg = shift;
  print "$msg";
  commit_upgrade_log($msg);
  die "$msg\n";
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
  my $ret = `mysqldump --opt -u root -p$passwd $a3_db | gzip > $db_dump ; echo  \${PIPESTATUS[0]}`;
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

sub check_up_to_date {
  open CMD, '-|', "yum list $a3_pkg" or die $@;
  local $/=undef;
  my $line = <CMD>;
  if ($line =~ /Available/m) {
    return 0
  }
  1;
}

sub check_yum_connectivity {
  my $repo_ip = `yum repolist -v|grep Repo-baseurl|grep aerohive|awk -F: '{print \$3}'|awk -F/ '{print \$3}'`;
  my $code = `/usr/bin/curl -s -I -m 60 -w %{http_code} -o /dev/null http://$repo_ip`;
  if ($code != 200){
    commit_upgrade_log("Unable to connect Aerohive yum repoistory");
    print "Connect to Aerohive yum repository failed!!\n";
    exit 1;
  }
}

sub get_current_version {
  open my $fh, '<', $a3_release or die "Unable to find the A3 release file, $!";
  while (<$fh>) {
    $current_version = (split / /, $_)[1];
  }
  close $fh;
  
  my $ret = `system "yum list $a3_pkg"`;

}

sub get_to_version {
  my $ava_version;
  open CMD, '-|', "yum list $a3_pkg avaliable" or die $@;
  while (<CMD>) {
    if($_ =~ /Available Packages/) {
      next;
    }
    #this will be 1.1.1-0.20180611.el7 string value
    $ava_version = (split /(\s)+/, $_)[1];
 }
 $to_version = (split /-/, $ava_version)[0];
 commit_upgrade_log("A3 current version is $current_version and to be upgraded version is $to_version");
}

sub execute_upgrade {
  my @all_pkgs;
  my $cmd = "yum update ";
  open CMD '-|', "yum list A3*|sed '1,/Available/d'|awk '{print $1}'" or die $@;
  while (<CMD>) {
    chomp($_);
    push @all_pkgs, $_;
  }
  foreach (@all_pkgs) {
       $cmd =. $_." "; 
  }
  print "The cmd is $cmd";
  if (system($cmd)) {
    commit_upgrade_log("Unable to update A3 pkgs, please check!!");
    print "Failed to upgrade A3 pkg\n";
  } 
}



check_db_schema_file {
  open my $fh, '<', "$a3_upgrade_path" or die "Unable to locate upgrade path file, $!";
  my $count = 0;
  # get the upgrade list from upgrade path file (From to To only)
  while (<$fh>) {
    chomp $_;
    if ($from eq $_) {
      $count++;
      push @upgrade_path_list, $_;
      next;
    }elsif ($to eq $_) {
      push @upgrade_path_list, $_;
      last;
    }

    if ($i == 0) {
      next;
    } else {
      push @upgrade_path_list, $_;
    }
  }
  print "Here the upgrade path list is @upgrade_path_list";
  commit_upgrade_log("The upgrade path is @upgrade_path_list");
  for (0..$#upgrade_path_list-1) {
    push @db_schema_files, "upgrade-".$upgrade_path_list[$_]."-".$upgrade_path_list[$_+1].".sql";
  }
  commit_upgrade_log("The db schema files need to be applied are @db_schema_files");
  foreach (@db_schema_files) {
    if (! -e $a3_db_dir/$_) {
	A3_Die("The DB Delta script for $_ is not exist, fatal!!");
    }
  }

}

sub apply_db_upgrade_schema {
  my $passwd = &read_passwd;
  chomp $passwd;
  foreach my $db_file (@db_schema_files) {
    my $cmd = "/usr/bin/mysql -u root -p$passwd A3 < $a3_db_dir/$db_file";
    if (!system($cmd) {
      A3_Die("DB schema apply failed!");
    }
  }

}


check_yum_connectivity();

if (check_up_to_date()) {
  commit_upgrade_log("A3 services already up to date");
  print "A3 services already up to date\n";
  exit 0;

}

get_current_version();
get_to_version();
dump_db();
dump_app();
stop_services();
execute_upgrade();
check_db_schema_file();
apply_db_upgrade_schema();

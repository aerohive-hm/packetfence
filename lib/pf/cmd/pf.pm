package pf::cmd::pf;
=head1 NAME

pf::cmd::pf

=head1 DESCRIPTION

Handles internal PacketFence CLI commands called using 'pfcmd'

=head1 SYNOPSIS

pfcmd <command> [options]

 Commands
  cache                       | manage the cache subsystem
  checkup                     | perform a sanity checkup and report any problems
  class                       | view violation classes
  configreload                | reload the configution
  fingerbank                  | Fingerbank related commands
  floatingnetworkdeviceconfig | query/modify floating network devices configuration parameters
  help                        | show help for pfcmd commands
  import                      | bulk import of information into the database
  ipmachistory                | IP/MAC history
  locationhistorymac          | Switch/Port history
  locationhistoryswitch       | Switch/Port history
  networkconfig               | query/modify network configuration parameters
  node                        | manipulate node entries
  pfconfig                    | interact with pfconfig
  connectionprofileconfig     | query/modify connection profile configuration parameters
  reload                      | rebuild fingerprint or violations tables without restart
  service                     | start/stop/restart and get PF daemon status
  schedule                    | Nessus scan scheduling
  switchconfig                | query/modify switches.conf configuration parameters
  version                     | output version information
  violationconfig             | query/modify violations.conf configuration parameters

Please view "pfcmd help <command>" for details on each option


=head1 DESCRIPTION

pf::cmd::pf

=cut

use strict;
use warnings;
use pf::cmd::pf::help;
use base qw(pf::cmd::subcmd);

sub helpActionCmd { "pf::cmd::pf::help" }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


package pf::pftest;

=head1 NAME

pf::pftest add documentation

=head1 SYNOPSIS

pftest <cmd> [options]

 Commands
  authentication              | checks authentication sources
  mysql                       | runs the mysql tuner
  profile_filter              | checks which profile will be used for a mac
  locationlog                 | checks for multiple open locationlog entries

Please view "pftest.pl help <command>" for details on each option

=head1 DESCRIPTION

pf::pftest

=cut

use strict;
use warnings;
use base qw(pf::cmd::subcmd);
use pf::pftest::help; #Preload help

sub helpActionCmd { "pf::pftest::help" }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


package pf::pfmon::task::option82_query;

=head1 NAME

pf::pfmon::task::option82_query - class for pfmon task option82 query

=cut

=head1 DESCRIPTION

pf::pfmon::task::option82_query

=cut

use strict;
use warnings;
use Moose;
use pf::config qw(%Config);
use pf::option82 qw(search_switch);
use pf::util;
extends qw(pf::pfmon::task);


=head2 run

run the option82 query task

=cut

sub run {
    search_switch() if isenabled($Config{'network'}{'dhcpoption82logger'});
}

=head1 AUTHOR


Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

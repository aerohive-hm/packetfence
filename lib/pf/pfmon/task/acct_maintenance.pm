package pf::pfmon::task::acct_maintenance;

=head1 NAME

pf::pfmon::task::acct_maintenance - class for pfmon task acct maintenance

=cut

=head1 DESCRIPTION

pf::pfmon::task::acct_maintenance

=cut

use strict;
use warnings;
use pf::accounting qw(acct_maintenance);
use Moose;
extends qw(pf::pfmon::task);


=head2 run

run the acct maintenance task

=cut

sub run {
    acct_maintenance();
}

=head1 AUTHOR


Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

package pf::pfmon::task::person_cleanup;

=head1 NAME

pf::pfmon::task::person_cleanup - class for pfmon task person cleanup

=cut

=head1 DESCRIPTION

pf::pfmon::task::person_cleanup

=cut

use strict;
use warnings;
use Moose;
use pf::person;
extends qw(pf::pfmon::task);

=head2 run

run the person cleanup task

=cut

sub run {
    person_cleanup();
}

=head1 AUTHOR


Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

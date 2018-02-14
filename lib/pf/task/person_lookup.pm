package pf::task::person_lookup;

=head1 NAME

pf::task::log - Task for looking up informations on a person

=cut

=head1 DESCRIPTION

pf::task::log

=cut

use strict;
use warnings;
use base 'pf::task';
use pf::lookup::person;

=head2 doTask

Log to pfqueue.log

=cut

sub doTask {
    my ($self, $args) = @_;
    pf::lookup::person::lookup_person($args->{pid}, $args->{source_id});
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


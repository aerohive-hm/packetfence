package pf::task::log;

=head1 NAME

pf::task::log - Task for logging to pfqueue.log

=cut

=head1 DESCRIPTION

pf::task::log

=cut

use strict;
use warnings;
use base 'pf::task';
use pf::log;
our $logger = get_logger();

=head2 doTask

Log to pfqueue.log

=cut

sub doTask {
    my ($self, $args) = @_;
    $logger->info(@$args);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

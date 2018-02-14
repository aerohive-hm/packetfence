package pf::task::api;

=head1 NAME

pf::task::api

=cut

=head1 DESCRIPTION

pf::task::api

=cut

use strict;
use warnings;
use base 'pf::task';
use POSIX;
use pf::log;
use pf::api;
use pf::api::can_fork;
use threads;
my $logger = get_logger();


=head2 doTask

Calls the api call

=cut

sub doTask {
    my ($self, $args) = @_;
    my $api_client = pf::api::can_fork->new();
    $api_client->notify(@$args);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


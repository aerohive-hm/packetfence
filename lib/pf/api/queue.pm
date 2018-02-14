package pf::api::queue;

=head1 NAME

pf::api::queue - The api queue notify

=cut

=head1 DESCRIPTION

pf::api::queue

=cut

use strict;
use warnings;
use Moo;
use pf::pfqueue::producer::redis;

=head2 queue

The queue to submit to

=cut

has queue => (
    is      => 'rw',
    default => 'general',
);

=head2 client

The queue client

=cut

has client => (
    is => 'rw',
    builder => 1,
    lazy => 1,
);

=head2 _build_client

Build the client

=cut

sub _build_client {
    my ($self) = @_;
    return pf::pfqueue::producer::redis->new;
}

=head2 call

=cut

sub call {
    my ($self) = @_;
    die "call not implemented\n";
}

=head2 notify

calls the pf api ignoring the return value

=cut

sub notify {
    my ($self, $method, @args) = @_;
    $self->client->submit($self->queue, api => [$method, @args]);
    return;
}

=head2 notify_delayed

calls the pf api ignoring the return value with a delay

=cut

sub notify_delayed {
    my ($self, $delay, $method, @args) = @_;
    $self->client->submit_delayed($self->queue, 'api', $delay, [$method, @args]);
    return;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


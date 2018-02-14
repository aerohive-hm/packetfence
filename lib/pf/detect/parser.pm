package pf::detect::parser;

=head1 NAME

pf::detect::parser

=cut

=head1 DESCRIPTION

pf::detect::parser

Base class for a pfdetect parser

=cut

use strict;
use warnings;
use Moo;
use pf::api::queue;

has id => (is => 'rw', required => 1);

has path => (is => 'rw', required => 1);

has type => (is => 'rw', required => 1);
 
has status => (is => 'rw', default =>  sub { "enabled" });

=head2 getApiClient

get the api client

=cut

sub getApiClient {
    my ($self) = @_;
    return pf::api::queue->new(queue => 'pfdetect');
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

package pf::services::manager::pfipset;
=head1 NAME

pf::services::manager::pfipset

=cut

=head1 DESCRIPTION

pf::services::manager::pfipset

=cut

use strict;
use warnings;
use Moo;
use pf::cluster;
use pf::config qw(
    %Config
);
use pf::util;

extends 'pf::services::manager';

has '+name' => ( default => sub { 'pfipset' } );

sub isManaged {
    my ($self) = @_;
    return  $self->SUPER::isManaged();
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

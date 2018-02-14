package pf::Role::CHI::Driver::FileUmask;

=head1 NAME

pf::Role::CHI::Driver::FileUmask add documentation

=cut

=head1 DESCRIPTION

pf::Role::CHI::Driver::FileUmask

=cut

use strict;
use warnings;
use Moo::Role;

has umask_on_store =>
  ( is => 'rw', default => sub { oct( 0002 ) } );

before store => sub {
    my ( $self ) = @_;
    umask $self->umask_on_store;
};

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


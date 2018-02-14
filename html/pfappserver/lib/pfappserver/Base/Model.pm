package pfappserver::Base::Model;

=head1 NAME

pfappserver::Base::Model

=cut

=head1 DESCRIPTION

pfappserver::Base::Model
The base class for the Catalyst Models

=cut

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Model'; }

=head2 idKey

The key of the id attribute

=cut

has idKey => ( is => 'ro', default => 'id');

=head2 itemKey

The key of a single item

=cut

has itemKey => ( is => 'ro', default => 'item');

=head2 itemsKey

The key of the list of items

=cut

has itemsKey => ( is => 'ro', default => 'items');

=head2 configFile

=cut


sub ACCEPT_CONTEXT {
    my ( $self,$c,%args) = @_;
    return $self->new(\%args);
}


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


package pfappserver::Model::Config::Profile;

=head1 NAME

pfappserver::Model::Config::Profile add documentation

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::Profile

=cut

use Moose;
use namespace::autoclean;
use pf::ConfigStore::Profile;

extends 'pfappserver::Base::Model::Config';

=head1 METHODS

=head2 _buildCachedConfig

=cut

has '+configStoreClass' => (default => 'pf::ConfigStore::Profile');

=head2 remove

Delete an existing item

=cut

sub remove {
    my ($self,$id) = @_;
    if ($id eq 'default') {
        return ($STATUS::INTERNAL_SERVER_ERROR, "Cannot delete this item");
    }
    return $self->SUPER::remove($id);
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


package pf::ConfigStore::SwitchGroup;
=head1 NAME

pf::ConfigStore::SwitchGroup

=cut

=head1 DESCRIPTION

pf::ConfigStore::SwitchGroup;

=cut

use Moo;
use namespace::autoclean;
use pf::ConfigStore::Pf;
use pf::ConfigStore::Group;

extends 'pf::ConfigStore::Switch';
with 'pf::ConfigStore::Group';
with 'pf::ConfigStore::Hierarchy';
with 'pf::ConfigStore::Role::ReverseLookup';

sub group { 'group' };

sub globalConfigStore { pf::ConfigStore::Switch->new }
=head2 canDelete

canDelete

=cut

sub canDelete {
    my ($self, $id) = @_;
    return !$self->isInSwitch('group', $id) && $self->SUPER::canDelete($id);
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

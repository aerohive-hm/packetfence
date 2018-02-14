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

sub group { 'group' };

sub globalConfigStore { pf::ConfigStore::Switch->new }

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

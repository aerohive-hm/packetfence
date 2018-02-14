package ConfigStore::HierarchyTest;

=head1 NAME

ConfigStore::HierarchyTest

=cut

=head1 DESCRIPTION

Class used to test the Hierarchy role of the Configstore

=cut

use Moo;
use pf::ConfigStore;
use pf::ConfigStore::Hierarchy;

extends qw(pf::ConfigStore);
with qw(pf::ConfigStore::Hierarchy);

sub default_section { undef }

sub topLevelGroup { "group default" }

sub _formatGroup {
    return "group ".$_[1];
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


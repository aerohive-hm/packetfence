package ConfigStore::GroupTest;

=head1 NAME

ConfigStore::GroupTest

=cut

=head1 DESCRIPTION

Class used to test the Group role of the Configstore

=cut

use Moo;
use pf::ConfigStore;
use pf::ConfigStore::Group;
extends qw(pf::ConfigStore);
with qw(pf::ConfigStore::Group);

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


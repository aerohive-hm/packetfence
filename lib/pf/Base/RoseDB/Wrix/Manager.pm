package pf::Base::RoseDB::Wrix::Manager;

=head1 NAME

pf::Base::RoseDB::Wrix::Manager add documentation

=cut

=head1 DESCRIPTION

pf::Base::RoseDB::Wrix::Manager

=cut

use strict;

use base qw(Rose::DB::Object::Manager);

use pf::Base::RoseDB::Wrix;

sub object_class { 'pf::Base::RoseDB::Wrix' }

__PACKAGE__->make_manager_methods('wrix');

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

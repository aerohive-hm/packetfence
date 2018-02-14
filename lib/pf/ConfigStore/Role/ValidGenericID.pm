package pf::ConfigStore::Role::ValidGenericID;
=head1 NAME

pf::ConfigStore::Role::ValidGenericID add documentation

=cut

=head1 DESCRIPTION

pf::ConfigStore::Role::ValidGenericID

=cut

use strict;
use warnings;

use Moo::Role;

sub validId { $_[1] =~ /[a-zA-Z0-9_-]+/; }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


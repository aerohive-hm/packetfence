package pfappserver::Role::Form::RolesAttribute;

=head1 NAME

pfappserver::Role::Form::RolesAttribute -

=cut

=head1 DESCRIPTION

pfappserver::Role::Form::RolesAttribute

=cut

use strict;
use warnings;
use HTML::FormHandler::Moose::Role;
use pf::ConfigStore::Roles;

has roles => ( is => 'rw', builder => '_build_roles');

sub _build_roles {
    my ($self) = @_;
    my $cs = pf::ConfigStore::Roles->new;
    return $cs->readAll('name');
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


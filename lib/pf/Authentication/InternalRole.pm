package pf::Authentication::InternalRole;

=head1 NAME

pf::Authentication::InternalRole -

=cut

=head1 DESCRIPTION

pf::Authentication::InternalRole

=cut

use strict;
use warnings;

use Moose::Role;
use pf::util qw(isenabled);
use pf::constants qw($TRUE $FALSE);
use List::MoreUtils qw(any);

has 'realms' => (isa => 'ArrayRef[Str]', is => 'rw');

=head2 realmIsAllowed

Checks to see if a realm is allowed for the source

A realm is allowed if realms is empty (undef or zero length)
Or if the realm is in the list of realms

=cut

sub realmIsAllowed {
    my ($self, $realm) = @_;
    my $realms = $self->realms;
    return $TRUE if !defined $realms || @$realms == 0;
    $realm //= 'null';
    $realm = lc($realm);
    return ( any { $_ =~ /^\Q$realm\E$/i } @$realms ) ? $TRUE : $FALSE;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


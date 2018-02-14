#!/usr/bin/perl

package pfappserver::Authentication::Store::PacketFence;

use base qw/Class::Accessor::Fast/;
use strict;
use warnings;

use pfappserver::Authentication::Store::PacketFence::User;
use Scalar::Util qw/blessed/;

our $VERSION = '0.001';

BEGIN { __PACKAGE__->mk_accessors(qw/file user_field user_class/) }

sub new {
  my ($class, $config, $app, $realm) = @_;

  $config->{user_class} ||= __PACKAGE__ . '::User';
  $config->{user_field} ||= 'username';

  bless { %$config }, $class;
}

sub find_user {
  my ($self, $authinfo, $c) = @_;
  my $username = $authinfo->{$self->user_field};
  my $roles = $c->session->{user_roles};
  $self->user_class->new($self, $username, $roles);
}

sub user_supports {
  my $self = shift;
  Catalyst::Authentication::Store::LDAP::User->supports(@_);
}

sub from_session {
  my ($self, $c, $username) = @_;
  $self->find_user({ username => $username }, $c);
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

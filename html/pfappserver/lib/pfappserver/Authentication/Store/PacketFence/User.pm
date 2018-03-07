#!/usr/bin/perl

package pfappserver::Authentication::Store::PacketFence::User;
use base qw/Catalyst::Authentication::User Class::Accessor::Fast/;

use strict;
use warnings;

use pf::constants;
use pf::config qw($WEB_ADMIN_ALL);
use pf::authentication;
use pf::Authentication::constants qw($LOGIN_SUCCESS $LOGIN_CHALLENGE);
use pf::log;
use List::MoreUtils qw(all any);
use pf::config::util;
use pf::util;
use pf::constants::realm;

BEGIN { __PACKAGE__->mk_accessors(qw/_user _store _roles _challenge/) }

use overload '""' => sub { shift->id }, fallback => 1;

sub new {
  my ( $class, $store, $user, $roles ) = @_;

  return unless $user;
  $roles = [qw(NONE)] unless $roles;
  bless { _store => $store, _user => $user, _roles => $roles }, $class;

}

sub id {
  my $self = shift;
  return $self->_user;
}

sub supported_features {
  return {
    password => { self_check => 1, },
    session => 1,
    roles => 1,
  };
}

sub check_password {
  my ($self, $password) = @_;

  my ($result, $roles) = pf::authentication::adminAuthentication($self->_user, $password);
  if($result == $LOGIN_SUCCESS) {
    $self->_roles($roles);
    return $TRUE;
  }
  elsif($result == $LOGIN_CHALLENGE) {
    $self->_challenge();
  }
  else {
    return $FALSE;
  }
}

sub roles {
    my ($self) = @_;
    return @{$self->_roles};
}

*for_session = \&id;

*get_object = \&_user;

sub AUTOLOAD {
  my $self = shift;

  ( my $method ) = ( our $AUTOLOAD =~ /([^:]+)$/ );

  return if $method eq "DESTROY";

  $self->_user->$method;
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

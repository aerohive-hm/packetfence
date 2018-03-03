package pfappserver::Form::Config::Firewall_SSO::FortiGate;

=head1 NAME

pfappserver::Form::Config::Firewall_SSO::FortiGate - Web form to add a Fortigate firewall

=head1 DESCRIPTION

Form definition to create or update a Fortigate firewall.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Firewall_SSO';
with 'pfappserver::Base::Form::Role::Help';

use pf::config;
use pf::util;
use File::Find qw(find);

has_field '+port' =>
  (
   default => 1813,
  );
has_field 'type' =>
  (
   type => 'Hidden',
  );

has_block definition =>
  (
   render_list => [ qw(id type password port categories networks cache_updates cache_timeout username_format default_realm) ],
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

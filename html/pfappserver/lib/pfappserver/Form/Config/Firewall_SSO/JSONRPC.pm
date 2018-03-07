package pfappserver::Form::Config::Firewall_SSO::JSONRPC;

=head1 NAME

pfappserver::Form::Config::Firewall_SSO::JSONRPC - Web form for a JSON-RPC device

=head1 DESCRIPTION

Form definition to create or update an JSON-RPC device.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Firewall_SSO';
with 'pfappserver::Base::Form::Role::Help';

use pf::config;
use pf::util;
use File::Find qw(find);

has_field 'username' =>
  (
   type => 'Text',
   label => 'Username',
   required => 1,
   messages => { required => 'Please specify the username for JSON-RPC server' },
  );
has_field 'password' =>
  (
   type => 'ObfuscatedText',
   label => 'Password',
   required => 1,
   messages => { required => 'You must specify the password' },
  );
has_field '+port' =>
  (
   default => 9090,
  );
has_field 'type' =>
  (
   type => 'Hidden',
  );

has_block definition =>
  (
   render_list => [ qw(id type username password port categories networks cache_updates cache_timeout username_format default_realm) ],
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

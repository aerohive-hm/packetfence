package pfappserver::Form::Config::Firewall_SSO::Iboss;

=head1 NAME

pfappserver::Form::Config::Firewall_SSO::Iboss - Web form for a Iboss device

=head1 DESCRIPTION

Form definition to create or update an Iboss device.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Firewall_SSO';
with 'pfappserver::Base::Form::Role::Help';

use pf::config;
use pf::util;
use File::Find qw(find);

has_field '+password' =>
  (
   default => 'XS832CF2A',
   tags => { after_element => \&help,
             help => 'Change the default key if necessary' },
  );
has_field '+port' =>
  (
    default => 8015,
  );
has_field 'nac_name' =>
  (
   type => 'Text',
   label => 'NAC Name',
   tags => { after_element => \&help,
             help => 'Should match the NAC name from the Iboss configuration' },
    default => 'PacketFence',
  );
has_field 'type' =>
  (
   type => 'Hidden',
  );

has_block definition =>
  (
   render_list => [ qw(id type password port nac_name categories networks cache_updates cache_timeout username_format default_realm) ],
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

package pfappserver::Form::Config::Provisioning::sentinelone;

=head1 NAME

pfappserver::Form::Config::Provisioning::sentinelone

=head1 DESCRIPTION

Web form for a SentinelOne provisioner

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Provisioning';
with 'pfappserver::Base::Form::Role::Help';

use pf::constants;

has_field 'host' =>
  (
   type => 'Text',
  );

has_field 'port' =>
  (
   type => 'PosInteger',
   required => $TRUE,
   default => $HTTPS_PORT,
  );

has_field 'protocol' =>
  (
   type => 'Select',
   options => [{ label => $HTTP, value => $HTTP }, { label => $HTTPS , value => $HTTPS }],
   default => 'https',
  );

has_field 'api_username' =>
  (
   type => 'Text',
   label => 'API username',
   required => $TRUE,
  );

has_field 'api_password' =>
  (
   type => 'ObfuscatedText',
   label => 'API password',
   required => $TRUE,
  );

has_field 'win_agent_download_uri' =>
  (
   type => 'Text',
   label => 'Windows agent download URI',
   required => $TRUE,
  );

has_field 'mac_osx_agent_download_uri' =>
  (
   type => 'Text',
   label => 'Mac OSX agent download URI',
   required => $TRUE,
  );

has_block definition =>
  (
   render_list => [ qw(id type description category oses host port protocol api_username api_password win_agent_download_uri mac_osx_agent_download_uri) ],
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

package pfappserver::Form::Config::Provisioning::symantec;

=head1 NAME

pfappserver::Form::Config::Provisioning - Web form for a switch

=head1 DESCRIPTION

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Provisioning';
with 'pfappserver::Base::Form::Role::Help';

has_field 'username' =>
  (
   type => 'Text',
   required => 1,
  );

has_field 'password' =>
  (
   type => 'Text',
   label => 'Client Secret',
   required => 1,
   password => 0,
  );

has_field 'host' =>
  (
   type => 'Text',
   required => 1,
  );

has_field 'port' =>
  (
   type => 'PosInteger',
   required => 1,
  );

has_field 'protocol' =>
  (
   type => 'Select',
   options => [{ label => 'http', value => 'http' }, { label => 'https' , value => 'http' }],
  );

has_field 'api_uri' =>
  (
   type => 'Text',
  );

has_field 'agent_download_uri' =>
  (
   type => 'Text',
   required => 1,
  );

has_block definition =>
  (
   render_list => [ qw(id type description category oses username password host port protocol api_uri agent_download_uri) ],
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

package pfappserver::Form::Config::Scan::OpenVAS;

=head1 NAME

pfappserver::Form::Config::Scan::OpenVAS - Web form to add a OpenVAS Scan Engine

=head1 DESCRIPTION

Form definition to create or update a OpenVAS Scan Engine.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Scan';
with 'pfappserver::Base::Form::Role::Help';

use pf::config;
use pf::util;
use File::Find qw(find);

## Definition
has 'roles' => (is => 'ro', default => sub {[]});

has_field 'ip' =>
  (
   type => 'Text',
   label => 'Hostname or IP Address',
   required => 1,
   messages => { required => 'Please specify the hostname or IP of the scan engine' },
  );

has_field 'port' =>
  (
   type => 'PosInteger',
   label => 'Port of the service',
   tags => { after_element => \&help,
             help => 'If you use an alternative port, please specify' },
   default => 9390,
  );
has_field 'type' =>
  (
   type => 'Hidden',
  );

has_block definition =>
  (
   render_list => [ qw(id ip type username password port openvas_configid openvas_reportformatid categories oses duration pre_registration registration post_registration) ],
  );

has_field 'openvas_configid' =>
  (
   type => 'Text',
   label => 'OpenVAS config ID',
   tags => { after_element => \&help,
             help => 'ID of the scanning configuration on the OpenVAS server' },
  );

has_field 'openvas_reportformatid' =>
  (
   type => 'Text',
   label => 'OpenVAS report format',
   default => 'f5c2a364-47d2-4700-b21d-0a7693daddab',
   tags => { after_element => \&help,
             help => 'ID of the .NBE report format on the OpenVAS server' },
  );

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

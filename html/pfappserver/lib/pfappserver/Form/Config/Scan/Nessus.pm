package pfappserver::Form::Config::Scan::Nessus;

=head1 NAME

pfappserver::Form::Config::Scan::Nessus - Web form to add a Nessus Scan Engine

=head1 DESCRIPTION

Form definition to create or update a Nessus Scan Engine.

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
   default => 8834,
  );
has_field 'type' =>
  (
   type => 'Hidden',
  );

has_block definition =>
  (
   render_list => [ qw(id ip type username password port nessus_clientpolicy categories oses duration pre_registration registration post_registration) ],
  );

has_field 'nessus_clientpolicy' =>
  (
   type => 'Text',
   label => 'Nessus client policy',
   tags => { after_element => \&help,
             help => 'Name of the policy to use on the nessus server' },
  );


=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

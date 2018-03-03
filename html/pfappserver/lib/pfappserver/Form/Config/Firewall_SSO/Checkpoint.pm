package pfappserver::Form::Config::Firewall_SSO::Checkpoint;

=head1 NAME

pfappserver::Form::Config::Firewall_SSO::Checkpoint - Web form to add a Checkpoint firewall

=head1 DESCRIPTION

Form definition to create or update a Checkpoint firewall.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Firewall_SSO';
with 'pfappserver::Base::Form::Role::Help';

use pf::config;
use pf::util;
use File::Find qw(find);

## Definition
has 'roles' => (is => 'ro', default => sub {[]});

has_field '+password' =>
  (
   label => 'Secret',
   messages => { required => 'You must specify the radius shared secret' },
  );
has_field '+port' =>
  (
   default => 1813,
  );
has_field 'type' =>
  (
   type => 'Hidden',
  );

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

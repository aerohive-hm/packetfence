package pf::UnifiedApi::Controller::Config::DeviceRegistrations;

=head1 NAME

pf::UnifiedApi::Controller::Config::DeviceRegistrations - 

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::DeviceRegistrations



=cut

use strict;
use warnings;


use Mojo::Base qw(pf::UnifiedApi::Controller::Config);

has 'config_store_class' => 'pf::ConfigStore::DeviceRegistration';
has 'form_class' => 'pfappserver::Form::Config::DeviceRegistration';
has 'primary_key' => 'device_registration_id';

use pf::ConfigStore::DeviceRegistration;
use pfappserver::Form::Config::DeviceRegistration;

 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


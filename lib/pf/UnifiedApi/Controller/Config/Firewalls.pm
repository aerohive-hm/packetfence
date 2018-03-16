package pf::UnifiedApi::Controller::Config::Firewalls;

=head1 NAME

pf::UnifiedApi::Controller::Config::Firewalls - 

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::Firewalls

=cut

use strict;
use warnings;

use Mojo::Base qw(pf::UnifiedApi::Controller::Config::Subtype);

has 'config_store_class' => 'pf::ConfigStore::Firewall_SSO';
has 'form_class' => 'pfappserver::Form::Config::Firewall_SSO';
has 'primary_key' => 'firewall_id';

use pf::ConfigStore::Firewall_SSO;
use pfappserver::Form::Config::Firewall_SSO;
use pfappserver::Form::Config::Firewall_SSO::BarracudaNG;
use pfappserver::Form::Config::Firewall_SSO::Checkpoint;
use pfappserver::Form::Config::Firewall_SSO::Iboss;
use pfappserver::Form::Config::Firewall_SSO::WatchGuard;
use pfappserver::Form::Config::Firewall_SSO::FortiGate;
use pfappserver::Form::Config::Firewall_SSO::JSONRPC;
use pfappserver::Form::Config::Firewall_SSO::PaloAlto;

our %TYPES_TO_FORMS = (
    map { $_ => "pfappserver::Form::Config::Firewall_SSO::$_" } qw(
      BarracudaNG
      Checkpoint
      Iboss
      WatchGuard
      FortiGate
      JSONRPC
      PaloAlto
    )
);

sub type_lookup {
    return \%TYPES_TO_FORMS;
}
 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


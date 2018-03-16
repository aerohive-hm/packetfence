package pf::UnifiedApi::Controller::Config::PkiProviders;

=head1 NAME

pf::UnifiedApi::Controller::Config::PkiProviders - 

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::PkiProviders

=cut

use strict;
use warnings;


use Mojo::Base qw(pf::UnifiedApi::Controller::Config::Subtype);

has 'config_store_class' => 'pf::ConfigStore::PKI_Provider';
has 'form_class' => 'pfappserver::Form::Config::PKI_Provider';
has 'primary_key' => 'pki_provider_id';

use pf::ConfigStore::PKI_Provider;
use pfappserver::Form::Config::PKI_Provider::packetfence_local;
use pfappserver::Form::Config::PKI_Provider::scep;
use pfappserver::Form::Config::PKI_Provider::packetfence_pki;

our %TYPES_TO_FORMS = (
    map { $_ => "pfappserver::Form::Config::PKI_Provider::$_" } qw(
        packetfence_local
        scep
        packetfence_pki
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


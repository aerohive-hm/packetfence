package pf::UnifiedApi::Controller::Config::Scans;

=head1 NAME

pf::UnifiedApi::Controller::Config::Scans - 

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::Scans



=cut

use strict;
use warnings;


use Mojo::Base qw(pf::UnifiedApi::Controller::Config::Subtype);

has 'config_store_class' => 'pf::ConfigStore::Scan';
has 'form_class' => 'pfappserver::Form::Config::Scan';
has 'primary_key' => 'scan_id';

use pf::ConfigStore::Scan;
use pfappserver::Form::Config::Scan;
use pfappserver::Form::Config::Scan::Nessus6;
use pfappserver::Form::Config::Scan::Nessus;
use pfappserver::Form::Config::Scan::OpenVAS;
use pfappserver::Form::Config::Scan::WMI;

our %TYPES_TO_FORMS = (
    map { $_ => "pfappserver::Form::Config::Scan::$_" } qw(
        Nessus6
        Nessus
        OpenVAS
        WMI
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


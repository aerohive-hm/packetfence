package pf::UnifiedApi::Controller::Config::SyslogParsers;

=head1 NAME

pf::UnifiedApi::Controller::Config::SyslogParsers - 

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::SyslogParsers



=cut

use strict;
use warnings;


use Mojo::Base qw(pf::UnifiedApi::Controller::Config::Subtype);

has 'config_store_class' => 'pf::ConfigStore::Pfdetect';
has 'form_class' => 'pfappserver::Form::Config::Pfdetect';
has 'primary_key' => 'syslog_parser_id';

use pf::ConfigStore::Pfdetect;
use pfappserver::Form::Config::Pfdetect;
use pfappserver::Form::Config::Pfdetect::dhcp;
use pfappserver::Form::Config::Pfdetect::fortianalyser;
use pfappserver::Form::Config::Pfdetect::regex;
use pfappserver::Form::Config::Pfdetect::security_onion;
use pfappserver::Form::Config::Pfdetect::snort;
use pfappserver::Form::Config::Pfdetect::suricata_md5;
use pfappserver::Form::Config::Pfdetect::suricata;

our %TYPES_TO_FORMS = (
    map { $_ => "pfappserver::Form::Config::Pfdetect::$_" } qw(
        dhcp
        fortianalyser
        regex
        security_onion
        snort
        suricata_md5
        suricata
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


package pf::ConfigStore::Report;
=head1 NAME

pf::ConfigStore::Report

=cut

=head1 DESCRIPTION

ConfigStore for the reports configuration

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw($report_config_file $report_default_config_file);
use pf::util;
extends 'pf::ConfigStore';

sub importConfigFile { $report_default_config_file };

sub configFile { $report_config_file };

sub pfconfigNamespace {'config::Report'}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;



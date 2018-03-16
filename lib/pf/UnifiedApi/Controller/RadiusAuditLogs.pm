package pf::UnifiedApi::Controller::RadiusAuditLogs;

=head1 NAME

pf::UnifiedApi::Controller::RadiusAuditLogs -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::RadiusAuditLogs

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::Crud';
use pf::dal::radius_audit_log;

has dal => 'pf::dal::radius_audit_log';
has url_param_name => 'radius_audit_log_id';
has primary_key => 'id';

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


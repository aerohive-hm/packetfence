package pf::UnifiedApi::Controller::DhcpOption82s;

=head1 NAME

pf::UnifiedApi::Controller::DhcpOption82s -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::DhcpOption82s

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::Crud';
use pf::dal::dhcp_option82;

has dal => 'pf::dal::dhcp_option82';
has url_param_name => 'dhcp_option82_id';
has primary_key => 'mac';

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


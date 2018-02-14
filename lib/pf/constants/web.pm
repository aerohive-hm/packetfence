package pf::constants::web;

=head1 NAME

pf::constants::web - constants for web 

=cut

=head1 DESCRIPTION

pf::constants::web

=cut

use strict;
use warnings;
use base qw(Exporter);

our @EXPORT_OK = qw($USER_AGENT_CACHE_EXPIRATION);

Readonly::Scalar our $USER_AGENT_CACHE_EXPIRATION => '5 minutes';

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;



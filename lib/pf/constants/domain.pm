package pf::constants::domain;

=head1 NAME

pf::constants::domain - constants for domain object

=cut

=head1 DESCRIPTION

pf::constants::domain

=cut

use strict;
use warnings;
use base qw(Exporter);
use Readonly;

our @EXPORT_OK = qw(
    $SAMBA_CONF_PATH 
    $NTLM_REDIS_CACHE_HOST
    $NTLM_REDIS_CACHE_PORT
);

Readonly::Scalar our $SAMBA_CONF_PATH => "/etc/samba/smb.conf";

Readonly::Scalar our $NTLM_REDIS_CACHE_HOST => "localhost";
Readonly::Scalar our $NTLM_REDIS_CACHE_PORT => 6383;
 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


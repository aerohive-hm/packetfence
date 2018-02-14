package pf::constants::provisioning;

=head1 NAME

pf::constants::provisioning

=cut

=head1 DESCRIPTION

pf::constants::provisioning - Constants for provisioner modules

=cut

use base qw(Exporter);
our @EXPORT_OK = qw(
    $SENTINEL_ONE_TOKEN_EXPIRY
    $NOT_COMPLIANT_FLAG
);

use Readonly;

=item $SENTINEL_ONE_TOKEN_EXPIRY

Amount of seconds a Sentinel one token is valid (1 hour)

=cut

Readonly our $SENTINEL_ONE_TOKEN_EXPIRY => 60*60;

=item $NOT_COMPLIANT_FLAG

The flag that defines a non-compliant device as returned by the MDM filters

=cut

Readonly our $NOT_COMPLIANT_FLAG => "non-compliant";

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

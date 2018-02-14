package pf::constants::parking;

=head1 NAME

pf::constants::parking - constants for parking object

=cut

=head1 DESCRIPTION

pf::constants::parking

=cut

use strict;
use warnings;
use base qw(Exporter);
use Readonly;

our @EXPORT_OK = qw($PARKING_DHCP_GROUP_NAME $PARKING_IPSET_NAME $PARKING_VID);

Readonly our $PARKING_DHCP_GROUP_NAME => "parking";

Readonly our $PARKING_IPSET_NAME => "parking";

Readonly our $PARKING_VID => 1300003;
 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


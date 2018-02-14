package pf::constants::violation;

=head1 NAME

pf::constants::violation - constants for violation

=cut

=head1 DESCRIPTION

pf::constants::violation

=cut

use strict;
use warnings;
use base qw(Exporter);
use Readonly;
use pf::constants;
use pf::constants::role qw($ISOLATION_ROLE $MAC_DETECTION_ROLE $VOICE_ROLE $INLINE_ROLE);

our @EXPORT_OK = qw($MAX_VID $LOST_OR_STOLEN %NON_WHITELISTABLE_ROLES);

Readonly our $MAX_VID => 2000000000;

Readonly our $LOST_OR_STOLEN => '1300005';

Readonly our %NON_WHITELISTABLE_ROLES => (
    $ISOLATION_ROLE     => $TRUE,
    $MAC_DETECTION_ROLE => $TRUE,
    $VOICE_ROLE         => $TRUE,
    $INLINE_ROLE        => $TRUE,
);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;



package pf::Switch::WirelessModuleTemplate;

=head1 NAME

pf::Switch::WirelessModuleTemplate

=head1 SYNOPSIS

The pf::Switch::WirelessModuleTemplate module implements an object oriented interface to
manage <HARDWARE>

=head1 STATUS

Developed and tested on <model> running <firmware>

=over

=item Supports

=over

=item <feature a>

=item <feature b>

=back

=back

=head1 BUGS AND LIMITATIONS

=over

=item <problem a>

<problem description>

=back

=cut

use strict;
use warnings;

use base ('pf::Switch');

use pf::constants;
use pf::config qw(
    $MAC $SSID
);

=head1 SUBROUTINES

=over

=cut

# CAPABILITIES
# access technology supported
sub supportsWirelessDot1x { return $TRUE; }
sub supportsWirelessMacAuth { return $TRUE; }
# inline capabilities
sub inlineCapabilities { return ($MAC,$SSID); }

=item getVersion

obtain image version information from switch

=cut

sub getVersion {
    # IMPLEMENT!
}

=item deauthenticateMacDefault

deauthenticate a MAC address from wireless network (including 802.1x)

=cut

sub deauthenticateMacDefault {
    # IMPLEMENT!
}

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

package pf::Switch::Huawei::S5710;


=head1 NAME

pf::Switch::Huawei::S5710

=head1 SYNOPSIS

The pf::Switch::Huawei::S5710 module manages access to Huawei

=head1 STATUS

There is no way to determine the SNMP ifindex from the RADIUS request.

Bumping a port doesn't reevaluate the access.

=cut

use strict;
use warnings;

use pf::log;
use POSIX;
use Try::Tiny;

use base ('pf::Switch::Huawei');

use pf::constants;
sub description { 'Huawei S5710' }

=head1 SUBROUTINES

=cut

sub supportsWiredMacAuth { return $TRUE; }
sub supportsWiredDot1x { return $TRUE; }

=head2 getIfType

Returning ETHERNET type since there is no standard way to get the ifindex

=cut

sub getIfType{ return $SNMP::ETHERNET_CSMACD; }

=head2 handleReAssignVlanTrapForWiredMacAuth

Called when a ReAssignVlan trap is received for a switch-port in Wired MAC Authentication.

=cut

sub handleReAssignVlanTrapForWiredMacAuth {
    my ($self, $ifIndex, $mac) = @_;
    my $logger = get_logger();

    $self->deauthenticateMacRadius($mac);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

package pf::Switch::Ruckus::Legacy;

=head1 NAME

pf::Switch::Ruckus::Legacy

=head1 SYNOPSIS

Override base methods to comply with legacy hardware

=cut

use strict;
use warnings;

use base ('pf::Switch::Ruckus');

use pf::accounting qw(node_accounting_dynauth_attr);
use pf::constants;
use pf::util;

sub description { 'Ruckus Wireless Controllers - Legacy' }

=over

=item deauthenticateMacDefault

Overrides base method to send Acct-Session-Id withing the RADIUS disconnect request

=cut

sub deauthenticateMacDefault {
    my ( $self, $mac, $is_dot1x ) = @_;
    my $logger = $self->logger;

    if ( !$self->isProductionMode() ) {
        $logger->info("not in production mode... we won't perform deauthentication");
        return 1;
    }

    #Fetching the acct-session-id
    my $dynauth = node_accounting_dynauth_attr($mac);

    $logger->debug("deauthenticate $mac using RADIUS Disconnect-Request deauth method");
    return $self->radiusDisconnect(
        $mac, { 'Acct-Session-Id' => $dynauth->{'acctsessionid'}, 'User-Name' => $dynauth->{'username'} },
    );
}


=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

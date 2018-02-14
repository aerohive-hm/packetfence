package pf::firewallsso;

=head1 NAME

pf::firewallsso

=cut

=head1 DESCRIPTION

Sends firewall SSO request to pfsso engine

=cut

use strict;
use warnings;

use pf::api::jsonrpcclient;
use pf::config qw(
    %ConfigFirewallSSO
);
use pf::constants qw(
    $TRUE
);
use pf::constants::api;
use pf::log;
use pf::node();
use pf::util();


=head1 SUBROUTINES

=over


=item do_sso

=cut

sub do_sso {
    my ( %postdata ) = @_;
    my $logger = pf::log::get_logger();

    unless ( scalar keys %ConfigFirewallSSO ) {
        $logger->debug("Trying to do firewall SSO without any firewall SSO configured. Exiting");
        return;
    }

    my $mac = pf::util::clean_mac($postdata{mac});
    my $node = pf::node::node_attributes($mac);

    $logger->info("Sending a firewall SSO '$postdata{method}' request for MAC '$mac' and IP '$postdata{ip}'");

    my $username = $node->{pid};
    my ($stripped_username, $realm) = pf::util::strip_username($username);

    pf::api::jsonrestclient->new(
        proto   => "http",
        host    => "localhost",
        port    => $pf::constants::api::PFSSO_PORT,
    )->call("/pfsso/".lc($postdata{method}), {
        ip                => $postdata{ip},
        mac               => $mac,
        # All values must be string for pfsso
        timeout           => $postdata{timeout}."",
        role              => $node->{category},
        username          => $username,
        stripped_username => $stripped_username,
        realm             => $realm,
        status            => $node->{status},
    });

    return $TRUE;
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


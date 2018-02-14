package pf::detect::parser::dhcp;

=head1 NAME

pf::detect::parser::dhcp

=cut

=head1 DESCRIPTION

pfdetect parser class for DHCP syslog (supports at least infoblox and ISC DHCP)

=cut

use strict;
use warnings;

use Moo;

use pf::log;

extends qw(pf::detect::parser);

sub parse {
    my ( $self, $line ) = @_;
    my $logger = pf::log::get_logger();

    my $data = $self->_parse($line);

    if(defined($data->{type}) && $data->{type} eq "DHCPACK") {
        my $apiclient = $self->getApiClient();
        $apiclient->notify('update_ip4log', ( 'mac' => $data->{mac}, ip => $data->{ip} ));
    }

    return 0;   # Returning 0 to pfdetect indicates "job's done"
}

sub _parse { 
    my ( $self, $line ) = @_;
    my $logger = pf::log::get_logger();
    my $data = {};

    my $type_match = "(DHCPDISCOVER|DHCPOFFER|DHCPREQUEST|DHCPACK|DHCPRELEASE|DHCPINFORM|DHCPEXPIRE)";
    my $ip_match = "([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)";
    my $mac_match = "([0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2})";
    # DHCPACK on 10.33.17.82 to 00:11:22:33:44:55
    # DHCPACK to 10.17.97.134 (00:11:22:33:44:55)
    if($line =~ /$type_match on $ip_match to $mac_match/) {
        $data->{type} = $1;
        $data->{ip} = $2;
        $data->{mac} = $3;
    }
    elsif($line =~ /$type_match to $ip_match \($mac_match\)/) {
        $data->{type} = $1;
        $data->{ip} = $2;
        $data->{mac} = $3;
    }
    else {
        get_logger->debug("Unknown line : $line");
    }

    return $data;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

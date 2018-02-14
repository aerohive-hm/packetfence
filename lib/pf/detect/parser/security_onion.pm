package pf::detect::parser::security_onion;

=head1 NAME

pf::detect::parser::security_onion

=cut

=head1 DESCRIPTION

pf::detect::parser::security_onion

Class to parse syslog from a Security onion appliance

=cut

use strict;
use warnings;
use Moo;
extends qw(pf::detect::parser);

sub parse {
    my ($self,$line) = @_;

    # Alert line example
    # Oct 28 13:37:42 poulichefencer sguil_alert: 13:37:42 pid(3403)  Alert Received: 0 2 misc-attack securityonion1-eth1 {2015-10-28 13:37:42} 3 88707 {ET TOR Known Tor Relay/Router (Not Exit) Node Traffic group 11} SRC.IP.AD.DR DST.IP.AD.DR 17 123 123 1 2522020 2376 7946 7946
    # Split the line on the Curly Brace { }
    my @split1 = split(m/[{}](?![^{}!()]*\))/, $line);
    my @split2 = split(" ", $split1[4]);

    my $data = {
        date    => $split1[1],
        descr   => $split1[3],
        srcip   => $split2[0],
        dstip   => $split2[1],
        sid     => $split2[6],
    };

    return { date => $data->{date}, srcip => $data->{srcip}, dstip => $data->{dstip}, events => { detect => $data->{sid}, suricata_event => $data->{descr} } };
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


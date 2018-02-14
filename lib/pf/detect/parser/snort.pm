package pf::detect::parser::snort;

=head1 NAME

pf::detect::parser::snort

=cut

=head1 DESCRIPTION

pf::detect::parser::snort

Class to parse syslog from Snort

=cut

use strict;
use warnings;
use Moo;
extends qw(pf::detect::parser);

sub parse {
    my ($self,$line) = @_;
    my $data;
    if ( $line
        =~ /^(.*)\[\d+:(\d+):\d+\]\s+(.+?)\s+\[.+?(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(:\d+){0,1}\s+\-\>\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(:\d+){0,1}/
        )
    {
    
        $data = {
            date  => $1,
            sid   => $2,
            descr => $3,
            srcip => $4,
            dstip => $6,
        };
        return { srcip => $data->{srcip}, date => $data->{date}, dstip => $data->{dstip}, events => { detect => $data->{sid}, suricata_event => $data->{descr} } };
    } elsif ( $line
        =~ /^(.+?)\s+\[\*\*\]\s+\[\d+:(\d+):\d+\]\s+Portscan\s+detected\s+from\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
        )
    {
        $data = {
            date  => $1,
            srcip => $3,
            descr => "PORTSCAN",
        };
        return { srcip => $data->{srcip}, date => $data->{date}, events => { detect => $data->{descr} } };
    } elsif ( $line
        =~ /^(.+?)\[\*\*\] \[\d+:(\d+):\d+\]\s+\(spp_portscan2\) Portscan detected from (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
        )
    {
        $data = {
            date  => $1,
            srcip => $3,
            descr => "PORTSCAN",
        };
        return { srcip => $data->{srcip}, date => $data->{date}, events => { detect => $data->{descr} } };
    }
    return undef;
}
 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

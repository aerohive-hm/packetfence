package pf::Switch::Ubiquiti;

=head1 NAME

pf::Switch::Ubiquiti - Object oriented module for Ubiquiti

=head1 SYNOPSIS

The pf::Switch::Ubiquiti module

=cut

use strict;
use warnings;

use base ('pf::Switch');
use Net::SNMP;

use pf::Switch::constants;
use pf::util;

sub getVersion {
    my ($self)       = @_;
    my $oid_sysDescr = '1.3.6.1.2.1.1.1.0';
    my $logger       = $self->logger;
    if ( !$self->connectRead() ) {
        return '';
    }
    $logger->trace("SNMP get_request for sysDescr: $oid_sysDescr");
    my $result = $self->{_sessionRead}->get_request( -varbindlist => [$oid_sysDescr] );
    my $sysDescr = ( $result->{$oid_sysDescr} || '' );

    # sysDescr sample output:
    #EdgeSwitch 48-Port 750W, 1.7.0.4922887, Linux 3.6.5-f4a26ed5, 0.0.0.0000000

    if ( $sysDescr =~ m/, (\d+\.\d+-\d+),/ ) {
        return $1;
    } else {
        $logger->warn("couldn't extract exact version information, returning SNMP System Description instead");
        return $sysDescr;
    }
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

package pf::Switch::Intel;

=head1 NAME

pf::Switch::Intel - Object oriented module to access SNMP enabled Intel switches

=head1 SYNOPSIS

The pf::Switch::Intel module implements an object oriented interface
to access SNMP enabled Intel switches.

=cut

use strict;
use warnings;

use base ('pf::Switch');

sub parseTrap {
    my ( $self, $trapString ) = @_;
    my $trapHashRef;
    my $logger = $self->logger;
    if ( $trapString
        =~ /^BEGIN TYPE ([23]) END TYPE BEGIN SUBTYPE 0 END SUBTYPE BEGIN VARIABLEBINDINGS \.1\.3\.6\.1\.2\.1\.2\.2\.1\.1\.(\d+) = INTEGER: \d+ END VARIABLEBINDINGS$/
        )
    {
        $trapHashRef->{'trapType'} = ( ( $1 == 2 ) ? "down" : "up" );
        $trapHashRef->{'trapIfIndex'} = $2;
    } else {
        $logger->debug("trap currently not handled");
        $trapHashRef->{'trapType'} = 'unknown';
    }
    return $trapHashRef;
}

sub getAlias {
    my ( $self, $ifIndex ) = @_;
    return "This function is not supported by Intel switches";
}

sub setAlias {
    my ( $self, $ifIndex, $alias ) = @_;
    return 1;
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

package pf::Switch::ThreeCom::NJ220;

=head1 NAME

pf::Switch::ThreeCom::NJ220 - Object oriented module to access SNMP enabled 3COM NJ220 switches

=head1 SYNOPSIS

The pf::Switch::ThreeCom::NJ220 module implements an object 
oriented interface to access SNMP enabled 3COM NJ220 switches.

The minimum required firmware version is 2.0.23.

=head1 CONFIGURATION AND ENVIRONMENT

F<conf/switches.conf>

=cut

use strict;
use warnings;
use Net::SNMP;
use base ('pf::Switch::ThreeCom');

sub description { '3COM NJ220' }

sub getMinOSVersion {
    my ($self) = @_;
    my $logger = $self->logger;
    return '2.0.23';
}

sub getVersion {
    my ($self) = @_;
    my $logger = $self->logger;
    $logger->info("we don't know how to determine the version through SNMP !");
    return '2.0.13';
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

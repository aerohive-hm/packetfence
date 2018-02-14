package pf::Switch::Accton::ES3526XA;

=head1 NAME

pf::Switch::Accton::ES3526XA - Object oriented module to access SNMP enabled Accton ES3526XA switches

=head1 SYNOPSIS

The pf::Switch::Accton::ES3526XA module implements an object oriented interface
to access SNMP enabled Accton::ES3526XA switches.

The minimum required firmware version is 2.3.3.5.

=head1 CONFIGURATION AND ENVIRONMENT

F<conf/switches.conf>

=cut

use strict;
use warnings;
use Net::SNMP;
use base ('pf::Switch::Accton');

sub description { 'Accton ES3526XA' }

sub getMinOSVersion {
    my ($self) = @_;
    my $logger = $self->logger;
    return '2.3.3.5';
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

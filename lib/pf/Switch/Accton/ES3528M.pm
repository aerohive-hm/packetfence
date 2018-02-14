package pf::Switch::Accton::ES3528M;

=head1 NAME

pf::Switch::Accton::ES3528M - Object oriented module to access SNMP enabled Accton ES3528M switches

=head1 SYNOPSIS

The pf::Switch::Accton::ES3528M module implements an object oriented interface
to access SNMP enabled Accton::ES3528M switches.

=cut

use strict;
use warnings;
use Net::SNMP;
use base ('pf::Switch::Accton');

sub description { 'Accton ES3528M' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

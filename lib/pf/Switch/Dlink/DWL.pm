package pf::Switch::Dlink::DWL;

=head1 NAME

pf::Switch::Dlink::DWL

=head1 SYNOPSIS

The pf::Switch::Dlink::DWL module implements an object oriented interface to manage Dlink::DWL Access-Points.

=head1 STATUS

This module is currently only a placeholder, see L<pf::Switch::Dlink::DWS_3026> for relevant support items.

=head1 BUGS AND LIMITATIONS

This module is currently only a placeholder, see L<pf::Switch::Dlink::DWS_3026> for relevant bugs and limitations.

=cut

use strict;
use warnings;

use Net::SNMP;

use base ('pf::Switch::Dlink::DWS_3026');

sub description { 'D-Link DWL Access-Point' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

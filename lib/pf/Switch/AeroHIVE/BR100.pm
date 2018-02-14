package pf::Switch::AeroHIVE::BR100;

=head1 NAME

pf::Switch::AeroHIVE::BR100

=head1 SYNOPSIS

Object oriented module to access and configure a AeroHIVE Branch Router 100.

=head1 STATUS

This module is currently only a placeholder, see pf::Switch::AeroHIVE

=cut

use strict;
use warnings;
use pf::constants;

use base ('pf::Switch::AeroHIVE');
sub description { 'AeroHive BR100' }

# CAPABILITIES
# access technology supported
sub supportsWiredMacAuth { return $TRUE; }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

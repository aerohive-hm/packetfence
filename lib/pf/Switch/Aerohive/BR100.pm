package pf::Switch::Aerohive::BR100;

=head1 NAME

pf::Switch::Aerohive::BR100

=head1 SYNOPSIS

Object oriented module to access and configure a Aerohive Branch Router 100.

=head1 STATUS

This module is currently only a placeholder, see pf::Switch::Aerohive

=cut

use strict;
use warnings;
use pf::constants;

use base ('pf::Switch::Aerohive');
sub description { 'Aerohive BR100' }

# CAPABILITIES
# access technology supported
sub supportsWiredMacAuth { return $TRUE; }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

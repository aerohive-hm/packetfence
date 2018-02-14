package pf::Switch::Netgear::MSeries;

=head1 NAME

pf::Switch::Netgear::MSeries - Object oriented module to access and configure Netgear M series switches.

head1 STATUS

Tested on a Netgear M4100 on firmware 10.0.1.27

=cut

use strict;
use warnings;

use pf::constants;

use base ('pf::Switch::Netgear');

sub supportsWiredMacAuth { return $TRUE }
sub supportsRadiusDynamicVlanAssignment { return $TRUE; }
sub description { return 'Netgear M series' }


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

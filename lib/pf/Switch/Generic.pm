package pf::Switch::Generic;

=head1 NAME

pf::Switch::Generic

=head1 SYNOPSIS

Implements a generic switch which supports RADIUS MAB + 802.1x in wired + wireless

=cut

use strict;
use warnings;

use base ('pf::Switch');

use pf::constants;

=head1 SUBROUTINES

=over

=cut

# Description
sub description { return "Generic" }

# CAPABILITIES
# access technology supported
sub supportsWirelessDot1x { return $TRUE; }
sub supportsWirelessMacAuth { return $TRUE; }
sub supportsWiredDot1x { return $TRUE; }
sub supportsWiredMacAuth { return $TRUE; }

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

package pf::Switch::EdgeCore;


=head1 NAME

pf::Switch::EdgeCore

=head1 SYNOPSIS

The pf::Switch::EdgeCore module manages access to EdgeCore

=head1 STATUS

Tested on EdgeCore 4510 running v1.3.2.0

=cut

use strict;
use warnings;

use base ('pf::Switch');

use pf::constants qw($TRUE);

sub description { 'EdgeCore' }

=head1 SUBROUTINES

=cut

sub supportsWiredMacAuth { return $TRUE; }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

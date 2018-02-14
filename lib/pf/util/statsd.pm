package pf::util::statsd;

=head1 NAME

pf::StatsD::util - module for StatsD related utilities

=cut

=head1 DESCRIPTION

pf::StatsD::util contains functions and utilities used to send StatsD messages.
modules.

=cut

our $VERSION = 1.000000;

use Exporter 'import';

our @EXPORT_OK = qw(called);

=head1 SUBROUTINES

=over

=item called

Returns the name of the function enclosing this call.

E.g. sub mysub { called() }; should return "mysub".

=cut

sub called {
    return (caller(1))[3];
}

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

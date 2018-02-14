package pf::util::apache;

=head1 NAME

pf::util::apache - apache-related utilities

=cut

=head1 DESCRIPTION

Module for apache-related functions and utilities used by all the modules.

=cut

use strict;
use warnings;

BEGIN {
    use Exporter ();
    our ( @ISA, @EXPORT_OK );
    @ISA = qw(Exporter);
    @EXPORT_OK = qw( url_parser );
}

# Note: avoid dependencies on core modules. This is a low-level module that
# should be as independant as possible.

=head1 SUBROUTINES

=over

=item url_parser

Returns a list with 
 Domain with protocol
 Protocol (http or https)
 Hostname
 Query string (path, file and arguments)

All values have ambiguous regexp characters quoted.

=cut

# url decompositor regular expression. 
my $url_pattern = qr/^
    (((?i)http|https):\/\/   # must begin by http or https (matched in a case-insensitive way)
    ([^\/]+))                # capture domain_url and the host (everything up to \/)
    (\/.*)?                  # optinally capture everything else as query string (path)
$/x;

sub url_parser {
    my ($url) = @_;

    if (defined($url) && $url =~ /$url_pattern/) {
        # if query_string is empty assign '/'
        my $query_string = (defined($4) ? quotemeta($4) : '\/');
        return (quotemeta(lc($1)), lc($2), quotemeta(lc($3)), $query_string);
    }

    return;
}

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

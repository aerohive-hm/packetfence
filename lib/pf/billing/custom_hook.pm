package pf::billing::custom_hook;

=head1 NAME

pf::billing::custom_hook - billing hook

=cut

=head1 DESCRIPTION

pf::billing::custom_hook is where to hook into httpd callbacks from billing providers

=cut

use strict;
use warnings;
use HTTP::Status qw(:constants);

=head1 SUBROUTINES

=head2 handle_hook ($billing_source, $headers, $content)

    The entry point for handling callbacks from billing providers

    Returns:
        An httpd status

=cut

sub handle_hook {
    my ($source, $headers, $content) = @_;
    return HTTP_OK;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

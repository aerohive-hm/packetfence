#!/usr/bin/perl

=head1 NAME

release.pl

=cut

=head1 DESCRIPTION

Tries to release the user from the parking state.
Notifies of the result through back-on-network.html and max-attempts.html

=cut

use strict;
use warnings;
use lib '/usr/local/pf/lib';

use CGI qw(:standard);

use pf::parking;

my $ip = $ENV{REMOTE_ADDR};
my $mac = pf::ip4log::ip2mac($ip);

if(pf::parking::unpark($mac, $ip)){
    print redirect("/back-on-network.html");
}
else {
    print redirect("/max-attempts.html");
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

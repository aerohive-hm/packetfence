#!/usr/bin/perl
=head1 NAME

squid-redirector.pl - a squid redirection helper to capture proxied requests to PacketFence's captive portal 

=cut

=head1 STATUS

Developed and tested with Squid 3.1.7.

=head1 CONFIGURATION AND ENVIRONMENT

Need configuration file: F<pf.conf> to find the fully qualified domain name used by the captive portal.

=cut

use constant INSTALL_DIR => '/usr/local/pf';
use constant CONFIG_FILE => '/conf/pf.conf';

use Config::IniFiles;

my %Config;
tie %Config, 'Config::IniFiles', (-file => INSTALL_DIR . CONFIG_FILE);

my @errors = @Config::IniFiles::errors;
if (scalar(@errors)) {
    print STDOUT join( "\n", @errors );
}

my $fqdn = $Config{'general'}{'hostname'} . "." . $Config{'general'}{'domain'};
my $captive_portal = qr|
    ^https?://     # HTTP or HTTPS
    \Q$fqdn\E/     # captive portal fully qualified domain name (meta-quoted to avoid regexp expansion)
|ix;

$|=1;
while (<>) {
    # parameters provided by Squid
    # http://wiki.squid-cache.org/Features/Redirectors
    my ($id, $url, $ip_fqdn, $ident, $method, %params) = split;

    # if we are already hitting the captive portal, don't do anything
    if ($url =~ /$captive_portal/) {
        print "$id ";
    } else {

        # in any other case, we redirect to captive portal
        print "$id 302:https://$fqdn/captive-portal?destination_url=$url";
    }
    # newline returns the response to squid
    print "\n";
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut    

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

package pf::proxypassthrough::constants;

=head1 NAME

pf::proxypassthrough::constants - Constants for the passthrough mod_proxy

=head1 DESCRIPTION

This file is splitted by packages and refering to the constant requires you to
specify the package.

=cut

use strict;
use warnings;

use Readonly;

use pf::authentication;
use pf::config qw(%Config);
use pf::class qw(class_view_all);
use pf::util::apache qw(url_parser);

=head1 SUBROUTINES

=cut

=head2 passthrough

Build all the permit domain for passthrough

=cut

sub proxy_passthrough { @{ $Config{fencing}{proxy_passthroughs} }; }

=head2 passthrough_remediation

Build all the permit domain for passthrough_remediation

=cut

sub proxy_passthrough_remediation {
    my @remediation_rules = class_view_all();
    my @domains;

    foreach my $row (@remediation_rules) {
        my $url = $row->{'url'};
        next if ( ( !defined($url) ) || ( $url =~ /^\// ) );
        my ($domainonly_url, $proto, $host, $query) = url_parser($url);
        push(@domains, $host);
    }
    return @domains;
}

=head1 PASSTHROUGH

=cut

package PROXYPASSTHROUGH;

my @passthrough_domains =  pf::proxypassthrough::constants::proxy_passthrough();
foreach (@passthrough_domains) { s{(\*)(.*)}{\(\.\*\)\Q$2\E} };

my $allow_passthrough_domains = join('|', @passthrough_domains) if (@passthrough_domains ne '0');

if (defined($allow_passthrough_domains)) {
    Readonly::Scalar our $ALLOWED_PASSTHROUGH_DOMAINS => qr/ ^(?: $allow_passthrough_domains ) /xo; # eXtended pattern, compile Once
} else {
    Readonly::Scalar our $ALLOWED_PASSTHROUGH_DOMAINS => '';
}

my @passthrough_remediation_domains =  pf::proxypassthrough::constants::proxy_passthrough_remediation();
foreach (@passthrough_remediation_domains) { s{([^/])$}{$1\$} };
foreach (@passthrough_remediation_domains) { s{(\*)(.*)}{\(\.\*\)\Q$2\E} };

my $allow_passthrough_remediation_domains = join('|', @passthrough_remediation_domains) if (@passthrough_remediation_domains ne '0');

if (defined($allow_passthrough_remediation_domains)) {
    Readonly::Scalar our $ALLOWED_PASSTHROUGH_REMEDIATION_DOMAINS => qr/ ^(?: $allow_passthrough_remediation_domains ) /xo; # eXtended pattern, compile Once
} else {
    Readonly::Scalar our $ALLOWED_PASSTHROUGH_REMEDIATION_DOMAINS => '';
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:



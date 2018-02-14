package pf::util::dns;

=head1 NAME

pf::util::dns

=cut

=head1 DESCRIPTION

Util functions for DNS

=cut

use strict;
use warnings;

use pf::constants;
use pfconfig::cached_hash;

tie our %passthroughs, 'pfconfig::cached_hash', 'resource::passthroughs';
tie our %isolation_passthroughs, 'pfconfig::cached_hash', 'resource::isolation_passthroughs';

our %ZONE_LOOKUP = (
    passthroughs => \%passthroughs,
    isolation_passthroughs => \%isolation_passthroughs,
);

=head2 matches_passthrough

Whether or not a domain matches a configured DNS passthrough

Returns 2 values
- Whether or not it matched
- List of ports that should be opened for this domain

=cut

sub matches_passthrough {
    my ($domain, $zone) = @_;
    
    unless(defined($zone)) {
        die "Undefined passthrough zone provided\n";
    }

    unless(exists $ZONE_LOOKUP{$zone}) {
        die "Invalid passthrough zone $zone\n";
    }

    return _matches_passthrough($ZONE_LOOKUP{$zone}, $domain);
}

sub _matches_passthrough {
    my ($passthroughs, $domain) = @_;

    # undef domains are not passthroughs
    return ($FALSE, []) unless(defined($domain));
    $domain = lc($domain);

    my ($res, $passthrough) = _matches_normal_passthrough($passthroughs, $domain);
    return ($res, $passthrough) if($res);

    ($res, $passthrough) = _matches_wildcard_passthrough($passthroughs, $domain);
    return ($res, $passthrough) if($res);

    # Fallback to not a passthrough
    return ($FALSE, []);
}

sub _matches_normal_passthrough {
    my ($passthroughs, $domain) = @_;

    # Check for non-wildcard passthroughs
    my $normal = $passthroughs->{normal}->{$domain};
    if(defined($normal)) {
        return ($TRUE, $normal);
    }
    else {
        return ($FALSE, []);
    }
}

sub _matches_wildcard_passthrough {
    my ($passthroughs, $domain) = @_;

    # check if its a sub-domain of a wildcard domain
    my @parts = split(/\./, $domain);
    my $last_element = scalar(@parts)-1;
    for (my $i=$last_element; $i>0; $i--) {
        my @sub_parts = @parts[$i..$last_element];
        my $domain = join('.', @sub_parts);
        my $wildcard = $passthroughs->{wildcard}->{$domain};
        if(defined($wildcard)) {
            return ($TRUE, $wildcard);
        }
    }

    return ($FALSE, []);
}

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

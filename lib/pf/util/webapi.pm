package pf::util::webapi;

=head1 NAME

pf::util::webapi -

=cut

=head1 DESCRIPTION

pf::util::webapi

=cut

use strict;
use warnings;
use pf::log;
use pf::util;
use List::MoreUtils qw(natatime);

our %MAC_KEYS = (
    'mac' => 1,
    'Calling-Station-Id' => 1,
    'User-Name' => 1,
);

sub add_mac_to_log_context {
    my ($args) = @_;
    return unless defined $args;
    my $params;
    if (@$args == 1) {
        my $tmp = $args->[0];
        if (ref($tmp) eq 'HASH') {
            $params = [%$tmp];
        }
        else {
            return;
        }
    }
    else {
        $params = $args;
    }
    if ((@$params % 2) == 0 ) {
        my $it = natatime 2, @$params;
        while (my ($k, $v) = $it->()) {
            last unless defined $k;
            if (exists $MAC_KEYS{$k}) {
                my $mac = clean_mac($v);
                if ($mac) {
                    Log::Log4perl::MDC->put('mac', $mac);
                    last;
                }
            }
        }
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

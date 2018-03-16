package pf::config::traffic_shaping;

=head1 NAME

pf::config::traffic_shaping -

=cut

=head1 DESCRIPTION

pf::config::traffic_shaping

=cut

use strict;
use warnings;
use pfconfig::cached_hash;

tie our %ConfigTrafficShaping, 'pfconfig::cached_hash', 'config::TrafficShaping';

BEGIN {
    use Exporter ();
    our ( @ISA, @EXPORT_OK );
    @ISA = qw(Exporter);
    @EXPORT_OK = qw(%ConfigTrafficShaping);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2016 Inverse inc.

=cut

1;

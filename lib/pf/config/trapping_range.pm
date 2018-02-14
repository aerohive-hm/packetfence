package pf::config::trapping_range;

=head1 NAME

pf::config::trapping_range -

=cut

=head1 DESCRIPTION

pf::config::trapping_range

=cut

use strict;
use warnings;
use pfconfig::cached_array;

tie our @TRAPPING_RANGE, 'pfconfig::cached_array' => 'resource::trapping_range';

BEGIN {
    use Exporter ();
    our ( @ISA, @EXPORT );
    @ISA = qw(Exporter);
    @EXPORT = qw(
        @TRAPPING_RANGE
    );
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

package pf::config::violation;

=head1 NAME

pf::config::violation -

=cut

=head1 DESCRIPTION

pf::config::violation

=cut

use strict;
use warnings;
use pfconfig::cached_array;

tie our @BANDWIDTH_EXPIRED_VIOLATIONS, 'pfconfig::cached_array' => 'resource::bandwidth_expired_violations';
tie our @ACCOUNTING_TRIGGERS, 'pfconfig::cached_array' => 'resource::accounting_triggers';

BEGIN {
    use Exporter ();
    our ( @ISA, @EXPORT );
    @ISA = qw(Exporter);
    @EXPORT = qw(
        @BANDWIDTH_EXPIRED_VIOLATIONS
        @ACCOUNTING_TRIGGERS
    );
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

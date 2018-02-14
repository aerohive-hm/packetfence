package pf::config::pfqueue;

=head1 NAME

pf::config::pfqueue

=cut

=head1 DESCRIPTION

Configuration from conf/pfqueue.conf

=cut

use strict;
use warnings;
use pfconfig::cached_hash;

BEGIN {
    use Exporter ();
    our ( @ISA, @EXPORT );
    @ISA = qw(Exporter);
    @EXPORT = qw(%ConfigPfqueue);
}

tie our %ConfigPfqueue, 'pfconfig::cached_hash', 'config::Pfqueue';

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

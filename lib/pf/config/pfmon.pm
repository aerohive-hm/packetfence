package pf::config::pfmon;

=head1 NAME

pf::config::pfmon

=cut

=head1 DESCRIPTION

Configuration from conf/pfmon.conf and conf/pfmon.conf.defaults

=cut

use strict;
use warnings;
use pfconfig::cached_hash;

BEGIN {
    use Exporter ();
    our ( @ISA, @EXPORT_OK );
    @ISA = qw(Exporter);
    @EXPORT_OK = qw(%ConfigPfmon %ConfigPfmonDefault);
}

tie our %ConfigPfmon, 'pfconfig::cached_hash', 'config::Pfmon';

tie our %ConfigPfmonDefault, 'pfconfig::cached_hash', 'config::PfmonDefault';

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

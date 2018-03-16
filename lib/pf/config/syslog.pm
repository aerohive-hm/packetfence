package pf::config::syslog;

=head1 NAME

pf::config::syslog -

=cut

=head1 DESCRIPTION

pf::config::syslog

=cut

use strict;
use warnings;
use pfconfig::cached_hash;

tie our %ConfigSyslog, 'pfconfig::cached_hash', 'config::Syslog';

BEGIN {
    use Exporter ();
    our ( @ISA, @EXPORT_OK );
    @ISA = qw(Exporter);
    @EXPORT_OK = qw(%ConfigSyslog);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

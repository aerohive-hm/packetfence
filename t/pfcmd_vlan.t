#!/usr/bin/perl -w
=head1 NAME

pfcmd_vlan.t

=head1 DESCRIPTION

Testing pfcmd_vlan command line interface (CLI)

=cut

use strict;
use warnings;
use diagnostics;

use lib '/usr/local/pf/lib';
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

use Test::More tests => 2;
use Test::NoWarnings;

use English '-no_match_vars';
use File::Basename qw(basename);
use Log::Log4perl;

# required to avoid warnings in admin guide asciidoc build
`perl -I/usr/local/pf/t -Mtest_paths /usr/local/pf/bin/pfcmd_vlan -help`;
is($CHILD_ERROR, 0, "pfcmd_vlan -help exits with status 0"); 

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut


#!/usr/bin/perl

=head1 NAME

add_status_to_pfdetect_conf - 

=cut

=head1 DESCRIPTION

Add status to pfdetect.conf for section that do not have them

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use pf::IniFiles;
use pf::file_paths qw($pfdetect_config_file);
use pf::util;

run_as_pf();

exit 0 unless -e $pfdetect_config_file;
my $ini = pf::IniFiles->new(-file => $pfdetect_config_file, -allowempty => 1);

for my $section ($ini->Sections()) {
    print "Checking $section\n";
    if ($ini->exists($section, 'status') || $section =~ / / ) {
        print "$section is good skipping\n";
        next;
    }
    $ini->newval($section, 'status', 'enabled');
}

$ini->RewriteConfig();

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut


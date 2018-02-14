#!/usr/bin/perl

=head1 NAME

to-7.3-adminroles-conf.pl

=cut

=head1 DESCRIPTION

Remove references to USERAGENTS_READ in adminroles.conf if there are any

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use pf::IniFiles;
use pf::file_paths qw($admin_roles_config_file);
use List::MoreUtils qw(any);
use pf::util;

run_as_pf();

exit 0 unless -e $admin_roles_config_file;
my $ini = pf::IniFiles->new(-file => $admin_roles_config_file, -allowempty => 1);

for my $section ($ini->Sections()) {
    if (my $actions = $ini->val($section, 'actions')) {
        $actions = [ split(/\s*,\s*/, $actions) ];
        if(any {$_ eq "USERAGENTS_READ"} @$actions) {
            print "Removing USERAGENTS_READ from actions in section $section\n";
            $actions = [ map { $_ ne "USERAGENTS_READ" ? $_ : () } @$actions ];
            $ini->setval($section, 'actions', join(',', @$actions));
        }
    }
}

$ini->RewriteConfig();

print "All done\n";

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut


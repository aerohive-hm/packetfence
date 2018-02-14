#!/usr/bin/perl

=head1 NAME

critic.t

=head1 DESCRIPTION

run Perl Critic for automated worst-practices avoidance

=cut

use strict;
use warnings;
use diagnostics;

use Test::Perl::Critic ( -profile => 'perlcriticrc' );
use Test::More;
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}
use Test::NoWarnings;

use TestUtils qw(get_all_perl_binaries get_all_perl_cgi get_all_perl_modules);


my @files = (
    '/usr/local/pf/addons/pfdetect_remote/sbin/pfdetect_remote',
);

push(@files, TestUtils::get_all_perl_binaries());
push(@files, TestUtils::get_all_perl_cgi());
push(@files, TestUtils::get_all_perl_modules());

# all files + no warnings
plan tests => scalar @files * 1 + 1;

foreach my $currentFile (@files) {
    critic_ok($currentFile);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut


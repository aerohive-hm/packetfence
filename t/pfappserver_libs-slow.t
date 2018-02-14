#!/usr/bin/perl -w

use strict;
use warnings;
use diagnostics;


# pf core libs
use lib qw(
    /usr/local/pf/lib
    /usr/local/pf/html/pfappserver/lib
    /usr/local/pf/html/captive-portal/lib
);

our $jobs;

BEGIN {
    $jobs = $ENV{'PF_SMOKE_TEST_JOBS'} || 6;
}

use File::Slurp qw(read_dir);
use File::Spec::Functions;
use Test::More;
use Test::ParallelSubtest max_parallel => $jobs;
use Test::NoWarnings;


BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

our %exclude;
@exclude{qw(pfappserver)} = ();
our @files = grep { /\.pm$/  } _readDirRecursive('/usr/local/pf/html/pfappserver/lib/');
our @libs = grep {!exists $exclude{$_}}
    map {
        s/\.pm$//;
        s#/#::#g;
        $_;
    } @files;

plan tests => (scalar @libs)  + 1;

foreach my $module ( @libs) {
    bg_subtest "use_ok $module" => sub {
        plan tests => 1;
        use_ok($module);
    };
}

bg_subtest_wait();

sub _readDirRecursive {
    my ($root_path,@subdir) = @_;
    my @files;
    foreach my $entry (read_dir($root_path)) {
        my $full_path = catfile($root_path,$entry);
        if (-d $full_path) {
            push @files, map {catfile($entry,$_) } _readDirRecursive($full_path);
        }
        elsif ($entry !~ m/^\./) {
            push @files, $entry;
        }
    }
    return @files;
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

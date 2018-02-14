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

BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

BEGIN {

    use File::Slurp qw(read_dir);
    use File::Spec::Functions;
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

    use Test::More;
    use Test::NoWarnings;
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
        use_ok($module);
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

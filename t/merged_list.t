#!/usr/bin/perl

=head1 NAME

merged_list

=cut

=head1 DESCRIPTION

merged_list

=cut

use strict;
use warnings;
# pf core libs
use lib '/usr/local/pf/lib';

BEGIN {
    use lib qw(/usr/local/pf/t);
    use File::Spec::Functions qw(catfile catdir rel2abs);
    use File::Basename qw(dirname);
    use test_paths_serial;
    use setup_test_config;
    my $test_dir = rel2abs(dirname($INC{'setup_test_config.pm'})) if exists $INC{'setup_test_config.pm'};
    $test_dir ||= catdir($pf::file_paths::install_dir,'t');
    $pf::file_paths::pf_config_file = catfile($test_dir,'data/pf.conf.tmp');
}

if (!-e $pf::file_paths::pf_config_file ) {
    open(my $fh, ">", $pf::file_paths::pf_config_file);
}
use Test::More tests => 6;

use Test::NoWarnings;
use Test::Exception;

use_ok('pf::config');

my @default_proxy_passthroughs = split /\s*,\s*/, $pf::config::Default_Config{fencing}{proxy_passthroughs};
# We use proxy_passthroughs to test the mergeable lists
ok(@default_proxy_passthroughs ~~ $pf::config::Config{fencing}{proxy_passthroughs}, "Not overriden passthroughs are equal to the default ones.");

use_ok('pf::ConfigStore::Pf');

my @additionnal = (
    "www.dinde.ca",
    "www.zamm.it",
);

my $cs = pf::ConfigStore::Pf->new;
$cs->update('fencing', {'proxy_passthroughs' => join ',', @additionnal});
$cs->commit();

ok(!(@default_proxy_passthroughs ~~ $pf::config::Config{fencing}{proxy_passthroughs}), "Merged passthroughs are not equal to the default ones.");

ok(([@default_proxy_passthroughs, @additionnal] ~~ $pf::config::Config{fencing}{proxy_passthroughs}), "Merged passthroughs are actually merged");

$cs->update('fencing', {'proxy_passthroughs' => undef});
$cs->commit();

END {
    truncate $pf::file_paths::pf_config_file, 0;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


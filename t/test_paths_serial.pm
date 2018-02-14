package test_paths_serial;

=head1 NAME

test_paths

=cut

=head1 DESCRIPTION

test_paths
Overrides the the location of config files to help with testing

=cut

use strict;
use warnings;


BEGIN {
    use test_paths;
    use File::Spec::Functions qw(catfile catdir rel2abs);
    use File::Basename qw(dirname);
    use pf::file_paths qw($install_dir);
    use pfconfig::constants;
    $test_paths::PFCONFIG_TEST_PID_FILE = "/usr/local/pf/var/run/pfconfig-test-serial.pid";
    $pfconfig::constants::CONFIG_FILE_PATH = catfile($test_paths::test_dir, 'data/pfconfig-serial.conf');
    $test_paths::PFCONFIG_RUNNER = catfile($test_paths::test_dir, 'pfconfig-test-serial');
    $pfconfig::constants::SOCKET_PATH = catfile($install_dir, "var/run/pfconfig-test-serial.sock");

}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;



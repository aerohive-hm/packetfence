package setup_test_config;

=head1 NAME

setup_test_config

=cut

=head1 DESCRIPTION

setup_test_config
Setups the configuration for the testing environment

=cut

use strict;
use warnings;


BEGIN {
    use test_paths;
    use pf::CHI;
    use pfconfig::constants;
    use File::Spec::Functions qw(catfile);

    if (test_paths::testIfFileUnlock($test_paths::PFCONFIG_TEST_PID_FILE)) {
        `$test_paths::PFCONFIG_RUNNER`
    }

    use pf::db;

    use pf::config qw(
        %Config
        $management_network
    );
    # Setup IP and VIP of management network
    if(defined($ENV{PF_TEST_MGMT_INT})){
        my $section_name = "interface ".$ENV{PF_TEST_MGMT_INT};
        $Config{$section_name}{ip} = $ENV{PF_TEST_MGMT_IP} // $pf::config::Config{$section_name}{ip};
        $Config{$section_name}{vip} = $ENV{PF_TEST_MGMT_IP} // $pf::config::Config{$section_name}{vip};
        $Config{$section_name}{mask} = $ENV{PF_TEST_MGMT_MASK} // $pf::config::Config{$section_name}{mask};
        $management_network->tag('ip', $Config{$section_name}{ip});
        $management_network->tag('vip', $Config{$section_name}{vip});
    }

    #increase "inactivity timeout"
    $ENV{MOJO_INACTIVITY_TIMEOUT} = "300";

    `rm -fr /tmp/chi/*`;
}

=head2 new_db_config

Override the database configuration

=cut

sub new_db_config {
    my ($config) = @_;
    my %new_config = (%{$config //{}}, %{$pf::db::DB_Config});
    if (tied $pf::db::DB_Config) {
        untie $pf::db::DB_Config;
    }
    $pf::db::DB_Config = \%new_config;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


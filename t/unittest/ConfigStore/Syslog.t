#!/usr/bin/perl

=head1 NAME

Syslog

=cut

=head1 DESCRIPTION

unit test for Syslog

=cut

use strict;
use warnings;
#
use lib '/usr/local/pf/lib';
use pf::ConfigStore::Syslog;
use pf::constants::syslog;

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;
}

use Test::More tests => 3;

#This test will running last
use Test::NoWarnings;

{
    my $config = pf::ConfigStore::Syslog->new;
    my $data = { logs => 'ALL', type => 'server' };
    $config->cleanupAfterRead( "id", $data );
    is_deeply(
        $data,
        {
            logs     => [ split( ',', $pf::constants::syslog::ALL_LOGS ) ],
            all_logs => 'enabled',
            type     => 'server'
        },
        "Expand the virtual field all_logs"
    );
}

{
    my $config = pf::ConfigStore::Syslog->new;
    my $data = { logs => [], all_logs => 'enabled', type => 'server' };
    $config->cleanupBeforeCommit( "id", $data );
    is_deeply(
        $data,
        {
            type => 'server',
            logs => 'ALL',
        },
        "Remove the virtual field all_logs"
    );
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


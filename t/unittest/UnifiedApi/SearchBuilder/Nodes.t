#!/usr/bin/perl

=head1 NAME

Nodes

=cut

=head1 DESCRIPTION

unit test for Nodes

=cut

use strict;
use warnings;
#
use lib '/usr/local/pf/lib';

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;
}

use Test::More tests => 20;

#This test will running last
use Test::NoWarnings;
use pf::UnifiedApi::SearchBuilder::Nodes;
use pf::error qw(is_error);
use pf::constants qw($ZERO_DATE);
use pf::dal::node;
my $dal = "pf::dal::node";

my $sb = pf::UnifiedApi::SearchBuilder::Nodes->new();

{
    my ($status, $col) = $sb->make_columns({ dal => $dal,  fields => [qw(mac $garbage ip4log.ip)] });
    ok(is_error($status), "Do no accept invalid columns");
}

{
    my @f = qw(mac ip4log.ip locationlog.ssid locationlog.port); 

    my %search_info = (
        dal => $dal,
        fields => \@f,
    );

    is_deeply(
        [ $sb->make_columns( \%search_info ) ],
        [ 200, [ 'node.mac', \'`ip4log`.`ip` AS `ip4log.ip`', \'`locationlog`.`ssid` AS `locationlog.ssid`', \'`locationlog`.`port` AS `locationlog.port`'] ],
        'Return the columns'
    );

    is_deeply(
        [ 
            $sb->make_from(\%search_info)
        ],
        [
            200,
            [
                -join => 'node',
                @pf::UnifiedApi::SearchBuilder::Nodes::IP4LOG_JOIN,
                @pf::UnifiedApi::SearchBuilder::Nodes::LOCATION_LOG_JOIN,
            ]
        ],
        'Return the joined tables'
    );
}

{
    my @f = qw(mac locationlog.ssid locationlog.port radacct.acctsessionid online);

    my %search_info = (
        dal => $dal,
        fields => \@f,
        query => {
            op => 'equals',
            field => 'ip4log.ip',
            value => "1.1.1.1"
        },
    );

    is_deeply(
        [ $sb->make_columns( \%search_info ) ],
        [
            200,
            [
                'node.mac',
                \'`locationlog`.`ssid` AS `locationlog.ssid`',
                \'`locationlog`.`port` AS `locationlog.port`',
                \'`radacct`.`acctsessionid` AS `radacct.acctsessionid`',
                "IF(radacct.acctstarttime IS NULL,'unknown',IF(radacct.acctstoptime IS NULL, 'on', 'off'))|online"
            ],
        ],
        'Return the columns'
    );
    is_deeply(
        [ 
            $sb->make_where(\%search_info)
        ],
        [
            200,
            {
                'ip4log.ip' => { "=" => "1.1.1.1"},
                'locationlog2.id' => undef,
                'r2.radacctid' => undef,
            },
        ],
        'Return the joined tables'
    );

    $sb->make_where(\%search_info);

    my @a = $sb->make_from(\%search_info);
    is_deeply(
        \@a,
        [
            200,
            [
                -join => 'node',
                @pf::UnifiedApi::SearchBuilder::Nodes::LOCATION_LOG_JOIN,
                @pf::UnifiedApi::SearchBuilder::Nodes::RADACCT_JOIN,
                @pf::UnifiedApi::SearchBuilder::Nodes::IP4LOG_JOIN,
            ]
        ],
        'Return the joined tables'
    );
}

{
    my @f = qw(mac online radacct.acctsessionid);

    my %search_info = (
        dal    => $dal,
        fields => \@f,
    );

    is_deeply(
        [ $sb->make_columns( \%search_info ) ],
        [
            200,
            [
                'node.mac',
                "IF(radacct.acctstarttime IS NULL,'unknown',IF(radacct.acctstoptime IS NULL, 'on', 'off'))|online",
                \'`radacct`.`acctsessionid` AS `radacct.acctsessionid`'
            ]
        ],
        'Return the columns with column spec'
    );

}

{
    my @f = qw(mac online);
    my %search_info = (
        dal    => $dal,
        fields => \@f,
        sort => ['online'],
    );
    my ($status, $results) = $sb->search(\%search_info);
    is($status, 200, "Including online");
}

{
    my $q = {
        op    => 'equals',
        field => 'online',
        value => "unknown",
    };

    my $s = {
        dal    => $dal,
        fields => [qw(mac online)],
        query  => $q,
    };

    ok(
        $sb->is_field_rewritable($s, 'online'),
        "Is online rewriteable"
    );

    is_deeply(
        $sb->rewrite_query( $s, $q ),
        { op => 'equals', value => undef, field => 'radacct.acctstarttime' },
        "Rewrite online='unknown'",
    );

    is_deeply(
        $sb->rewrite_query(
            $s, { op => 'equals', value => 'on', field => 'online' }
        ),
        {
            'op' => 'and',
            'values' => [
                { op => 'not_equals', value => undef, field => 'radacct.acctstarttime' },
                { op => 'equals', value => undef, field => 'radacct.acctstoptime' },
            ],
        },
        "Rewrite online='on'",
    );

    is_deeply(
        $sb->rewrite_query(
            $s, { op => 'equals', value => 'off', field => 'online' }
        ),
        { op => 'not_equals', value => undef, field => 'radacct.acctstoptime' },
        "Rewrite online='off'",
    );

    is_deeply(
        $sb->rewrite_query(
            $s, { op => 'not_equals', value => 'off', field => 'online' }
        ),
        {
            op => 'or',
            values => [
                { op => 'equals', value => undef, field => 'radacct.acctstarttime' },
                { op => 'equals', value => undef, field => 'radacct.acctstoptime' },
            ],
        },
        "Rewrite online!='off'",
    );

    is_deeply(
        $sb->rewrite_query(
            $s, { op => 'not_equals', value => 'on', field => 'online' }
        ),
        {
            op => 'or',
            values => [
                { op => 'equals', value => undef, field => 'radacct.acctstarttime' },
                { op => 'not_equals', value => undef, field => 'radacct.acctstoptime' },
            ],
        },
        "Rewrite online!='on'",
    );

    is_deeply(
        $sb->rewrite_query(
            $s, { op => 'not_equals', value => 'unknown', field => 'online' }
        ),
        {
            op => 'not_equals', value => undef, field => 'radacct.acctstarttime',
        },
        "Rewrite online!='unknown'",
    );
}

{
    my @f = qw(mac online);
    my %search_info = (
        dal    => $dal,
        fields => \@f,
        query => {
            op => 'equals',
            field => 'online',
            value => "unknown",
        },
    );
    my ($status, $results) = $sb->search(\%search_info);
    is($status, 200, "Query remap for online");
}

{
    my @f = qw(status online mac pid ip4log.ip bypass_role_id);

    my %search_info = (
        dal => $dal, 
        fields => \@f,
    );

    is_deeply(
        [ $sb->make_columns( \%search_info ) ],
        [
            200,
            [
                'node.status',
                "IF(radacct.acctstarttime IS NULL,'unknown',IF(radacct.acctstoptime IS NULL, 'on', 'off'))|online",
                'node.mac',
                'node.pid',
                \'`ip4log`.`ip` AS `ip4log.ip`',
                'node.bypass_role_id',
            ],
        ],
        'Return the columns'
    );
    is_deeply(
        [ 
            $sb->make_where(\%search_info)
        ],
        [
            200,
            {
                'r2.radacctid' => undef,
            },
        ],
        'Return the joined tables'
    );

    $sb->make_where(\%search_info);

    my @a = $sb->make_from(\%search_info);
    is_deeply(
        \@a,
        [
            200,
            [
                -join => 'node',
                @pf::UnifiedApi::SearchBuilder::Nodes::RADACCT_JOIN,
                @pf::UnifiedApi::SearchBuilder::Nodes::IP4LOG_JOIN,
            ]
        ],
        'Return the joined tables'
    );
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

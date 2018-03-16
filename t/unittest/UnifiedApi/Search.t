#!/usr/bin/perl

=head1 NAME

Search

=cut

=head1 DESCRIPTION

unit test for Search

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

use Test::More tests => 15;
use Test::Mojo;
use pf::UnifiedApi::Search;

use pf::SQL::Abstract;

#This test will running last
use Test::NoWarnings;


my $t = Test::Mojo->new('pf::UnifiedApi');
#This is the first test
is_deeply(
    pf::UnifiedApi::Search::searchQueryToSqlAbstract(
        {
            "field" => "pid",
            "op"    => "equals",
            "value" => "lzammit"
        }
    ),
    {
        pid => { "=" => "lzammit" }
    },
    "pid = 'lzammit'"
);

is_deeply(
    pf::UnifiedApi::Search::searchQueryToSqlAbstract(
        {
            "field" => "pid",
            "op"    => "greater_than",
            "value" => "lzammit"
        }
    ),
    {
        pid => { ">" => "lzammit" }
    },
    "pid > 'lzammit'"
);

is_deeply(
    pf::UnifiedApi::Search::searchQueryToSqlAbstract(
        {
            "field" => "pid",
            "op"    => "less_than",
            "value" => "lzammit"
        }
    ),
    {
        pid => { "<" => "lzammit" }
    },
    "pid < 'lzammit'"
);

is_deeply(
    pf::UnifiedApi::Search::searchQueryToSqlAbstract(
        {
            "field" => "pid",
            "op"    => "greater_than_equals",
            "value" => "lzammit"
        }
    ),
    {
        pid => { ">=" => "lzammit" }
    },
    "pid >= 'lzammit'"
);

is_deeply(
    pf::UnifiedApi::Search::searchQueryToSqlAbstract(
        {
            "field" => "pid",
            "op"    => "less_than_equals",
            "value" => "lzammit"
        }
    ),
    {
        pid => { "<=" => "lzammit" }
    },
    "pid <= 'lzammit'"
);

is_deeply(
    pf::UnifiedApi::Search::searchQueryToSqlAbstract(
        {
            "field" => "pid",
            "op"    => "not_equals",
            "value" => "lzammit"
        }
    ),
    {
        pid => { "!=" => "lzammit" },
    },
    "pid != 'lzammit'"
);

is_deeply(
    pf::UnifiedApi::Search::searchQueryToSqlAbstract(
        {
            "field" => "pid",
            "op"    => "starts_with",
            "value" => "lzammit"
        }
    ),
    {
        pid => { "-like" => "lzammit%" },
    },
    "pid LIKE 'lzammit%'"
);

is_deeply(
    pf::UnifiedApi::Search::searchQueryToSqlAbstract(
        {
            "field" => "pid",
            "op"    => "starts_with",
            "value" => "lzammit\%"
        }
    ),
    {
        pid => { "-like" => \[ q{? ESCAPE '\\\\'}, "lzammit\\\%\%" ] },
    },
    "pid LIKE 'lzammit\\\%\%' ESCAPE '\\\\'"
);

is_deeply(
    pf::UnifiedApi::Search::searchQueryToSqlAbstract(
        {
            "field" => "pid",
            "op"    => "ends_with",
            "value" => "lzammit"
        }
    ),
    {
        pid => { "-like" => "%lzammit" },
    },
    "pid LIKE 'lzammit%'"
);

is_deeply(
    pf::UnifiedApi::Search::searchQueryToSqlAbstract(
        {
            "field" => "pid",
            "op"    => "contains",
            "value" => "lzammit"
        }
    ),
    {
        pid => { "-like" => "%lzammit%" },
    },
    "pid LIKE '%lzammit%'"
);

is_deeply(
    pf::UnifiedApi::Search::searchQueryToSqlAbstract(
                {
                    "field"  => "detect_date",
                    "op"     => "between",
                    "values" => [ "2017-01-01 ", "2017-01-02 " ]
                },
    ),
    {
        detect_date => {
            -between => ["2017-01-01 ", "2017-01-02 "]
        },
    },
    "detect_date BETWEEN '2017-01-01' AND '2017-01-02'",
);


is_deeply(
    pf::UnifiedApi::Search::searchQueryToSqlAbstract(
        {
            "op"     => "and",
            "values" => [
                {
                    "field"  => "detect_date",
                    "op"     => "between",
                    "values" => [ "2017-01-01 ", "2017-01-02 " ]
                },
                {
                    "op"     => "or",
                    "values" => [
                        {
                            "field" => "mac",
                            "op"    => "ends_with",
                            "value" => "ab:cd"
                        },
                        {
                            "field" => "pid",
                            "op"    => "equals",
                            "value" => "lzammit"
                        }
                    ]
                }
            ]
        }

    ),
    {
        -and => [
            {
                detect_date => {
                    -between => ["2017-01-01 ", "2017-01-02 "],
                },
            },
            {
                -or => [
                    {
                        mac => { -like => '%ab:cd' }
                    },
                    {
                        pid => { "=" => "lzammit" }
                    }
                ],
            }
        ],
    },
    "Parsing a complex query"
);

is_deeply(
    pf::UnifiedApi::Search::searchQueryToSqlAbstract(
        {
            "op"     => "and",
            "values" => [
                {
                    "field"  => "detect_date",
                    "op"     => "between",
                    "values" => [ "2017-01-01 ", "2017-01-02 " ]
                },
            ]
        }

    ),
    {
        detect_date => {
            -between => [ "2017-01-01 ", "2017-01-02 " ],
        },
    },
    "Flatten a single sub query for an and op"
);

is_deeply(
    pf::UnifiedApi::Search::searchQueryToSqlAbstract(
        {
            "op"     => "or",
            "values" => [
                {
                    "field"  => "detect_date",
                    "op"     => "between",
                    "values" => [ "2017-01-01 ", "2017-01-02 " ]
                },
            ]
        }

    ),
    {
        detect_date => {
            -between => [ "2017-01-01 ", "2017-01-02 " ],
        },
    },
    "Flatten a single sub query for an or op"
);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


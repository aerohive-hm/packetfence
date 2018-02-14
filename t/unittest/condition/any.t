=head1 NAME

Tests for pf::condition::any

=cut

=head1 DESCRIPTION

Tests for pf::condition::any

=cut

use strict;
use warnings;

use lib '/usr/local/pf/lib';
use Test::More tests => 4;

BEGIN {
    use_ok("pf::filter_engine");
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;
}


#This test will running last
use Test::NoWarnings;
use pf::filter;
use pf::condition::any;
use pf::condition::false;
use pf::condition::true;

{

    my $engine = pf::filter_engine->new(
        {   filters => [
                pf::filter->new(
                    {   answer    => 'no match',
                        condition => pf::condition::any->new(
                            conditions => [
                                pf::condition::false->new,
                                pf::condition::false->new,
                            ]
                        ),
                    }
                ),
                pf::filter->new(
                    {   answer    => 'match1',
                        condition => pf::condition::any->new(
                            conditions => [
                                pf::condition::false->new,
                                pf::condition::true->new,
                            ]
                        ),
                    }
                ),
                pf::filter->new(
                    {   answer    => 'match2',
                        condition => pf::condition::any->new(
                            conditions => [
                                pf::condition::false->new,
                                pf::condition::true->new,
                            ]
                        ),
                    }
                ),
            ],
        }
    );

    #This is the first test
    is($engine->match_first({}), 'match1', "Match first");

    #This is the second test
    is_deeply([$engine->match_all({})], ['match1', 'match2'], "Match all");

}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;



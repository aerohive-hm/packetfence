=head1 NAME

pf::filter_engine - test for pf::filter_engine

=cut

=head1 DESCRIPTION

test for pf::filter_engine

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
use pf::condition::false;
use pf::condition::true;

{

    my $engine = pf::filter_engine->new(
        {   filters => [
                pf::filter->new(
                    {   answer    => 'falses',
                        condition => pf::condition::false->new,
                    }
                ),
                pf::filter->new(
                    {   answer    => 'true1',
                        condition => pf::condition::true->new,
                    }
                ),
                pf::filter->new(
                    {   answer    => 'true2',
                        condition => pf::condition::true->new,
                    }
                ),
            ],
        }
    );

    #This is the first test
    is($engine->match_first({}), 'true1', "Match first");

    #This is the second test
    is_deeply([$engine->match_all({})], ['true1', 'true2'], "Match all");

}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

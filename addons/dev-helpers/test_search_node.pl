#!/usr/bin/perl

=head1 NAME

search_node -

=cut

=head1 DESCRIPTION

search_node

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use pf::SearchBuilder::Node;
use pfappserver::Base::Model::Search;
use pfappserver::Model::Search::Node;

=head2 input from catalyst

| searches.0.name                     | switch_ip                            |
| searches.0.op                       | equal                                |
| searches.0.value                    | 192.168.56.101                       |

=cut

my $query = {
    searches => [
        {name => 'mac', op => 'equal', value => '00:25:4b:8d:06:af'}
    ],
    online_date => {
        start => '2011-11-09',
        end => '2016-11-09',
    }
};

my $search = pfappserver::Model::Search::Node->new;

use Data::Dumper;
my $builder = $search->make_builder;
$search->setup_query($builder, $query);
print $builder->sql,";\n";
#my $results = $search->do_query($builder, $query);


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut


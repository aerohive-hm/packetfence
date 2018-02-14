package pf::extended_node_data;

=head1 NAME

pf::extended_node_data -

=cut

=head1 DESCRIPTION

pf::extended_node_data

=cut

use strict;
use warnings;
use pf::Redis;
use JSON::MaybeXS;
use Exporter qw(import);

BEGIN {
    our @EXPORT = qw(extended_node_get_data);
}

=head2 extended_node_get_data

Get the node extended data

=cut

sub extended_node_get_data {
    my ($mac, $namespace) = @_;
    my $redis = pf::Redis->new(server => '127.0.0.1:6379');
    my $json = JSON::MaybeXS->new;
    my ($text) = $redis->get("extended:${namespace}:${mac}");
    if (defined $text) {
        return $json->decode($text);
    }
    return undef;
}


 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

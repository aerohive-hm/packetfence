package pf::CHI::Request;

=head1 NAME

pf::CHI::Request -

=cut

=head1 DESCRIPTION

pf::CHI::Request

=cut

use strict;
use warnings;
use CHI::Memoize qw(memoize memoized);
use base qw(CHI);
our %CACHE;

use Exporter qw(import);

our @EXPORT_OK = qw(
    pf_memoize
);


__PACKAGE__->config({
    storage => {
        memory => {
            driver     => 'Memory',
            datastore  => \%CACHE,
            serializer => 'Sereal',
        },
        raw_memory => {
            driver     => 'RawMemory',
            datastore  => \%CACHE,
        },
    },
    namespace => {
       'pf::node::_node_exist' => {
           storage => 'raw_memory',
       },
    },
    memoize_cache_objects => 1,
    defaults              => {'storage' => 'memory'},
});

sub clear_all {
    %CACHE = ();
}

sub pf_memoize {
    my ($func) = @_;
    memoize($func, cache => pf::CHI::Request->new(namespace => $func));
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


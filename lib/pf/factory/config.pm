package pf::factory::config;

=head1 NAME

pf::factory::config 

=cut

=head1 DESCRIPTION

pf::factory::config

The factory for creating pfconfig::cached based objects

=cut

use strict;
use warnings;
use pfconfig::cached_hash;
use pfconfig::cached_array;
use pfconfig::cached_scalar;

sub new {
    my ($class,$type,$namespace) = @_;

    if ($type eq "cached_hash") {
        my %object;
        tie %object, 'pfconfig::cached_hash', $namespace;
        return %object;
    }
    elsif ($type eq "cached_array"){
        my @object;
        tie @object, 'pfconfig::cached_array', $namespace;
        return @object;
    }
    elsif ($type eq "cached_scalar"){
        my $object;
        tie $object, 'pfconfig::cached_scalar', $namespace;
        return $object;
    }
    else {
        die "$type is not a valid type";
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


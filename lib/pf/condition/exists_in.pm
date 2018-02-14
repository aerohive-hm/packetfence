package pf::condition::exists_in;

=head1 NAME

pf::condition::exists_in - checks if a value exists in a hash

=cut

=head1 DESCRIPTION

pf::condition::exists_in

=cut

use strict;
use warnings;
use Moose;
use MooseX::Types::Moose qw(HashRef);
extends qw(pf::condition);
use pf::constants;

=head2 lookup

The hash to lookup the values

=cut

has lookup => (
    is => 'ro',
    isa => HashRef,
    required => 1,
);

=head2 match

Matches if the argument exists in the hash

=cut

sub match {
    my ($self,$arg) = @_;
    return $FALSE if(!defined($arg));
    return exists ${$self->lookup}{$arg} ? $TRUE : $FALSE;
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

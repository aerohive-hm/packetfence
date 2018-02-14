package pf::condition::regex_not;

=head1 NAME

pf::condition::regex_not

=cut

=head1 DESCRIPTION

pf::condition::regex_not

=cut

use strict;
use warnings;
use Moose;


extends qw(pf::condition::regex);
use pf::constants;

=head2 match

Match if argument does not match the regex defined

=cut

sub match {
    my ($self,$arg) = @_;
    my $match = $self->value;
    return 0 if(!defined($arg));
    return $arg !~ $match;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

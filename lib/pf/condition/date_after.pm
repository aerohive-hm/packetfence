package pf::condition::date_after;

=head1 NAME

pf::condition::date_after

=cut

=head1 DESCRIPTION

Check if a given date is after actual (or supplied) date

Date format is YYYY-MM-DD HH:MM:SS

=cut

use strict;
use warnings;

use Moose;
use POSIX qw(strftime);
use Time::Piece;

extends 'pf::condition';

has value => (
    is => 'rw',
    isa => 'Maybe[Str]',
    required => 0,
);

sub match {
    my ($self, $arg) = @_;

    my $date_format = "%Y-%m-%d %H:%M:%S";

    my $date_to_compare = $arg;
    my $date_control = $self->value // strftime $date_format, localtime;

    $date_to_compare = Time::Piece->strptime($date_to_compare, $date_format);
    $date_control = Time::Piece->strptime($date_control, $date_format);

    return $date_to_compare > $date_control;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


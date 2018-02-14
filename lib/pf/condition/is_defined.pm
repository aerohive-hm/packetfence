package pf::condition::is_defined;

=head1 NAME

pf::condition::is_defined

=cut

=head1 DESCRIPTION

pf::condition::is_defined

=cut

use strict;
use warnings;
use Moose;
extends qw(pf::condition);

=head2 match

Match defined arguments

=cut

sub match {
    my ($self,$arg) = @_;
    return defined($arg);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


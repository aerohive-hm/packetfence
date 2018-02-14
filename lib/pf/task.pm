package pf::task;
=head1 NAME

pf::task - Parent class for pfqueue worker

=head1 DESCRIPTION

pf::task

=cut

use strict;
use warnings;
use Data::UUID;

my $GENERATOR = Data::UUID->new;

=head2 new

The constructor

=cut

sub new {
    my ($proto, @args) = @_;
    my $class = ref($proto) || $proto;
    return bless {args => \@args}, $class;
}

=head2 doTask

The function to override to perform a task

=cut

sub doTask {
    die "Unimplemented doTask";
}

=head2 generateId

Generate the task id

=cut

sub generateId {
    my ($self, $metadata) = @_;
   "Task:" . $GENERATOR->create_str . ":$metadata";
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


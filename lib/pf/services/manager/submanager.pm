package pf::services::manager::submanager;
=head1 NAME

pf::services::manager::submanager add documentation

=cut

=head1 DESCRIPTION

pf::services::manager::submanager

a subclass for handling a service the has multple sub services

=cut

use strict;
use warnings;
use Moo;
use List::MoreUtils qw(true any all);

extends 'pf::services::manager';

=head2 managers

The list of sub managers

=cut

sub managers {
    my ($self) = @_;
    return ();
}

=head2 generateConfig startService postStartCleanup stop 

Delegating generateConfig startService postStartCleanup stop to sub managers

=cut

for my $func (qw(generateConfig startService postStartCleanup stop)) {
    around $func => sub {
        my ($orig,$self,$quick) = @_;
        my $count = 0;
        my $pass = true {$count++; $_->$func($quick) } $self->managers;
        return $pass == $count;
    };
}

=head2 removeStalePid

Delegating removeStalePid to sub managers

=cut

sub removeStalePid {
    my ($self,$quick) = @_;
    $_->removeStalePid($quick) foreach $self->managers;
}

=head2 status

returns all the pids of the submanagers

=cut

sub status {
    my ($self,$quick) = @_;
    my @results = map { $_->status($quick) } $self->managers;
    my $failed = true { $_ eq '0' } @results;
    return join(" ",@results) if ( @results && $failed == 0 ) || ($quick && @results != $failed);
    return ("0");
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


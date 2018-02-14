package captiveportal::Role::Action::Hookable;

=head1 NAME

captiveportal::Role::Action::Hookable add documentation

=cut

=head1 DESCRIPTION

captiveportal::Role::Action::Hookable

=cut

use strict;
use warnings;
use HTTP::Status qw(:constants);
use Moose::Role;
use namespace::autoclean;

=head1 METHODS

=head2 before execute

See if action has a config hook one of the configured

before
after
override

=cut

sub wasSeen {
    my ( $self, $c ) = @_;
    my $seenKey = $self->seenKey;
    my $seenHash = $c->stash->{$seenKey} || {};
    $c->stash( $seenKey => $seenHash );
    my $seen = $seenHash->{ $self->private_path }++;
    return $seen;
}

sub resetSeenCount {
    my ( $self, $c ) = @_;
    my $seenKey = $self->seenKey;
    my $seenHash = $c->stash->{$seenKey} || {};
    $seenHash->{ $self->private_path } = 0;
    $c->stash( $seenKey => $seenHash );
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


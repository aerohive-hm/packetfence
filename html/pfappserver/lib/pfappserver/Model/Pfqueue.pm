package pfappserver::Model::Pfqueue;

=head1 NAME

pfappserver::Model::Pfqueue - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

use Moose;
use namespace::autoclean;
use pf::pfqueue::stats;

extends 'Catalyst::Model';

has stats => (
    is      => 'rw',
    default => sub {
        return pf::pfqueue::stats->new;
    },
    handles => [qw(counters miss_counters queue_counts)],
);

sub ACCEPT_CONTEXT {
    my ( $self, $c, @args ) = @_;
    return $self->new(@args);
}

=head1 METHODS

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

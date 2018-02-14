package pfappserver::Model::Enforcement;

=head1 NAME

pfappserver::Model::Enforcement - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

use strict;
use warnings;

use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

# TODO: Should migrate theses into a database table with some flags for the mechanisms
my @mechanisms           = qw/vlan inline option webauth/;
# TODO once we display option we should move 'other' over to there
my %types   = (
    vlan        => [ 'management', 'vlan-registration', 'vlan-isolation'],
    inline      => [ 'management', 'inline', 'inlinel2', 'inlinel3' ], # inline is kept for backwards compat.
#    option      => [ 'high-availability', 'dhcp-listener', 'monitor' ],
    webauth     => ['management', 'portal'],
    other       => ['dns-enforcement'],
    radius      => ['management'],
);

=head1 METHODS

=over

=item getAvailableMechanisms

=cut

sub getAvailableMechanisms {
    my ( $self ) = @_;

    return \@mechanisms;
}

=item getAvailableTypes

=cut

sub getAvailableTypes {
    my ( $self, $mechanism, $interface, $interfaces ) = @_;

    my @mechanisms;
    my @available_types;

    if (ref($mechanism)) {
        @mechanisms = @$mechanism;
    }
    elsif ($mechanism eq 'all') {
        @mechanisms = keys %types;
    }
    else {
        @mechanisms = ($mechanism);
    }

    my @exclusions;
    if ($interfaces) {
        foreach my $i (keys %$interfaces) {
            next if ($i eq $interface);
            # Don't return "management" if it's already set for an interface
            push(@exclusions, 'management') if ($interfaces->{$i}->{type} eq 'management');
        }
    }
    foreach my $m (@mechanisms) {
        foreach my $type (@{$types{$m}}) {
            unless ($self->_isInArray(\@exclusions, $type) ||
                    $self->_isInArray(\@available_types, $type)) {
                push(@available_types, $type);
            }
        }
    }
    @available_types = sort @available_types;
    push(@available_types, 'other');

    return \@available_types;
}

=item _isInArray

=cut

sub _isInArray {
    my ( $self, $array, $element ) = @_;

    if ( !grep {$_ eq $element} @$array ) {
        return;
    }

    return 1;
}

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

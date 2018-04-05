package pfappserver::Model::Entitlement;

=head1 NAME

pfappserver::Model::Entitlement - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

use strict;
use warnings;

use Date::Parse;

use Moose;

use pf::log;
use pf::a3_entitlement;
use pf::node;

extends 'Catalyst::Model';

=head1 METHODS

=head2 list

Retrieve the list of entitlement keys currently installed on this system.

=cut

sub list_entitlement_keys {
    # return pf::a3_entitlement::find_all();
    my $entitlements = pf::a3_entitlement::find_all();

    if($entitlements) {
        my $now = time();

        foreach my $key (@$entitlements) {
            my $start = str2time($key->{sub_start});
            my $end   = str2time($key->{sub_end});

            if ($now < $start || $now > $end) {
                $key->{lic_status} = "notValidExpired"
            } elsif (($end - $now) <= 30 * 24 * 60 * 60) {
                $key->{lic_status} = "expiringSoon"
            } else {
                $key->{lic_status} = "";
            }
        }
    }
    return $entitlements;
}

=head2 apply

Apply a new entitlement key to this system.

=cut

sub apply_entitlement_key {
    my ( $self, $key ) = @_;
    my $logger = get_logger();

    $logger->info("Validating entitlement key $key...");

    # Send key to Aerohive to validate
    my $responseHash = pf::a3_entitlement::verify($key);

    if ($responseHash) {
        if ($responseHash->{err_status}) {
            $logger->warn("Got error response ($responseHash->{err_status}) for $key");
            return $responseHash;
        }
        else {
            # On success, save entitlement properties and return object
            if (pf::a3_entitlement::create($key, $responseHash)) {
                $logger->info("Total capacity is now " . $self->get_licensed_capacity());
                return pf::a3_entitlement::find_one($key);
            }
        }
    }

    return undef;
}

=head2 get

Find a specific entitlement key.

=cut

sub get_entitlement_key {
    my ( $self, $key ) = @_;

    return pf::a3_entitlement::find_one($key);
}

=head2 get_licensed_capacity

Get the total licensed endpoint capacity from active entitlements

=cut

sub get_licensed_capacity {
    my $total = 0;

    foreach my $entitlement (pf::a3_entitlement::find_active()) {
        $total += $entitlement->{endpoint_count};
    }

    return $total;
}

=head2 get_used_capacity

Get the current used endpoint capacity

=cut

sub get_used_capacity {
    return pf::node->node_count_all()->{nb} // 0;
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;

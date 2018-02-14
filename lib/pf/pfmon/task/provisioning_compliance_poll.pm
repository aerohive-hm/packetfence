package pf::pfmon::task::provisioning_compliance_poll;

=head1 NAME

pf::pfmon::task::provisioning_compliance_poll - class for pfmon task provisioning compliance poll

=cut

=head1 DESCRIPTION

pf::pfmon::task::provisioning_compliance_poll

=cut

use strict;
use warnings;
use Moose;
extends qw(pf::pfmon::task);

=head2 run

Polls each provisioner to enforce compliance

=cut

sub run {
    my ($self) = @_;
    foreach my $id (@{pf::ConfigStore::Provisioning->new->readAllIds}) {
        my $provisioner = pf::factory::provisioner->new($id);
        if($provisioner->supportsPolling){
            $provisioner->pollAndEnforce($self->interval);
        }
    }
}

=head1 AUTHOR


Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

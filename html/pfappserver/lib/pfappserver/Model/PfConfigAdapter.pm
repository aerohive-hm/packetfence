package pfappserver::Model::PfConfigAdapter;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use Try::Tiny;

use pf::log;
use pf::constants;
use pf::config qw(
    $management_network
    %Config
);
use pfconfig::manager;

=head1 NAME

pfappserver::Model::PfConfigAdapter - Catalyst Model

=head1 DESCRIPTION

A wrapper above pf::config to expose some of its feature. The longer term
plan is to migrate out of pf::config and all into Web Services.


=head2 getWebAdminIp

Returns the IP where the Web Administration interface runs.

Will prefer returning the virtual IP if there's one.

=cut

sub getWebAdminIp {
    my ($self) = @_;
    my $logger = get_logger();

    my $mgmt_net = $management_network;
    my $ip = undef;
    if ($mgmt_net) {
        $ip = (defined($mgmt_net->tag('vip'))) ? $mgmt_net->tag('vip') : $mgmt_net->tag('ip');
    }

    return $ip;
}

=head2 getWebAdminPort

Returns the port on which the Web Administration interface runs.

=cut

sub getWebAdminPort {
    my ($self) = @_;
    my $logger = get_logger();

    return $Config{'ports'}{'admin'};
}

=head2 reloadConfiguration

Tell pf::config to reload its configuration.

=cut

sub reloadConfiguration {
    my ($self) = @_;
    my $logger = get_logger();

    $logger->info("reloading PacketFence configuration");

    my $status = pfconfig::manager->new->expire_all;
    pf::config::configreload(1);

    $logger->info("done reloading PacketFence configuration");
    return $TRUE;

}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

package pfappserver::PacketFence::Controller::Config::DeviceRegistration;

=head1 NAME

pfappserver::PacketFence::Controller::Config::DeviceRegistration add documentation

=cut

=head1 DESCRIPTION

ConnectionDeviceRegistration

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;  # automatically turns on strict and warnings
use namespace::autoclean;
use pf::error;
use pf::config qw(%Profiles_Config);
use List::MoreUtils qw(any);

BEGIN {
    extends 'pfappserver::Base::Controller';
    with 'pfappserver::Base::Controller::Crud::Config';
    with 'pfappserver::Base::Controller::Crud::Config::Clone';
}

__PACKAGE__->config(
    action => {
        # Reconfigure the object dispatcher from pfappserver::Base::Controller::Crud
        object => { Chained => '/', PathPart => 'config/device_registration', CaptureArgs => 1 },
        # Configure access rights
        view   => { AdminRole => 'DEVICE_REGISTRATION_READ' },
        list   => { AdminRole => 'DEVICE_REGISTRATION_READ' },
        create => { AdminRole => 'DEVICE_REGISTRATION_CREATE' },
        clone  => { AdminRole => 'DEVICE_REGISTRATION_CREATE' },
        update => { AdminRole => 'DEVICE_REGISTRATION_UPDATE' },
        remove => { AdminRole => 'DEVICE_REGISTRATION_DELETE' },
    },
    action_args => {
        # Setting the global model and form for all actions
        '*' => { model => "Config::DeviceRegistration",form => "Config::DeviceRegistration" },
    },
);

=head1 METHODS

=head2 index

Usage: /config/provisioning

=cut

sub index :Path :Args(0) {
    my ($self, $c) = @_;
    $c->forward('list');
}

before [qw(remove)] => sub {
    my ($self, $c, @args) = @_;
    # We check that it's not used by any connection profile
    my $count = 0;
    while (my ($id, $config) = each %Profiles_Config) {
        $count ++ if ( any { $_ eq $c->stash->{'id'} } @{$config->{device_registration}});
    }

    if ($count > 0) {
        $c->response->status($STATUS::FORBIDDEN);
        $c->stash->{status_msg} = "This device registration is used by at least a Connection Profile.";
        $c->stash->{current_view} = 'JSON';
        $c->detach();
    }

};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

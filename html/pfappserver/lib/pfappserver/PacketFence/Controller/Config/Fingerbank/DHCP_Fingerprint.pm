package pfappserver::PacketFence::Controller::Config::Fingerbank::DHCP_Fingerprint;

=head1 NAME

pfappserver::PacketFence::Controller::Config::Fingerbank::DHCP_Fingerprint

=head1 DESCRIPTION

Controller for managing the fingerbank DHCP_Fingerprint data

=cut

use Moose;  # automatically turns on strict and warnings
use namespace::autoclean;

BEGIN {
    extends 'pfappserver::Base::Controller';
    with 'pfappserver::Base::Controller::Crud::Fingerbank';
}

__PACKAGE__->config(
    action => {
        # Reconfigure the object and scope actions from
        __PACKAGE__->action_defaults,
        scope  => { Chained => '/', PathPart => 'config/fingerbank/dhcp_fingerprint', CaptureArgs => 1 },
    },
    action_args => {
        # Setting the global model and form for all actions
        '*' => { model => __PACKAGE__->get_model_name , form => __PACKAGE__->get_form_name },
    },
);

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

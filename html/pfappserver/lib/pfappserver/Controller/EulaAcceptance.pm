package pfappserver::Controller::EulaAcceptance;

=head1 NAME

pfappserver::Controller::EulaAcceptance

=head1 DESCRIPTION

Place all customization for Controller::EulaAcceptance here

=cut

use Moose;

BEGIN { extends 'pfappserver::PacketFence::Controller::EulaAcceptance'; }

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;

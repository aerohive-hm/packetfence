package pfappserver::Controller::Entitlement;

=head1 NAME

pfappserver::Controller::Entitlement

=head1 DESCRIPTION

Place all customization for Controller::Entitlement here

=cut

use Moose;

BEGIN { extends 'pfappserver::PacketFence::Controller::Entitlement'; }

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;
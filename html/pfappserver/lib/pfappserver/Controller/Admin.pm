package pfappserver::Controller::Admin;

=head1 NAME

pfappserver::Controller::Admin

=head1 DESCRIPTION

Place all customization for Controller::Admin here

=cut

use Moose;

BEGIN { extends 'pfappserver::PacketFence::Controller::Admin'; }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

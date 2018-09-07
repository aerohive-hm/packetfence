package pfappserver::Controller::A3;

use Moose;

BEGIN { extends 'pfappserver::PacketFence::Controller::A3'; }

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

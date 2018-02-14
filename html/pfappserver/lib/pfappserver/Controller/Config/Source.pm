package pfappserver::Controller::Config::Source;

=head1 NAME

pfappserver::Controller::Config::Source

=head1 DESCRIPTION

Place all customization for Controller::Config::Source here

=cut

use Moose;

BEGIN { extends 'pfappserver::PacketFence::Controller::Config::Source'; }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

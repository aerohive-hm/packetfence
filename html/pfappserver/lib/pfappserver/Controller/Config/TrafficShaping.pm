package pfappserver::Controller::Config::TrafficShaping;

=head1 NAME

pfappserver::Controller::Config::TrafficShaping

=head1 DESCRIPTION

Place all customization for Controller::Config::TrafficShaping here

=cut

use Moose;

BEGIN { extends 'pfappserver::PacketFence::Controller::Config::TrafficShaping'; }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2015 Inverse inc.

=cut


__PACKAGE__->meta->make_immutable;

1;

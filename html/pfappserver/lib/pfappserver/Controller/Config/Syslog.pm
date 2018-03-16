package pfappserver::Controller::Config::Syslog;

=head1 NAME

pfappserver::Controller::Config::Syslog

=head1 DESCRIPTION

Place all customization for Controller::Config::Syslog here

=cut

use Moose;

BEGIN { extends 'pfappserver::PacketFence::Controller::Config::Syslog'; }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut


__PACKAGE__->meta->make_immutable;

1;

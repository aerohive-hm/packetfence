package pfappserver::Controller::Config::Fingerbank::DHCP6_Fingerprint;

=head1 NAME

pfappserver::Controller::Config::Fingerbank::DHCP6_Fingerprint

=head1 DESCRIPTION

Meant to override / customize Config::Fingerbank::DHCP6_Fingerprint controller.

Refer to L<pfappserver::PacketFence::Controller::Config::Fingerbank::DHCP6_Fingerprint>

=cut

use Moose;  # automatically turns on strict and warnings
use namespace::autoclean;

BEGIN { extends 'pfappserver::PacketFence::Controller::Config::Fingerbank::DHCP6_Fingerprint'; }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

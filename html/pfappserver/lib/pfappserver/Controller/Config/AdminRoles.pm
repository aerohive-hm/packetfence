package pfappserver::Controller::Config::AdminRoles;

=head1 NAME

pfappserver::Controller::Config::AdminRoles

=head1 DESCRIPTION

Place all customization for Controller::Config::AdminRoles here

=cut

use Moose;

BEGIN { extends 'pfappserver::PacketFence::Controller::Config::AdminRoles'; }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

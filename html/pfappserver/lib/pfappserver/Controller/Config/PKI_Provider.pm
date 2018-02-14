package pfappserver::Controller::Config::PKI_Provider;

=head1 NAME

pfappserver::Controller::Config::PKI_Provider

=head1 DESCRIPTION

Place all customization for Controller::Config::PKI_Provider here

=cut

use Moose;

BEGIN { extends 'pfappserver::PacketFence::Controller::Config::PKI_Provider'; }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

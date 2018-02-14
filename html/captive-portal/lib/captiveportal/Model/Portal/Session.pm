package captiveportal::Model::Portal::Session;
use Moose;

extends 'captiveportal::PacketFence::Model::Portal::Session';

=head1 NAME

captiveportal::Model::Portal::Session - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut


__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

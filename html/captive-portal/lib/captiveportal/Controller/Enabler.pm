package captiveportal::Controller::Enabler;
use Moose;

BEGIN { extends 'captiveportal::PacketFence::Controller::Enabler'; }

=head1 NAME

captiveportal::Controller::Enabler - Enabler Controller for captiveportal

=head1 DESCRIPTION

[enter your description here]

=cut

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

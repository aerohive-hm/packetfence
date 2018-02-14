package captiveportal::Form::Authentication;

=head1 NAME

captiveportal::Form::Authentication

=head1 DESCRIPTION

Form definition for the Authentication on the portal

=cut

use HTML::FormHandler::Moose;
extends 'captiveportal::PacketFence::Form::Authentication';

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

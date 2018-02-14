package captiveportal::Form::Field::AUP;

=head1 NAME

captiveportal::Form::Field::AUP

=head1 DESCRIPTION

AUP Field

=cut

use HTML::FormHandler::Moose;
extends 'captiveportal::PacketFence::Form::Field::AUP';

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

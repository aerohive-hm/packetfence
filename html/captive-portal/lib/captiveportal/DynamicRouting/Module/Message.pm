package captiveportal::DynamicRouting::Module::Message;
use Moose;

BEGIN { extends 'captiveportal::PacketFence::DynamicRouting::Module::Message'; }

=head1 NAME

captiveportal::DynamicRouting::Module::Message - Message Controller for captiveportal

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


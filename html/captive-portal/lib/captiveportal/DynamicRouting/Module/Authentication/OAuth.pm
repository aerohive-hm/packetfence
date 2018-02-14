package captiveportal::DynamicRouting::Module::Authentication::OAuth;
use Moose;

BEGIN { extends 'captiveportal::PacketFence::DynamicRouting::Module::Authentication::OAuth'; }

=head1 NAME

captiveportal::DynamicRouting::Module::Authentication::OAuth - OAuth Controller for captiveportal

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


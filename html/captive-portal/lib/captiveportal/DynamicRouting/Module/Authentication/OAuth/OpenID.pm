package captiveportal::DynamicRouting::Module::Authentication::OAuth::OpenID;
use Moose;

BEGIN { extends 'captiveportal::PacketFence::DynamicRouting::Module::Authentication::OAuth::OpenID'; }

=head1 NAME

captiveportal::DynamicRouting::Module::Authentication::OAuth::OpenID - OpenID Controller for captiveportal

=head1 DESCRIPTION

OpenID OAuth module

=cut

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;


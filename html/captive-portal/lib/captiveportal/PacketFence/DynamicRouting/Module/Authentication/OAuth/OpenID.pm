package captiveportal::PacketFence::DynamicRouting::Module::Authentication::OAuth::OpenID;

=head1 NAME

captiveportal::DynamicRouting::Module::Authentication::OAuth::OpenID

=head1 DESCRIPTION

OpenID OAuth module

=cut

use Moose;
extends 'captiveportal::DynamicRouting::Module::Authentication::OAuth';

has '+source' => (isa => 'pf::Authentication::Source::OpenIDSource');

has 'token_scheme' => (is => 'rw', default => sub {"auth-header:Bearer"});

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;


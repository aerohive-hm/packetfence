package pf::Authentication::Source::OpenIDSource;

=head1 NAME

pf::Authentication::Source::OpenIDSource

=head1 DESCRIPTION

=cut

use pf::log;
use Moose;
extends 'pf::Authentication::Source::OAuthSource';
with 'pf::Authentication::CreateLocalAccountRole';

has '+type' => (default => 'OpenID');
has '+class' => (default => 'external');
has 'client_id' => (isa => 'Str', is => 'rw', required => 1);
has 'client_secret' => (isa => 'Str', is => 'rw', required => 1);
has 'site' => (isa => 'Str', is => 'rw');
has 'access_token_path' => (isa => 'Str', is => 'rw');
has 'authorize_path' => (isa => 'Str', is => 'rw');
has 'scope' => (isa => 'Str', is => 'rw', default => 'openid');
has 'protected_resource_url' => (isa => 'Str', is => 'rw');
has 'redirect_url' => (isa => 'Str', is => 'rw', required => 1, default => 'https://<hostname>/oauth2/callback');
has 'domains' => (isa => 'Str', is => 'rw', required => 1);

=head2 dynamic_routing_module

Which module to use for DynamicRouting

=cut

sub dynamic_routing_module { 'Authentication::OAuth::OpenID' }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

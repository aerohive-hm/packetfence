package pf::Authentication::Source::GoogleSource;

=head1 NAME

pf::Authentication::Source::GoogleSource

=head1 DESCRIPTION

=cut

use pf::person;
use Moose;
extends 'pf::Authentication::Source::OAuthSource';
with 'pf::Authentication::CreateLocalAccountRole';

has '+type' => (default => 'Google');
has '+class' => (default => 'external');
has 'client_id' => (isa => 'Str', is => 'rw', required => 1, default => 'YOUR_API_ID.apps.googleusercontent.com');
has 'client_secret' => (isa => 'Str', is => 'rw', required => 1);
has 'site' => (isa => 'Str', is => 'rw', default => 'https://accounts.google.com');
has 'authorize_path' => (isa => 'Str', is => 'rw', default => '/o/oauth2/auth');
has 'access_token_path' => (isa => 'Str', is => 'rw', default => '/o/oauth2/token');
has 'access_token_param' => (isa => 'Str', is => 'rw', default => 'oauth_token');
has 'scope' => (isa => 'Str', is => 'rw', default => 'https://www.googleapis.com/auth/userinfo.email');
has 'protected_resource_url' => (isa => 'Str', is => 'rw', default => 'https://www.googleapis.com/oauth2/v2/userinfo');
has 'redirect_url' => (isa => 'Str', is => 'rw', required => 1, default => 'https://<hostname>/oauth2/callback');
has 'domains' => (isa => 'Str', is => 'rw', required => 1, default => '*.google.com,*.gstatic.com,googleapis.com,accounts.youtube.com,*.googleusercontent.com');

=head2 dynamic_routing_module

Which module to use for DynamicRouting

=cut

sub dynamic_routing_module { 'Authentication::OAuth::Google' }

=head2 lookup_from_provider_info

Lookup the person information from the authentication hash received during the OAuth process

=cut

sub lookup_from_provider_info {
    my ( $self, $pid, $info ) = @_;
    person_modify( $pid, firstname => $info->{given_name}, lastname => $info->{family_name}, email => $info->{email}, gender => $info->{gender} );
}

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

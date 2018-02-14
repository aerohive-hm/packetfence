package pf::Authentication::Source::PinterestSource;

=head1 NAME

pf::Authentication::Source::PinterestSource

=head1 DESCRIPTION

=cut

use pf::person;
use pf::log;
use Moose;
extends 'pf::Authentication::Source::OAuthSource';
with 'pf::Authentication::CreateLocalAccountRole';

has '+type' => (default => 'Pinterest');
has '+class' => (default => 'external');
has 'client_id' => (isa => 'Str', is => 'rw', required => 1);
has 'client_secret' => (isa => 'Str', is => 'rw', required => 1);
has 'site' => (isa => 'Str', is => 'rw', default => 'https://api.pinterest.com');
has 'authorize_path' => (isa => 'Str', is => 'rw', default => '/oauth/');
has 'access_token_path' => (isa => 'Str', is => 'rw', default => '/v1/oauth/token');
has 'access_token_param' => (isa => 'Str', is => 'rw', default => 'access_token');
has 'scope' => (isa => 'Str', is => 'rw', default => 'read_public');
has 'protected_resource_url' => (isa => 'Str', is => 'rw', default => 'https://api.pinterest.com/v1/me');
has 'redirect_url' => (isa => 'Str', is => 'rw', required => 1, default => 'https://<hostname>/oauth2/callback');
has 'domains' => (isa => 'Str', is => 'rw', required => 1, default => '*.pinterest.com,*.api.pinterest.com,*.akamaiedge.net,*.pinimg.com,*.fastlylb.net');

=head2 dynamic_routing_module

Which module to use for DynamicRouting

=cut

sub dynamic_routing_module { 'Authentication::OAuth::Pinterest' }

=head2 lookup_from_provider_info

Lookup the person information from the authentication hash received during the OAuth process

=cut

sub lookup_from_provider_info {
    my ( $self, $pid, $info ) = @_;

    person_modify( $pid, firstname => $info->{first_name}, lastname => $info->{last_name}, email => $info->{email} );
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

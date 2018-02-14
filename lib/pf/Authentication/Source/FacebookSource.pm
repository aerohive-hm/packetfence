package pf::Authentication::Source::FacebookSource;

=head1 NAME

pf::Authentication::Source::FacebookSource

=head1 DESCRIPTION

=cut

use pf::person;
use pf::log;
use Moose;
extends 'pf::Authentication::Source::OAuthSource';
with 'pf::Authentication::CreateLocalAccountRole';

has '+type' => (default => 'Facebook');
has '+class' => (default => 'external');
has 'client_id' => (isa => 'Str', is => 'rw', required => 1);
has 'client_secret' => (isa => 'Str', is => 'rw', required => 1);
has 'site' => (isa => 'Str', is => 'rw', default => 'https://graph.facebook.com');
has 'access_token_path' => (isa => 'Str', is => 'rw', default => '/oauth/access_token');
has 'access_token_param' => (isa => 'Str', is => 'rw', default => 'access_token');
has 'scope' => (isa => 'Str', is => 'rw', default => 'email');
has 'protected_resource_url' => (isa => 'Str', is => 'rw', default => 'https://graph.facebook.com/me?fields=id,name,email,first_name,last_name');
has 'redirect_url' => (isa => 'Str', is => 'rw', required => 1, default => 'https://<hostname>/oauth2/callback');
has 'domains' => (isa => 'Str', is => 'rw', required => 1, default => '*.facebook.com,*.fbcdn.net,*.akamaihd.net,*.akamaiedge.net,*.edgekey.net,*.akamai.net');

=head2 dynamic_routing_module

Which module to use for DynamicRouting

=cut

sub dynamic_routing_module { 'Authentication::OAuth::Facebook' }

=head2 lookup_from_provider_info

Lookup the person information from the authentication hash received during the OAuth process

=cut

sub lookup_from_provider_info {
    my ( $self, $pid, $info ) = @_;

    person_modify( $pid, firstname => $info->{first_name}, lastname => $info->{last_name}, email => $info->{email}, gender => $info->{gender}, birthday => $info->{birthday}, locale => $info->{locale} );
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

package pf::Authentication::Source::InstagramSource;

=head1 NAME

pf::Authentication::Source::InstagramSource

=head1 DESCRIPTION

This module implements methods for the Instagram source and the methods necessary
to perform the OAuth flow since Net::OAuth2 lacks support for Instagram OAuth.

=cut

use pf::person;
use pf::log;
use Moose;
extends 'pf::Authentication::Source::OAuthSource';
with 'pf::Authentication::CreateLocalAccountRole';

has '+type' => (default => 'Instagram');
has '+class' => (default => 'external');
has 'client_id' => (isa => 'Str', is => 'rw', required => 1);
has 'client_secret' => (isa => 'Str', is => 'rw', required => 1);
has 'site' => (isa => 'Str', is => 'rw', default => 'https://api.instagram.com');
has 'access_token_path' => (isa => 'Str', is => 'rw', default => '/oauth/access_token');
has 'access_token_param' => (isa => 'Str', is => 'rw', default => 'access_token');
has 'scope' => (isa => 'Str', is => 'rw', default => 'basic');
has 'protected_resource_url' => (isa => 'Str', is => 'rw', default => 'https://api.instagram.com/v1/users/self/?access_token=');
has 'redirect_url' => (isa => 'Str', is => 'rw', required => 1, default => 'https://<hostname>/oauth2/callback');
has 'domains' => (isa => 'Str', is => 'rw', required => 1, default => '*.instagram.com,*.cdninstagram.com,*.fbcdn.net');

=head2 dynamic_routing_module

Which module to use for DynamicRouting

=cut

sub dynamic_routing_module { 'Authentication::OAuth::Instagram' }

=head2 lookup_from_provider_info

Lookup the person information from the authentication hash received during the OAuth process

=cut

sub lookup_from_provider_info {
    my ( $self, $pid, $info ) = @_;
    
    my $full_name = $info->{data}{full_name};

    if (defined($full_name)) {
        my @fullname = split(/ /, $full_name);
        person_modify( $pid, firstname => shift @fullname );
        person_modify( $pid, lastname => join(' ', @fullname) );
    }
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

package pf::Authentication::Source::GithubSource;

=head1 NAME

pf::Authentication::Source::GithubSource

=head1 DESCRIPTION

=cut

use pf::person;
use Moose;
extends 'pf::Authentication::Source::OAuthSource';
with 'pf::Authentication::CreateLocalAccountRole';

has '+type' => (default => 'Github');
has '+class' => (default => 'external');
has 'scope' => (isa => 'Str', is => 'rw', default => 'user,user:email');
has 'client_id' => (isa => 'Str', is => 'rw', required => 1);
has 'client_secret' => (isa => 'Str', is => 'rw', required => 1);
has 'site' => (isa => 'Str', is => 'rw', default => 'https://github.com');
has 'authorize_path' => (isa => 'Str', is => 'rw', default => '/login/oauth/authorize');
has 'access_token_path' => (isa => 'Str', is => 'rw', default => '/login/oauth/access_token');
has 'access_token_param' => (isa => 'Str', is => 'rw', default => 'access_token');
has 'protected_resource_url' => (isa => 'Str', is => 'rw', default => 'https://api.github.com/user');
has 'redirect_url' => (isa => 'Str', is => 'rw', required => 1, default => 'https://<hostname>/oauth2/callback');
has 'domains' => (isa => 'Str', is => 'rw', required => 1, default => 'api.github.com,*.github.com,github.com');

=head2 dynamic_routing_module

Which module to use for DynamicRouting

=cut

sub dynamic_routing_module { 'Authentication::OAuth::Github' }

=head2 lookup_from_provider_info

Lookup the person information from the authentication hash received during the OAuth process

=cut

sub lookup_from_provider_info {
    my ( $self, $pid, $info ) = @_;
    my ($first_name, $last_name) = split(' ', $info->{name});
    person_modify( $pid, firstname => $first_name, lastname => $last_name, email => $info->{email} );
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

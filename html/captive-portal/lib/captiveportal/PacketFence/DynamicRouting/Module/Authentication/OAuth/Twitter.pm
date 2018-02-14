package captiveportal::PacketFence::DynamicRouting::Module::Authentication::OAuth::Twitter;

=head1 NAME

captiveportal::DynamicRouting::Module::Authentication::OAuth::Twitter

=head1 DESCRIPTION

Twitter OAuth module

=cut

use Moose;
extends 'captiveportal::DynamicRouting::Module::Authentication::OAuth';

has '+source' => (isa => 'pf::Authentication::Source::TwitterSource');

use pf::auth_log;
use pf::log;

=head2 get_client

The client is the TwitterSource class

=cut

sub get_client {
    my ($self) = @_;
    return $self->source;
}

=head2 get_token

Get the token through the TwitterSource class

=cut

sub get_token {
    my ($self) = @_;
    my $oauth_token = $self->app->request->parameters->{oauth_token};
    my $oauth_verifier = $self->app->request->parameters->{oauth_verifier}; 
    get_logger->info("Got token $oauth_token and verifier $oauth_verifier to finish authorization with Twitter");
    return  $self->get_client->get_access_token($oauth_token, $oauth_verifier);
}

=head2 handle_callback

Handle the callback through the TwitterSource class

=cut

sub handle_callback {
    my ($self) = @_;

    my $token = $self->get_token();
    return unless($token);

    my $pid = $token->{username}.'@twitter';
    $self->username($pid);

    get_logger->info("OAuth2 successfull for username ".$self->username);
    
    pf::auth_log::record_completed_oauth($self->source->type, $self->current_mac, $pid, $pf::auth_log::COMPLETED, $self->app->profile->name);

    $self->done();
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;


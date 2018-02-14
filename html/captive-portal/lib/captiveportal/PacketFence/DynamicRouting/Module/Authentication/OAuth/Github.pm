package captiveportal::PacketFence::DynamicRouting::Module::Authentication::OAuth::Github;

=head1 NAME

captiveportal::DynamicRouting::Module::Authentication::OAuth::Github

=head1 DESCRIPTION

Github OAuth module

=cut

use Moose;
extends 'captiveportal::DynamicRouting::Module::Authentication::OAuth';

has '+source' => (isa => 'pf::Authentication::Source::GithubSource');

has '+token_scheme' => (default => sub{"uri-query:access_token"});

=head2 _extract_username_from_response

Create a generic username if no e-mail is in the response

=cut

sub _extract_username_from_response {
    my ($self, $info) = @_;
    return $info->{email} || $info->{login}.'@github';
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;


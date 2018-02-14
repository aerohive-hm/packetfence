package captiveportal::PacketFence::DynamicRouting::Module::Authentication::OAuth::LinkedIn;

=head1 NAME

captiveportal::DynamicRouting::Module::Authentication::OAuth::LinkedIn

=head1 DESCRIPTION

LinkedIn OAuth module

=cut

use Moose;
extends 'captiveportal::DynamicRouting::Module::Authentication::OAuth';

has '+token_scheme' => (default => 'uri-query:oauth2_access_token');

has '+source' => (isa => 'pf::Authentication::Source::LinkedInSource');

=head2 _decode_response

The e-mail is returned as a quoted string

=cut

sub _decode_response {
    my ($self, $response) = @_;
    my $pid = $response->content();
    $pid =~ s/"//g;
    return {email => $pid};
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;


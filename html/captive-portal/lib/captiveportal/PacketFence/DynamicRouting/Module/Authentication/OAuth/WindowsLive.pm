package captiveportal::PacketFence::DynamicRouting::Module::Authentication::OAuth::WindowsLive;

=head1 NAME

captiveportal::DynamicRouting::Module::Authentication::OAuth::WindowsLive

=head1 DESCRIPTION

WindowsLive OAuth module

=cut

use Moose;
extends 'captiveportal::DynamicRouting::Module::Authentication::OAuth';

has '+token_scheme' => (default => "auth-header:Bearer");

has '+source' => (isa => 'pf::Authentication::Source::WindowsLiveSource');

=head2 _extract_username_from_response

Get the username from the response

=cut

sub _extract_username_from_response {
    my ($self, $info) = @_;
    return $info->{emails}->{account};
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;


package captiveportal::PacketFence::View::MobileConfig;

use strict;
use warnings;
use Moose;
extends 'captiveportal::View::HTML';
use pf::file_paths qw($install_dir);

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.xml',
    render_die         => 1,
    INCLUDE_PATH       => ["$install_dir/html/captive-portal/templates"]
);

after process => sub {
    my ($self, $c) = @_;
    my $headers = $c->response->headers;
    my $filename = $c->stash->{filename} || 'wireless-profile.mobileconfig';
    $headers->content_type('application/x-apple-aspen-config; chatset=utf-8');
    $headers->header('Content-Disposition', "attachment; filename=\"$filename\"");
    my $provisioner = $c->stash->{provisioner};
    if ($provisioner->can_sign_profile) {
        $c->response->body($provisioner->sign_profile($c->response->body));
    }

    #Logging the content body
    $c->log->trace(sub {$c->response->body});
};

=head1 NAME

captiveportal::View::MobileConfig - TT View for captiveportal

=head1 DESCRIPTION

TT View for captiveportal.

=head1 SEE ALSO

L<captiveportal>

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

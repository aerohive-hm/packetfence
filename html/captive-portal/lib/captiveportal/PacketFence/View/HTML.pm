package captiveportal::PacketFence::View::HTML;

use strict;
use warnings;
use Locale::gettext qw(gettext ngettext);
use Moose;
use utf8;
extends 'Catalyst::View';


=head2 process

Process the view using the informations in the stash

=cut

sub process {
    my ($self, $c) = @_;
    $c->stash->{application}->render($c->stash->{template}, $c->stash);
    $c->response->body($c->stash->{application}->template_output);
}

=head1 NAME

captiveportal::View::HTML - TT View for captiveportal

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

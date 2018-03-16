package pf::UnifiedApi::Controller::Ip4logs;

=head1 NAME

pf::UnifiedApi::Controller::Ip4logs -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Ip4logs

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::Crud';
use pf::ip4log;

has dal => 'pf::dal::ip4log';
has url_param_name => 'ip4log_id';
has primary_key => 'ip';

sub open {
    my ($self) = @_;
    my $search = $self->param('search');
    my @iplog = pf::ip4log::list_open($search);
    return $self->render(json => { item => $iplog[0] }) if $iplog[0];
    return $self->render(status => 404, json => { message => $self->status_to_error_msg(404) });
}

sub history {
    my ($self) = @_;
    my $search = $self->param('search');
    my @iplog = pf::ip4log::get_history($search);
    return $self->render(json => { items => \@iplog } ) if scalar @iplog > 0 and defined($iplog[0]);
    return $self->render(json => { items => [] });
}

sub archive {
    my ($self) = @_;
    my $search = $self->param('search');
    my @iplog = pf::ip4log::get_archive($search);
    return $self->render(json => { items => \@iplog } ) if scalar @iplog > 0 and defined($iplog[0]);
    return $self->render(json => { items => [] });
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

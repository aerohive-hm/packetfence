package pf::UnifiedApi::Controller::Ip6logs;

=head1 NAME

pf::UnifiedApi::Controller::Ip6logs -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Ip6logs

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::Crud';
use pf::ip6log;

has dal => 'pf::dal::ip6log';
has url_param_name => 'ip6log_id';
has primary_key => 'ip';

sub open {
    my ($self) = @_;
    my $search = $self->param('search');
    my @iplog = pf::ip6log::list_open($search);
    return $self->render(json => { item => $iplog[0] }) if $iplog[0];
    return $self->render(status => 404, json => { message => $self->status_to_error_msg(404) });
}

sub history {
    my ($self) = @_;
    my $search = $self->param('search');
    my @iplog = pf::ip6log::get_history($search);
    return $self->render(json => { items => \@iplog } ) if scalar @iplog > 0 and defined($iplog[0]);
    return $self->render(json => { items => [] });
}

sub archive {
    my ($self) = @_;
    my $search = $self->param('search');
    my @iplog = pf::ip6log::get_archive($search);
    return $self->render(json => { items => \@iplog } ) if scalar @iplog > 0 and defined($iplog[0]);
    return $self->render(json => { items => [] });
}

sub mac2ip {
    my ($self) = @_;
    my $mac = $self->param('mac');
    return $self->render(json => { ip => pf::ip6log::mac2ip($mac) });
}

sub ip2mac {
    my ($self) = @_;
    my $ip = $self->param('ip');
    return $self->render(json => { mac => pf::ip6log::ip2mac($ip) });
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

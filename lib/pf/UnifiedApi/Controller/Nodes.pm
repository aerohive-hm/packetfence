package pf::UnifiedApi::Controller::Nodes;

=head1 NAME

pf::UnifiedApi::Controller::Nodes -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Nodes

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::Crud';
use pf::dal::node;
use pf::locationlog qw(locationlog_history_mac locationlog_view_open_mac);

has dal => 'pf::dal::node';
has url_param_name => 'node_id';
has primary_key => 'mac';

sub latest_locationlog_by_mac {
    my ($self) = @_;
    my $mac = $self->param('mac');
    $self->render(json => locationlog_view_open_mac($mac));
}

sub locationlog_by_mac {
    my ($self) = @_;
    my $mac = $self->param('mac');
    $self->render(json => { items => [locationlog_history_mac($mac)]});
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


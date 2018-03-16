package pf::UnifiedApi::Controller::Violations;

=head1 NAME

pf::UnifiedApi::Controller::Violations -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Violations

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::Crud';
use pf::violation;

has dal => 'pf::dal::violation';
has url_param_name => 'violation_id';
has primary_key => 'id';

sub by_mac {
    my ($self) = @_;
    my $search = $self->param('search');
    return $self->_search_by_mac($search) if pf::util::valid_mac($search);
    $self->render_error(404, $self->status_to_error_msg(404));
}

sub _search_by_mac {
    my ($self, $mac) = @_;
    my @violations = pf::violation::violation_view_desc($mac);
    return $self->render(json => { items => \@violations }) if scalar @violations > 0 and defined($violations[0]);
    return $self->render(json => undef);
}

sub _search_by_id {
    my ($self, $id) = @_;
    my @violation = pf::violation::violation_view($id);
    return $self->render(json => { items => [ $violation[0] ] } ) if scalar @violation > 0 and defined($violation[0]);
    return $self->render(json => undef);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

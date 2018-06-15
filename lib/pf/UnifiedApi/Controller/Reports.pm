package pf::UnifiedApi::Controller::Reports;

=head1 NAME

pf::UnifiedApi::Controller::Reports -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Reports

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller';
use pf::pfcmd::report;

sub os_all {
    my ($self) = @_;
    $self->render(json => { items => [report_os_all()]});
}

sub os_range {
    my ($self) = @_;
    my $start = $self->_get_datetime($self->param('start'));
    my $end = $self->_get_datetime($self->param('end'));
    $self->render(json => { items => [report_os($start, $end)]});
}

sub os_active {
    my ($self) = @_;
    $self->render(json => { items => [report_os_active()]});
}

sub osclass_all {
    my ($self) = @_;
    $self->render(json => { items => [report_osclass_all()]});
}

sub osclass_active {
    my ($self) = @_;
    $self->render(json => { items => [report_osclass_active()]});
}

sub inactive_all {
    my ($self) = @_;
    $self->render(json => { items => [report_inactive_all()]});
}

sub active_all {
    my ($self) = @_;
    $self->render(json => { items => [report_active_all()]});
}

sub unregistered_all {
    my ($self) = @_;
    $self->render(json => { items => [report_unregistered_all()]});
}

sub unregistered_active {
    my ($self) = @_;
    $self->render(json => { items => [report_unregistered_active()]});
}

sub registered_all {
    my ($self) = @_;
    $self->render(json => { items => [report_registered_all()]});
}

sub registered_active {
    my ($self) = @_;
    $self->render(json => { items => [report_registered_active()]});
}

sub unknownprints_all {
    my ($self) = @_;
    $self->render(json => { items => [report_unknownprints_all()]});
}

sub unknownprints_active {
    my ($self) = @_;
    $self->render(json => { items => [report_unknownprints_active()]});
}

sub statics_all {
    my ($self) = @_;
    $self->render(json => { items => [report_statics_all()]});
}

sub statics_active {
    my ($self) = @_;
    $self->render(json => { items => [report_statics_active()]});
}

sub openviolations_all {
    my ($self) = @_;
    $self->render(json => { items => [report_openviolations_all()]});
}

sub openviolations_active {
    my ($self) = @_;
    $self->render(json => { items => [report_openviolations_active()]});
}

sub connectiontype_all {
    my ($self) = @_;
    $self->render(json => { items => [report_connectiontype_all()]});
}

sub connectiontype_range {
    my ($self) = @_;
    my $start = $self->_get_datetime($self->param('start'));
    my $end = $self->_get_datetime($self->param('end'));
    $self->render(json => { items => [report_connectiontype($start, $end)]});
}

sub connectiontype_active {
    my ($self) = @_;
    $self->render(json => { items => [report_connectiontype_active()]});
}

sub connectiontypereg_all {
    my ($self) = @_;
    $self->render(json => { items => [report_connectiontypereg_all()]});
}

sub connectiontypereg_active {
    my ($self) = @_;
    $self->render(json => { items => [report_connectiontypereg_active()]});
}

sub ssid_all {
    my ($self) = @_;
    $self->render(json => { items => [report_ssid_all()]});
}

sub ssid_range {
    my ($self) = @_;
    my $start = $self->_get_datetime($self->param('start'));
    my $end = $self->_get_datetime($self->param('end'));
    $self->render(json => { items => [report_ssid($start, $end)]});
}

sub ssid_active {
    my ($self) = @_;
    $self->render(json => { items => [report_ssid_active()]});
}

sub osclassbandwidth_all {
    my ($self) = @_;
    $self->render(json => { items => [report_osclassbandwidth_all()]});
}

sub osclassbandwidth_range {
    my ($self) = @_;
    my $start = $self->_get_datetime($self->param('start'));
    my $end = $self->_get_datetime($self->param('end'));
    $self->render(json => { items => [report_osclassbandwidth($start, $end)]});
}

sub osclassbandwidth_day {
    my ($self) = @_;
    $self->render(json => { items => [report_osclassbandwidth_day()]});
}

sub osclassbandwidth_week {
    my ($self) = @_;
    $self->render(json => { items => [report_osclassbandwidth_week()]});
}

sub osclassbandwidth_month {
    my ($self) = @_;
    $self->render(json => { items => [report_osclassbandwidth_month()]});
}

sub osclassbandwidth_year {
    my ($self) = @_;
    $self->render(json => { items => [report_osclassbandwidth_year()]});
}

sub nodebandwidth_all {
    my ($self) = @_;
    $self->render(json => { items => [report_nodebandwidth_all()]});
}

sub nodebandwidth_range {
    my ($self) = @_;
    my $start = $self->_get_datetime($self->param('start'));
    my $end = $self->_get_datetime($self->param('end'));
    $self->render(json => { items => [report_nodebandwidth($start, $end)]});
}

sub topauthenticationfailures_by_mac {
    my ($self) = @_;
    my $start = $self->_get_datetime($self->param('start'));
    my $end = $self->_get_datetime($self->param('end'));
    $self->render(json => { items => [report_topauthenticationfailures_by_mac($start, $end)]});
}

sub topauthenticationfailures_by_ssid {
    my ($self) = @_;
    my $start = $self->_get_datetime($self->param('start'));
    my $end = $self->_get_datetime($self->param('end'));
    $self->render(json => { items => [report_topauthenticationfailures_by_ssid($start, $end)]});
}

sub topauthenticationfailures_by_username {
    my ($self) = @_;
    my $start = $self->_get_datetime($self->param('start'));
    my $end = $self->_get_datetime($self->param('end'));
    $self->render(json => { items => [report_topauthenticationfailures_by_username($start, $end)]});
}

sub topauthenticationsuccesses_by_mac {
    my ($self) = @_;
    my $start = $self->_get_datetime($self->param('start'));
    my $end = $self->_get_datetime($self->param('end'));
    $self->render(json => { items => [report_topauthenticationsuccesses_by_mac($start, $end)]});
}

sub topauthenticationsuccesses_by_ssid {
    my ($self) = @_;
    my $start = $self->_get_datetime($self->param('start'));
    my $end = $self->_get_datetime($self->param('end'));
    $self->render(json => { items => [report_topauthenticationsuccesses_by_ssid($start, $end)]});
}

sub topauthenticationsuccesses_by_username {
    my ($self) = @_;
    my $start = $self->_get_datetime($self->param('start'));
    my $end = $self->_get_datetime($self->param('end'));
    $self->render(json => { items => [report_topauthenticationsuccesses_by_username($start, $end)]});
}

sub topauthenticationsuccesses_by_computername {
    my ($self) = @_;
    my $start = $self->_get_datetime($self->param('start'));
    my $end = $self->_get_datetime($self->param('end'));
    $self->render(json => { items => [report_topauthenticationsuccesses_by_computername($start, $end)]});
}

sub _get_datetime {
    my ($self, $datetime) = @_;
    return $datetime;
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


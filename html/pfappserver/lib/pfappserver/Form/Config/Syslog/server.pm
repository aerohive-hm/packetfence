package pfappserver::Form::Config::Syslog::server;

=head1 NAME

pfappserver::Form::Config::Syslog::server -

=cut

=head1 DESCRIPTION

pfappserver::Form::Config::Syslog::server

=cut

use strict;
use warnings;
use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Syslog';
with 'pfappserver::Base::Form::Role::Help';

has_field proto => (
    type => 'Select',
    options => [{label => 'udp', value => 'udp'}, {label => 'tcp', value => 'tcp'}],
    required => 1,
);

has_field host => (
    type => 'Text',
    required => 1,
);

has_field port => (
    type => 'PosInteger',
    default => '514',
    required => 1,
);

has_block definition =>
  (
    render_list => [qw(type proto host port all_logs logs)],
  );

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


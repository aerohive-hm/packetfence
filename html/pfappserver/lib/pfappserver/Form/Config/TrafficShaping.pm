package pfappserver::Form::Config::TrafficShaping;

=head1 NAME

pfappserver::Form::Config::TrafficShaping - Web form for to assign a download/upload limit

=head1 DESCRIPTION

Form definition to create or update an download/upload limit

=cut

use strict;
use warnings;
use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';

use pf::log;

my $BANDWIDTH_CHECK = qr/\d+(KB|MB|GB|TB|PB)?/;
my $BANDWIDTH_CHECK_FAIL_MSG = "Bandwidth must be in the following format 'nXY' where XY is one of the following KB,MB,GB,TB,PB";

## Definition
has_field 'id' =>
  (
   type => 'Text',
   label => 'Role',
   required => 1,
   messages => { required => 'The role to apply traffic shaping' },
  );
has_field 'upload' =>
  (
   type => 'Text',
   apply => [ { check => $BANDWIDTH_CHECK, message => $BANDWIDTH_CHECK_FAIL_MSG } ],
   tags => { after_element => \&help,
             help => $BANDWIDTH_CHECK_FAIL_MSG },
  );
has_field 'download' =>
  (
   type => 'Text',
   apply => [ { check => $BANDWIDTH_CHECK, message => $BANDWIDTH_CHECK_FAIL_MSG } ],
   tags => { after_element => \&help,
             help => $BANDWIDTH_CHECK_FAIL_MSG },
  );

has_block  definition =>
  (
    render_list => [qw(upload download)],
  );

=head1 COPYRIGHT

Copyright (C) 2005-2015 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable;
1;

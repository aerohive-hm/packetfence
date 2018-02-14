package pfappserver::Form::Config::Pfdetect;

=head1 NAME

pfappserver::Form::Config::Pfdetect - Web form for a pfdetect detector

=head1 DESCRIPTION

Form definition to create or update a pfdetect detector.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';

use pf::config;
use pf::util;
use pf::constants::pfdetect qw(@PFDETECT_PARSERS);

## Definition
has_field 'id' =>
  (
   type => 'Text',
   label => 'Detector',
   required => 1,
   messages => { required => 'Please specify a detector id' },
   apply => [ pfappserver::Base::Form::id_validator('detector id') ]
  );

=head2 status

status

=cut

has_field 'status' => (
    type            => 'Toggle',
    label           => 'Enabled',
    checkbox_value  => 'enabled',
    unchecked_value => 'disabled',
    default => 'enabled',
);

has_field 'path' =>
  (
   type => 'Text',
   label => 'Alert pipe',
   required => 1,
   messages => { required => 'Please specify an alert pipe' },
  );

has_field 'type' =>
  (
   type => 'Hidden',
   required => 1,
  );

has_block definition =>
  (
   render_list => [ qw(id type status path) ],
  );

=over

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

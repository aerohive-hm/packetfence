package pfappserver::Form::Config::SwitchGroup;

=head1 NAME

pfappserver::Form::Config::Switch - Web form for a switch

=head1 DESCRIPTION

Form definition to create or update a network switch.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Switch';

## Definition

=head2 id

Override the field from switch to change the label

=cut

has_field 'id' =>
  (
   type => 'Text',
   label => 'Group name',
   required => 1,
   messages => { required => 'Please specify a group name' },
   apply => [ pfappserver::Base::Form::id_validator('group name') ]
  );

=head2 group

Overide the field from switch so a group cannot be specified

=cut

has_field 'group' =>
  (
   type => 'Hidden',
   value => '',
   default => '',
  );


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

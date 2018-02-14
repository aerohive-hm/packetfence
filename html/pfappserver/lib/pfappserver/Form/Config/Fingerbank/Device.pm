package pfappserver::Form::Config::Fingerbank::Device;

=head1 NAME

pfappserver::Form::Config::Fingerbank::Device

=head1 DESCRIPTION

Web form for Fingerbank devices

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';

## Definition
has_field 'id' =>
  (
   type => 'Text',
   label => 'Id',
   readonly => 1,
  );

has_field 'parent_id' => 
  (
   type => 'FingerbankField',
   label => 'Parent device',
   fingerbank_model => "fingerbank::Model::Device",
  );

has_field name =>
  (
   type => 'Text',
   required => 1,
  );

has_field [qw(mobile tablet)] =>
  (
   type => 'Toggle',
  );

has_field created_at =>
  (
  type => 'Uneditable',
  );

has_field updated_at =>
  (
  type => 'Uneditable',
  );

has_block definition =>
  (
    render_list => [qw(name parent_id mobile tablet created_at updated_at)],
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

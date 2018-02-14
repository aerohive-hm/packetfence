package pfappserver::Form::Config::Fingerbank::MAC_Vendor;

=head1 NAME

pfappserver::Form::Config::Fingerbank::MAC_Vendor

=head1 DESCRIPTION

Web form for Fingerbank MAC Vendor

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';

## Definition
has_field 'id' =>
  (
   type => 'Text',
   label => 'ID',
   readonly => 1,
  );

has_field 'name' =>
  (
   type => 'Text',
   label => 'Vendor',
  );

has_field 'mac' =>
  (
   type => 'Text',
   label => 'OUI',
   tags => { after_element => \&help,
             help => 'The OUI is the first six digits or letters of a MAC address. They must be entered without any space or separator (ex: 001122).' },
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
    render_list => [qw(name mac created_at updated_at)],
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

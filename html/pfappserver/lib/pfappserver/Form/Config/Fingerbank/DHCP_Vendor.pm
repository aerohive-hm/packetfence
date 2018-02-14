package pfappserver::Form::Config::Fingerbank::DHCP_Vendor;

=head1 NAME

pfappserver::Form::Config::Fingerbank::DHCP_Vendor

=head1 DESCRIPTION

Web form for Fingerbank DHCP Vendor

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';

## Definition
has_field 'id' =>
  (
   type => 'Text',
   label => 'ID',
   readonly => 1,
  );

has_field 'value' =>
  (
   type => 'Text',
   label => 'Value',
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
    render_list => [qw(value created_at updated_at)],
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

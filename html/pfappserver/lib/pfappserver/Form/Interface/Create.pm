package pfappserver::Form::Interface::Create;

=head1 NAME

pfappserver::Form::Interface::Create - Web form to add a VLAN

=head1 DESCRIPTION

Form definition to add a VLAN to a network interface.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Interface';
with 'pfappserver::Base::Form::Role::Help';


# Form fields
has_field 'vlan' =>
  (
   type => 'Text',
   label => 'Virtual LAN ID',
   required => 1,
   messages => { required => 'Please specify a VLAN ID.' },
   tags => { after_element => \&help,
             help => 'VLAN ID (must be a number below 4096)' },
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

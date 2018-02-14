package pfappserver::Form::Config::FloatingDevice;

=head1 NAME

pfappserver::Form::Config::FloatingDevice - Web form for a floating device

=head1 DESCRIPTION

Form definition to create or update a floating network device.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';

use pf::config;
use pf::util;

## Definition
has_field 'id' =>
  (
   type => 'MACAddress',
   label => 'MAC Address',
   accept => ['default'],
   required => 1,
   messages => { required => 'Please specify the MAC address of the floating device.' },
  );
has_field 'ip' =>
  (
   type => 'IPAddress',
   label => 'IP Address',
  );
has_field 'pvid' =>
  (
   type => 'PosInteger',
   label => 'Native VLAN',
   required => 1,
   tags => { after_element => \&help,
             help => 'VLAN in which PacketFence should put the port' },
  );
has_field 'trunkPort' =>
  (
   type => 'Checkbox',
   label => 'Trunk Port',
   checkbox_value => 'yes',
   tags => { after_element => \&help,
             help => 'The port must be configured as a muti-vlan port' },
  );
has_field 'taggedVlan' =>
  (
   type => 'Text',
   label => 'Tagged VLANs',
   tags => { after_element => \&help,
             help => 'Comma separated list of VLANs. If the port is a multi-vlan, these are the VLANs that have to be tagged on the port.' },
  );

=head2 Methods

=over

=item validate

Make sure some tagged VLANs are defined when trunk port is enabled.

=cut

sub validate {
    my $self = shift;

    if ($self->value->{'trunkPort'} eq 'yes') {
        unless ($self->value->{'taggedVlan'} =~ m/^(\d+,)*\d+$/) {
            $self->field('taggedVlan')->add_error("Please specify the VLANs to be tagged on the port.");
        }
    }
}

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

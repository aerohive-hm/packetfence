package pfappserver::Form::Config::Network;

=head1 NAME

pfappserver::Form::Interface - Web form for a network

=head1 DESCRIPTION

Form definition to update a default network.

=cut

use pf::util;

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';

has 'network' => ( is => 'ro' );

has_field 'type' =>
  (
   type => 'Hidden',
  );
has_field 'dhcp_start' =>
  (
   type => 'IPAddress',
   label => 'Starting IP Address',
   required_when => { 'fake_mac_enabled' => sub { $_[0] ne '1' } },
   messages => { required => 'Please specify the starting IP address of the DHCP scope.' },
  );
has_field 'dhcp_end' =>
  (
   type => 'IPAddress',
   label => 'Ending IP Address',
   required_when => { 'fake_mac_enabled' => sub { $_[0] ne '1' } },
   messages => { required => 'Please specify the ending IP address of the DHCP scope.' },
  );
has_field 'dhcp_default_lease_time' =>
  (
   type => 'PosInteger',
   label => 'Default Lease Time',
   required_when => { 'fake_mac_enabled' => sub { $_[0] ne '1' } },
   messages => { required => 'Please specify the default DHCP lease time.' },
  );
has_field 'dhcp_max_lease_time' =>
  (
   type => 'PosInteger',
   label => 'Max Lease Time',
   required_when => { 'fake_mac_enabled' => sub { $_[0] ne '1' } },
   messages => { required => 'Please specify the maximum DHCP lease time.' },
  );
has_field 'dns' =>
  (
   type => 'IPAddresses',
   label => 'DNS Server',
   required_when => { 'fake_mac_enabled' => sub { $_[0] ne '1' } },
   messages => { required => "Please specify the DNS server's IP address(es)." },
   tags => { after_element => \&help,
             help => 'Should match the IP of a registration interface or the production DNS server if the network is Inline L3' },
  );

=head2 validate

Make sure the ending DHCP IP address is after the starting DHCP IP address.

Make sure the max lease time is higher than the default lease time.

=cut

sub validate {
    my $self = shift;

    if ($self->value->{dhcp_start} && $self->value->{dhcp_end}
        && ip2int($self->value->{dhcp_start}) >= ip2int($self->value->{dhcp_end})) {
        $self->field('dhcp_end')->add_error('The ending DHCP address must be greater than the starting DHCP address.');
    }
    if ($self->value->{dhcp_default_lease_time} && $self->value->{dhcp_max_lease_time}
        && $self->value->{dhcp_default_lease_time} > $self->value->{dhcp_max_lease_time}) {
        $self->field('dhcp_max_lease_time')->add_error('The maximum lease time must be greater than the default lease time.');
    }
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

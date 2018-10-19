package pfappserver::Form::Interface;

=head1 NAME

pfappserver::Form::Interface - Web form for a network interface

=head1 DESCRIPTION

Form definition to create or update a network interface.

=cut

use HTML::FormHandler::Moose;
use List::MoreUtils qw(firstidx any);

extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';

# Form select options
has 'types' => ( is => 'ro' );

has_field 'name' =>
  (
   type => 'Hidden',
  );
has_field 'ipaddress' =>
  (
   type => 'IPAddress',
   label => 'IPv4 Address',
  );
has_field 'netmask' =>
  (
   type => 'IPAddress',
   label => 'IPv4 Netmask',
   element_attr => { 'placeholder' => '255.255.255.0' },
  );
has_field 'ipv6_address' => (
    type => 'IP6Address',
    label => 'IPv6 Address',
);
has_field 'ipv6_prefix' => (
    type=> 'Text',
    label => 'IPv6 Prefix',
);
has_field 'type' =>
  (
   type => 'Select',
   label => 'Type',
   element_class => ['chzn-deselect'],
   element_attr => { 'data-placeholder' => 'None' },
  );
has_field 'additional_listening_daemons' => (
    type            => 'Select',
    multiple        => 1,
    label           => 'Additional listening daemon(s)',
    options_method  => \&options_additional_listening_daemons,
    element_class   => [ 'chzn-select' ],
    element_attr    => {
        'data-placeholder' => 'Click to add a daemon',
    },
);
has_field 'dns' =>
  (
   type => 'IPAddresses',
   label => 'DNS',
   wrapper_attr => { 'class' => 'hide' },
   tags => { after_element => \&help,
             help => 'The primary DNS server of your network.' },
  );

has_field 'dhcpd_enabled' =>
   (
    type => 'Toggle',
    checkbox_value => 1,
    default => 1,
    label => 'Enable DHCP Server',
   );

has_field 'high_availability' =>
   (
    type => 'Toggle',
    checkbox_value => 1,
    unchecked_value => 0,
    default => 0,
   );

has_field 'nat_enabled' => (
    type => 'Toggle',
    checkbox_value => 1,
    unchecked_value => 0,
    default => 1,
    label => 'Enable NATting',
);

has_field 'split_network' => (
    type => 'Toggle',
    checkbox_value => 1,
    unchecked_value => 0,
    default => 0,
    label => 'Split network by role',
    tags => { after_element => \&help,
             help => 'This will create a small network for each roles.' },
);

has_field 'reg_network' =>
  (
   type => 'Text',
   label => 'Registration IP Address CIDR format',
   tags => { after_element => \&help,
             help => 'When split network by role is enabled then this network will be used as the registration network (example: 192.168.0.1/24).' },
  );


=head2 options_type

=cut

sub options_type {
    my $self = shift;

    # $self->types comes from pfappserver::Model::Enforcement->getAvailableTypes
    my @types;
    if ( defined $self->types ) {
        for my $type ( @{$self->types} ) {
            # we remove inline, even though it may still be in pf.conf for backwards compatibility reasons.
            next if ($type eq 'inline' || $type eq 'inlinel3');
            push @types, ( $type => $self->_localize($type) );
        }
    }


    return ('none' => 'None', @types);
}

=head2 options_additional_listening_daemons

=cut

sub options_additional_listening_daemons {
    my $self = shift;

    return map { { value => $_, label => $_ } }
        qw(portal radius);
}

=head2 validate

Force DNS to be defined when the 'inline' type is selected

=cut

sub validate {
    my $self = shift;

    if (defined $self->value->{type} &&
        ( $self->value->{type} eq 'inlinel2' or
          $self->value->{type} eq 'inline' )
        ) {
        unless ($self->value->{dns}) {
            $self->field('dns')->add_error('Please specify your DNS server.');
        }
    }

    # Remove 'portal' additional listening daemon on already enabled httpd.portal interfaces
    # TODO: Make a list of interface type rather than this ugly "or" - dwuelfrath@inverse.ca 2015.06.11
    my @types = qw(vlan-registration vlan-isolation dns-enforcement inline inlinel2 portal);
    if ( defined $self->value->{type} && any { $_ eq $self->value->{type} } @types ) {
        my %daemons = map { $_ => 1 } @{$self->value->{additional_listening_daemons}};
        if ( exists($daemons{'portal'}) ) {
            my $index = firstidx { $_ eq 'portal' } @{$self->value->{additional_listening_daemons}};
            splice @{$self->value->{additional_listening_daemons}}, $index, 1;
        }
    }
    # Remove double radius type if exist
    @types = qw(radius);
    if ( defined $self->value->{type} && any { $_ eq $self->value->{type} } @types ) {
        my %daemons = map { $_ => 1 } @{$self->value->{additional_listening_daemons}};
        if ( exists($daemons{'radius'}) ) {
            my $index = firstidx { $_ eq 'radius' } @{$self->value->{additional_listening_daemons}};
            splice @{$self->value->{additional_listening_daemons}}, $index, 1;
        }
    }
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

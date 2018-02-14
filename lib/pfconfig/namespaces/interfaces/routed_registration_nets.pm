package pfconfig::namespaces::interfaces::routed_registration_nets;

=head1 NAME

pfconfig::namespaces::interfaces::routed_registration_nets

=cut

=head1 DESCRIPTION

pfconfig::namespaces::interfaces::routed_registration_nets

=cut

use strict;
use warnings;
use pfconfig::namespaces::config::Network;

use base 'pfconfig::namespaces::interfaces';

sub init {
    my ($self) = @_;
    $self->{network_config} = $self->{cache}->get_cache('config::Network');
}

sub build {
    my ($self)                   = @_;
    my %ConfigNetworks           = %{ $self->{network_config} };
    my @routed_registration_nets = ();
    foreach my $network ( keys %ConfigNetworks ) {
        my $type = $ConfigNetworks{$network}{type};
        if ( pfconfig::namespaces::config::Network::is_network_type_vlan_reg($type) ) {
            my $registration_obj = new Net::Netmask( $network, $ConfigNetworks{$network}{'netmask'} );
            push @routed_registration_nets, $registration_obj;
        }
    }
    return \@routed_registration_nets;
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:


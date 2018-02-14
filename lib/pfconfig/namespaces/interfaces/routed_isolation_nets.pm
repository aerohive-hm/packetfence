package pfconfig::namespaces::interfaces::routed_isolation_nets;

=head1 NAME

pfconfig::namespaces::interfaces::routed_isolation_nets

=cut

=head1 DESCRIPTION

pfconfig::namespaces::interfaces::routed_isolation_nets

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
    my ($self)                = @_;
    my %ConfigNetworks        = %{ $self->{network_config} };
    my @routed_isolation_nets = ();
    foreach my $network ( keys %ConfigNetworks ) {
        my $type = $ConfigNetworks{$network}{type};
        if ( pfconfig::namespaces::config::Network::is_network_type_vlan_isol($type) ) {
            my $isolation_obj = new Net::Netmask( $network, $ConfigNetworks{$network}{'netmask'} );
            push @routed_isolation_nets, $isolation_obj;
        }
    }
    return \@routed_isolation_nets;
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


package pfconfig::namespaces::interfaces::inline_nets;

=head1 NAME

pfconfig::namespaces::interfaces::inline_nets

=cut

=head1 DESCRIPTION

pfconfig::namespaces::interfaces::inline_nets

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
    my ($self)         = @_;
    my %ConfigNetworks = %{ $self->{network_config} };
    my @inline_nets    = ();
    foreach my $network ( keys %ConfigNetworks ) {
        my $type = $ConfigNetworks{$network}{type};
        if ( pfconfig::namespaces::config::Network::is_network_type_inline($type) ) {
            my $inline_obj = new Net::Netmask( $network, $ConfigNetworks{$network}{'netmask'} );
            push @inline_nets, $inline_obj;
        }
    }
    return \@inline_nets;
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


package pfconfig::namespaces::resource::domain_dns_servers;

=head1 NAME

pfconfig::namespaces::resource::domain_dns_servers

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::domain_dns_servers

This module create an associative hash between a domain and it's DNS server

=cut

use strict;
use warnings;
use pf::util;

use base 'pfconfig::namespaces::resource';

sub init {
    my ($self) = @_;

    # we depend on the switch configuration object (russian doll style)
    $self->{domains} = $self->{cache}->get_cache('config::Domain');
}

sub build {
    my ($self) = @_;
    my %ConfigDomain = %{$self->{domains}};
    my %domain_dns_servers;
    foreach my $key ( keys %ConfigDomain ) {
        $domain_dns_servers{$ConfigDomain{$key}->{dns_name}} = [ split(/\s*,\s*/, $ConfigDomain{$key}->{dns_servers}) ] if (isenabled($ConfigDomain{$key}->{registration}));
    }
    return \%domain_dns_servers;
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


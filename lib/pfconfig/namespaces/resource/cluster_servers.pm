package pfconfig::namespaces::resource::cluster_servers;

=head1 NAME

pfconfig::namespaces::resource::fqdn

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::fqdn

=cut

use strict;
use warnings;

use pfconfig::namespaces::config::Cluster;

use base 'pfconfig::namespaces::resource';

sub init {
    my ($self) = @_;

    $self->{cluster_resource} = pfconfig::namespaces::config::Cluster->new($self->{cache});
}

sub build {
    my ($self) = @_;
    my @cluster_ips;
    $self->{cluster_resource}->build();

    return $self->{cluster_resource}->{_servers};
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


package pfconfig::namespaces::resource::cluster_hosts;

=head1 NAME

pfconfig::namespaces::resource::fqdn

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::fqdn

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::resource';
use pfconfig::namespaces::config::Cluster;

sub init {
    my ($self) = @_;

    $self->{cluster_resource} = pfconfig::namespaces::config::Cluster->new($self->{cache});
}

sub build {
    my ($self) = @_;
    my @cluster_ips;
    $self->{cluster_resource}->build();

    my @cluster_hosts = map { $_->{host} } @{$self->{cluster_resource}->{_servers}};

    return \@cluster_hosts;
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


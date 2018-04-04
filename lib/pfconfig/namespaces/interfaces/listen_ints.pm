package pfconfig::namespaces::interfaces::listen_ints;

=head1 NAME

pfconfig::namespaces::interfaces::listen_ints

=cut

=head1 DESCRIPTION

pfconfig::namespaces::interfaces::listen_ints

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::interfaces';

sub init {
    my ($self, $host_id) = @_;
    $self->{child_resources} = [ 'config::Stats' ];

    $self->{_interfaces} = defined($host_id) ? $self->{cache}->get_cache("interfaces($host_id)") : $self->{cache}->get_cache("interfaces");
}

sub build {
    my ($self) = @_;

    return $self->{_interfaces}->{listen_ints};
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


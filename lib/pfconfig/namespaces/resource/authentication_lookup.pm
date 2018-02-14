package pfconfig::namespaces::resource::authentication_lookup;

=head1 NAME

pfconfig::namespaces::resource::authentication_lookup

=head1 DESCRIPTION

pfconfig::namespaces::resource::authentication_lookup

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::resource';

sub init {
    my ($self) = @_;
    $self->{_authentication_config} = $self->{cache}->get_cache('config::Authentication');
}

sub build {
    my ($self) = @_;

    return $self->{_authentication_config}->{authentication_lookup};
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


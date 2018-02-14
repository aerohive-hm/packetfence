package pfconfig::namespaces::resource::Database;

=head1 NAME

pfconfig::namespaces::resource::Database

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::Database

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::resource';

sub init {
    my ($self) = @_;
    $self->{config} = $self->{cache}->get_cache('config::Pf');
}

sub build {
    my ($self) = @_;

    my %Config = %{ $self->{config} };
    return $Config{'database'};
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


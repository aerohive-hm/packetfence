package pfconfig::memory_cached;

=head1 NAME

pfconfig::memory_cached

=cut

=head1 DESCRIPTION

pfconfig::memory_cached

This module is used to compute values and tie them to a pfconfig namespace so they are only created when the pfconfig namespace gets updated

This stores the objects in memory (subcache) and flushes them whenever the pfconfig namespace its tied to expires

=cut

=head1 USAGE

=cut

use strict;
use warnings;

use pf::log;
use pfconfig::cached;
our @ISA = ( 'pfconfig::cached' );

=head2 init

Constructor

=cut

sub init {
    my ( $self, @namespaces ) = @_;

    $self->{"_namespaces"} = \@namespaces;

    return $self;
}

=head2 is_valid

Method that is used to determine if the object has been refreshed in pfconfig
Uses the control files in var/control and the memorized_at hash to know if a namespace has expired

This is overriden for the support of the mutli-namespace

=cut

sub is_valid {
    my ($self)         = @_;
    foreach my $namespace (@{$self->{_namespaces}}) {
        $self->{_namespace} = $namespace;
        $self->{"_control_file_path"} = pfconfig::util::control_file_path($namespace);
        return 0 unless($self->SUPER::is_valid());
    }
    return 1;
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



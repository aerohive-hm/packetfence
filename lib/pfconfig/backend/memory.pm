package pfconfig::backend::memory;

=head1 NAME

pfconfig::backend::memory;

=cut

=head1 DESCRIPTION

pfconfig::backend::memory;

Defines a CHI Memory backend to use as a layer 2 cache

=cut

use strict;
use warnings;

use base 'pfconfig::backend';
use CHI;
use pfconfig::empty_string;

my $empty_string = pfconfig::empty_string->new;

=head2 init

initialize the cache

=cut

sub init {
    my ($self) = @_;
    $self->{cache} = CHI->new(driver => 'Memory', datastore => {},'serializer' => 'Sereal');
}

=head2 set

Set value in the CHI cache

=cut

sub set {
    my ( $self, $key, $value ) = @_;

    # There is an issue writing empty strings with CHI Memory driver
    # We workaround it using a class that represents an empty string
    if ( defined($value) && "$value" eq '' ) {
        $value = $empty_string;
    }
    $self->SUPER::set( $key, $value );
}

=head2 get

Get value from the CHI cache

=cut

sub get {
    my ( $self, $key ) = @_;
    my $value = $self->SUPER::get($key);

    # There is an issue writing empty strings with CHI Memory driver
    # We workaround it using a class that represents an empty string
    if ( ref($value) eq "pfconfig::empty_string" && $value->isa("pfconfig::empty_string") ) {
        $value = '';
    }
    return $value;
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


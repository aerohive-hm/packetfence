package pfconfig::namespaces::resource;

=head1 NAME

pfconfig::namespaces:resource

=cut

=head1 DESCRIPTION

pfconfig::namespaces:resource

Abstract class representing a resource

=cut

=head1 USAGE

You can define a resource so it is accessible by the manager
by doing the following : 
- Subclass this class in pfconfig/namespaces/
- Add any additionnal initialization by overiding init
- Create the definition of the object using the build method

=cut

use strict;
use warnings;

sub new {
    my ( $class, $cache, @args ) = @_;
    my $self = bless {}, $class;

    $self->{cache} = $cache;

    $self->init(@args);

    return $self;
}

sub init {
}

sub build {
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


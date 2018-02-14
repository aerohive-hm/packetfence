package pfconfig::namespaces::resource::local_secret;

=head1 NAME

pfconfig::namespaces::resource::local_secret

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::local_secret

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::resource';

use pf::file_paths qw($local_secret_file);
use File::Slurp qw(read_file);

sub init {
    my ($self) = @_;

    $self->{child_resources} = [ 'config::Switch' ];
}

sub build {
    my ($self) = @_;
    return read_file($local_secret_file);
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



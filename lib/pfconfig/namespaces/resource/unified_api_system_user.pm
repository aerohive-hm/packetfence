package pfconfig::namespaces::resource::unified_api_system_user;

=head1 NAME

pfconfig::namespaces::resource::unified_api_system_user

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::unified_api_system_user

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::resource';

use pf::file_paths qw($unified_api_system_pass_file);
use File::Slurp qw(read_file);

sub build {
    my ($self) = @_;
    my $pass = read_file($unified_api_system_pass_file);

    return {
        user => "system",
        pass => $pass,
    };
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

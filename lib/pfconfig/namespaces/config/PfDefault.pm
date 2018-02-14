package pfconfig::namespaces::config::PfDefault;

=head1 NAME

pfconfig::namespaces::config::PfDefault

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::PfDefault

This module creates the configuration hash associated to pf.conf.defaults

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use Config::IniFiles;
use pf::file_paths qw($pf_default_file);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file}            = "/usr/local/pf/conf/pf.conf.defaults";
    $self->{child_resources} = [ 'config::Pf', ];
}

sub build_child {
    my ($self) = @_;

    return $self->{cfg};
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


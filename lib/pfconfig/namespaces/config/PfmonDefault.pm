package pfconfig::namespaces::config::PfmonDefault;

=head1 NAME

pfconfig::namespaces::config::PfmonDefault

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::PfmonDefault

This module creates the configuration hash associated to pfmon.conf.defaults

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::file_paths qw($pfmon_default_config_file);
use Clone qw(clone);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $pfmon_default_config_file;
}


sub build_child {
    my ($self) = @_;
    my $tmp_cfg = clone($self->{cfg});

    return $tmp_cfg;
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


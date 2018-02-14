package pfconfig::namespaces::config::Pfmon;

=head1 NAME

pfconfig::namespaces::config::Pfmon

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::Pfmon

This module creates the configuration hash associated to pfmon.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::file_paths qw($pfmon_config_file $pfmon_default_config_file);
use pf::util qw(normalize_time);
use pf::IniFiles;
use Clone qw(clone);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $pfmon_config_file;
    my $defaults = pf::IniFiles->new(-file => $pfmon_default_config_file);
    $self->{added_params}{'-import'} = $defaults;
}

our %TIME_ATTR = (
    interval => 1,
    window => 1,
    timeout => 1,
    rotate_timeout => 1,
    rotate_window => 1,
);

sub build_child {
    my ($self) = @_;
    my $tmp_cfg = clone($self->{cfg});
    foreach my $task_data (values %$tmp_cfg) {
        foreach my $key (keys %$task_data) {
            $task_data->{$key} = normalize_time($task_data->{$key}) if exists $TIME_ATTR{$key};
        }
    }

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


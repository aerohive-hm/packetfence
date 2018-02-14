package pfconfig::namespaces::config::Wmi;

=head1 NAME

pfconfig::namespaces::config::Wmi

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::Wmi

This module creates the configuration hash associated to wmi.conf

=cut


use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::log;
use pf::file_paths qw($wmi_config_file);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $wmi_config_file;
    $self->{expandable_params} = qw(actions);
}

sub build_child {
    my ($self) = @_;

    my %tmp_cfg = %{$self->{cfg}};

    foreach my $key ( keys %tmp_cfg){
        $self->cleanup_after_read($key, $tmp_cfg{$key});
        $self->cleanup_whitespaces( \%tmp_cfg );
    }

    return \%tmp_cfg;

}

sub cleanup_after_read {
    my ($self, $id, $item) = @_;
    $self->expand_list($item, $self->{expandable_params});
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


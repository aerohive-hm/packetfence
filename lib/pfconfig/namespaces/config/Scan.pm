package pfconfig::namespaces::config::Scan;

=head1 NAME

pfconfig::namespaces::config::Scan

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::Scan

This module creates the configuration hash associated to scan.conf

=cut


use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::log;
use pf::file_paths qw($scan_config_file);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $scan_config_file;
}

sub build_child {
    my ($self) = @_;

    my %tmp_cfg = %{$self->{cfg}};

    foreach my $key ( keys %tmp_cfg){
        $self->cleanup_after_read($key, $tmp_cfg{$key});
    }

    return \%tmp_cfg;

}

sub cleanup_after_read {
    my ($self, $id, $data) = @_;
    $self->expand_list($data, qw(category oses rules));
    if(exists $data->{oses} && defined $data->{oses}) {
        $data->{oses} = ref($data->{oses}) eq 'ARRAY' ? $data->{oses} : [$data->{oses}];
    }
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


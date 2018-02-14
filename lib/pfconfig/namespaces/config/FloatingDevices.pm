package pfconfig::namespaces::config::FloatingDevices;

=head1 NAME

pfconfig::namespaces::config::template

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::template

This module creates the configuration hash associated to somefile.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use pf::file_paths qw($floating_devices_config_file);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $floating_devices_config_file;
}

sub build_child {
    my ($self) = @_;

    my %ConfigFloatingDevices = %{ $self->{cfg} };

    $self->cleanup_whitespaces( \%ConfigFloatingDevices );

    foreach my $section ( keys %ConfigFloatingDevices ) {
        if ( defined( $ConfigFloatingDevices{$section}{"trunkPort"} )
            && $ConfigFloatingDevices{$section}{"trunkPort"} =~ /^\s*(y|yes|true|enabled|1)\s*$/i )
        {
            $ConfigFloatingDevices{$section}{"trunkPort"} = '1';
        }
        else {
            $ConfigFloatingDevices{$section}{"trunkPort"} = '0';
        }
    }

    return \%ConfigFloatingDevices;

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


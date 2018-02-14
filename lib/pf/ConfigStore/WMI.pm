package pf::ConfigStore::WMI;
=head1 NAME

pf::ConfigStore::WMI
Store WMI Rules

=cut

=head1 DESCRIPTION

pf::ConfigStore::WMI

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw($wmi_config_file);
extends 'pf::ConfigStore';

sub configFile { $wmi_config_file };

sub pfconfigNamespace {'config::Wmi'}

=head2 cleanupAfterRead

Clean up realm data

=cut

sub cleanupAfterRead {
    my ($self, $id, $profile) = @_;
    $self->expand_list($profile, $self->_fields_expanded);
}

=head2 cleanupBeforeCommit

Clean data before update or creating

=cut

sub cleanupBeforeCommit {
    my ($self, $id, $profile) = @_;
    $self->flatten_list($profile, $self->_fields_expanded);
}

=head2 _fields_expanded

=cut

sub _fields_expanded {
    return qw(actions);
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


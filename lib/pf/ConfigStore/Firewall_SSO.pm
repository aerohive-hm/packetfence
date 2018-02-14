package pf::ConfigStore::Firewall_SSO;
=head1 NAME

pf::ConfigStore::FirewallSSO add documentation

=cut

=head1 DESCRIPTION

pf::ConfigStore::FirewallSSO

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw($firewall_sso_config_file);
extends 'pf::ConfigStore';

sub configFile { $firewall_sso_config_file };

sub pfconfigNamespace { 'config::Firewall_SSO' }

=head2 cleanupAfterRead

Clean up switch data

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
    return qw(categories);
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


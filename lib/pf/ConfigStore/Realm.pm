package pf::ConfigStore::Realm;
=head1 NAME

pf::ConfigStore::Realm
Store Realm configuration

=cut

=head1 DESCRIPTION

pf::ConfigStore::Realm

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw(
    $realm_config_file
    $realm_default_config_file
);
extends 'pf::ConfigStore';

sub configFile { $realm_config_file }

sub importConfigFile { $realm_default_config_file }

sub pfconfigNamespace {'config::Realm'}

=head2 cleanupAfterRead

Clean up realm data

=cut

sub cleanupAfterRead {
    my ($self, $id, $profile) = @_;
    $self->expand_list($profile, $self->_fields_expanded);
    # This can be an array if it's fresh out of the file. We make it separated by newlines so it works fine the frontend
    if(ref($profile->{options}) eq 'ARRAY'){
        $profile->{options} = $self->join_options($profile->{options});
    }
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


=head2 join_options

Join options in array with a newline

=cut

sub join_options {
    my ($self,$options) = @_;
    return join("\n",@$options);
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


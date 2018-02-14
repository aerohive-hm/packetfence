package pfappserver::Model::Config::Pfconfig;
=head1 NAME

pfappserver::Model::Config::Pfconfig

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::Pf to interface with pfconfig's configuration
This doesn't use the ConfigStore

=cut

use Moose;
use namespace::autoclean;
use pfconfig::config;
use pfconfig::constants;
use Config::IniFiles;

extends 'pfappserver::Base::Model';

=head1 FIELDS

=head2 config_file

pfconfig's config file

=cut

has config_file => (
   is => 'ro',
   lazy => 1,
   isa => 'Config::IniFiles',
   builder => '_build_config_file'
);

=head2 _build_config_file

=cut

sub _build_config_file {
    my $file = $pfconfig::constants::CONFIG_FILE_PATH;
    my $config = Config::IniFiles->new( -file => $file );
    return $config;
}

=head2 remove

Delete an existing item

=cut

sub remove {
    my ($self,$id) = @_;
    return ($STATUS::INTERNAL_SERVER_ERROR, "Cannot delete this item");
}

sub update_mysql_credentials {
    my ($self, $user, $password) = @_;
    $self->config_file->setval('mysql', 'user', $user);
    $self->config_file->setval('mysql', 'pass', $password);
    return ($self->config_file->RewriteConfig(), undef);
}

sub update_db_name {
    my ($self, $db) = @_;
    $self->config_file->setval('mysql', 'db', $db);
    return ($self->config_file->RewriteConfig(), undef);
}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


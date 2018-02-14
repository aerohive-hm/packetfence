package pf::services::manager::redis;
=head1 NAME

pf::services::manager::redis - base class for redis services

=cut

=head1 DESCRIPTION

pf::services::manager::redis

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw(
    $conf_dir
    $generated_conf_dir
    $install_dir
);
use pf::config qw(
    %Config
);
use pf::util;

extends 'pf::services::manager';

has 'redis_config_template' => (is => 'rw', builder => 1, lazy => 1);

has 'redis_config_file' => (is => 'rw', builder => 1, lazy => 1);

sub _cmdLine {
    my ($self) = @_;
    my $config = $self->redis_config_file;
    return $self->executable . " $config"; 
}

sub generateConfig {
    my ($self) = @_;
    my $tags = $self->make_tags;
    my $template = $self->redis_config_template;
    parse_template($tags, $template, $self->redis_config_file);
}

sub make_tags {
    my ($self) = @_;
    my %tags;
    my $template = $self->redis_config_template;
    $tags{'template'}    = $template;
    $tags{'install_dir'} = $install_dir;
    $tags{'name'} = $self->name;
    return \%tags;
}

sub _build_redis_config_template {
    my ($self) = @_;
    my $name = $self->name;
    return "$conf_dir/${name}.conf";

}

sub _build_redis_config_file {
    my ($self) = @_;
    my $name = $self->name;
    return "$generated_conf_dir/${name}.conf";
}

sub executable {
    my ($self) = @_;
    my $service = ( $Config{'services'}{"redis_binary"} || "$install_dir/sbin/redis" );
    return $service;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


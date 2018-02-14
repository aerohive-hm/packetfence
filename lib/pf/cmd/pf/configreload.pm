package pf::cmd::pf::configreload;
=head1 NAME

pf::cmd::pf::configreload add documentation

=head1 SYNOPSIS

 pfcmd configreload [soft|hard]

reloads the configuration

  soft   | reload changed configuration files
  hard   | reload all configuration files

  defaults to soft

=head1 DESCRIPTION

pf::cmd::pf::configreload

=cut

use strict;
use warnings;
use pf::constants::exit_code qw($EXIT_SUCCESS);
use pf::util;

use base qw(pf::base::cmd::action_cmd);

sub default_action { 'soft' }

sub action_soft {
    my ($self) = @_;
    $self->configreload();
}

sub action_hard {
    my ($self) = @_;
    $self->configreload(1);
}


sub configreload {
    my ($self,$force)  = @_;
    run_as_pf();
    require pf::config;
    pf::config::configreload($force);
    return $EXIT_SUCCESS;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


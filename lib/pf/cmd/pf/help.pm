package pf::cmd::pf::help;
=head1 NAME

pfcmd - PacketFence command line interface

=head1 SYNOPSIS

pfcmd help [command]

Please view "pfcmd help" for all command

=cut

=head1 DESCRIPTION

pf::cmd::pf::help

=cut

use strict;
use warnings;

use base qw(pf::cmd::help);

sub run {
    my ($self) = @_;
    my ($cmd) = $self->args;
    if(!defined $cmd) {
        return $self->SUPER::run;
    }
    return $self->showHelp("pf::cmd::pf::${cmd}");
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


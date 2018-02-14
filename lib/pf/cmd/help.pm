package pf::cmd::help;
=head1 NAME

pf::cmd::help

=cut

=head1 DESCRIPTION

pf::cmd::help

A pf::cmd class that extracts the usage from the parentCmd

=cut

use strict;
use warnings;
use base qw(pf::cmd);
use Pod::Find qw(pod_where);

sub run {
    my ($self) = @_;
    my ($cmd) = $self->args;
    my $parentCmd = $self->{parentCmd};
    if(!defined $cmd || $cmd eq 'help') {
        return $parentCmd->showHelp;
    }
    my $base = ref($parentCmd) || $parentCmd;
    my $package = "${base}::${cmd}";
    my $location = pod_where( { -inc => 1 }, $package);
    if ($location) {
        return $self->showHelp($package);
    }
    $parentCmd->{help_msg} = "unknown command \"$cmd\"";
    return $parentCmd->showHelp;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


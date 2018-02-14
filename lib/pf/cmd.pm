package pf::cmd;

=head1 NAME

pf::cmd add documentation

=head1 DESCRIPTION

pf::cmd

=cut

use strict;
use warnings;
use Role::Tiny::With;
with 'pf::cmd::roles::show_help';

sub new {
    my ($class,$args) = @_;
    my $self = bless $args,$class;
    return $self;
}

sub run {
    my ($self) = @_;
    if ($self->parseArgs) {
        $self->_run;
    } else {
        $self->showHelp;
    }
}

sub parseArgs {
    my ($self) = @_;
    return $self->args == 0;
}

sub args {
    return @{$_[0]->{args} || []};
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


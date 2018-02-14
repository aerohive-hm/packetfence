package pf::base::cmd::action_cmd;
=head1 NAME

pf::cmd::action_cmd add documentation

=cut

=head1 DESCRIPTION

pf::cmd::action_cmd

=cut

use strict;
use warnings;
use base qw(pf::cmd);

=head2 default_action

The default action to make when none is specified
Defaults to no action

=cut

sub default_action { undef }

sub parseArgs {
    my ($self) = @_;
    my ($action,@args) = $self->args;
    $action = $self->default_action if(!defined($action) && defined($self->default_action));
    if($self->is_valid_action($action)) {
        $self->{action} = $action;
        return $self->_parseArgs(@args);
    }
    return 0;
}

sub _parseArgs {
    my ($self,@args) = @_;
    my $result = 1;
    my $action = $self->{action};
    my $parse_action = "parse_$action";
    if ($self->can($parse_action)) {
        $result = $self->$parse_action(@args);
    }
    $self->{action_args} = \@args unless exists $self->{action_args};
    return $result;
}

sub is_valid_action {
    my ($self,$action) = @_;
    return defined $action ? $self->can("action_$action") : 0;
}

sub _run {
    my ($self) = @_;
    my $action = $self->{action};
    my $method = "action_$action";
    return $self->$method;
}

sub action_args {
    my ($self) = @_;
    return @{ $self->{action_args} || []  }
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


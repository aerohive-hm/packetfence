package pfappserver::Role::Controller::Audit;

=head1 NAME

pfappserver::Role::Controller::Audit - Role for Audit logging

=cut

=head1 DESCRIPTION

pfappserver::Role::Controller::Audit

=cut

use strict;
use warnings;

use Moose::Role;

=head2 audit_current_action

Create an audit log entry

=cut

sub audit_current_action {
    my ($self, $c, @args) = @_;
    my $action = $c->action;
    $c->model("Audit")->write_json_entry({
        user => $c->user->id,
        action => $action->name,
        context => $action->private_path,
        happened_at => scalar localtime(),
        @args,
    });
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

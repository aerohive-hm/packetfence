package pf::class;

=head1 NAME

pf::class - module to manage the violation classes.

=cut

=head1 DESCRIPTION

pf::class contains the functions necessary to manage the violation classes.

=cut

use strict;
use warnings;
use pf::log;

use constant CLASS => 'class';

BEGIN {
    use Exporter ();
    our ( @ISA, @EXPORT );
    @ISA = qw(Exporter);
    @EXPORT = qw(
        class_view       class_view_all
        class_add        class_delete
        class_merge      class_next_vid
    );
}

use pf::action;
use pf::dal::class;
use pf::error qw(is_error is_success);

sub class_exist {
    my ($id) = @_;
    my $status = pf::dal::class->exists({vid => $id});
    return (is_success($id));
}

sub class_view {
    my ($id) = @_;
    my ($status, $item) = pf::dal::class->find({vid => $id});
    if (is_error($status)) {
        return (0);
    }
    return ($item->to_hash);
}

sub class_view_all {
    my ($status, $item) = pf::dal::class->search(
        -group_by => 'class.vid',
    );
    if (is_error($status)) {
        return;
    }
    return @{ $item->all(undef) // []};
}

sub class_add {
    my $logger = get_logger();
    my %values;
    @values{qw(vid description auto_enable max_enables grace_period window vclose priority template max_enable_url redirect_url button_text enabled vlan target_category delay_by external_command)} = @_;
    my $status = pf::dal::class->create(\%values);
    if ($status == $STATUS::CONFLICT) {
        return (2);
    }
    return (1);
}

sub class_delete {
    my ($id) = @_;
    my $logger = get_logger();
    my $status = pf::dal::class->remove_by_id({vid => $id});
    $logger->debug("class $id deleted");
    return (is_success($status));
}

sub class_merge {
    my $id = $_[0];
    my $actions = pop(@_);
    my $whitelisted_roles = pop(@_);
    my $logger = get_logger();

    # delete existing violation actions
    if ( !pf::action::action_delete_all($id) ) {
        $logger->error("error deleting actions for class $id");
        return (0);
    }
    my %values;
    @values{qw(vid description auto_enable max_enables grace_period window vclose priority template max_enable_url redirect_url button_text enabled vlan target_category delay_by external_command)} = @_;
    my $item = pf::dal::class->new(\%values);
    my $status = $item->save();

    if ($actions) {
        foreach my $action ( split( /\s*,\s*/, $actions ) ) {
            pf::action::action_add($id, $action);
        }
    }

}

sub class_next_vid {
    my ($status, $iter) = pf::dal::class->search(
        -columns => ['MAX(`vid`+1)|auto_increment_id'],
        -with_class => undef,
        -from => 'class'
    );
    if (is_error($status)) {
        return undef;
    }
    my $item = $iter->next // {};
    return $item->{auto_increment_id};
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

Copyright (C) 2005 Kevin Amorin

Copyright (C) 2005 David LaPorte

=cut

1;

package pfappserver::Form::Field::DynamicTable;

=head1 NAME

pfappserver::Form::Field::DynamicTable add documentation

=cut

=head1 DESCRIPTION

pfappserver::Form::Field::DynamicTable

=cut

use strict;
use warnings;
use Moose;
extends 'HTML::FormHandler::Field::Repeatable';

has '+widget' => ( default => 'DynamicTable' );
has '+num_extra' => ( default => 1 );
has '+widget_wrapper' => ( default => '+Simple' );
has '+do_wrapper' => ( default => 1 );
has '+do_label' => ( default => 1 );
has 'sortable' => ( is =>'rw', default => 0 );

sub wrapper_tag {
    "table"
}

sub BUILD {
    my ($self) = @_;
    $self->add_wrapper_class(qw(table table-dynamic table-condensed));
    $self->add_wrapper_class(qw(table-sortable)) if $self->sortable;
    $self->set_tag("wrapper_tag", $self->wrapper_tag);
    $self->set_wrapper_attr("id", $self->id);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


package pfappserver::Form::Widget::Field::DynamicTable;

=head1 NAME

pfappserver::Form::Widget::Field::DynamicTable add documentation

=cut

=head1 DESCRIPTION

pfappserver::Form::Widget::Field::DynamicTable

=cut

use Moose::Role;
with 'HTML::FormHandler::Widget::Field::Repeatable';

sub render_subfield {
    my ( $self, $result, $subfield ) = @_;
    my $subresult = $result->field( $subfield->name );

    return "" unless $subresult
        or ( $self->has_flag("is_repeatable")
            and $subfield->name < $self->num_when_empty
        );
    my $extra = '';
    if ($self->num_fields == ($subfield->name + 1)) {
        $subfield->set_tag("dynamic_row_class","hidden");
        set_disabled($subfield);
        $extra = "<tr><td colspan='3'></td></tr>" if $self->sortable;
    }

    return $subfield->render($subresult) . $extra;
}

sub set_disabled {
    my ($field) = @_;
    if ($field->can("fields")) {
        foreach my $subfield ($field->fields) {
            set_disabled($subfield);
        }
    }
    $field->set_element_attr("disabled" => "disabled");
}

use namespace::autoclean;
1;

# }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


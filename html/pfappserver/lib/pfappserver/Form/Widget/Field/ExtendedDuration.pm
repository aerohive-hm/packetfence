package pfappserver::Form::Widget::Field::ExtendedDuration;

=head1 NAME

pfappserver::Form::Widget::Field::ExtendedDuration - extended duration complex widget

=head1 DESCRIPTION

This compound field is to be used only with the ExtendedDuration form field.

=cut

use Moose::Role;
with 'HTML::FormHandler::Widget::Field::Compound';

=head1 METHODS

=cut

sub render_element {
    my ( $self, $result ) = @_;
    $result ||= $self->result;

    my $output = '';
    my $toggle = 0;

    foreach my $subfield ( $self->sorted_fields ) {
        if ($subfield->{type} eq 'Toggle') {
            if ($toggle) {
                $output .= $self->render_subfield( $result, $subfield );
                $output .= '</div>';
            }
            else {
                $output .= '</div><div class="controls">';
                $output .= $self->render_subfield( $result, $subfield );
                $toggle = 1;
            }
        }
        else {
            $output .= $self->render_subfield( $result, $subfield );
        }
    }
    $output =~ s/^\n//; # remove newlines so they're not duplicated

    return $output;
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

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

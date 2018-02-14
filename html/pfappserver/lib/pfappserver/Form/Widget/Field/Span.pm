package pfappserver::Form::Widget::Field::Span;

=head1 NAME

pfappserver::Form::Widget::Field::Span - noneditable span

=head1 DESCRIPTION

Renders a uneditable pseudo-field as a span in a form.

Fixes a closing tag in the shipped version.

=cut

use Moose::Role;
use HTML::FormHandler::Render::Util ('process_attrs');
with 'HTML::FormHandler::Widget::Field::Span';
use HTML::Entities qw(encode_entities);

use namespace::autoclean;


sub render_element {
    my ( $self, $result ) = @_;
    $result ||= $self->result;

    my $output = '<span';
    $output .= ' id="' . $self->id . '"';
    $output .= process_attrs($self->element_attributes($result));
    $output .= '>'; # the shipped version is incorrectly closing the span tag
    if(defined $self->value) {
        if($self->can("escape_value") && $self->escape_value) {
            $output .= encode_entities($self->value);
        }
        else {
            $output .= $self->value;
        }
    }
    $output .= '</span>';
    return $output;
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

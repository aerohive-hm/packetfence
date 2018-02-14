package pfappserver::Form::Widget::Field::Switch;

=head1 NAME

pfappserver::Form::Widget::Field::Switch - on/off switch

=head1 DESCRIPTION

Renders a checkbox as a big on/off switch.

=cut

use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

sub render_element {
    my ( $self, $result ) = @_; 
    $result ||= $self->result;

    my $checkbox_value = $self->checkbox_value;
    my $output = qq[<div class="switch">\n]
        . '<input type="checkbox" name="'
        . $self->html_name . '" id="' . $self->id . '" value="'
        . $self->html_filter($checkbox_value) . '"';
    $output .= ' checked="checked"'
        if $result->fif eq $checkbox_value;
    $output .= process_attrs($self->element_attributes($result));
    $output .= ' /></div>';

    return $output;
}

sub render {
    my ( $self, $result ) = @_; 
    $result ||= $self->result;
    die "No result for form field '" . $self->full_name . "'. Field may be inactive." unless $result;
    my $output = $self->render_element( $result );
    return $self->wrap_field( $result, $output );
}

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

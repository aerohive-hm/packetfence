package captiveportal::PacketFence::Form::Widget::Field::AUP;

=head1 NAME

captiveportal::PacketFence::Form::Widget::Field::AUP

=head1 DESCRIPTION

AUP Widget

=cut

use Moose::Role;
with 'HTML::FormHandler::Widget::Field::Checkbox';

=head2 render_element

Render the AUP with its checkbox

=cut

sub render_element {
    my ($self, $result) = @_;
    my $checkbox = HTML::FormHandler::Widget::Field::Checkbox::render_element($self, $result);
    my $divs = '';
    $divs .= '<div class="o-aup">'.$self->form->app->_render($self->form->app->current_module ? $self->form->app->current_module->aup_template() : "aup_text.html").'</div>';
    $divs .= '<div class="text-center u-padding-top">'.$checkbox.'<label for="'.$self->id.'" class="c-btn c-btn--primary u-1/1 u-2/3@tablet u-3/5@desktop">'.
      $self->form->app->i18n('I accept the terms').'</label></div>';

    return $divs;
}

=head2 render

Render the field

=cut

sub render {
    my ($self, $result) = @_;
    $result ||= $self->result;
    die "No result for form field '" . $self->full_name . "'. Field may be inactive." unless $result;
    return $self->render_element( $result );
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

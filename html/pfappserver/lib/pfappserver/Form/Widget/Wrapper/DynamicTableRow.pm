package pfappserver::Form::Widget::Wrapper::DynamicTableRow;

=head1 NAME

pfappserver::Form::Widget::Wrapper::Table add documentation

=cut

=head1 DESCRIPTION

pfappserver::Form::Widget::Wrapper::Table

=cut

use Moose::Role;
with 'HTML::FormHandler::Widget::Wrapper::Bootstrap';
use HTML::FormHandler::Render::Util ('process_attrs');

around wrap_field => sub {
    my ($orig, $self, $result, $rendered_widget ) = @_;
    my $class = $self->get_tag("dynamic_row_class");
    $class = " class=\"$class\"" if $class;
    my $extra = "<td>";
    $extra ="<td class=\"sort-handle\">" . ($self->name + 1) . "</td>\n<td>" if $self->parent->sortable ;
    return "<tr${class}>${extra}" . $rendered_widget .
         '</td><td class="action"><a class="btn-icon" href="#delete"><i class="icon-minus-circle"></i></a><a class="btn-icon" href="#add"><i class="icon-plus-circle"></i></a></td></tr>';
};

use namespace::autoclean;
1;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


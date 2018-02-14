package pfappserver::Form::Widget::Wrapper::Modal;

=head1 NAME

pfappserver::Form::Widget::Wrapper::Table add documentation

=cut

=head1 DESCRIPTION

pfappserver::Form::Widget::Wrapper::Table

=cut

use Moose::Role;
with 'HTML::FormHandler::Widget::Wrapper::Bootstrap';
use HTML::FormHandler::Render::Util ('process_attrs');
use pf::log;

around wrap_field => sub {
    my ($orig, $self, $result, $rendered_widget ) = @_;
    my $output = '';
#    use Data::Dumper;get_logger->info(Dumper($self));
    my $parent_name = $self->parent->name;
    my $name = $self->name;
    my $id = "modal_${parent_name}_${name}";
    $output .= qq{<div class="control-group">};
    $output .= qq{<a href="#$id" class="btn" data-toggle="modal">$parent_name $name</a>};
    $output .= qq{<div class="modal fade hide" id="$id">};
    $output .= qq{<div class="modal-header">};
    $output .= qq{      <a class="close" data-dismiss="modal">&times;</a>};
    $output .= qq{      <h3><i></i> <span></span></h3>};
    $output .= qq{</div>};
    $output .= qq{<div class="modal-body">$rendered_widget</div>};
    $output .= qq{<div class="modal-footer">};
    $output .= qq{      <a class="close" data-dismiss="modal">&times;</a>};
    $output .= qq{</div>};
    $output .= qq{</div>};
    $output .= qq{</div>};
    return $output;
};

use namespace::autoclean;
1;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


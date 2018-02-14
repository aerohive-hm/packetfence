package pfappserver::Base::Form::Role::Defaults;

=head1 NAME

pfappserver::Base::Form::Role::Defaults

=head1 DESCRIPTION

This roles provides defaults

=cut

use namespace::autoclean;
use HTML::FormHandler::Moose::Role;

=head2 defaults_list

Format the default values for a list (CSV)

=cut

sub defaults_list {
    my $self = shift;

    my $id = $self->_localize($self->label);
    my $content;
    foreach my $element (split(',', $self->get_tag('defaults'))){
        $content .= "<span class=\"label label-info\" >$element</span>";
    }
    if ($self->get_tag('defaults')) {
        return sprintf("<div class='list-defaults alert alert-info'><strong>Built-in $id :</strong> %s</div>", $content);
    }
}


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

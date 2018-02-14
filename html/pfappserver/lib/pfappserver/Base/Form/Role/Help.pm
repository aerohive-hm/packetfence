package pfappserver::Base::Form::Role::Help;

=head1 NAME

pfappserver::Base::Form::Role::Help

=head1 DESCRIPTION

This roles provides help and help_list

=cut

use namespace::autoclean;
use HTML::FormHandler::Moose::Role;

=head2 help

=cut

sub help {
    my $self = shift;
    my $help = undef;

    if ($self->get_tag('help')) {
        return sprintf('<p class="help-block">%s</p>', $self->_localize($self->get_tag('help')));
    }
}

=head2 help_list

=cut

sub help_list {
    my $self = shift;
    my $help = undef;

    if ($self->get_tag('help')) {
        return sprintf('<dl class="help-block">%s</dl>', $self->_localize($self->get_tag('help')));
    }
}


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

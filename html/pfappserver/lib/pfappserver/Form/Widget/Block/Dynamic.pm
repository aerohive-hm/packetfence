package pfappserver::Form::Widget::Block::Dynamic;

=head1 NAME

pfappserver::Form::Widget::Block::Dynamic -

=cut

=head1 DESCRIPTION

pfappserver::Form::Widget::Block::Dynamic

=cut

use strict;
use warnings;
use Moose;
extends 'HTML::FormHandler::Widget::Block';

has '+render_list' => ( lazy => 1 );

sub default_build_render_list {
[]
}

has 'build_render_list_method' => (
    is      => 'rw',
    isa     => 'CodeRef',
    traits  => ['Code'],
    handles => {'build_render_list' => 'execute_method'},
    default => sub { \&default_build_render_list },
);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


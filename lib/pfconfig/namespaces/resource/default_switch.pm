package pfconfig::namespaces::resource::default_switch;

=head1 NAME

pfconfig::namespaces::resource::default_switch

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::default_switch

This module creates the configuration hash associated to the default switch 

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::resource';

sub init {
    my ($self) = @_;

    # we depend on the switch configuration object (russian doll style)
    $self->{switches} = $self->{cache}->get_cache('config::Switch');
}

sub build {
    my ($self) = @_;
    return $self->{switches}{default};
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:


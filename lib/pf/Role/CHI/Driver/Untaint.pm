package pf::Role::CHI::Driver::Untaint;

=head1 NAME

pf::Role::CHI::Driver::Untaint add documentation

=cut

=head1 DESCRIPTION

pf::Role::CHI::Driver::Untaint

=cut

use strict;
use warnings;
use Moo::Role;


around get_keys => sub {
    my ( $orig, $self ) = @_;
    return map { /^(.*)$/;$1 } $self->$orig;
};

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


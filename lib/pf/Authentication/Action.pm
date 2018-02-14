package pf::Authentication::Action;

=head1 NAME

pf::Authentication::Action

=head1 DESCRIPTION

=cut

use pf::Authentication::constants;
use Moose;

use List::MoreUtils qw(any);
use List::Util qw(first);

has 'type'  => (isa => 'Str', is => 'rw', required => 1);
has 'class' => (isa => 'Str', is => 'rw', required => 1);
has 'value' => (isa => 'Str', is => 'rw', required => 0);

=head2 BUILDARGS

=cut

sub BUILDARGS {
    my ($class, @args) = @_;
    my $argshash = $class->SUPER::BUILDARGS(@args);
    if (exists $argshash->{type} && !exists $argshash->{class}) {
        $argshash->{class} = $class->getRuleClassForAction($argshash->{type});
    }
    return $argshash;
}

=head2 getRuleClassForAction

Returns the rule class for an action

=cut

sub getRuleClassForAction {
    my ( $self, $action ) = @_;
    return exists $Actions::ACTION_CLASS_TO_TYPE{$action} ? $Actions::ACTION_CLASS_TO_TYPE{$action} : $Rules::AUTH;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

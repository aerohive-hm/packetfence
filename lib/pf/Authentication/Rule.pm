package pf::Authentication::Rule;

=head1 NAME

pf::Authentication::Rule

=head1 DESCRIPTION

=cut

use Moose;

use pf::Authentication::constants;

has 'id' => (isa => 'Str', is => 'rw', required => 1);
has 'class' => (isa => 'Str', is => 'rw', default => $Rules::AUTH);
has 'description' => (isa => 'Str', is => 'rw', required => 0);
has 'match' => (isa => 'Maybe[Str]', is => 'rw', default => $Rules::ANY);
has 'actions' => (isa => 'ArrayRef', is => 'rw', required => 0);
has 'conditions' => (isa => 'ArrayRef', is => 'rw', required => 0);

sub add_action {
  my ($self, $action) = @_;
  push(@{$self->{'actions'}}, $action);
}

sub add_condition {
  my ($self, $condition) = @_;
  push(@{$self->{'conditions'}}, $condition);
}

sub is_fallback {
  my $self = shift;

  if (scalar @{$self->{'conditions'}} == 0 &&
      scalar @{$self->{'actions'}} > 0)
    {
      return 1;
    }

  return 0;
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

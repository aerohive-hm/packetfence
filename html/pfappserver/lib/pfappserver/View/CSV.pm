package pfappserver::View::CSV;

=head1 NAME

pfappserver::View::CSV

=head1 DESCRIPTION

Used to render CSV

=cut

use base qw ( Catalyst::View::CSV );

__PACKAGE__->config ( sep_char => ",", suffix => "csv", binary => 1);

sub process {
    my ($self, $c) = @_;
    unless(defined($c->stash->{columns})){
        if(defined($c->stash->{items}->[0])) {
            $c->stash->{columns} = [keys(%{$c->stash->{items}->[0]})];
        }
    }
    $c->stash->{data} = $c->stash->{items};
    $self->SUPER::process($c);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable(inline_constructor => 0) unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

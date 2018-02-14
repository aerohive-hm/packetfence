package pfconfig::undef_element;

=head1 NAME

pfconfig::empty_string

=cut

=head1 DESCRIPTION

Used to represent an empty string in the BDB backend since Cache::BDB doesn't store empty strings

=cut

sub new {
    my ($class) = @_;
    my $self = bless {}, $class;
    return $self;
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

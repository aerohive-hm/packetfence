package pfconfig::namespaces::resource::bandwidth_expired_violations;

=head1 NAME

pfconfig::namespaces::resource::bandwidth_expired_violations

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::bandwidth_expired_violations

=cut

use strict;
use warnings;
use pfconfig::namespaces::FilterEngine::Violation;

use base 'pfconfig::namespaces::resource';

sub init {
    my ($self) = @_;
    $self->{_engine} = pfconfig::namespaces::FilterEngine::Violation->new;
    $self->{_engine}->build();
}

sub build {
    my ($self) = @_;

    return $self->{_engine}->{bandwidth_expired_violations};
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


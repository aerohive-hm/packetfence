package pfconfig::namespaces::resource::accounting_triggers;

=head1 NAME

pfconfig::namespaces::resource::accounting_triggers

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::accouting_triggers

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

    return $self->{_engine}->{accounting_triggers};
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


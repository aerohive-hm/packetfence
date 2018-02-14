package pfconfig::namespaces::resource::fqdn;

=head1 NAME

pfconfig::namespaces::resource::fqdn

=cut

=head1 DESCRIPTION

pfconfig::namespaces::resource::fqdn

=cut

use strict;
use warnings;

use base 'pfconfig::namespaces::resource';

sub init {
    my ($self) = @_;
    $self->{config} = $self->{cache}->get_cache('config::Pf');
}

sub build {
    my ($self) = @_;
    my $fqdn = join(".", @{$self->{config}{'general'}}{'hostname', 'domain'});
    return $fqdn;
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


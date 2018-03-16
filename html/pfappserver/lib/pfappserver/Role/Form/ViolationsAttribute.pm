package pfappserver::Role::Form::ViolationsAttribute;

=head1 NAME

pfappserver::Role::Form::ViolationsAttribute -

=cut

=head1 DESCRIPTION

pfappserver::Role::Form::ViolationsAttribute

=cut

use strict;
use warnings;
use HTML::FormHandler::Moose::Role;
use pf::ConfigStore::Violations;

has violations => ( is => 'rw', builder => '_build_violations');

sub _build_violations {
    my ($self) = @_;
    my $cs = pf::ConfigStore::Violations->new;
    return $cs->readAll;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


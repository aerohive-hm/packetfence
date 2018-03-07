package pfappserver::Base::Form::Role::InternalSource;

=head1 NAME

pfappserver::Base::Form::Role::InternalSource - Role for Local Accounts

=cut

=head1 DESCRIPTION

pfappserver::Base::Form::Role::InternalSource

=cut

use strict;
use warnings;
use namespace::autoclean;
use HTML::FormHandler::Moose::Role;
use pf::config qw(%ConfigRealm);
with 'pfappserver::Base::Form::Role::Help';

has_field 'realms' => (
    type           => 'Select',
    multiple       => 1,
    label          => 'Associated Realms',
    options_method => \&options_realm,
    element_class  => ['chzn-deselect'],
    element_attr   => { 'data-placeholder' => 'Click to add a realm' },
    tags           => {
        after_element => \&help,
        help          => 'Realms that will be associated with this source'
    },
    default => '',
);

has_block internal_sources => (
    render_list => [qw(realms)],
);

=head2 options_realm

retrive the realms

=cut

sub options_realm {
    my ($self) = @_;
    my @roles = map { $_ => $_ } sort keys %ConfigRealm;
    return @roles;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


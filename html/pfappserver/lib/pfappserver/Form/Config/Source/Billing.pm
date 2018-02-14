package pfappserver::Form::Config::Source::Billing;

=head1 NAME

pfappserver::Form::Config::Source::Billing;

=cut

=head1 DESCRIPTION

Parent class for Billing Form


=cut

use strict;
use warnings;
use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Source';
with 'pfappserver::Base::Form::Role::Help';
with 'pfappserver::Base::Form::Role::SourceLocalAccount';

has_field currency => (
    type => 'Select',
    default => 'USD',
    options_method => \&options_currency,
);

has_field 'send_email_confirmation' => (
   type => 'Toggle',
   label => 'Send billing confirmation',
   checkbox_value => 'enabled',
   unchecked_value => 'disabled',
);


has_field test_mode => (
    type => 'Checkbox',
    checkbox_value => '1',
    unchecked_value => '0',
);

=head2 options_currency

Currencies options for the a billing sources

=cut

sub options_currency {
    my ($field) = @_;
    my $form = $field->form;
    map {{value => $_, label => $_}} $form->currencies;
}

=head2 currencies

The list of currencies for the billing source

=cut

sub currencies { qw(USD CAD) }

# Form fields

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

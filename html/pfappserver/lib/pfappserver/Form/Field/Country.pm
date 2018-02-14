package pfappserver::Form::Field::Country;
=head1 NAME

pfappserver::Form::Field::Country add documentation

=cut

=head1 DESCRIPTION

pfappserver::Form::Field::Country

=cut

use strict;
use warnings;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Select';
use Locale::Country;
use namespace::autoclean;

our @COUNTRIES = Locale::Country::all_country_names();

our @DEFAULT_OPTIONS = map { { label => $_, value => uc(country2code($_)) } } sort @COUNTRIES;


sub build_options {
    return \@DEFAULT_OPTIONS;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


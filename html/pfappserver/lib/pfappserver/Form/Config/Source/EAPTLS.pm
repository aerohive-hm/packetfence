package pfappserver::Form::Config::Source::EAPTLS;

=head1 NAME

pfappserver::Form::Config::Source::EAPTLS

=cut

=head1 DESCRIPTION

Form definition to create or update an EAPTLS authentication source.

=cut

use strict;
use warnings;
use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Source';
with 'pfappserver::Base::Form::Role::Help', 'pfappserver::Base::Form::Role::InternalSource';

use pf::Authentication::Source::EAPTLSSource;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

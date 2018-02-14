package pfappserver::Form::Config::Fingerbank::Onboard;

=head1 NAME

pfappserver::Form::Config::Fingerbank::Onboard

=head1 DESCRIPTION

Form definition for Fingerbank onboarding procedure

=cut

use HTML::FormHandler::Moose;

extends 'pfappserver::Base::Form';

has_field 'api_key' => (
    type     => 'Text',
    label    => 'API Key',
    required => 1,
);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

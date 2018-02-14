package pfappserver::Form::Config::Source::Twilio;

=head1 NAME

pfappserver::Form::Config::Source::Twilio

=cut

=head1 DESCRIPTION

Form definition to create or update a Twilio authentication source.

=cut

use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'pfappserver::Form::Config::Source';
with 'pfappserver::Base::Form::Role::Help';
with 'pfappserver::Base::Form::Role::SourceLocalAccount';

has_field 'account_sid' => (
    type        => 'Text',
    label       => 'Account SID',
    required    => 1,
    # Default value needed for creating dummy source
    default     => '',
    tags        => {
        after_element   => \&help,
        help            => 'Twilio Account SID',
    },
);

has_field 'auth_token' => (
    type        => 'Text',
    label       => 'Auth Token',
    required    => 1,
    # Default value needed for creating dummy source
    default     => "",
    tags        => {
        after_element   => \&help,
        help            => 'Twilio Auth Token',
    },
);

has_field 'twilio_phone_number' => (
    type            => 'Text',
    label           => 'Phone Number (From)',
    required        => 1,
    # Default value needed for creating dummy source
    default         => "",
    tags            => {
        after_element   => \&help,
        help            => 'Twilio provided phone number which will show as the sender',
    },
    element_attr    => {
        placeholder     => pf::Authentication::Source::TwilioSource->meta->get_attribute('twilio_phone_number')->default,
    },
);

has_field 'pin_code_length' => (
    type => 'PosInteger',
    label => 'PIN Code Length',
    default => pf::Authentication::Source::TwilioSource->meta->get_attribute('pin_code_length')->default,
    tags => {
        after_element => \&help,
        help => 'The length of the PIN code to be sent over sms',
    },
);


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


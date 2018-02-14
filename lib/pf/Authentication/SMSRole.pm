package pf::Authentication::SMSRole;

=head1 NAME

pf::Authentication::SMSRole -

=cut

=head1 DESCRIPTION

pf::Authentication::SMSRole

=cut

use strict;
use warnings;
use Moose::Role;

has 'pin_code_length' => (default => 6, is => 'rw', isa => 'Int');

=head2 sendActivationSMS

Send the Activation SMS

=cut

sub sendActivationSMS {
    my ( $self, $pin, $mac ) = @_;
    require pf::activation;

    my $activation = pf::activation::view_by_code_mac($pf::activation::SMS_ACTIVATION, $pin, $mac);
    my $phone_number = $activation->{'contact_info'};

    return $self->sendSMS({to=> $phone_number, message => "PIN: $pin", activation => $activation});
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

package pfappserver::Form::Config::Provisioning::dpsk;

=head1 NAME

pfappserver::Form::Config::Provisioning::dpsk - Web form for Dynamic PSK provisioner

=head1 DESCRIPTION

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Provisioning';

has_field 'ssid' =>
  (
   type => 'Text',
   label => 'SSID',
  );

has_field 'psk_size' =>
  (
   type => 'PSKLength',
   default => 8,
   label => 'PSK length',
   tags => { after_element => \&help,
             help => 'This is the length of the PSK key you want to generate. The minimum length is eight characters.' },
  );

has_block definition =>
  (
   render_list => [ qw(id description type category ssid oses psk_size) ],
  );


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

package pfappserver::Form::Config::Provisioning::mobileiron;

=head1 NAME

pfappserver::Form::Config::Provisioning::mobileiron - Web form for mobileiron provisioner

=head1 DESCRIPTION

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Provisioning';
with 'pfappserver::Base::Form::Role::Help';

has_field username => (
    type => 'Text',
    required => 1,
);

has_field password => (
    type => 'ObfuscatedText',
    required => 1,
);

has_field host => (
    type => 'Text',
    required => 1,
);

has_field android_download_uri => (
    type => 'Text',
    required => 1,
);

has_field ios_download_uri => (
    type => 'Text',
    required => 1,
);

has_field windows_phone_download_uri => (
    type => 'Text',
    required => 1,
);

has_field boarding_host => (
    type => 'Text',
    required => 1,
);

has_field boarding_port => (
    type => 'Text',
    required => 1,
);

has_block definition =>
  (
   render_list => [ qw(id type description category oses username password host android_download_uri ios_download_uri windows_phone_download_uri boarding_host boarding_port) ],
  );

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};
1;

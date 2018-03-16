package pf::UnifiedApi::Controller::Config::Sources;

=head1 NAME

pf::UnifiedApi::Controller::Config::Sources - 

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Config::Sources

=cut

use strict;
use warnings;


use Mojo::Base qw(pf::UnifiedApi::Controller::Config::Subtype);

has 'config_store_class' => 'pf::ConfigStore::Source';
has 'form_class' => 'pfappserver::Form::Config::Source';
has 'primary_key' => 'source_id';

use pf::ConfigStore::Source;
use pfappserver::Form::Config::Source;
use pfappserver::Form::Config::Source::AdminProxy;
use pfappserver::Form::Config::Source::AD;
use pfappserver::Form::Config::Source::AuthorizeNet;
use pfappserver::Form::Config::Source::Blackhole;
use pfappserver::Form::Config::Source::EAPTLS;
use pfappserver::Form::Config::Source::Eduroam;
use pfappserver::Form::Config::Source::Email;
use pfappserver::Form::Config::Source::Facebook;
use pfappserver::Form::Config::Source::Github;
use pfappserver::Form::Config::Source::Google;
use pfappserver::Form::Config::Source::Htpasswd;
use pfappserver::Form::Config::Source::HTTP;
use pfappserver::Form::Config::Source::Instagram;
use pfappserver::Form::Config::Source::Kerberos;
use pfappserver::Form::Config::Source::Kickbox;
use pfappserver::Form::Config::Source::LDAP;
use pfappserver::Form::Config::Source::LinkedIn;
use pfappserver::Form::Config::Source::Mirapay;
use pfappserver::Form::Config::Source::Null;
use pfappserver::Form::Config::Source::OpenID;
use pfappserver::Form::Config::Source::Paypal;
use pfappserver::Form::Config::Source::Pinterest;
use pfappserver::Form::Config::Source::RADIUS;
use pfappserver::Form::Config::Source::SAML;
use pfappserver::Form::Config::Source::SMS;
use pfappserver::Form::Config::Source::SponsorEmail;
use pfappserver::Form::Config::Source::Stripe;
use pfappserver::Form::Config::Source::Twilio;
use pfappserver::Form::Config::Source::Twitter;
use pfappserver::Form::Config::Source::WindowsLive;

our %TYPES_TO_FORMS = (
    map { $_ => "pfappserver::Form::Config::Source::$_" } qw(
      AdminProxy
      AD
      AuthorizeNet
      Blackhole
      EAPTLS
      Eduroam
      Email
      Facebook
      Github
      Google
      Htpasswd
      HTTP
      Instagram
      Kerberos
      Kickbox
      LDAP
      LinkedIn
      Mirapay
      Null
      OpenID
      Paypal
      Pinterest
      RADIUS
      SAML
      SMS
      SponsorEmail
      Stripe
      Twilio
      Twitter
      WindowsLive
    )
);

sub type_lookup {
    return \%TYPES_TO_FORMS;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


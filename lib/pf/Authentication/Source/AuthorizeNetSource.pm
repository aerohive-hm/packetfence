package pf::Authentication::Source::AuthorizeNetSource;

=head1 NAME

pf::Authentication::Source::AuthorizeNetSource

=cut

=head1 DESCRIPTION

pf::Authentication::Source::AuthorizeNetSource

=cut

use strict;
use warnings;
use Moose;
use pf::config qw($default_pid $fqdn);
use pf::constants qw($FALSE $TRUE);
use pf::Authentication::constants;
use pf::util;
use pf::log;
use WWW::Curl::Easy;
use JSON::MaybeXS;
use List::Util qw(first);
use Digest::HMAC_MD5 qw(hmac_md5_hex);
use Digest::MD5 qw(md5_hex);
use Time::Local;

extends 'pf::Authentication::Source::BillingSource';
with 'pf::Authentication::CreateLocalAccountRole';

=head2 Attributes

=head2 class

=cut

has '+class' => (default => 'billing');

has '+type' => (default => 'AuthorizeNet');

has 'api_login_id' => (is => 'rw', required => 1);

has 'transaction_key' => (is => 'rw', required => 1);

has 'md5_hash' => (is => 'rw', required => 1);

has 'domains' => (is => 'rw', required => 1, default => '*.authorize.net');

=head2 prepare_payment

Prepare the payment from authorize.net

=cut

sub prepare_payment {
    my ($self, $session, $tier, $params, $uri) = @_;
    my $hash = {};
    $self->_calculate_fingerpint_hash($hash,$tier);
    return $hash;
}

=head2 _calculate_fingerpint_hash

Calculate the fingerprint hash

=cut

sub _calculate_fingerpint_hash {
    my ($self, $hash, $tier) = @_;
    my $amount    = $tier->{price};
    my $sequence  = time() + int(rand(10000));
#    my $timestamp = timegm(localtime());
    my $timestamp = time();
    my $fingerprint = hmac_md5_hex($self->api_login_id . "^" . $sequence . "^" . $timestamp . "^" . $amount . "^", $self->transaction_key);
    $hash->{fp_hash}      = $fingerprint;
    $hash->{fp_sequence}  = $sequence;
    $hash->{fp_timestamp} = $timestamp;
}

=head2 verify

Verify the payment from authorize.net

=cut

sub verify {
    my ($self, $session, $parameters, $uri) = @_;
    my $logger = pf::log::get_logger;
    my $md5_validation = md5_hex($self->md5_hash.$self->api_login_id.$parameters->{x_trans_id}.$parameters->{x_amount});
    if(uc($md5_validation) eq $parameters->{x_MD5_Hash}){
        $logger->info("Payment validation succeeded.");
    }
    else {
        die "Payment validation failed.";
    }
    return {};
}

=head2 cancel

Not implemented

=cut

sub cancel {
    my ($self, $session, $parameters, $uri) = @_;
    return {};
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

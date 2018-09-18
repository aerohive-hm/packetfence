package pfappserver::Controller::AMA;

=head1 NAME

pfappserver::Controller::AMA - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use strict;
use warnings;

use Moose;
use pf::error qw(is_success is_error);

use pf::log;
use pf::util;
use Data::Dumper;

use pf::api::unifiedapiclient;
use JSON;
use WWW::Curl::Easy;

BEGIN {extends 'pfappserver::Base::Controller';}

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(0) :AdminRole('SYSTEM_READ') {
    my ( $self, $c ) = @_;

}

=head2 begin

This controller defaults view is JSON.

=cut

sub begin :Private {
    my ( $self, $c ) = @_;
    $c->stash->{current_view} = 'JSON';
}

=head2

Linking nodes to the cloud

Usage: /ama/cloud_integration

=cut

sub cloud_integration :Local :Args() :AdminRole('SYSTEM_READ') {
    my ($self, $c) = @_;

    my $logger = get_logger();
    my $url = "http://127.0.0.1:10000/api/v1/configuration/cloud";
    my $input_data = $c->request->{parameters};

    if ($c->request->method eq 'POST'){

        my ($retcode, $response_body, $response_code) = _call_url('POST', $url, $input_data);

        if ($retcode == 0) {
            $c->stash->{A3_data} = $response_body;
            $c->response->status($response_code);
        }
        else {
            $logger->error("Failed to call POST $url ret: $retcode");
            $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
        }
    } elsif ($c->request->method eq 'GET') {
        my ($retcode, $response_body, $response_code) = _call_url('GET', $url, $input_data);

        if ($retcode == 0) {
            $c->stash->{A3_data} = $response_body;
            $c->response->status($response_code);
        }
        else {
            $logger->error("Failed to call POST $url ret: $retcode");
            $c->response->status($STATUS::INTERNAL_SERVER_ERROR);
        }
    } else {
        $c->response->status($STATUS::METHOD_NOT_ALLOWED);
    }
}

=head2 _call_url

=cut

sub _call_url {
    my ($method, $url, $input_data) = @_;
    my $curl = WWW::Curl::Easy->new;
    my $logger = get_logger();
    my $json = JSON->new->allow_nonref;
    if ($method eq 'POST') {
        $curl->setopt(CURLOPT_POST, 1);
    } elsif ($method eq 'GET') {
        $curl->setopt(CURLOPT_HTTPGET, 1);
    } else {
        return -1, "unsupported methods";
    }


    $curl->setopt(CURLOPT_URL, $url);


    $curl->setopt(CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);


    $curl->setopt(CURLOPT_POSTFIELDS, $json->encode($input_data));

    my $response_body;
    $curl->setopt(CURLOPT_WRITEDATA, \$response_body);

    my $retcode = $curl->perform;
    $logger->info("calling url $method: $url, with $input_data");

    if ($retcode == 0) {
        my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
        return $retcode, $response_body, $response_code;
    }

    return $retcode, undef, 500;

}

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

=head1 AUTHOR

Aerohive Networks, Inc. <info365@aerohive.com>

=head1 COPYRIGHT

Copyright (C) 2018 Aerohive Networks, Inc.

=cut

1;

package pf::radius::rpc;

=head1 NAME

pf::radius::rpc add documentation

=cut

=head1 DESCRIPTION

pf::radius::rpc

=cut

use strict;
use warnings;

use WWW::Curl::Easy;
use Data::MessagePack;

use base qw(Exporter);
our @EXPORT = qw(send_rpc_request build_msgpack_request send_msgpack_notification);

# Configuration parameter
use constant SOAP_PORT => '7070'; #TODO: See note1

sub send_rpc_request {
    use bytes;
    my ($config,$function,$data) = @_;
    my $response;
    my $curl = _curlSetup($config,$function);
    my $request = build_msgpack_request($function,$data);
    my $response_body;
    $curl->setopt(CURLOPT_POSTFIELDSIZE,length($request));
    $curl->setopt(CURLOPT_POSTFIELDS, $request);
    $curl->setopt(CURLOPT_WRITEDATA, \$response_body);

    # Starts the actual request
    my $curl_return_code = $curl->perform;

    # Looking at the results...
    if ( $curl_return_code == 0 ) {
        my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
        if($response_code == 200) {
            $response = Data::MessagePack->unpack($response_body);
        } else {
            die "An error occured while processing the MessagePack request return code ($response_code)";
        }
    } else {
        my $msg = "An error occured while sending a MessagePack request: $curl_return_code ".$curl->strerror($curl_return_code)." ".$curl->errbuf;
        die $msg;
    }

    return $response->[3];
}

sub _curlSetup {
    my ($config, $function) = @_;
    my ($server,$port,$proto,$user,$pass) = @{$config}{qw(server port proto user pass)};
    my $url = "$proto://${server}:${port}";
    my $curl = WWW::Curl::Easy->new;
    $curl->setopt(CURLOPT_HEADER, 0);
    $curl->setopt(CURLOPT_DNS_USE_GLOBAL_CACHE, 0);
    $curl->setopt(CURLOPT_NOSIGNAL, 1);
    $curl->setopt(CURLOPT_URL, $url);
    $curl->setopt(CURLOPT_HTTPHEADER, ['Content-Type: application/x-msgpack',"Request: $function"]);
    $curl->setopt(CURLOPT_SSL_VERIFYPEER, 0);
    if($user && $pass) {
        $curl->setopt(CURLOPT_HTTPAUTH, CURLOPT_HTTPAUTH);
        $curl->setopt(CURLOPT_USERNAME, $user);
        $curl->setopt(CURLOPT_PASSWORD, $pass);
    }
    return $curl;
}


sub build_msgpack_request {
    my ($function,$hash) = @_;
    my $request = [0,0,$function,[%$hash]];
    return Data::MessagePack->pack($request);
}

sub send_msgpack_notification {
    use bytes;
    my ($config,$function,$data) = @_;
    my $response;
    my $curl = _curlSetup($config,$function);
    my $request = build_msgpack_notification($function,$data);
    my $response_body;
    $curl->setopt(CURLOPT_POSTFIELDSIZE,length($request));
    $curl->setopt(CURLOPT_POSTFIELDS, $request);
    $curl->setopt(CURLOPT_WRITEDATA, \$response_body);

    # Starts the actual request
    my $curl_return_code = $curl->perform;

    # Looking at the results...
    if ( $curl_return_code != 0 ) {
        my $msg = "An error occured while sending a MessagePack request: $curl_return_code ".$curl->strerror($curl_return_code)." ".$curl->errbuf;
        die $msg;
    }

    return;
}



sub build_msgpack_notification {
    my ($function,$hash) = @_;
    my $request = [2,$function,[%$hash]];
    return Data::MessagePack->pack($request);
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


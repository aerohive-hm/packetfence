package pf::snmptrapd;

=head1 NAME

pfsnmptrapd

=cut

=head1 DESCRIPTION

pfsnmptrapd

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use JSON::MaybeXS;
use NetSNMP::TrapReceiver;
use pf::pfqueue::producer::redis;
#      "receivedfrom" : "UDP: [192.168.57.101]:36745->[192.168.57.101]",
our $TRAP_RECEIVED_FROM = qr/
    (?:UDP:\ \[)?
    (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})
    (?:\]\d+)?

/sx;

our $JSON = JSON::MaybeXS->new;

=head2 receiver

=cut

sub receiver {
    my ($trapInfo, $variables) = @_;
    #Serializing the OID to a string
    fixUpOids($variables);
    my $switchIp;
    if($trapInfo->{receivedfrom} =~ $TRAP_RECEIVED_FROM) {
        $trapInfo->{switchIp} = $switchIp = $1;
    }
    return NETSNMPTRAPD_HANDLER_FAIL unless defined $switchIp;
    my $producer = pf::pfqueue::producer::redis->new({
        redis => _redis_client(),
    });
#    Delay parsing by two seconds to allow snmp to do it's magic
    $producer->submit_delayed("pfsnmp_parsing", "pfsnmp_parsing", 2000, [$trapInfo, $variables]);
    return NETSNMPTRAPD_HANDLER_OK;
}

sub fixUpOids {
    my ($variables) = @_;
    foreach my $variable (@$variables) {
        $variable->[0] = $variable->[0]->quote_oid;
    }
}

NetSNMP::TrapReceiver::register("all", \&receiver) || warn "failed to register perl trap handler\n";

sub _redis_client {
    return pf::Redis->new(
        server    => '127.0.0.1:6380',
        reconnect => 1,
        every     => 100,
    );
}

 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

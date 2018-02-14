#!/usr/bin/perl 
#
# Copyright (C) 2005-2018 Inverse inc.
#
# Authors: Inverse inc. <info@inverse.ca> 
#

use strict;
use Error qw(:try);
use POSIX;
use SF::Logger;
use SF::IPAddr;

use XML::Smart;

use lib("../");
use SOAP::Lite;

use Constants;

#Do not do this at home
use IO::Socket::SSL;
IO::Socket::SSL::set_defaults(SSL_verify_mode => "SSL_VERIFY_NONE");
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;

                   ### Configuration Variables ###
my $config_file = "instance.conf";
                 ### End Configuration Variables ###

# Input Handling

my $prog = $0;
$prog =~ s/^.*\///;
if(@ARGV < 2){
    warn( "usage: $prog remediation sid ip\n");
    exit(INPUT_ERR);
}

my ($rem,$sid,$src_ip) = @ARGV;

my $XML = XML::Smart->new($config_file);

my %rem_config;

my $found=0;
my $net=0;

foreach my $localrem(@{$XML->{instance}->{remediation}}) {
    if($localrem->{name} =~ /^$rem$/) {
        $found=1;
	my @config = $XML->{instance}->{config}->nodes();
	foreach my $config (@config) {
            $rem_config{$config->{name}} = $config->content;
        }
    }

    $rem_config{'type'}=$localrem->{type};
}

if($found == 0) {
    sfinfo($prog,"input","$rem is not configured");
    exit(CONFIG_ERR);
}

# Do our stuff
eval {
   my $url = "https://" . $rem_config{'user'} . ":" . $rem_config{'password'} . "@" . $rem_config{'host_addr'} . ":" . $rem_config{'port'} . "/webapi";
   my $soap = new SOAP::Lite(
        uri => 'http://www.packetfence.org/PFAPI',
        proxy => $url
      );
   $soap->ssl_opts(verify_hostname => 0);
   $soap->{_transport}->{_proxy}->{ssl_opts}->{verify_hostname} = 0;

   my $date = POSIX::strftime("%m/%d-%H:%M:%S",localtime(time));

   my %event = (
       events => {
           detect => $sid,
       },
       srcip => $src_ip,
       date  => $date,
   );
   my $result = $soap->event_add(%event);

   if ($result->fault) {
      sferror($prog, "cmd_output", "violation could not be added: " . $result->faultcode . " - " . $result->faultstring . " - " . $result->faultdetail);
      exit(UNDEF);
   }
};

if ($@) {
    sferror($prog, "input", "connection to $rem_config{'host_addr'} with username $rem_config{'user'} was NOT successful: $@");
    exit(UNDEF);
}

exit(SUCCESS);

#!/usr/bin/perl

=head1 NAME

coa-calls.pl

=head1 DESCRIPTION

Create several CoA / Disconnect requests in a multi-threaded fashion to validate that we don't have concurrency issues.

=cut

use strict;
use warnings;

use threads;

use lib '/usr/local/pf/lib';
use pf::util::radius qw(perform_disconnect);

#my $coa_server_ip = '192.168.1.1';
my $coa_server_ip = '127.0.0.1';
my $coa_server_secret = 'qwerty';
my $nb_threads = $ARGV[0];
my $nb_requests_per_thread = $ARGV[1];
my $mac_prefix = "AA-BB-";

die "coa-calls: please specify the number of threads and the number of requests per thread on the command line" 
    if (!($nb_threads && $nb_requests_per_thread));

print "about to launch $nb_threads threads sending each $nb_requests_per_thread Disconnect-Request...\n";

# worker launcher
my @threads;
for (my $i = 0; $i<$nb_threads; $i++) {

  # create the thread
  push @threads, threads->create( \&coa_requests, $i);
}

# wait for everyone
foreach my $thread (@threads) {
  $thread->join();
}

sub coa_requests {

  my ($tid) = @_;
  
  my $mac_thread = sprintf("%02x", $tid);

  for(my $i=0; $i<$nb_requests_per_thread; $i++) {

    # generating last 6 mac digit with i (zero filled)
    my $zero_filled_i = sprintf('%06d', $i);
    $zero_filled_i =~ /(\d{2})(\d{2})(\d{2})/;
    my $mac_suffix = "-$1-$2-$3";
  
    my $mac = $mac_prefix . $mac_thread . $mac_suffix;
    print "thread $tid connection #$i: about to launch coa call with mac $mac\n";

    my $response = perform_disconnect(
        { nas_ip => $coa_server_ip, secret => $coa_server_secret },
        {
            'Calling-Station-Id' => $mac,
            'NAS-IP-Address' => $coa_server_ip,
        }
    );

    if ($response->{'Code'} eq 'Disconnect-ACK' && $response->{'Reply-Message'} eq $mac) {
        print "SUCCESS - Successfully kicked client $mac\n";
    } else {
        my $response = defined($response->{'Reply-Message'}) ? $response->{'Reply-Message'} : 'nothing';
        die("ERROR - invalid returned Code or Reply-Message expected $mac got: $response");
    }
  }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut


=head1 NAME

util::networking test

=cut

=head1 DESCRIPTION

util::networking test

=cut

use strict;
use warnings;
use lib '/usr/local/pf/lib';

BEGIN {
    #include test libs
    use lib qw(/usr/local/pf/t);
    #Module for overriding configuration paths
    use setup_test_config;
}

use Test::More tests => 10;
#This test will running last
use Test::NoWarnings;
use Socket;


use_ok("pf::util::networking");

my $data = "1" x (1024*64);

{
    socketpair(my $client, my $server, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or BAILOUT("Cannot create socketpair $!");

    is(pf::util::networking::syswrite_all($client,$data),length($data),"Writing all the bytes to a socket");

    is(pf::util::networking::sysread_all($server,my $read_buf, length($data)),length($data),"Reading all the bytes from a socket");

    is($read_buf,$data,"Bytes written to socket is equal to the bytes read from a socket");

    shutdown($client,2);
    shutdown($server,2);
    close($client);
    close($server);
}

{
    socketpair(my $client, my $server, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or BAILOUT("Cannot create socketpair $!");

    is(pf::util::networking::send_data_with_length($client,$data),length($data),"Writing data with embedded length to a socket");

    is(pf::util::networking::read_data_with_length($server,my $read_buf),length($data),"Reading data with embedded length to a socket");

    is($read_buf,$data,"Bytes written to socket is equal to the bytes read from a socket");

    shutdown($client,2);
    shutdown($server,2);
    close($client);
    close($server);
}

{
    socketpair(my $client, my $server, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or BAILOUT("Cannot create socketpair $!");
    my $pid = fork;
    BAILOUT("Cannot fork") unless defined $pid;
    if($pid) {
        is(pf::util::networking::sysread_all($server,my $read_buf, length($data)),length($data),"Reading all the bytes from a socket sent one byte at a time");
        is($read_buf,$data,"Bytes written to socket is equal to the bytes read from a socket sent one byte at a time");
    }
    else {
        my $data_length = length($data);
        #Writing to the buffer one byte at a time
        for (my $i = 0;$i < $data_length;$i++) {
            syswrite($client,$data,1,$i);
        }
        exit;
    }
    shutdown($client,2);
    shutdown($server,2);
    close($client);
    close($server);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

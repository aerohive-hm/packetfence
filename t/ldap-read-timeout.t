#!/usr/bin/perl

=head1 NAME

ldap-auth

=cut

=head1 DESCRIPTION

ldap-auth

=cut

package TestLdapServer;

use strict;
use warnings;
use Net::LDAP::Constant qw(LDAP_SUCCESS);
use Net::LDAP::Server;
use base 'Net::LDAP::Server';
use fields qw();

use constant RESULT_OK => {
    'matchedDN'    => '',
    'errorMessage' => '',
    'resultCode'   => LDAP_SUCCESS
};

# constructor
sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
    return $self;
}

# the bind operation
sub bind {
    my $self    = shift;
    my $reqData = shift;
    sleep 3;
    return RESULT_OK;
}

# the search operation
sub search {
    my $self    = shift;
    my $reqData = shift;
    my $base = $reqData->{'baseObject'};
    my @entries;
    if ($reqData->{'scope'}) {

        my $entry1 = Net::LDAP::Entry->new;
        $entry1->dn("cn=bob,$base");
        $entry1->add(
            cn          => 'bob',
            memberOf => ['CN=IS_Assurance,DC=ldap,DC=inverse,DC=ca'],
        );
        push @entries, $entry1;
    }
    else {
        # base
        my $entry = Net::LDAP::Entry->new;
        $entry->dn($base);
        $entry->add(
            dn => $base,
            sn => 'value1',
            cn => [qw(value1 value2)]
        );
        push @entries, $entry;
    }
    return RESULT_OK, @entries;
}

package Listener;
use Net::Daemon;
use base 'Net::Daemon';

sub Run {
    my $self = shift;

    my $handler = TestLdapServer->new($self->{socket});
    while (1) {
        my $finished = $handler->handle;
        if ($finished) {

            # we have finished with the socket
            $self->{socket}->close;
            return;
        }
    }
}

package main;
use strict;
use warnings;

use IO::Handle;
use POSIX;

pipe(my $reader, my $writer);
my $pid = fork();

exit 1 unless defined $pid;

unless ($pid) {
    close($reader);
    $writer->autoflush(1);
    my $listener = Listener->new(
        {   localport => 33389,
            logfile   => 'STDERR',
            pidfile   => '/tmp/pf-ldap.pid',
            mode      => 'single'
        }
    );
    $writer->write("done\n");
    close($writer);
    eval {
        $listener->Bind;
    };
    POSIX::_exit(0);
}

close($writer);
my $line = <$reader>;
close($reader);
sleep(1);

BEGIN {
    use lib qw(/usr/local/pf/lib);
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

use Test::More tests => 3;    # last test to print

use Test::NoWarnings;
use pf::authentication;
use pf::Authentication::constants;

my $source = getAuthenticationSource('LDAP0');

$source->cache->clear;

isa_ok($source,'pf::Authentication::Source::LDAPSource');

my $params = { username => 'bob', context => '' };

my @action = pf::authentication::match([$source], $params, $Actions::SET_ROLE);

is_deeply(\@action, [undef], "Timeout reading");

END {
    local $?;
    `kill \$(cat /tmp/pf-ldap.pid)`
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

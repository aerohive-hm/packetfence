package pf::services::manager::iptables;

=head1 NAME

pf::services::manager::iptables add documentation

=cut

=head1 DESCRIPTION

pf::services::manager::iptables

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw($install_dir);
use pf::log;
use pf::util;
use pf::iptables;
use pf::config qw(%Config);

extends 'pf::services::manager';

has '+name' => (default => sub { 'iptables' } );

has '+shouldCheckup' => ( default => sub { 1 }  );

has 'runningServices' => (is => 'rw', default => sub { 0 } );


=head2 start

start iptables

=cut

sub startService {
    my ($self) = @_;
    my $technique;
    unless ($self->isAlive()) {
        $technique = getIptablesTechnique();
        $technique->iptables_save($install_dir . '/var/iptables.bak');
    }
    $technique ||= getIptablesTechnique();
    $technique->iptables_generate();
    return 1;
}


=head2 getIptablesTechnique

getIptablesTechnique

=cut

sub getIptablesTechnique {
    require pf::inline::custom;
    my $iptables = pf::inline::custom->new();
    return $iptables->{_technique};
}

=head2 start

Wrapper around systemctl. systemctl should in turn call the actuall _start.

=cut

sub start {
    my ($self,$quick) = @_;
    system('sudo systemctl start packetfence-iptables');
    return $? == 0;
}

=head2 _start

start the service (called from systemd)

=cut

sub _start {
    my ($self) = @_;
    my $result = 0;
    unless ( $self->isAlive() ) {
        $result = $self->startService();
    }
    return $result;
}

=head2 stop

Wrapper around systemctl. systemctl should in turn call the actual _stop.

=cut

sub stop {
    my ($self) = @_;
    system('sudo systemctl stop packetfence-iptables');
    return 1;
}

=head2 _stop

stop iptables (called from systemd)

=cut

sub _stop {
    my ($self) = @_;
    my $logger = get_logger();
    if ( $self->isAlive() ) {
        getIptablesTechnique->iptables_restore( $install_dir . '/var/iptables.bak' );
    }
    return 1;
}

=head2 isAlive

Check if iptables is alive.
Since it's never really stopped then we check if the fake PID exists

=cut

sub isAlive {
    my ($self) = @_;
    my $logger = get_logger();
    my $result;
    my $pid = $self->pid;
    my $_EXIT_CODE_EXISTS = "0";
    my $rules_applied = defined( pf_run( "sudo " . $Config{'services'}{"iptables_binary"} . " -S | grep " . $pf::iptables::FW_FILTER_INPUT_MGMT ,accepted_exit_status => [$_EXIT_CODE_EXISTS]) );
    return ($pid && $rules_applied);
}

=head2 pid

Override the default method to check pid since there really is no such thing for iptables (it's not a process).

=cut

sub pid {
    my $self   = shift;
    my $result = `sudo systemctl show -p ActiveState packetfence-iptables`;
    chomp $result;
    my $state = ( split( '=', $result ) )[1];
    if ( grep { $state eq $_ } qw( active activating deactivating ) ) {
        return -1;
    }
    else { return 0; }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


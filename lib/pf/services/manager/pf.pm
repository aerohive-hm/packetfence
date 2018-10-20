package pf::services::manager::pf;

=head1 NAME

pf::services::manager::pf
Service manager for the virtual service "pf".
This manager allows using pfcmd to manage the packetfence.target as a service.

=cut

=head1 DESCRIPTION

pf::services::manager::pf

=cut

use strict;
use warnings;
use Term::ANSIColor;
use Moo;
use pf::constants qw($TRUE $FALSE);
use pf::log;
use pf::util::console;
use pf::cluster;
extends 'pf::services::manager';

has '+name' => ( default => sub {'pf'} );

has isvirtual    => ( is => 'rw', default => sub {1} );
has forceManaged => ( is => 'rw', default => sub {1} );

sub _buildpidFile { 0; }

sub isManaged {
    my ($self) = @_;
    return 1;
}

sub start {
    my ( $self, $quick ) = @_;
    my $result = 0;
    if ( $self->startService($quick) ) {
        $result = $self->postStartCleanup($quick);
    }
    return $result;
}

sub postStartCleanup {
    my ( $self, $quick ) = @_;
    return $TRUE;
}

=head2 _build_launcher

Build the command to lauch the service.

=cut 

sub _build_launcher {
    my ($self) = @_;
    if($cluster_enabled) {
        return "sudo systemctl isolate packetfence-cluster.target";
    } else {
        return "sudo systemctl isolate packetfence.target";
    }
}


sub print_status {
    my ($self) = @_;
    my @output = `systemctl --all --no-pager`;
    my $header = shift @output;
    my $colors = pf::util::console::colors();
    my $pid;
    my @manager;
    my $isManaged;
    for my $output (@output) {
        if ($output =~ /(packetfence-(.+)\.service)\s+loaded\s+active/) {
            my $service = $1;
            my $main_service = $2;
            my $sub_service = $main_service;
            if ($sub_service =~ /(radiusd).*/) {
                $sub_service = $1;
            }
            my @service = grep {$_ =~ /$sub_service/} @pf::services::ALL_SERVICES;
            if (@service == 0) {
                $pid = $self->sub_pid($service);
            } else {
                @manager = grep { $_->name eq $main_service } pf::services::getManagers(\@service);
                $pid = $manager[0]->pid;
            }
            $service .= (" " x (50 - length($service)));
            print "$service\t$colors->{success}started   ${pid}$colors->{reset}\n";
        } elsif ($output =~ /(packetfence-(.+)\.service)\s+loaded\s+(inactive|failed)/) {
            $pid = 0;
            my $service = $1;
            my $main_service = $2;
            my $sub_service = $main_service;
            if ($sub_service =~ /(radiusd).*/) {
                $sub_service = $1;
            }
            my @service = grep {$_ =~ /$sub_service/} @pf::services::ALL_SERVICES;
            if (@service == 0) {
                $pid = $self->sub_pid($service);
                $isManaged = $FALSE;
            } else {
                @manager = grep { $_->name eq $main_service } pf::services::getManagers(\@service);
                if (@manager) {
                    $pid = $manager[0]->pid;
                    $isManaged = $manager[0]->isManaged;
                }
            }
            $service .= (" " x (50 - length($service)));
            if (@manager && $isManaged && !$manager[0]->optional) {
                print "$service\t$colors->{error}stopped   ${pid}$colors->{reset}\n";
            } else {
                print "$service\t$colors->{warning}optional  ${pid}$colors->{reset}\n";
            }
        }
    }
}


sub sub_pid {
    my ($self, $service) = @_;
    my $logger = get_logger();
    my $pid = `sudo systemctl show -p MainPID $service`;
    chomp $pid;
    $pid = (split(/=/, $pid))[1];
    if (defined $pid) {
        $logger->debug("sudo systemctl $service returned $pid");
    } else {
        $logger->error("Error getting pid for $service");
    }
    return $pid;
}

sub pid {
    my ($self) = @_;
    my @status;
    if($cluster_enabled) {
        @status = `sudo systemctl status packetfence-cluster.target`;
    } else {
        @status = `sudo systemctl status packetfence.target`;
    }
    my $pid = grep {/Active: active/} @status;
    return $pid;
}

=head2 stop

Stop the service waiting for it to shutdown

=cut

sub stop {
    my ( $self, $quick ) = @_;
    my $pid = $self->pid;
    if ($pid) {
        $self->stopService($quick);
        return 1;
    }
    return;
}

sub stopService {
    my ($self) = @_;
    my $logger = get_logger();
    $logger->info("Stopping packetfence.target");
    `sudo systemctl isolate packetfence-base.target`;
    if ( $? == -1 ) {
        $logger->error("failed to execute: $!\n");
    }
    else {
        $logger->info( "systemctl isolate packetfence-base  exited with value %d\n", $? >> 8 );
    }
}

=head2 systemdTarget

systemdTarget

=cut

sub systemdTarget {
    my ($self) = @_;
    return "packetfence.target";
}
=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

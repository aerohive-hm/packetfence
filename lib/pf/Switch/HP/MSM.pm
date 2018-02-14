package pf::Switch::HP::MSM;

=head1 NAME

pf::Switch::HP::MSM

=head1 SYNOPSIS

The pf::Switch::HP::MSM module manages access to HP Procurve access point MSM

=head1 STATUS

Should work on all HP Wireless Access Point

=cut

use strict;
use warnings;

use POSIX;

use base ('pf::Switch::HP::Controller_MSM710');

use pf::file_paths qw($lib_dir);
sub description { 'HP ProCurve MSM Access Point' }

# importing switch constants
use pf::Switch::constants;
use pf::util;

=head1 SUBROUTINES

=over

=cut

=item _deauthenticateMacWithSSH

Method to deauthenticate a node with SSH

=cut

sub _deauthenticateMacWithSSH {
    my ( $self, $mac ) = @_;
    my $logger = $self->logger;
    my $session;
    my @addition_ops;
    if (defined $self->{_disconnectPort} && $self->{_cliTransport} eq 'SSH' ) {
        @addition_ops = (
            connect_options => {
                ops => [ '-p' => $self->{_disconnectPort}  ]
            }
        );
    }
    eval {
        require Net::Appliance::Session;
        $session = Net::Appliance::Session->new(
            Host      => $self->{_ip},
            Timeout   => 20,
            Transport => $self->{_cliTransport},
            Platform => 'HP',
            Source   => $lib_dir.'/pf/Switch/HP/nas-pb.yml',
            @addition_ops
        );
        $session->connect(
            Name     => $self->{_cliUser},
            Password => $self->{_cliPwd}
        );
    };

    if ($@) {
        $logger->error( "ERROR: Can not connect to controller $self->{'_ip'} using "
                . $self->{_cliTransport} );
        return 1;
    }
    $session->cmd("enable");
    $session->cmd("disassociate wireless client $mac");
    $session->close();

    return 1;
}

=item deauthTechniques

Return the reference to the deauth technique or the default deauth technique.

=cut

sub deauthTechniques {
    my ($self, $method) = @_;
    my $logger = $self->logger;
    my $default = $SNMP::SSH;
    my %tech = (
        $SNMP::SSH  => '_deauthenticateMacWithSSH',
    );

    if (!defined($method) || !defined($tech{$method})) {
        $method = $default;
    }
    return $method,$tech{$method};
}


=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

package captiveportal::PacketFence::Controller::Remediation;
use Moose;
use namespace::autoclean;
use pf::web;
use pf::violation;
use pf::class;
use pf::node;
use List::Util qw(first);
use pf::config qw(%Config);
use pf::util;
use File::Spec::Functions;

BEGIN { extends 'captiveportal::Base::Controller'; }

=head1 NAME

captiveportal::PacketFence::Controller::Remediation - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    my $portalSession = $c->portalSession;
    my $mac           = $portalSession->clientMac;
    my $logger        = $c->log;

    $c->stash->{'user_agent'} = $c->request->user_agent;
    my $request = $c->req;

    # check for open violations
    my $violation = $self->getViolation($c);

    if ($violation) {

        # There is a violation, redirect the user
        # FIXME: there is not enough validation below
        my $vid      = $violation->{'vid'};
        my $class = class_view($vid);

        # Retrieve violation template name
        my $template = $class->{'template'};

        my $node_info = node_view($mac);
        $c->stash(
            'title'        => "violation: quarantine established",
            'template'     => 'remediation.html',
            'notes'        => $violation->{'notes'},
            map { $_ => $node_info->{$_} }
              qw(dhcp_fingerprint last_switch last_port
              last_vlan last_connection_type last_ssid username)
        );

        # Find the subtemplate
        my $langs = $c->forward(Root => 'getLanguages');
        $c->stash->{sub_template} = $c->profile->findViolationTemplate($template, $langs);

    } else {
        $logger->info( "No open violation for " . $mac );

        # TODO - rework to not show "Your computer was not found in the A3 database. Please reboot to solve this issue."
        $self->showError( $c, "error: not found in the database" );
    }
}


sub scan_status : Private {
    my ( $self, $c, $scan_start_time ) = @_;
    my $portalSession = $c->portalSession;

    $c->stash(
        title => "scan: scan in progress",
        template    => 'scan-in-progress.html',
        timer         => $Config{'captive_portal'}{'network_redirect_delay'},
        txt_message => [
            'scan in progress contact support if too long',
            $scan_start_time
        ],
    );
}

sub getViolation {
    my ( $self, $c ) = @_;
    my $violation     = $c->stash->{violation};
    unless($violation) {
        my $mac           = $c->portalSession->clientMac;
        $c->stash->{violation} = $violation = violation_view_top($mac);
    }
    return $violation;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

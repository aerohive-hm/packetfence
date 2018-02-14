package pf::scan::wmi;

=head1 NAME

pf::scan::wmi

=cut

=head1 DESCRIPTION

pf::scan::wmi is a module to add WMI scanning option.

=cut

use strict;
use warnings;

use pf::log;
use Readonly;

use base ('pf::scan');

use pf::config;
use pf::scan;
use pf::util;
use pf::node;
use pf::scan::wmi::rules;
use pf::violation qw(violation_close);
use pf::api::jsonrpcclient;

sub description { 'WMI Scanner' }

=head1 SUBROUTINES

=over   

=item new

Create a new WMI scanning object with the required attributes

=cut

sub new {
    my ( $class, %data ) = @_;
    my $logger = get_logger();

    $logger->debug("Instantiating a new pf::scan::wmi scanning object");

    my $self = bless {
            '_id'       => undef,
            '_username' => undef,
            '_password' => undef,
            '_scanIp'   => undef,
            '_report'   => undef,
            '_file'     => undef,
            '_policy'   => undef,
            '_type'     => undef,
            '_status'   => undef,
            '_domain'   => undef,
            '_oses'     => undef,
            '_categories' => undef,
    }, $class;

    foreach my $value ( keys %data ) {
        $self->{'_' . $value} = $data{$value};
    }

    return $self;
}

=item startScan

=cut

# WARNING: A lot of extra single quoting has been done to fix perl taint mode issues: #1087
sub startScan {
    my ( $self ) = @_;
    my $logger = get_logger();

    my $rule_tester = new pf::scan::wmi::rules;
    my $result = $rule_tester->test($self);
 
    my $scan_vid = $pf::constants::scan::POST_SCAN_VID;
    $scan_vid = $pf::constants::scan::SCAN_VID if ($self->{'_registration'});
    $scan_vid = $pf::constants::scan::PRE_SCAN_VID if ($self->{'_pre_registration'});

    if (!$result) {
        $logger->warn("WMI scan didnt start");
        return $scan_vid;
    }

    my $apiclient = pf::api::jsonrpcclient->new;
    my %data = (
       'vid' => $scan_vid,
       'mac' => $self->{'_scanMac'},
    );
    $apiclient->notify('close_violation', %data );

    $self->setStatus($pf::constants::scan::STATUS_CLOSED);
    $self->statusReportSyncToDb();
    return 0;
}

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

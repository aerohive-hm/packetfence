package pf::scan::openvas;

=head1 NAME

pf::scan::openvas

=cut

=head1 DESCRIPTION

pf::scan::openvas is a module to add OpenVAS scanning option.

=cut

use strict;
use warnings;

use pf::log;
use MIME::Base64;
use Readonly;

use base ('pf::scan');

use pf::constants;
use pf::constants::scan qw($SCAN_VID $PRE_SCAN_VID $POST_SCAN_VID $STATUS_STARTED);
use pf::config qw(%Config);
use pf::util;

sub description { 'Openvas Scanner' }

Readonly our $RESPONSE_OK                   => 200;
Readonly our $RESPONSE_RESOURCE_CREATED     => 201;
Readonly our $RESPONSE_REQUEST_SUBMITTED    => 202;

=head1 METHODS

=over

=item createEscalator

Create an escalator which will trigger an action on the OpenVAS server once the scan will finish

=cut

sub createEscalator {
    my ( $self ) = @_;
    my $logger = get_logger();

    my $name = $self->{_id};
    my $callback = $self->_generateCallback();
    my $command = _get_escalator_string($name, $callback);

    $logger->info("Creating a new scan escalator named $name");

    my $cmd = "omp -h $self->{_ip} -p $self->{_port} -u $self->{_username} -w $self->{_password} -X '$command'";
    $logger->trace("Scan escalator creation command: $cmd");
    my $output = pf_run($cmd);
    chomp($output);
    $logger->trace("Scan escalator creation output: $output");

    # Fetch response status and escalator id
    my ($response, $escalator_id) = ($output =~ /<create_escalator_response\
            status="([0-9]+)"\      # status code
            id="([a-zA-Z0-9\-]+)"   # escalator id
            /x);

    # Scan escalator successfully created
    if ( defined($response) && $response eq $RESPONSE_RESOURCE_CREATED ) {
        $logger->info("Scan escalator named $name successfully created with id: $escalator_id");
        $self->{_escalatorId} = $escalator_id;
        return $TRUE;
    }

    $logger->warn("There was an error creating scan escalator named $name, here's the output: $output");
    return;
}

=item createTarget

Create a target (a target is a host to scan)

=cut

sub createTarget {
    my ( $self ) = @_;
    my $logger = get_logger();

    my $name = $self->{_id};
    my $target_host = $self->{_scanIp};
    my $command = "<create_target><name>$name</name><hosts>$target_host</hosts></create_target>";

    $logger->info("Creating a new scan target named $name for host $target_host");

    my $cmd = "omp -h $self->{_ip} -p $self->{_port} -u $self->{_username} -w $self->{_password} -X '$command'";
    $logger->trace("Scan target creation command: $cmd");
    my $output = pf_run($cmd);
    chomp($output);
    $logger->trace("Scan target creation output: $output");

    # Fetch response status and target id
    my ($response, $target_id) = ($output =~ /<create_target_response\
            status="([0-9]+)"\      # status code
            id="([a-zA-Z0-9\-]+)"   # task id
            /x);

    # Scan target successfully created
    if ( defined($response) && $response eq $RESPONSE_RESOURCE_CREATED ) {
        $logger->info("Scan target named $name successfully created with id: $target_id");
        $self->{_targetId} = $target_id;
        return $TRUE;
    }

    $logger->warn("There was an error creating scan target named $name, here's the output: $output");
    return;
}

=item createTask

Create a task (a task is a scan) with the existing config id and previously created target and escalator

=cut

sub createTask {
    my ( $self )  = @_;
    my $logger = get_logger();

    my $name = $self->{_id};

    $logger->info("Creating a new scan task named $name");

    my $command = _get_task_string(
        $name, $self->{_openvas_configid}, $self->{_targetId}, $self->{_escalatorId}
    );
    my $cmd = "omp -h $self->{_ip} -p $self->{_port} -u $self->{_username} -w $self->{_password} -X '$command'";
    $logger->trace("Scan task creation command: $cmd");
    my $output = pf_run($cmd);
    chomp($output);
    $logger->trace("Scan task creation output: $output");

    # Fetch response status and task id
    my ($response, $task_id) = ($output =~ /<create_task_response\
            status="([0-9]+)"\      # status code
            id="([a-zA-Z0-9\-]*)"   # task id
            /x);

    # Scan task successfully created
    if ( defined($response) && $response eq $RESPONSE_RESOURCE_CREATED ) {
        $logger->info("Scan task named $name successfully created with id: $task_id");
        $self->{_taskId} = $task_id;
        return $TRUE;
    }

    $logger->warn("There was an error creating scan task named $name, here's the output: $output");
    return;
}

=item processReport

Retrieve the report associated with a task.
When retrieving a report in other format than XML, we received the report in base64 encoding.

Report processing's duty is to ensure that the proper violation will be triggered.

=cut

sub processReport {
    my ( $self ) = @_;
    my $logger = get_logger();

    my $name                = $self->{_id};
    my $report_id           = $self->{_reportId};
    my $report_format_id    = $self->{'_openvas_reportformatid'};
    my $command             = "<get_reports report_id=\"$report_id\" format_id=\"$report_format_id\"/>";

    $logger->info("Getting the scan report for the finished scan task named $name");

    my $cmd = "omp -h $self->{_ip} -p $self->{_port} -u $self->{_username} -w $self->{_password} -X '$command'";
    $logger->trace("Report fetching command: $cmd");
    my $output = pf_run($cmd);
    chomp($output);
    $logger->trace("Report fetching output: $output");

    # Fetch response status and report
    my ($response, $raw_report) = ($output =~ /<get_reports_response\
            status="([0-9]+)"       # status code
            [^\<]+[\<][^\>]+[\>]    # get to the report
            ([a-zA-Z0-9\=]+)        # report base64 encoded
            /x);

    # Scan report successfully fetched
    if ( defined($response) && $response eq $RESPONSE_OK && defined($raw_report) ) {
        $logger->info("Report id $report_id successfully fetched for task named $name");
        $self->{_report} = decode_base64($raw_report);   # we need to decode the base64 report

        # We need to manipulate the scan report.
        # Each line of the scan report is pushed into an arrayref
        $self->{'_report'} = [ split("\n", $self->{'_report'}) ];
        my $scan_vid = $POST_SCAN_VID;
        $scan_vid = $SCAN_VID if ($self->{'_registration'});
        $scan_vid = $PRE_SCAN_VID if ($self->{'_pre_registration'});
        pf::scan::parse_scan_report($self,$scan_vid);

        return $TRUE;
    }

    $logger->warn("There was an error fetching the scan report for the task named $name, here's the output: $output");
    return;
}

=item new

Create a new Openvas scanning object with the required attributes

=cut

sub new {
    my ( $class, %data ) = @_;
    my $logger = get_logger();

    $logger->debug("Instantiating a new pf::scan::openvas scanning object");

    my $self = bless {
            '_id'               => undef,
            '_ip'               => undef,
            '_port'             => undef,
            '_username'         => undef,
            '_password'         => undef,
            '_scanIp'           => undef,
            '_scanMac'          => undef,
            '_report'           => undef,
            '_openvas_configId'         => undef,
            '_openvas_reportFormatId'   => undef,
            '_targetId'         => undef,
            '_escalatorId'      => undef,
            '_taskId'           => undef,
            '_reportId'         => undef,
            '_status'           => undef,
            '_type'             => undef,
            '_oses'             => undef,
            '_categories'         => undef,
    }, $class;

    foreach my $value ( keys %data ) {
        $self->{'_' . $value} = $data{$value};
    }

    return $self;
}

=item startScan

That's where we use all of these method to run a scan

=cut

sub startScan {
    my ( $self ) = @_;
    my $logger = get_logger();

    $self->createTarget();
    $self->createEscalator();
    $self->createTask();
    $self->startTask();
}

=item startTask

Start a scanning task with the previously created target and escalator

=cut

sub startTask {
    my ( $self ) = @_;
    my $logger = get_logger();

    my $name    = $self->{_id};
    my $task_id = $self->{_taskId};
    my $command = "<start_task task_id=\"$task_id\"/>";

    $logger->info("Starting scan task named $name");

    my $cmd = "omp -h $self->{_ip} -p $self->{_port} -u $self->{_username} -w $self->{_password} -X '$command'";
    $logger->trace("Scan task starting command: $cmd");
    my $output = pf_run($cmd);
    chomp($output);
    $logger->trace("Scan task starting output: $output");

    # Fetch response status and report id
    my ($response, $report_id) = ($output =~ /<start_task_response\
            status="([0-9]+)"[^\<]+[\<] # status code
            report_id>([a-zA-Z0-9\-]+)  # report id
            /x);

    # Scan task successfully started
    if ( defined($response) && $response eq $RESPONSE_REQUEST_SUBMITTED ) {
        $logger->info("Scan task named $name successfully started");
        $self->{_reportId} = $report_id;
        $self->{'_status'} = $STATUS_STARTED;
        $self->statusReportSyncToDb();
        return $TRUE;
    }

    $logger->warn("There was an error starting the scan task named $name, here's the output: $output");
    return;
}

=item _generateCallback

Escalator callback needs to be different if we are running OpenVAS locally or remotely.

Local: plain HTTP on loopback (127.0.0.1)

Remote: HTTPS with fully qualified domain name on admin interface

=cut

sub _generateCallback {
    my ( $self ) = @_;
    my $logger = get_logger();

    my $name = $self->{'_id'};
    my $callback = "<method>HTTP Get<data>";
    if ($self->{'_ip'} eq '127.0.0.1') {
        $callback .= "http://127.0.0.1/scan/report/$name";
    }
    else {
        $callback .= "https://$Config{general}{hostname}.$Config{general}{domain}:$Config{ports}{admin}/scan/report/$name";
    }
    $callback .= "<name>URL</name></data></method>";

    $logger->debug("Generated OpenVAS callback is: $callback");
    return $callback;
}

=back

=head1 SUBROUTINES

=over

=item _get_escalator_string

create_escalator string creation.

=cut

sub _get_escalator_string {
    my ($name, $callback) = @_;

    return <<"EOF";
<create_escalator>
  <name>$name</name>
  <condition>Always<data>High<name>level</name></data><data>changed<name>direction</name></data></condition>
  <event>Task run status changed<data>Done<name>status</name></data></event>
  $callback
</create_escalator>
EOF
}

=item _get_task_string

create_task string creation.

=cut

sub _get_task_string {
    my ($name, $config_id, $target_id, $escalator_id) = @_;

    return <<"EOF";
<create_task>
  <name>$name</name>
  <config id=\"$config_id\"/>
  <target id=\"$target_id\"/>
  <escalator id=\"$escalator_id\"/>
</create_task>
EOF
}

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

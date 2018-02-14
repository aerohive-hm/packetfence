=head1 NAME

symantec2

=cut

=head1 DESCRIPTION

symantec2

=cut

use strict;
use warnings;

use lib qw(/usr/local/pf/lib);
BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}

use Test::More tests => 7;                      # last test to print

use Test::NoWarnings;

our $xmlZero = <<'XML';
<?xml version="1.0" encoding="UTF-8"?>
<ise_api>
    <name>attributes</name>
    <api_version>1</api_version>
    <paging_info>0</paging_info>
    <deviceList></deviceList>
</ise_api>
XML

our $xmlOne = <<'XML';
<?xml version="1.0" encoding="UTF-8"?>
<ise_api>
    <name>attributes</name>
    <api_version>1</api_version>
    <paging_info>0</paging_info>
    <deviceList>
        <device>
            <macaddress>182032973F6E</macaddress>
            <attributes>
                <register_status>true</register_status>
                <compliance>
                    <status>true</status>
                    <failure_reason>something not compliant</failure_reason>
                </compliance>
                <pin_lock_on>true</pin_lock_on>
                <jail_broken>false</jail_broken>
                <imei>1234567890</imei>
                <os_version>Android,2.3.2</os_version>
            </attributes>
        </device>
    </deviceList>
</ise_api>
XML

our $xmlTwo = <<'XML';
<?xml version="1.0" encoding="UTF-8"?>
<ise_api>
    <name>attributes</name>
    <api_version>1</api_version>
    <paging_info>0</paging_info>
    <deviceList>
        <device>
            <macaddress>182032973F6F</macaddress>
            <attributes>
                <register_status>true</register_status>
                <compliance>
                    <status>false</status>
                    <failure_reason>something not compliant</failure_reason>
                </compliance>
                <pin_lock_on>true</pin_lock_on>
                <jail_broken>false</jail_broken>
                <imei>1234567890</imei>
                <os_version>Android,2.3.2</os_version>
            </attributes>
        </device>
        <device>
            <macaddress>182032973F6E</macaddress>
            <attributes>
                <register_status>true</register_status>
                <compliance>
                    <status>true</status>
                    <failure_reason>something not compliant</failure_reason>
                </compliance>
                <pin_lock_on>true</pin_lock_on>
                <jail_broken>false</jail_broken>
                <imei>1234567890</imei>
                <os_version>Android,2.3.2</os_version>
            </attributes>
        </device>
    </deviceList>
</ise_api>
XML


use pf::provisioner::symantec;
use HTTP::Response;

my $response = HTTP::Response->new;

my $provisioner = pf::provisioner::symantec->new( { oses => [ qw(Android)] });

#print "xmlZero is_valid\n" if is_valid(undef,$xmlZero,"18:20:32:97:3f:6e");
#print "xmlOne is_valid\n" if is_valid(undef,$xmlOne,"18:20:32:97:3f:6e");
#print "xmlTwo is_valid\n" if is_valid(undef,$xmlTwo,"18:20:32:97:3f:6e");

$response->content($xmlZero);

ok(!$provisioner->is_valid($response,"18:20:32:97:3f:6e"));

$response->content($xmlOne);

ok($provisioner->is_valid($response,"18:20:32:97:3f:6e"));
ok(!$provisioner->is_valid($response,"18:20:32:97:3f:6f"));

$response->content($xmlTwo);

ok($provisioner->is_valid($response,"18:20:32:97:3f:6e"));
ok(!$provisioner->is_valid($response,"18:20:32:97:3f:6f"));
ok(!$provisioner->is_valid($response,"18:20:32:97:3f:6a"));

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

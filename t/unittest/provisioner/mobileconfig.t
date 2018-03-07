=head1 NAME

provisioner

=cut

=head1 DESCRIPTION

provisioner

=cut

use strict;
use warnings;
# pf core libs
use lib '/usr/local/pf/lib';

BEGIN {
    use lib qw(/usr/local/pf/t);
    use setup_test_config;
}
use Test::More tests => 5;

use Test::NoWarnings;
use Test::Exception;

our $TEST_CATEGORY = "test";

our $ANDROID_DEVICE = 'Android OS';
our $APPLE_DEVICE   = 'iOS',
our $TEST_NODE_ATTRIBUTE = { category => $TEST_CATEGORY };

use_ok("pf::provisioner::mobileconfig");

my $provisioner = new_ok(
    "pf::provisioner::mobileconfig",
    [{
        category => [$TEST_CATEGORY],
    }]
);

ok(!$provisioner->match($ANDROID_DEVICE,$TEST_NODE_ATTRIBUTE),"Does not match android device");

ok($provisioner->match($APPLE_DEVICE,$TEST_NODE_ATTRIBUTE),"Matches apple device");

1;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;



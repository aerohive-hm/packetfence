=head1 NAME

admin_roles

=cut

=head1 DESCRIPTION

admin_roles

=cut

use strict;
use warnings;
BEGIN {
    use lib qw(/usr/local/pf/t /usr/local/pf/lib);
    use setup_test_config;
}

use Test::More tests => 7;                      # last test to print

use Test::NoWarnings;

use_ok("pf::admin_roles");

ok(admin_can(["User Manager"],'USERS_CREATE'),"User Manager can create a user");

ok(!admin_can(["User Manager"],'NODES_READ'),"User Manager cannot read a node");

ok(admin_can(["ALL"],'USERS_CREATE'),"ALL can create a user");

is_deeply(
    [admin_allowed_options(["User Manager"], 'allowed_access_levels')],
    ['User Manager', 'Node Manager', 'NONE'],
    "User Manager allowed options for access levels"
);

is_deeply(
    [admin_allowed_options(['User Manager',"Alt User Manager"], 'allowed_access_levels')],
    ['User Manager', 'Node Manager', 'NONE','Violation Manager'],
    "Alt User Manager and User Manager allowed options for access levels"
);
 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;



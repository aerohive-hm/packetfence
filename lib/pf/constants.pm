package pf::constants;
=head1 NAME

pf::constants add documentation

=cut

=head1 DESCRIPTION

pf::constants

=cut

use strict;
use warnings;
use Readonly;
use base qw(Exporter);
our @EXPORT = qw(
    $FALSE $TRUE $YES $NO $default_pid $admin_pid $YELLOW_COLOR $RED_COLOR $GREEN_COLOR
    $HTTP $HTTPS $HTTP_PORT $HTTPS_PORT $ZERO_DATE $DEFAULT_TENANT_ID
);

# some global constants
Readonly::Scalar our $FALSE => 0;
Readonly::Scalar our $TRUE => 1;
Readonly::Scalar our $YES => 'yes';
Readonly::Scalar our $NO => 'no';
Readonly::Scalar our $default_pid => 'default';
Readonly::Scalar our $admin_pid => 'admin';
Readonly::Scalar our $YELLOW_COLOR => 'yellow';
Readonly::Scalar our $RED_COLOR => 'red';
Readonly::Scalar our $GREEN_COLOR => 'green';
Readonly::Scalar our $ZERO_DATE => '0000-00-00 00:00:00';

Readonly::Hash our %BUILTIN_USERS => (
    $default_pid => 1, 
    $admin_pid => 1,
);

Readonly::Scalar our $HTTP_PORT => 80;
Readonly::Scalar our $HTTPS_PORT => 443;

Readonly::Scalar our $HTTP => "http";
Readonly::Scalar our $HTTPS => "https";

Readonly::Scalar our $DEFAULT_TENANT_ID => 1;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

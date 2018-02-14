package pf::web::apache2_version;

=head1 NAME

pf::web::apache2_version

=head1 SYNOPSIS

This module is to change remote_ip to client_ip as it was changed in Apache2.4::Connection Perl WebAPI

=cut

use strict;
use warnings;

use Apache2::Connection ();

*Apache2::Connection::remote_ip = *Apache2::Connection::client_ip;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

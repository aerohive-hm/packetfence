package pfconfig::constants;

=head1 NAME

pfconfig::constants

=cut

=head1 DESCRIPTION

pfconfig::constants

Constants for pfconfig

=cut

use strict;
use warnings;
use Readonly;

our $CONFIG_FILE_PATH = "/usr/local/pf/conf/pfconfig.conf";
our $SOCKET_PATH = "/usr/local/pf/var/run/pfconfig.sock";
Readonly::Scalar our $CONTROL_FILE_DIR => "/usr/local/pf/var/control";


Readonly::Scalar our $DEFAULT_BACKEND => "mysql";

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:


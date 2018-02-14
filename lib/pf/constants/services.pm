package pf::constants::services;

=head1 NAME

pf::constants::services

=head1 DESCRIPTION

Constants for the services

=cut


use base qw(Exporter);

our @EXPORT_OK = qw(JUST_MANAGED);

use constant {
    JUST_MANAGED                => 0b0000001,
};

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

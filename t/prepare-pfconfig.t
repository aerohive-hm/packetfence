#!/usr/bin/perl

=head1 NAME

prepare-pfconfig.t

=cut

=head1 DESCRIPTION

Used to store the sample data into pfconfig before the tests instead of the
data in the normal configuration directory

=cut



BEGIN {
    # log4perl init
    use constant INSTALL_DIR => '/usr/local/pf';
    use lib INSTALL_DIR . "/lib";
    use lib INSTALL_DIR . "/t";
    use setup_test_config;
}

use pfconfig::manager;

pfconfig::manager->new->expire_all;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:


#!/usr/bin/perl
=head1 NAME

webservices_modperl_require add documentation

=cut

=head1 DESCRIPTION

webservices_modperl_require

=cut

BEGIN {
    use lib "/usr/local/pf/lib";
    use pf::log 'service' => 'httpd.webservices', reinit => 1;
}

use pf::config();
use pf::node();
use pf::locationlog();
use pf::ip4log();
use pf::violation();
use pf::util();
use pf::radius::custom();

1;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut


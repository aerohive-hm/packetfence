#!/usr/bin/perl
=head1 NAME

aaa_modperl_require

=cut

=head1 DESCRIPTION

aaa_modperl_require

=cut

BEGIN {
    use lib "/usr/local/pf/lib";
    use pf::log 'service' => 'httpd.aaa', reinit => 1;
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


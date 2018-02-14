package pf::web::dispatcher::custom;

=head1 NAME

pf::web::dispatcher

=cut

=head1 DESCRIPTION

=cut

use strict;
use warnings;

use Apache2::Const -compile => qw(OK DECLINED HTTP_MOVED_TEMPORARILY);
use Apache2::RequestIO ();
use Apache2::RequestRec ();
use Apache2::Response ();
use Apache2::RequestUtil ();
use Apache2::ServerRec;

use APR::Table;
use APR::URI;
use Template;
use URI::Escape::XS qw(uri_escape);

use pf::config;
use pf::util;
use pf::web::constants;
use pf::proxypassthrough::constants;

use base ('pf::web::dispatcher');

BEGIN {
    use pf::log 'service' => 'httpd.portal';
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


package pf::WebAPI::AuthenHandler;
=head1 NAME

pf::WebAPI::AuthenHandler

=cut

=head1 DESCRIPTION

pf::WebAPI::AuthenHandler provides the authentication for the webservice api

=cut

use strict;
use warnings;


use strict;
use warnings;

use Apache2::Access ();
use Apache2::RequestUtil ();
use Apache2::RequestRec;

use Apache2::Const -compile => qw(OK DECLINED HTTP_UNAUTHORIZED);

use pf::config qw(%Config);
use pf::log;


=head1 METHODS

=head2 handler

apache handler for webservices authentication

=cut

sub handler {
    my $r = shift;
    my $status = Apache2::Const::OK;
    my ($webservices_user,$webservices_pass) = @{$Config{webservices}}{qw(user pass)};
    if(defined $webservices_user && $webservices_user ne '' && defined $webservices_pass && $webservices_pass ne '') {
        my $pass;
        ($status, $pass) = $r->get_basic_auth_pw;
        if ($status == Apache2::Const::OK) {
            my $user = $r->user;
            if ( defined $user && defined $pass &&
                    $webservices_user eq $user &&
                    $webservices_pass eq $pass  ) {
                return Apache2::Const::OK;
            }
        }
    }
    $r->note_basic_auth_failure;
    return Apache2::Const::HTTP_UNAUTHORIZED;
}

1;


=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


package pf::web::custom;

=head1 NAME

pf::web::custom - custom code to override pf::web's behavior

=cut

=head1 DESCRIPTION

pf::web::custom allows you to redefine subs in pf::web.
It will never be overwritten when upgrading PacketFence.

=cut

use strict;
use warnings;
use Date::Parse;
use File::Basename;
use POSIX;
use JSON::MaybeXS;
use Template;
use Locale::gettext;
use pf::log;
use Readonly;

use pf::config;
use pf::util;
use pf::ip4log;
use pf::node qw(node_attributes node_view node_modify);
use pf::web;

=head1 WARNING

What we are doing here is a little bit tricky: We are redefining subs in pf::web.

To do so, we are messing with typeglobs installing anonymous subs in the pf::web namespace
replacing earlier implementations.

=cut

{
no warnings 'redefine';
package pf::web;

# sample constant
#Readonly::Scalar our $GUEST_SESSION_DURATION => 60 * 60 * 24 * 7; # read 7 days

=head1 SUBROUTINES

=over

=item categorization sample

WARNING: The technique described below is for demonstration purposes only.
Node categorization is better performed by the authentication modules under
conf/authentication now. See L<pf::web::auth> for more information.

Here if a particular session variable was set, we categorize the node as a guest
and we set it's expiration to now + $GUEST_SESSION_DURATION.
Then the normal registration code is called.

To set the particular session variable use the following:
 $session->param("usercategory", "guest");

=cut

=item inject variables for templates

Here's an example to make variables accessible to the templates globally.

Also remember that you can always use the $portalSession->stash to add
variables from every location in the code (CGI's, pf::web, etc.). It's
probably the best approach if what you want to inject depend on some state
or user input.

=cut

#*pf::web::stash_template_vars = sub {
#    my ($portalSession, $template) = @_;
#    return { 'helpdesk_phone' => '514-555-1337' };
#};


# If you want to redefine pf::web::guest methods, remember to place yourself in that package with:
#package pf::web::guest;
# and also to redefine in pf::web::guest::... not pf::web::...

# end of no warnings 'redefine' block

}

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

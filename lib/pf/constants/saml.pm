package pf::constants::saml;

=head1 NAME

pf::constants::saml

=cut

=head1 DESCRIPTION

Constants for SAML.
This module was created as a bridge between Lasso::Constants and PacketFence. Given we have made Lasso a conditional runtime use, constants the way they were defined in Lasso didn't work. This module is there to allow to 'require' Lasso while being able to use its constants by requiring this module.

Important note: This is a hack.

=cut

use strict;
use warnings;
use Lasso;

our $PROVIDER_ROLE_IDP = Lasso::Constants::PROVIDER_ROLE_IDP;
our $HTTP_METHOD_REDIRECT = Lasso::Constants::HTTP_METHOD_REDIRECT;
our $SAML2_NAME_IDENTIFIER_FORMAT_PERSISTENT = Lasso::Constants::SAML2_NAME_IDENTIFIER_FORMAT_PERSISTENT;
our $SAML2_METADATA_BINDING_ARTIFACT = Lasso::Constants::SAML2_METADATA_BINDING_ARTIFACT;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


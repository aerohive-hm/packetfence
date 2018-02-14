package pf::constants::role;

=head1 NAME

pf::constants::role - constants for roles

=cut

=head1 DESCRIPTION

pf::constants::role

=cut

use strict;
use warnings;
use Readonly;

use Exporter qw(import);

our @EXPORT_OK = qw(
    @ROLES
    %STANDARD_ROLES
    $REGISTRATION_ROLE
    $ISOLATION_ROLE
    $MAC_DETECTION_ROLE
    $INLINE_ROLE
    $VOICE_ROLE
    $DEFAULT_ROLE
    $GUEST_ROLE
    $GAMING_ROLE
    $REJECT_ROLE
    $USERNAMEHASH
);

our %EXPORT_TAGS = (
    all => \@EXPORT_OK,
);

=head2 ROLES

Required roles for every switch. Those are reserved words for any additional custom role.

=cut

Readonly::Scalar our $REGISTRATION_ROLE  => 'registration';
Readonly::Scalar our $ISOLATION_ROLE     => 'isolation';
Readonly::Scalar our $MAC_DETECTION_ROLE => 'macDetection';
Readonly::Scalar our $INLINE_ROLE        => 'inline';
Readonly::Scalar our $VOICE_ROLE         => 'voice';
Readonly::Scalar our $DEFAULT_ROLE       => 'default';
Readonly::Scalar our $GUEST_ROLE         => 'guest';
Readonly::Scalar our $GAMING_ROLE        => 'gaming';
Readonly::Scalar our $REJECT_ROLE        => 'REJECT';

Readonly::Array our @ROLES => (
    $REGISTRATION_ROLE,
    $ISOLATION_ROLE,
    $MAC_DETECTION_ROLE,
    $INLINE_ROLE,
);

Readonly::Hash our %STANDARD_ROLES => (
    $VOICE_ROLE   => 1,
    $DEFAULT_ROLE => 1,
    $GUEST_ROLE   => 1,
    $GAMING_ROLE  => 1,
    $REJECT_ROLE  => 1,
);

=head2 POOL

Constant used in the pool code

=cut

Readonly::Scalar our $USERNAMEHASH  => 'username_hash';

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

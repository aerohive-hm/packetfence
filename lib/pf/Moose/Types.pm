package pf::Moose::Types;

=head1 NAME

pf::Moose::Types -

=cut

=head1 DESCRIPTION

pf::Moose::Types

=cut

use strict;
use warnings;
use Moose::Util::TypeConstraints;
use NetAddr::IP;
use pf::util qw(normalize_time);

subtype 'NetAddrIpStr', as 'NetAddr::IP';

coerce 'NetAddrIpStr', from 'Str', via { NetAddr::IP->new($_) };

subtype 'RegexpRefStr', as 'RegexpRef';

coerce 'RegexpRefStr', from 'Str', via {qr/$_/};

subtype 'PfInterval', as 'Int';

coerce 'PfInterval', from 'Str', via { return normalize_time($_) };

no Moose::Util::TypeConstraints;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


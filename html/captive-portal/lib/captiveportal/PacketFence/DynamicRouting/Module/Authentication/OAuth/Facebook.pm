package captiveportal::PacketFence::DynamicRouting::Module::Authentication::OAuth::Facebook;

=head1 NAME

captiveportal::DynamicRouting::Module::Authentication::OAuth::Facebook

=head1 DESCRIPTION

Facebook OAuth module

=cut

use Moose;
extends 'captiveportal::DynamicRouting::Module::Authentication::OAuth';

has '+source' => (isa => 'pf::Authentication::Source::FacebookSource');

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;


package captiveportal::DynamicRouting::Module::FixedRole;
use Moose;

BEGIN { extends 'captiveportal::PacketFence::DynamicRouting::Module::FixedRole'; }

=head1 NAME

captiveportal::DynamicRouting::Module::FixedRole - FixedRole Controller for captiveportal

=head1 DESCRIPTION

If the old device category is in the list then keep it

=cut

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;



package captiveportal::DynamicRouting::Detach;

=head1 NAME

captiveportal::DynamicRouting::Detach

=head1 DESCRIPTION

Module to use when dying to signal it was a detach (to stop processing the request)

=cut

use Moose;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

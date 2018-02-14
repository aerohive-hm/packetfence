package pf::api::error;

=head1 NAME

pf::api::error

=cut

=head1 DESCRIPTION

Error object for API that returns a specific status code and response

=cut


use Moose;
use Apache2::Const -compile =>
  qw(DONE OK DECLINED HTTP_UNAUTHORIZED HTTP_NOT_IMPLEMENTED HTTP_UNSUPPORTED_MEDIA_TYPE HTTP_PRECONDITION_FAILED HTTP_NO_CONTENT HTTP_NOT_FOUND SERVER_ERROR HTTP_OK HTTP_INTERNAL_SERVER_ERROR);

has 'status' => (is => 'rw', default => sub {Apache2::Const::SERVER_ERROR});

has 'response' => (is => 'rw', default => sub {''});

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

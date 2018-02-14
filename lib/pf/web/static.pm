package pf::web::static;

=head1 static

Serve static content

=cut

use strict;
use warnings;

use Apache2::Const -compile => qw(DECLINED);

sub handler {
    return Apache2::Const::DECLINED;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

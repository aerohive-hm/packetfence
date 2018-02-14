#!/usr/bin/perl
=head1 NAME

collector_modperl_require

=cut

=head1 DESCRIPTION

collector_modperl_require

=cut

BEGIN {
    use lib "/usr/local/pf/lib";
    use pf::log 'service' => 'httpd.collector', reinit => 1;
}

use JSON::MaybeXS;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

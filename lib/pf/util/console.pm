package pf::util::console;

=head1 NAME

pf::util::console -

=cut

=head1 DESCRIPTION

pf::util::console

=cut

use strict;
use warnings;
use IO::Interactive qw(is_interactive);
use Term::ANSIColor;
use pf::constants qw($BLUE_COLOR $TRUE $RED_COLOR $GREEN_COLOR $YELLOW_COLOR);

=head2 colors

colors

=cut

sub colors {
    my $is_interactive = is_interactive();
    return {
        'reset'   => $is_interactive ? color 'reset'       : '',
        'warning' => $is_interactive ? color $YELLOW_COLOR : '',
        'error'   => $is_interactive ? color $RED_COLOR    : '',
        'success' => $is_interactive ? color $GREEN_COLOR  : '',
        'status'  => $is_interactive ? color $BLUE_COLOR   : '',
        'interactive' => $is_interactive,
    };
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

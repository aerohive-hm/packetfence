package pf::cmd::pf::locationhistoryswitch;
=head1 NAME

pf::cmd::pf::locationhistoryswitch add documentation

=head1 SYNOPSIS

pfcmd locationhistoryswitch switch ifIndex [date]

get the MAC connected to a specified switch port with optional date (in mysql format)

examples:

  pfcmd locationhistoryswitch 192.168.0.1 10
  pfcmd locationhistoryswitch 192.168.0.1 6 2006-10-12 15:00:00

=head1 DESCRIPTION

pf::cmd::pf::locationhistoryswitch

=cut

use strict;
use warnings;
use base qw(pf::cmd::display);
use Date::Parse;

sub parseArgs {
    my ($self) = @_;
    my ($switch,$ifIndex,@date_args) = $self->args;
    if (defined $switch) {
        require pf::locationlog;
        import pf::locationlog;
        my %params = (ifIndex => $ifIndex);
        my $date = join(' ',@date_args);
        $params{'date'} = str2time($date) if $date;
        $self->{function} = \&locationlog_history_switchport;
        $self->{key} = $switch;
        $self->{params} = \%params;
        return 1;
    }
    return 0;
}

sub field_ui { "locationhistoryswitch" }

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


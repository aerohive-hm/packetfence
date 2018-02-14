package pf::cmd::pf::locationhistorymac;
=head1 NAME

pf::cmd::pf::locationhistorymac add documentation

=head1 SYNOPSIS

pfcmd locationhistorymac mac [date]

get the switch port where a specified MAC connected to with optional date (in mysql format)

examples:
  pfcmd locationhistorymac 00:11:22:33:44:55
  pfcmd locationhistorymac 00:11:22:33:44:55 2006-10-12 15:00:00

=head1 DESCRIPTION

pf::cmd::pf::locationhistorymac

=cut

use strict;
use warnings;
use base qw(pf::cmd::display);

sub parseArgs {
    my ($self) = @_;
    my ($key,@date_args) = $self->args;
    if($key) {
        require pf::locationlog;
        import pf::locationlog;
        my %params;
        $params{date} = str2time(join(' ',@date_args));
        $params{mac} = $key;
        $self->{function} = \&locationlog_history_mac;
        $self->{key} = $key;
        $self->{params} = \%params;
        return 1;
    }
    return 0;
}

sub field_ui { "locationhistorymac" }


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


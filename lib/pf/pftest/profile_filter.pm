package pf::pftest::profile_filter;
=head1 NAME

pf::pftest::profile_filter

=head1 SYNOPSIS

 pftest profile_filter mac [name=value ...]

manipulate node entries

examples:

 pftest profile_filter 01:02:03:04:05:06 last_ssid=Bob


=head1 DESCRIPTION

pf::pftest::profile_filter

=cut

use strict;
use warnings;
use base qw(pf::cmd);
use pf::Connection::ProfileFactory;
use pf::util qw(clean_mac);
use pf::constants::exit_code qw($EXIT_SUCCESS);
use pf::constants;

sub parseArgs {
    my ($self) = @_;
    my ($mac, @args) = $self->args;
    $self->{mac} = clean_mac($mac);
    return $FALSE unless $self->{mac};
    return $self->_parse_attributes(@args);
}

sub _run {
    my ($self) = @_;
    my $profile = pf::Connection::ProfileFactory->instantiate($self->{mac}, $self->{params});
    my $name = $profile->name;
    print "Found '$name' profile for $self->{mac} \n";
    return $EXIT_SUCCESS;
}

=head2 _parse_attributes

parse and validate the arguments for 'pfcmd node add|edit' commands

=cut

sub _parse_attributes {
    my ($self,@attributes) = @_;
    my %params;
    for my $attribute (@attributes) {
        if($attribute =~ /^([a-zA-Z0-9_-]+)=(.*)$/ ) {
            $params{$1} = $2;
        } else {
            print STDERR "$attribute is badily formatted\n";
            return 0;
        }
    }
    $self->{params} = \%params;
    return 1;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


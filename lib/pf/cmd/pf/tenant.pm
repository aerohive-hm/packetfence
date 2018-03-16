package pf::cmd::pf::tenant;

=head1 NAME

pf::cmd::pf::tenant -

=cut

=head1 SYNOPSIS

 pfcmd tenant <add> name 

=head1 DESCRIPTION

pf::cmd::pf::tenant

=cut

use strict;
use warnings;
use pf::constants::exit_code qw($EXIT_SUCCESS $EXIT_FAILURE);
use pf::constants qw($TRUE $FALSE);
use base qw(pf::base::cmd::action_cmd);
use pf::tenant qw(tenant_add);
 
=head2 parse_add

parse_add

=cut

sub parse_add {
    my ($self, $name, @args) = @_;
    unless (defined $name) {
        print STDERR "Must provide a tenant name\n";
        return $FALSE;
    }
    my %fields = (name => $name);
    $self->{fields} = \%fields;
    return $TRUE;
}

=head2 action_add

action_add

=cut

sub action_add {
    my ($self) = @_;
    my $fields = $self->{fields};
    my $results = tenant_add($fields);
    unless ($results) {
        return $EXIT_FAILURE;
    }
    return $EXIT_SUCCESS;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


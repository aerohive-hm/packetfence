package pf::tenant;

=head1 NAME

pf::tenant -

=cut

=head1 DESCRIPTION

pf::tenant

=cut

use strict;
use warnings;
use pf::error qw(is_error is_success);
use pf::constants qw($TRUE $FALSE);
use pf::dal::tenant;
use pf::dal::person;

use Exporter qw(import);

our @EXPORT_OK = qw(
    tenant_add
    tenant_view_by_name
);


=head2 tenant_add

tenant_add

=cut

sub tenant_add {
    my ($data) = @_;
    my $status = pf::dal::tenant->create($data);
    return is_success($status);
}

=head2 tenant_view_by_name

tenant_view_by_name

=cut

sub tenant_view_by_name {
    my ($name) = @_;
    my ($status, $iter) = pf::dal::tenant->search(
        -where => {
            name => $name,
        },
        -limit => 1,
        -with_class => undef,
    );
    if (is_error($status)) {
        return undef;
    }
    my $item = $iter->next;
    return $item;
}



=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


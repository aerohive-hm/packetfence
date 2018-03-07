package pf::dal::tenant;

=head1 NAME

pf::dal::tenant - pf::dal module to override for the table tenant

=cut

=head1 DESCRIPTION

pf::dal::tenant

pf::dal implementation for the table tenant

=cut

use strict;
use warnings;

use base qw(pf::dal::_tenant);
use pf::dal::person;
use pf::error qw(is_error);

sub after_create_hook {
    my ($self) = @_;
    my $status = pf::dal::person->create({
        pid => "default",
        notes => "Default User for tenant $self->{name}",
        tenant_id => $self->{id},
        -no_auto_tenant_id => 1,
    });
    if (is_error($status)) {
        $self->logger->error("Unable to create default user for the tenant");
    }
}
 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

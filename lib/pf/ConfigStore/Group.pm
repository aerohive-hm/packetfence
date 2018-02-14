package pf::ConfigStore::Group;
=head1 NAME

pf::ConfigStore::Group

=cut

=head1 DESCRIPTION

pf::ConfigStore::Group
Is the Generic class for the cached config

=cut

use Moo::Role;
use namespace::autoclean;

=head2 Fields

=over

=item group

=cut

has group => ( is=> 'ro' );

=back

=head2 Methods

=over

=item _Sections

=cut

sub _Sections {
    my ($self) = @_;
    my $group = $self->group;
    return grep { s/^\Q$group\E // }  $self->cachedConfig->Sections($group);
}

=item _formatSectionName

=cut

sub _formatSectionName {
   my ($self,$id) = @_;
   return $self->group . " " . $id;
}

=item _cleanupId

=cut

sub _cleanupId {
    my ($self, $id) = @_;
    my $quoted_group = quotemeta($self->group);
    $id =~ s/^$quoted_group //g;
    return $id;
}

=back

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


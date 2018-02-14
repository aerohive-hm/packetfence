package pfappserver::Model::Node::Tab::Option82;

=head1 NAME

pfappserver::Model::Node::Tab::Option82 -

=cut

=head1 DESCRIPTION

pfappserver::Model::Node::Tab::Option82

=cut

use strict;
use warnings;
use pf::dhcp_option82;
use pf::SwitchFactory;

=head2 process_view

Process view

=cut

sub process_view {
    my ($self, $c, @args) = @_;
    my $mac = $c->stash->{mac};
    my ($option_82) = dhcp_option82_view($mac);
    return ($STATUS::OK, {
        item => $option_82,
        columns => [sort @pf::dhcp_option82::FIELDS],
        display_columns => [sort keys %pf::dhcp_option82::HEADINGS],
        headings => \%pf::dhcp_option82::HEADINGS,
        switch_config => \%pf::SwitchFactory::SwitchConfig,
    });
}

=head2 process_tab

Process tab

=cut

sub process_tab {
    my ($self, $c, @args) = @_;
    return ($STATUS::OK, {});
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

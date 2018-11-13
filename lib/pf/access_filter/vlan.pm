package pf::access_filter::vlan;

=head1 NAME

pf::access_filter::vlan -

=head1 DESCRIPTION

pf::access_filter::vlan

=cut

use strict;
use warnings;
use pf::api::jsonrpcclient;
use Scalar::Util qw(reftype);

use base qw(pf::access_filter);
tie our %ConfigVlanFilters, 'pfconfig::cached_hash', 'config::VlanFilters';
tie our %VlanFilterEngineScopes, 'pfconfig::cached_hash', 'FilterEngine::VlanScopes';

=head2 filterRule

    Handle the role update

=cut

sub filterRule {
    my ($self, $rule, $args) = @_;
    if(defined $rule) {
        if (defined($rule->{'action'}) && $rule->{'action'} ne '') {
            $self->dispatchAction($rule, $args);
        }
        my $scope = $rule->{scope};
        if (defined($rule->{'role'}) && $rule->{'role'} ne '') {
            my $role = $rule->{'role'};
            $role = evalAnswer($role,$args);
            return $role;
        }
    }
    return undef;
}

=head2 getEngineForScope

 gets the engine for the scope

=cut

sub getEngineForScope {
    my ($self, $scope) = @_;
    if (exists $VlanFilterEngineScopes{$scope}) {
        return $VlanFilterEngineScopes{$scope};
    }
    return undef;
}

=head2 dispatchAction

Return the reference to the function that call the api.

=cut

sub dispatchAction {
    my ($self, $rule, $args) = @_;

    my $param = $self->evalParamAction($rule->{'action_param'}, $args);
    my $apiclient = pf::api::jsonrpcclient->new;
    $apiclient->notify($rule->{'action'}, %{$param});
}

=head2 evalParam

evaluate action parameters

=cut

sub evalParamAction {
    my ($self, $action_param, $args) = @_;
    my @params = split(/\s*,\s*/, $action_param);
    my $return = {};
    foreach my $param (@params) {
        $param =~ s/\$([A-Za-z0-9_]+)/$args->{$1} \/\/ '' /ge;
        $param =~ s/^\s+|\s+$//g;
        my @param_unit = split(/\s*=\s*/, $param);
        $return = {%$return, @param_unit};
    }
    return $return;
}


=head2 evalAnswer

evaluate the radius answer

=cut

sub evalAnswer {
    my ($answer,$args) = @_;

    my $return = evalParam($answer,$args);
    return $return;

}

=head2 evalParam

evaluate all the variables

=cut

sub evalParam {
    my ($answer, $args) = @_;
    $answer =~ s/\$([a-zA-Z_0-9]+)/$args->{$1} \/\/ ''/ge;
    $answer =~ s/\$\{([a-zA-Z0-9_\-]+(?:\.[a-zA-Z0-9_\-]+)*)\}/&_replaceParamsDeep($1,$args)/ge;
    return $answer;
}


=head2 _replaceParamsDeep

evaluate all the variables deeply

=cut

sub _replaceParamsDeep {
    my ($param_string, $args) = @_;
    my @params = split /\./, $param_string;
    my $param  = pop @params;
    my $hash   = $args;
    foreach my $key (@params) {
        if (exists $hash->{$key} && reftype($hash->{$key}) eq 'HASH') {
            $hash = $hash->{$key};
            next;
        }
        return '';
    }
    return $hash->{$param} // '';
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

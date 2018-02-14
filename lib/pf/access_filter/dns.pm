package pf::access_filter::dns;

=head1 NAME

pf::access_filter::dns -

=head1 DESCRIPTION

pf::access_filter::dns

=cut

use strict;
use warnings;
use pf::api::jsonrpcclient;
use pf::log;

use base qw(pf::access_filter);
tie our %ConfigDNS_Filters, 'pfconfig::cached_hash', 'config::DNS_Filters';
tie our %DNSFilterEngineScopes, 'pfconfig::cached_hash', 'FilterEngine::DNS_Scopes';

=head2 test

Test all the rules

=cut

sub test {
    my ($self, $scope, $args) = @_;
    my $logger = $self->logger;
    my $engine = $self->getEngineForScope($scope);
    if ($engine) {
        my $answer = $engine->match_first($args);
        return $answer;
    }
    $logger->debug(sub {"No engine found for $scope"});
    return undef;
}

=head2 filterRule

    Handle the role update

=cut

sub filterRule {
    my ($self, $rule, $args) = @_;
    my $logger = $self->logger;
    if(defined $rule) {
        $logger->info(evalParam($rule->{'log'},$args)) if defined($rule->{'log'});
        if (defined($rule->{'action'}) && $rule->{'action'} ne '') {
            $self->dispatchAction($rule, $args);
        }
        my $answer = $rule->{answer};
        if (defined $answer && $answer ne '') {
            my %results = %$rule;
            $answer =~ s/\$([a-zA-Z_]+)/$args->{$1} \/\/ ''/ge;
            $results{answer} = $answer;
            return \%results;
        }
    }
    return undef;
}

=head2 getEngineForScope

 gets the engine for the scope

=cut

sub getEngineForScope {
    my ($self, $scope) = @_;
    if (exists $DNSFilterEngineScopes{$scope}) {
        return $DNSFilterEngineScopes{$scope};
    }
    return undef;
}

=head2 dispatchAction

Return the reference to the function that call the api.

=cut

sub dispatchAction {
    my ($self, $rule, $args) = @_;

    my $param = $self->evalParam($rule->{'action_param'}, $args);
    my $apiclient = pf::api::jsonrpcclient->new;
    $apiclient->notify($rule->{'action'}, %{$param});
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

=head2 evalParam

evaluate all the variables

=cut

sub evalParam {
    my ($answer, $args) = @_;
    $answer =~ s/\$([a-zA-Z_0-9]+)/$args->{$1} \/\/ ''/ge;
    $answer =~ s/\${([a-zA-Z0-9_\-]+(?:\.[a-zA-Z0-9_\-]+)*)}/&_replaceParamsDeep($1,$args)/ge;
    return $answer;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

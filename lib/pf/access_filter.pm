package pf::access_filter;

=head1 NAME

pf::access_filter - handle the authorization rules on the vlan attribution

=head1 DESCRIPTION

pf::access_filter deny, rewrite role based on rules.

=cut

use strict;
use warnings;

use pf::log;
use pf::api::jsonrpcclient;
use pf::config qw(%connection_type_to_str);
use pf::person qw(person_view);
use pf::factory::condition::access_filter;
use pf::filter_engine;
use pf::filter;
=head1 SUBROUTINES

=head2 new

=cut

sub new {
   my ( $proto, %argv ) = @_;
   my $class = ref($proto) || $proto;
   $class->logger->debug("instantiating new $class");
   my $self = bless {}, $class;
   return $self;
}

=head2 test

Test all the rules

=cut

sub test {
    my ($self, $scope, $args) = @_;
    my $logger = $self->logger;
    my $engine = $self->getEngineForScope($scope);
    if ($engine) {
        my $answer = $engine->match_first($args);
        if (defined $answer) {
            $logger->info("Match rule $answer->{_rule}");
        }
        else {
            $logger->debug(sub {"No rule matched for scope $scope"});
        }
        return $answer;
    }
    $logger->debug(sub {"No engine found for $scope"});
    return undef;
}


=head2 filter

 Filter the arguments passed

=cut

sub filter {
    my ($self, $scope, $args) = @_;
    my $rule = $self->test($scope, $args);
    return $self->filterRule($rule, $args);
}


=head2 getEngineForScope

 get the filter engine for the scope provided

=cut

sub getEngineForScope {
    my ($self, $scope) = @_;
    return undef;
}

=head2 logger

Return the current logger for the object

=cut

sub logger {
    my ($proto) = @_;
    return get_logger( ref($proto) || $proto );
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

package pf::Role::CHI::Driver::ComputeWithUndef;

=head1 NAME

pf::Role::CHI::Driver::ComputeWithUndef

=cut

=head1 DESCRIPTION

Adds a method that caches undef results in compute

=cut

use strict;
use warnings;
use Moo::Role;
use pfconfig::util qw($undef_element);

sub compute_with_undef {
    my ($self, $key, $on_miss, $options) = @_;
    my $return = $self->get($key);
    if(defined($return) && ref($return) eq "pfconfig::undef_element"){
        return undef;
    }
    elsif(defined($return)){
        return $return;
    }

    my $result = $on_miss->();
    if(defined($result)){
        $self->set($key,$result,$options);
    }
    else {
        $self->set($key, $undef_element,$options);
    }

    return $result;
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


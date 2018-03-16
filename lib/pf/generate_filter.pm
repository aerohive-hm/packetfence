package pf::generate_filter;

=head1 NAME

pf::generate_filter -

=cut

=head1 DESCRIPTION

pf::generate_filter

=cut

use strict;
use warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(
    generate_filter
    filter_with_offset_limit
);

our %FILTER_GENERATORS = (
    equal => \&generate_equal_filter,
    not_equal => \&generate_not_equal_filter,
    starts_with => \&generate_starts_with_filter,
    ends_with => \&generate_ends_with_filter,
    like => \&generate_like_filter,
);

sub generate_filter {
    my ($op, $field_name, $value) = @_;
    if (exists $FILTER_GENERATORS{$op} && defined $value) {
        return $FILTER_GENERATORS{$op}->($op, $field_name, $value);
    }
    return undef;
}

sub generate_equal_filter {
    my ($op, $field_name, $value) = @_;
    return sub {
        my $h = shift;
        defined $h && exists $h->{$field_name} && defined $h->{$field_name} && $h->{$field_name} eq $value            
    };
}

sub generate_not_equal_filter {
    my ($op, $field_name, $value) = @_;
    return sub {
        my $h = shift;
        defined $h && exists $h->{$field_name} && defined $h->{$field_name} && $h->{$field_name} ne $value
    };
}

sub generate_starts_with_filter {
    my ($op, $field_name, $value) = @_;
    return sub {
        my $h = shift;
        defined $h && exists $h->{$field_name} && defined $h->{$field_name} && $h->{$field_name} =~ /^\Q$value\E/
    };
}

sub generate_ends_with_filter {
    my ($op, $field_name, $value) = @_;
    return sub {
        my $h = shift;
        defined $h && exists $h->{$field_name} && defined $h->{$field_name} && $h->{$field_name} =~ /\Q$value\E$/
    };
}

sub generate_like_filter {
    my ($op, $field_name, $value) = @_;
    return sub {
        my $h = shift;
        defined $h && exists $h->{$field_name} && defined $h->{$field_name} && $h->{$field_name} =~ /\Q$value\E/
    };
}

sub filter_with_offset_limit {
    my ($filter, $offset, $limit, $values) = @_;
    my @matches;
    my $found = 0;
    for my $v (@$values) {
        next unless $filter->($v);
        if ($found >= $offset) {
           push @matches, $v;
           last if $limit == @matches;
        }
        $found++;
    }
    return \@matches;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2017 Inverse inc.

=cut

1;


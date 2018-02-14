package captiveportal::PacketFence::Form::Survey;

=head1 NAME

captiveportal::Form::Survey

=head1 DESCRIPTION

Form definition for the Survey on the portal

=cut

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has 'app' => (is => 'rw', isa => 'captiveportal::DynamicRouting::Application', required => 1);
has 'module' => (is => 'rw', isa => 'captiveportal::DynamicRouting::Module', required => 1);

has '+field_name_space' => ( default => 'captiveportal::Form::Field' );
has '+widget_name_space' => ( default => 'captiveportal::Form::Widget' );

use pf::log;
use pf::sms_carrier;
use pf::util;

has 'survey' => (is => 'rw');

my %skip = (
    id => 1,
);

has '+is_html5' => (default => 1);

sub field_list {
    my ($self) = @_;
    
    my @fields;

    while(my ($field_id, $field_config) = each(%{$self->survey->fields})) {
        my $type = $field_config->{type};
        my $options = {};

        if($type eq "Select") {
            $options = {
                type => $type,
                options => [ map { my @a = split(/\|/, $_) ; {value => $a[0], label => $a[1]} } ('', @{$field_config->{choices}}) ],
            };
        } elsif ($type eq "Scale") {
            $options = {
                type => 'PosInteger',
                validate_method => sub {
                    my ($self) = @_;
                    my $minimum = $field_config->{minimum};
                    my $maximum = $field_config->{maximum};
                    unless($self->value >= $minimum && $self->value <= $maximum) {
                        $self->add_error("Value must be between $minimum and $maximum");
                    }
                },
            };
        } elsif ($type eq "Checkbox") {
            $options->{checkbox_value} = "Y";
        }

        # Set the type unless its been set before
        $options->{type} //= $type;

        $options->{label} = $field_config->{label};

        push @fields, "fields[$field_id]" => $options;
    }
    return \@fields;
}

=head2 get_field

Get a field following the standard field[$name] by its name 

=cut

sub get_field {
    my ($self, $name) = @_;
    $name = "fields[".$name."]";
    return $self->field($name) || die "Can't build field $name";
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

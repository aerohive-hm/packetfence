package pfappserver::Form::Config::Pfmon::certificates_check;

=head1 NAME

pfappserver::Form::Config::Pfmon::certificates_check

=head1 DESCRIPTION

Web form for certificates_check pfmon task

=cut

use HTML::FormHandler::Moose;

use pfappserver::Form::Config::Pfmon qw(default_field_method);

extends 'pfappserver::Form::Config::Pfmon';
with 'pfappserver::Base::Form::Role::Help';


has_field 'delay' => (
    type            => 'Duration',
    default_method  => \&default_field_method,
    tags => { 
        after_element   => \&help,
        help            => "Minimum gap before certificate expiration date (will the certificate expires in ...)",
    },
);

has_field 'certificates' => (
    type            => 'TextArea',
    default_method  => \&default_field_method,
    tags => { 
        after_element   => \&help,
        help            => "SSL certificate(s) to monitor. Comma-delimited list",
    },
);

has_block definition => (
    render_list => [qw(type status interval delay certificates)],
);


=head2 default_type

default value of type

=cut

sub default_type {
    return "certificates_check";
}


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

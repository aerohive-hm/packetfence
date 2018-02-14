package pfappserver::Form::Config::Pfmon::violation_maintenance;

=head1 NAME

pfappserver::Form::Config::Pfmon::violation_maintenance - Web form for violation_maintenance pfmon task

=head1 DESCRIPTION

Web form for violation_maintenance pfmon task

=cut

use HTML::FormHandler::Moose;

use pfappserver::Form::Config::Pfmon qw(default_field_method batch_help_text timeout_help_text window_help_text);

extends 'pfappserver::Form::Config::Pfmon';
with 'pfappserver::Base::Form::Role::Help';

has_field 'batch' => (
    type => 'PosInteger',
    default_method => \&default_field_method,
    tags => { after_element => \&help,
             help => \&batch_help_text },
);

has_field 'timeout' => (
    type => 'Duration',
    default_method => \&default_field_method,
    tags => { after_element => \&help,
             help => \&timeout_help_text },
);


=head2 default_type

default value of type

=cut

sub default_type {
    return "violation_maintenance";
}

has_block  definition =>
  (
    render_list => [qw(type status interval batch timeout)],
  );


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

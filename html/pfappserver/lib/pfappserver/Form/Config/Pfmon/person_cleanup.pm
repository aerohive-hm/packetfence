package pfappserver::Form::Config::Pfmon::person_cleanup;

=head1 NAME

pfappserver::Form::Config::Pfmon::person_cleanup - Web form for person_cleanup pfmon task

=head1 DESCRIPTION

Web form for person_cleanup pfmon task

=cut

use HTML::FormHandler::Moose;

extends 'pfappserver::Form::Config::Pfmon';
with 'pfappserver::Base::Form::Role::Help';


=head2 default_type

default value of type

=cut

sub default_type {
    return "person_cleanup";
}

has_block  definition =>
  (
    render_list => [qw(type status interval)],
  );


=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

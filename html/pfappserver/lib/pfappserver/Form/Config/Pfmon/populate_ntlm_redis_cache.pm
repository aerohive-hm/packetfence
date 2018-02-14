package pfappserver::Form::Config::Pfmon::populate_ntlm_redis_cache;

=head1 NAME

pfappserver::Form::Config::Pfmon::populate_ntlm_redis_cache - Web form for populate_ntlm_redis_cache pfmon task

=head1 DESCRIPTION

Web form for populate_ntlm_redis_cache pfmon task

=cut

use HTML::FormHandler::Moose;

extends 'pfappserver::Form::Config::Pfmon';
with 'pfappserver::Base::Form::Role::Help';


=head2 default_type

default value of type

=cut

sub default_type {
    return "populate_ntlm_redis_cache";
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

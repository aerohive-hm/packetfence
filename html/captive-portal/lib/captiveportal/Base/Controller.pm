package captiveportal::Base::Controller;

=head1 NAME

captiveportal::Base::Controller add documentation

=cut

=head1 DESCRIPTION

captiveportal::Base::Controller

=cut

use Moose;
use Moose::Util qw(apply_all_roles);
use namespace::autoclean;
use pf::authentication;
use pf::config;
use pf::enforcement qw(reevaluate_access);
use pf::ip4log;
use pf::node
  qw(node_attributes node_modify node_register node_view is_max_reg_nodes_reached);
use pf::util;
use pf::violation qw(violation_count);
use pf::web::constants;
use pf::web;
BEGIN { extends 'Catalyst::Controller'; }

sub showError {
    my ( $self, $c, $error ) = @_;
    my $text_message;
    if ( ref($error) ) {
        $text_message = i18n_format(@$error);
    } else {
        $text_message = i18n($error);
    }
    utf8::decode($text_message);
    $c->stash(
        template    => 'error.html',
        message => $text_message,
    );
    $c->detach;
}

=head2 reached_retry_limit

Test if the retry limit has been reached for a session key
If the max is undef or 0 then check is disabled

=cut

sub reached_retry_limit {
    my ( $self, $c, $retry_key, $max ) = @_;
    return 0 unless $max;
    my $cache = $c->user_cache;
    my $retries = $cache->get($retry_key) || 1;
    $retries++;
    $cache->set($retry_key,$retries,$c->profile->{_block_interval});
    return $retries > $max;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

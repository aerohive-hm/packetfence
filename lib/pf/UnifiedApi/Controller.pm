package pf::UnifiedApi::Controller;

=head1 NAME

pf::UnifiedApi::Controller -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller

=cut

use strict;
use warnings;
use Mojo::Base 'Mojolicious::Controller';
use pf::error qw(is_error);
use JSON::MaybeXS qw();
has activity_timeout => 300;
has 'openapi_generator_class' => undef;

our $ERROR_400_MSG = "Bad Request. One of the submitted parameters has an invalid format";
our $ERROR_404_MSG = "Not Found. The requested resource could not be found";
our $ERROR_409_MSG = "An attempt to add a duplicate entry was stopped. Entry already exists and should be modified instead of created.";
our $ERROR_422_MSG = "Request cannot be processed because the resource has failed validation after the modification.";

our %STATUS_TO_MSG = (
    400 => $ERROR_400_MSG,
    404 => $ERROR_404_MSG,
    409 => $ERROR_409_MSG,
    422 => $ERROR_422_MSG,
);

use Mojo::JSON qw(decode_json);
use pf::util;

sub log {
    my ($self) = @_;
    return $self->app->log;
}

sub render_error {
    my ($self, $code, $msg, $errors) = @_;
    $errors //= [];
    my $data = {message => $msg, errors => $errors};
    $self->render(json => $data, status => $code);
    return 0;
}

sub render_empty {
    my ($self) = @_;
    return $self->render(text => '', status => 204);
}

sub status_to_error_msg {
    my ($self, $status) = @_;
    return exists $STATUS_TO_MSG{$status} ? $STATUS_TO_MSG{$status} : "Server error";
}

sub parse_json {
    my ($self) = @_;
    my $json = eval {
        JSON::MaybeXS::decode_json($self->req->body)
    };
    if ($@) {
        $self->log->error($@);
        return (400, { message => $self->status_to_error_msg(400)});
    }
    return (200, $json);
}

sub get_json {
    my ($self) = @_;
    local $@;
    my $error;
    my $data = eval {
        decode_json($self->tx->req->body);
    };
    if ($@) {
        $error = $@->message;
        $self->log->error($error);
        $error = strip_filename_from_exceptions($error);
    }
    return ($error, $data);
}

sub unknown_action {
    my ($self) = @_;
    return $self->render_error(404, "Unknown path");
}

sub openapi_generator {
    my ($self) = @_;
    my $class = $self->openapi_generator_class;
    return $class ? $class->new : undef;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


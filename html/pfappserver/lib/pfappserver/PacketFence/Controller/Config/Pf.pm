package pfappserver::PacketFence::Controller::Config::Pf;

=head1 NAME

pfappserver::PacketFence::Controller::Config::Pf - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use HTTP::Status qw(:constants is_error);
use Moose;
use namespace::autoclean;

BEGIN { extends 'pfappserver::Base::Controller'; }

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->visit('read', ['all'], ['read']);
}

=head2 object

Chained dispatch for a configuration parameter.

=cut

sub object :Chained('/') :PathPart('config/pf') :CaptureArgs(1) {
    my ($self, $c, $config_item) = @_;
    $c->stash->{config_item} = $config_item;
}

=head2 read

/config/pf/<section.param>/read

=cut

sub read :Chained('object') :PathPart('read') :Args(0) {
    my ($self, $c) = @_;
    my $config_item = $c->stash->{config_item};
    my ($section, $param) = split /\./, $config_item;

    my ($status, $result) = $c->model('Config::Pf')->read($section);
    if (is_error($status)) {
        $c->res->status($status);
        $c->error($result);
    }
    elsif(exists $result->{$param} ) {
        $c->stash->{config} = $result->{$param};
    }
    else {
        $c->res->status(HTTP_NOT_FOUND);
        $c->error("$config_item is not found");
    }
}

=head2 help

/config/pf/<section.param>/help

Get help on a configuration parameter.

=cut

sub help :Chained('object') :PathPart('help') :Args(0) {
    my ($self, $c) = @_;
    my $config_item = $c->stash->{config_item};

    my ($status, $message) = $c->model('Config::Pf')->help($config_item);
    if (is_error($status)) {
        $c->res->status($status);
        $c->error($message);
    }
    else {
        $c->stash->{config} = $message;
    }
}

=head2 delete

/config/pf/<section.param>/delete

=cut

sub delete :Chained('object') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;

    # TODO reset to default value or simply don't implement?
    $c->res->status(HTTP_NOT_IMPLEMENTED);
}

=head2 update

/config/pf/<section.param>/update

=cut

sub update :Chained('object') :PathPart('update') :Args(0) {
    my ($self, $c) = @_;
    my $config_item = $c->stash->{config_item};

    my $value = $c->request->body_params->{value};
    my ($section, $param) = split /\./, $config_item;
    if (defined($value) && !ref($value)) {
        my ($status, $message) = $c->model('Config::Pf')->update($section => { $param => $value });
        if (is_error($status)) {
            $c->res->status($status);
            $c->error($message);
        }
        else {
            $c->res->status(HTTP_CREATED);
            $c->stash->{status_msg} = $message;
            $c->model('Config::Pf')->commit();
        }
    }
    else {
        $c->res->status(HTTP_BAD_REQUEST);
        $c->stash->{status_msg} = 'Missing parameters or malformed request';
    }
}

=head2 create

/config/pf/<section.param>/create

=cut


sub create :Chained('object') :PathPart('create') :Args(0) {
    my ($self, $c) = @_;
    my $config_item = $c->stash->{config_item};

    # TODO redirect to /update (or the other way around) or simply don't implement?
    $c->res->status(HTTP_NOT_IMPLEMENTED);
}

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;
    # TODO In DEVEL that's cool, but in production we want only a 500 generic message and logging on 'unhandled' errors
    if ( scalar @{ $c->error } ) {
        $c->stash->{status_msg} = $c->error;
        $c->forward('View::JSON');
        $c->error(0);
    }
    $c->forward('View::JSON');
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;

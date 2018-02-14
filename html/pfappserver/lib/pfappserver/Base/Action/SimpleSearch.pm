package pfappserver::Base::Action::SimpleSearch;

=head1 NAME

/usr/local/pf/html/pfappserver/lib/pfappserver/Base/Action add documentation

=head1 DESCRIPTION

SimpleSearch

=cut

use strict;
use warnings;
use Moose::Role;
use namespace::autoclean;

after execute => sub {
    my ( $self, $controller, $c, %args ) = @_;
    %args = map { $_ => $args{$_}  } grep { $controller->valid_param($_) } keys %args;
    $c->stash(%args);
    my $model_name = $self->attributes->{SimpleSearch}[0];
    if ($c->request->method eq 'POST') {
        # Store columns in the session
        my $columns = $c->request->params->{'column'};
        $columns = [$columns] if (ref($columns) ne 'ARRAY');
        my %columns_hash = map { $_ => 1 } @{$columns};
        my %params = ( lc($model_name) . 'columns' => \%columns_hash );
        $c->session(%params);
    }
    $controller->_list_items( $c, $model_name );
};

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;


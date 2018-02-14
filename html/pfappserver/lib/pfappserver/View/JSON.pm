package pfappserver::View::JSON;

use strict;
use base 'Catalyst::View::JSON';

=head2 process

Override the content type for IE

=cut

sub process {
    my ($self, $c) = @_;
    $self->SUPER::process($c);
    if( my $content_type = $c->stash->{json_view_content_type}) {
        my $res = $c->res;
        my $encoding = $self->encoding || 'utf-8';
        $res->content_type("$content_type; charset=$encoding");
        if($encoding eq 'utf-8' && $content_type eq 'text/plain') {
            my $user_agent = $c->req->user_agent || '';
            #Remove the utf-8 bom for safari
            if ($user_agent =~ m/\bSafari\b/ and $user_agent !~ m/\bChrome\b/) {
                use bytes;
                my $output = $res->output();
                $output =~ s/^(?:\357\273\277|\377\376\0\0|\0\0\376\377|\376\377|\377\376)//;
                #$output =~ s/\x{FEFF}//;
                $res->output($output);
            }
        }
    }
};

=head1 NAME

pfappserver::View::JSON - Catalyst JSON View

=head1 SYNOPSIS

See L<pfappserver>

=head1 DESCRIPTION

Catalyst JSON View.

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

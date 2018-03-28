package pf::UnifiedApi::Controller::Translations;

=head1 NAME

pf::UnifiedApi::Controller::Translations -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Translations

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller::RestRoute';
use pf::I18N::pfappserver;

our $languages_list = pf::I18N::pfappserver->languages_list;

sub list {
    my ($self) = @_;
    my @items = (
        {
            lang    => 'i_default',
            lexicon => \%pf::I18N::pfappserver::Lexicon,
        },
    );
    for my $lang (keys(%$languages_list)) {
        push @items, {
            lang => $lang,
            lexicon => $self->lexicon($lang),
        };
    }

    return $self->render(status => 200, json => {items => \@items});
}

sub resource {
    my ($self) = @_;
    my $translation_id = $self->stash('translation_id');
    return exists $languages_list->{$translation_id};
}

sub get {
    my ($self) = @_;
    my $lang = $self->stash('translation_id');
    my $lexicon = $self->lexicon($lang);
    return $self->render(
        status => 200,
        json => {
            item => {
                lang => $lang,
                lexicon => $lexicon,
            }
        }
    );
}

sub lexicon {
    my ($self, $lang) = @_;
    no strict qw(refs);
    my $lexicon = "pf::I18N::pfappserver::${lang}::Lexicon";
    my $ref = *{$lexicon};
    return \%{$ref};
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

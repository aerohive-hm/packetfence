package captiveportal::Base::I18N;

=head1 NAME

captiveportal::Base::I18N

=head1 DESCRIPTION

For the internationalization of the fields

=cut

use Moose;
extends 'HTML::FormHandler::I18N';

use Locale::gettext qw(gettext ngettext);
use pf::web ();

=head2 handle_posted_fields

Internationalize a string
Escapes the bracket arguments to put them in %s format which is used by the portal PO files

=cut

sub maketext {
    my $self = shift;
    my @args = @_;
    $args[0] =~ s/\[\_.+?\]/\%s/g;
    if(@args > 1){
        return pf::web::i18n_format(@args);
    }
    else {
        return pf::web::i18n(@args);
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;



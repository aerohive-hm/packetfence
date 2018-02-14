package pfconfig::namespaces::config::Documentation;

=head1 NAME

pfconfig::namespaces::config::Documentation

=cut

=head1 DESCRIPTION

pfconfig::namespaces::config::Documentation

This module creates the configuration hash associated to documentation.conf

=cut

use strict;
use warnings;

use pfconfig::namespaces::config;
use Config::IniFiles;
use pf::file_paths qw($pf_doc_file);

use base 'pfconfig::namespaces::config';

sub init {
    my ($self) = @_;
    $self->{file} = $pf_doc_file;
    $self->{child_resources} = [ 'config::PfDefault' ];
}

sub build_child {
    my ($self) = @_;

    my %Doc_Config = %{ $self->{cfg} };

    $self->cleanup_whitespaces( \%Doc_Config );

    foreach my $doc_data ( values %Doc_Config ) {
        if ( exists $doc_data->{options} && defined $doc_data->{options} ) {
            my $options = $doc_data->{options};
            $doc_data->{options} = [ split( /\|/, $options ) ] if defined $options;
        }
        else {
            $doc_data->{options} = [];
        }
        if ( exists $doc_data->{description} && defined $doc_data->{description} ) {

            # Limited formatting from text to html
            my $description = $doc_data->{description};
            $description =~ s/</&lt;/g;                                  # convert < to HTML entity
            $description =~ s/>/&gt;/g;                                  # convert > to HTML entity
            $description
                =~ s/(\S*(&lt;|&gt;)\S*)(?=[\s,\.])/<code>$1<\/code>/g;  # enclose strings that contain < or >
            $description =~ s/(\S+\.(html|tt|pm|pl|txt))\b(?!<\/code>)/<code>$1<\/code>/g
                ;    # enclose strings that ends with .html, .tt, etc
            $description
                =~ s/^ \* (.+?)$/<li>$1<\/li>/mg;    # create list elements for lines beginning with " * "
            $description =~ s/(<li>.*<\/li>)/<ul>$1<\/ul>/s;     # create lists from preceding substitution
            $description =~ s/\"([^\"]+)\"/<i>$1<\/i>/mg;        # enclose strings surrounded by double quotes
            $description =~ s/\[(\S+)\]/<strong>$1<\/strong>/mg; # enclose strings surrounded by brakets
            $description =~ s/(https?:\/\/\S+)/<a href="$1">$1<\/a>/g;    # make links clickable
            $doc_data->{description} = $description;
        }
    }

    return \%Doc_Config;

}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:


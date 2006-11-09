#!/usr/bin/perl -w
use strict;

use CGI qw/:standard *table/;
use CGI::Pretty;

use Lingua::Identify qw/:all/;

# first, calculate the result (if asked)
my $result = '';
if (param()) {

  param('text')      or $result .= 'Please insert some text to identify.'      . br ;
  param('languages') or $result .= 'Please select at least one language.'      . br ;
  param('methods')   or $result .= 'Please select at least one method to use.' . br ;

  unless ($result) {

    my @lang    = param('languages');
    my $text    = param('text');
    my @methods = param('methods');
    my %methods;
    for (param('methods')) {
      $methods{$_} = param("method_$_");
    }

    set_active_languages(@lang);
    my @results = langof( { method => \%methods }, $text );

    $result = join (br, b ( ucfirst name_of($results[0]) ) .
                        ' (confidence level ' .
                        per(confidence(@results)).')',

                        '',

                        table (#{-border=>1},
                          map { Tr(@$_)}
                            map { [ td( ucfirst name_of($results[$_*2]) ),
                                    td( {-width=>'2%'}                  ),
                                    td( {-align=>'right'}, per($results[$_*2 + 1])         ), ]
                                } 0 .. ($#results-1) / 2
                        )
                   );
  }

}

# now let's print the stuff

my %language_labels = map { $_ => ucfirst name_of($_) } get_all_languages;
my @all_languages = sort { $language_labels{$a} cmp $language_labels{$b} } keys %language_labels;

my %method_labels = (
                 smallwords => 'Small Word Technique ',

                 prefixes1  => 'Prefixes Analysis, size 1 ',
                 prefixes2  => 'Prefixes Analysis, size 2 ',
                 prefixes3  => 'Prefixes Analysis, size 3 ',
                 prefixes4  => 'Prefixes Analysis, size 4 ',

                 suffixes1  => 'Suffixes Analysis, size 1 ',
                 suffixes2  => 'Suffixes Analysis, size 2 ',
                 suffixes3  => 'Suffixes Analysis, size 3 ',
                 suffixes4  => 'Suffixes Analysis, size 4 ',

                 ngrams1    => 'Ngram Categorization, size 1 ',
                 ngrams2    => 'Ngram Categorization, size 2 ',
                 ngrams3    => 'Ngram Categorization, size 3 ',
                 ngrams4    => 'Ngram Categorization, size 4 ',
);

#for (keys %method_labels) {
#  $method_labels{$_} .= textfield("method_$_",'1',5,5);
#}

my @methods = qw/smallwords prefixes1 prefixes2 prefixes3 prefixes4 suffixes1
		 suffixes2 suffixes3 suffixes4 ngrams1 ngrams2 ngrams3
                 ngrams4/;

print header,
      start_form,

      table(#{-border=>1},
             Tr({-valign=>'top'},

                 td( # box to insert text in
                     "Insert text to identify here (powered by <a href=\"http://search.cpan.org/dist/Lingua-Identify/\">Lingua::Identify</a> v @{[Lingua::Identify->VERSION]})", br,
                     textarea(-name=>'text',
                              -rows=>10,
                              -columns=>50), p,
                     submit, reset, p,
                     $result,
                   ),

                 td({-nowrap=>'nowrap'}, # language list
                     'Available languages', br,
                     checkbox_group(-name=>'languages',
                                    -values=>[@all_languages],
                                    -default=>[@all_languages],
                                    -linebreak=>'true',
                                    -labels=>\%language_labels,
                                    )
                    ),

                 td({-nowrap=>'nowrap'}, # method list
                     'Available methods', br,
                     checkbox_group(-name=>'methods',
                                    -values=>[@methods],
                                    -default=>[@methods],
                                    -linebreak=>'true',
                                    -labels=>\%method_labels,
                                    )
                    ),

                 td({-nowrap=>'nowrap'}, # method relevance
                     'Method relevance', br,

                     map {textfield("method_$_",'1',5,5),br} @methods

                    ),

               )
           ),

      end_form;

sub per {
  sprintf("%.2f%", 100 * shift);
}

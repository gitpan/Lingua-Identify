package Lingua::Identify;

use 5.006;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
	'all' => [ qw(
			langof
			activate_all_languages	deactivate_all_languages
			get_all_languages	get_active_languages
			get_inactive_languages	is_active
			is_valid_language	activate_language
			deactivate_language	set_active_languages
			name_of
		) ],
	'language_manipulation' => [ qw(
			activate_all_languages	deactivate_all_languages
			get_all_languages	get_active_languages
			get_inactive_languages	is_active
			is_valid_language	activate_language
			deactivate_language	set_active_languages
			name_of
		) ],
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
);

our $VERSION = '0.05';

=head1 NAME

Lingua::Identify - Language identification

=head1 SYNOPSIS

  use Lingua::Identify qw(langof);
  $a = langof($textstring); # gives the most probable language

  @a = langof($textstring); # gives pairs of languages / probabilities
                            # sorted from most to least probable

  %a = langof($textstring); # gives a hash of language / probability

  # or the hard (expert) way (see section OPTIONS, under HOW TO PERFORM
  # IDENTIFICATION)

  $a = langof({ method => [qw/smallwords prefix2 suffix2/] },$textstring);

=head1 DESCRIPTION

C<Lingua::Identify> identifies the language a given string or file is
written in.

See section WHY LINGUA::IDENTIFY for a list of C<Lingua::Identify>'s strong
points.

See section KNOWN LANGUAGES for a list of available languages and HOW TO
PERFORM IDENTIFICATION to know how to really use this module.

If you're in a hurry, jump to section EXAMPLES, way down below.

Also, don't forget to read the following section, IMPORTANT WARNING.

=head1 IMPORTANT WARNING

Take a word that exists in two different languages, take a good look at it and
answer this question: "What language does this word belong to?".

You can't give an answer like "Language X", right? You can only say it looks
like any of a set of languages.

Similarly, it isn't always easy to identify the language of a text if the only
two active languages are very similar.

Now that we've taken out of the way the warning that language identification
is not 100% accurate, please keep reading the documentation.

=head1 WHY LINGUA::IDENTIFY

You might be wondering why you should use Lingua::Identify instead of any other
tool for language identification.

Here's a list of Lingua::Identify's strong points:

=over 6

=item * it's free and its source is open;

=item * it's portable (it's Perl, which means it will work in lots of different
platforms);

=item * 4 different methods of language identification and still growing (see
METHODS OF LANGUAGE IDENTIFICATION for more details on this one);

=item * it's a module, which means you can easily write your own application
(be it CGI, TK, whatever) using it;

=item * it comes with I<langident>, which means you don't actually need to
write your own application;

=item * 19 languages and growing;

=item * it's flexible (you can actually chose the methods to use and their
relevance, and pretty soon you'll be able to chose some other things)

=item * it's easy to deal with languages (you can activate and deactivate the
ones you chose whenever you want to, which can improve your times and
accuracy);

=item * and other things too, probably.

=back

=cut

# initialization

our (@all_languages,@active_languages,%languages,%regexen,@methods);
BEGIN {

  use Class::Factory::Util;
  for ( Lingua::Identify->subclasses() ) {
    /^[A-Z][A-Z]$/ || next;
    eval "require Lingua::Identify::$_ ;";
    $languages{_versions}{lc $_} >= 0.01 ||
      die "Required version of language $_ not found.\n";
  } 
  
  @all_languages = @active_languages = keys %{$languages{_names}};

  @methods = qw/smallwords/;

}

=head1 HOW TO PERFORM IDENTIFICATION

To identify the language a given text is written in, use the I<langof> function.
To get a single value, do:

  $language = langof($text);

To get the most probable language and also the percentage of its probability,
do:

  ($language, $probability) = langof($text);

If you want a hash where each active language is mapped into its percentage,
use this:

  %languages = langof($text);

=cut

sub langof {
  my %config = ();
  if (ref($_[0]) eq 'HASH') {%config = (%config, %{+shift})}

  my $text = join "\n", @_;

  # select the methods
  my %methods;
  if (defined $config{method}) {
    for (ref($config{method})) {
      if (/^HASH$/) {
        %methods = %{$config{method}};
      }
      elsif (/^ARRAY$/) {
        for (@{$config{method}}) {
          $methods{$_}++;
        }
      }
      else {
        $methods{$config{method}} = 1;
      }
    }
  }
  else {
    %methods = (qw/smallwords 0.5 prefixes2 1 suffixes3 1 ngrams3 1.3/);
  }

=head2 OPTIONS

I<langof> can also be given some configuration parameters, in this way:

  $language = langof(\%config, $text);

These parameters are detailed here:

=over 6

=item * B<method>

You can chose which method or methods to use, and also the relevance of each of
them.

To chose a single method to use:

  langof( {method => 'smallwords' }, $text);

To chose several methods:

  langof( {method => [qw/prefixes2 suffixes2/]}, $text);

To chose several methods and give them different weight:

  langof( {method => {smallwords => 0.5, ngrams3 => 1.5} }, $text);

To see the list of available methods, see section METHODS OF LANGUAGE
IDENTIFICATION.

If no method is specified, the configuration for this parameter is the
following (this might change in the future):

  method => {
    smallwords => 0.5,
    prefixes2  => 1,
    suffixes3  => 1,
    ngrams3    => 1.3
  };

=back

=cut

  # use the methods
  my (%result,$total);
  for (keys %methods) {
    my %temp_result;

    if (/^smallwords$/) {
      %temp_result = langof_by_word_method('smallwords', $text);
    }
    elsif (/^(prefixes[1-4])$/) {
      %temp_result = langof_by_prefix_method($1, $text);
    }
    elsif (/^(suffixes[1-4])$/) {
      %temp_result = langof_by_suffix_method($1, $text);
    }
    elsif (/^(ngrams[1-4])$/) {
      %temp_result = langof_by_ngram_method($1, $text);
    }

    for my $l (keys %temp_result) {
      my $temp = $temp_result{$l} * $methods{$_};
      $result{$l} += $temp;
      $total += $temp;
    }
  }

  # report the results
  my @result = (
    map { ( $_, ($total ? $result{$_} / $total : 0)) }
      sort { $result{$b} <=> $result{$a} } keys %result
  );

  return wantarray ? @result : $result[0];
}

=head1 LANGUAGE IDENTIFICATION IN GENERAL

Language identification is based in patterns.

In order to identify the language a given text is written in, we repeat a given
process for each active language (see section LANGUAGES MANIPULATION); in that
process, we look for common patterns of that language. Those patterns can be
prefixes, suffixes, common words, ngrams or even sequences of words.

After repeating the process for each language, the total score for each of them
is then used to compute the probability (in percentage) for each language to be
the one of that text.

=cut

sub langof_by_method {
  my ($method, $elements, $text) = @_;
  my (%result, $total);

  for my $language (get_active_languages()) {
    for (keys %{$languages{$method}{$language}}) {
      if (exists $$elements{$_}) {
        $result{$language} +=
          $$elements{$_} * ${languages{$method}{$language}{$_}};
        $total +=
          $$elements{$_} * ${languages{$method}{$language}{$_}};
      }
    }
  }

  my @result = (
    map { ( $_, ($total ? $result{$_} / $total : 0)) }
      sort { $result{$b} <=> $result{$a} } keys %result
  );

  return wantarray ? @result : $result[0];
}

=head1 METHODS OF LANGUAGE IDENTIFICATION

C<Lingua::Identify> currently comprises four different ways for language
identification, in a total of thirteen variations of those.

The available methods are the following: B<smallwords>, B<prefixes1>,
B<prefixes2>, B<prefixes3>, B<prefixes4>, B<suffixes1>, B<suffixes2>,
B<suffixes3>, B<suffixes4>, B<ngrams1>, B<ngrams2>, B<ngrams3> and B<ngrams4>.

Here's a more detailed explanation of each of those ways and those methods

=head2 Small Word Technique - B<smallwords>

The "Small Word Technique" searches the text for the most common words of each
active language. These words are usually articles, pronouns, etc, which happen
to be (usually) the shortest words of the language; hence, the method name.

This is usually a good method for big texts, especially if you happen to have
few languages active.

=cut

sub langof_by_word_method {
  use Text::ExtractWords qw(words_count);

  my ($method, $text) = (shift, shift);

  my %words;
  words_count(\%words, $text);

  return langof_by_method($method, \%words, $text);
}

=head2 Prefix Analysis - B<prefixes1>, B<prefixes2>, B<prefixes3>, B<prefixes4>

This method analyses text for the common prefixes of each active language.

The methods are, respectively, for prefixes of size 1, 2, 3 and 4.

=cut

sub langof_by_prefix_method {
  use Text::Affixes;

  (my $method = shift) =~ /^prefixes(\d)$/;
  my $text = shift;

  my $prefixes = get_prefixes({min => $1, max => $1}, $text);

  return langof_by_method($method, $$prefixes{$1}, $text);
}

=head2 Suffix Analysis - B<suffixes1>, B<suffixes2>, B<suffixes3>, B<suffixes4>

Similar to the Prefix Analysis (see above), but instead analysing common
suffixes.

The methods are, respectively, for suffixes of size 1, 2, 3 and 4.

=cut

sub langof_by_suffix_method {
  use Text::Affixes;

  (my $method = shift) =~ /^suffixes(\d)$/;
  my $text = shift;

  my $suffixes = get_suffixes({min => $1, max => $1}, $text);

  return langof_by_method($method, $$suffixes{$1}, $text);
}

=head2 Ngram Categorization - B<ngrams1>, B<ngrams2>, B<ngrams3>, B<ngrams4>

Ngrams are sequences of tokens. You can think of them as syllables, but they
are also more than that, as they are not only comprised by characters, but also
by spaces (delimiting or separating words).

Ngrams are a very good way for identifying languages, given that the most
common ones of each language are not generally very common in others.

This is usually the best method for small amounts of text or too many active
languages.

The methods are, respectively, for ngrams of size 1, 2, 3 and 4.

=cut

sub langof_by_ngram_method {
  use Text::Ngram qw(ngram_counts);

  (my $method = shift) =~ /^ngrams([2-4])$/;
  my $text = shift;

  my $ngrams = ngram_counts($text, $1);

  return langof_by_method($method, $ngrams, $text);
}

=head1 LANGUAGE MANIPULATION

When trying to perform language identification, C<Lingua::Identify> works not with
all available languages, but instead with the ones that are active.

By default, all available languages are active, but that can be changed by the
user.

For your convenience, several methods regarding language manipulation were
created. In order to use them, load the module with the tag
:language_manipulation.

These methods work with the two letters code for languages.

=over 6

=item B<activate_language>

Activate a language

  activate_language('en');

  # or

  activate_language($_) for get_all_languages();

=cut

sub activate_language {
  unless (grep { $_ eq $_[0] } @active_languages) {
    push @active_languages, $_[0];
  }
  @active_languages;
}

=item B<activate_all_languages>

Activates all languages

  activate_all_languages();

=cut

sub activate_all_languages {
  @active_languages = get_all_languages();
}

=item B<deactivate_language>

Deactivates a language

  deactivate_language('en');

=cut

sub deactivate_language {
  @active_languages = grep { ! ($_ eq $_[0]) } @active_languages;
}

=item B<deactivate_all_languages>

Deactivates all languages

  deactivate_all_languages();

=cut

sub deactivate_all_languages {
  @active_languages = ();
}

=item B<get_all_languages>

Returns the names of all available languages

  my @all_languages = get_all_languages();

=cut

sub get_all_languages {
  @all_languages;
}

=item B<get_active_languages>

Returns the names of all active languages

  my @active_languages = get_active_languages();

=cut

sub get_active_languages {
  @active_languages;
}

=item B<get_inactive_languages>

Returns the names of all inactive languages

  my @active_languages = get_inactive_languages();

=cut

sub get_inactive_languages {
  grep { ! is_active($_) } get_all_languages();
}

=item B<is_active>

Returns the name of the language if it is active, an empty list otherwise

  if (is_active('en')) {
    # YOUR CODE HERE
  }

=cut

sub is_active {
  grep { $_ eq $_[0] } get_active_languages();
}

=item B<is_valid_language>

Returns the name of the language if it exists, an empty list otherwise

  if (is_valid_language('en')) {
    # YOUR CODE HERE
  }

=cut

sub is_valid_language {
  grep { $_ eq $_[0] } get_all_languages();
}

=item B<set_active_languages>

Sets the active languages

  set_active_languages('en', 'pt');

  # or

  set_active_languages(get_all_languages());

=cut

sub set_active_languages {
  @active_languages = grep { is_valid_language($_) } @_;
}

=item B<name_of>

Given the two letter tag of a language, returns its name

  my $language_name = name_of('pt');

=cut

sub name_of {
  my $tag = shift || return undef;
  $languages{_names}{$tag};
}

=back

=cut

1;
__END__

=head1 KNOWN LANGUAGES

Currently, C<Lingua::Identify> knows the following languages:

=over 6

=item AF - Afrikaans
=item BR - Breton
=item BS - Bosnian
=item CY - Welsh
=item DA - Danish
=item DE - German
=item EN - English
=item EO - Esperanto
=item ES - Spanish
=item FI - Finnish
=item FR - French
=item FY - Frisian
=item IT - Italian
=item LA - Latin
=item NL - Dutch
=item NO - Norwegian
=item PT - Portuguese
=item SQ - Albanian
=item SV - Swedish

=back

=head1 EXAMPLES

=head2 THE BASIC EXAMPLE

Check the language a given text file is written in:

  use Lingua::Identify qw/langof/;

  my $text = join "\n", <>;

  # identify the language by letting the module decide on the best way
  # to do so
  my $language = langof($text);

=head2 IDENTIFYING BETWEEN TWO LANGUAGES

Check the language a given text file is written in, supposing you
happen to know it's either Portuguese or English:

  use Lingua::Identify qw/langof activate_language/;
  activate_language(qw/pt en/);

  my $text = join "\n", <>;

  # identify the language by letting the module decide on the best way
  # to do so
  my $language = langof($text);

=head1 TO DO

=over 6

=item * Implement something like a confidence_level(@results)

=item * Add more examples in the documentation;

=item * Add examples of the values returned;

=item * Configuration parameter to let the user chose which part(s) of the text
to use;

=item * Configuration parameter to let the user chose a maximum size of text to
deal with;

=item * WordNgrams based methods;

=item * Easy way to learn new languages;

=item * More languages;

=item * File recognition and treatment;

=item * Create sets of languages and permit their activation/deactivation;

=back

=head1 SEE ALSO

langident(1), Text::ExtractWords(3), Text::Ngram(3), Text::Affixes(3).

A linguist and/or a shrink.

The latest CVS version of C<Lingua::Identify> can be attained at
http://natura.di.uminho.pt/natura/viewcvs.cgi/Lingua/Identify/

=head1 AUTHOR

Jose Castro, C<< <cog@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2004 Jose Castro, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

#use Test::More tests => 4;
use Test::More 'no_plan';
BEGIN { use_ok('Lingua::Identify') };

#########################

$pt_sentence = 'Todas as ferramentas foram desenvolvidas na linguagem de
scripting Perl, pelo que a aprendizagem de novas técnicas e o aprofundamento
dos conhecimentos já existentes nesta área revelou-se fundamental.';

$en_sentence = 'If you\'re new to Perl, you should start with perlintro, which is a general intro for beginners and provides some background to help you navigate the rest of Perl\'s extensive documentation.
';

# Some basic tests of language identification

set_active_languages('pt','en');
is(langof($pt_sentence),'pt','Basic Portuguese test');

set_active_languages('fr','en');
is(langof($en_sentence),'en','Basic English test');

__END__

my @a = langof($pt_sentence);

is($a[0],'a');
is($a[1],'b');
is($a[2],'c');
is($a[3],'d');
is($a[4],'e');
is($a[5],'f');

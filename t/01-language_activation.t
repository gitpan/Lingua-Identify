# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

#use Test::More tests => 4;
use Test::More 'no_plan';
BEGIN { use_ok('Lingua::Identify') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

$pt_sentence = 'O projecto tem estado ligado às Disciplinas de Scripting, de
PLN e também de FTT leccionadas na Universidade do Minho, Departamento de
Informática.';

$en_sentence = 'YAPC::Europe::2004 in Belfast will run from Wednesday 15th to
Friday 17th September. Our theme will be "Perl for Profit".';

# Testing active languages and the activation / deactivation

# lets see if the results include all known languages
%results = langof($pt_sentence);
@results = sort keys %results;

@active_languages = active_languages();
@active_languages = sort @active_languages;
is(@results, @active_languages, 'Active languages');

# lets activate one single language and see if it's the only one activated
set_active_languages('pt');
@active_languages = active_languages();
is(@active_languages,1);
is($active_languages[0],'pt');


use Test::More tests => 25;
BEGIN { use_ok('Lingua::Identify', ':language_manipulation') };

for (get_all_languages()) {
  is(is_valid_language($_), 1);
}

for (qw/zbr xx zz/, '') {
  is(is_valid_language($_), 0);
}

is_deeply([get_all_languages()], [get_active_languages()]);
is_deeply([sort (get_all_languages())], [sort (get_active_languages())]);

is_deeply([sort (get_all_languages())], [sort qw/de en es fr it pt/]);

is_deeply([sort (deactivate_language('fr'))], [qw/de en es it pt/]);

is_deeply([sort (get_active_languages())], [qw/de en es it pt/]);

is_deeply([get_inactive_languages()], [qw/fr/]);

is(is_active('fr'), 0);

is_deeply([deactivate_all_languages()], []);

is_deeply([get_inactive_languages()], [get_all_languages()]);

is_deeply([activate_language('pt')],[qw/pt/]);

is(is_active('pt'), 1);

is_deeply([sort (set_active_languages(qw/it fr/))], [qw/fr it/]);

is_deeply([sort (get_active_languages())], [qw/fr it/]);

is_deeply([activate_all_languages()], [get_all_languages()]);

use Test::More tests => 57;
BEGIN { use_ok('Lingua::Identify', ':language_manipulation') };

my @languages = qw/af bg br bs cy da de en eo es fi fr fy ga hr hu
                   id is it la ms nl no pl pt ro ru sl so sq sv sw
                   tr/;

for (get_all_languages()) {
  is(is_valid_language($_), 1);
}

for (qw/zbr xx zz/, '') {
  is(is_valid_language($_), 0);
}

is_deeply(	[ get_all_languages()                      ],
		[ get_active_languages()                   ]);

is_deeply(	[ sort ( get_all_languages() )             ],
		[ sort ( get_active_languages() )          ]);

is_deeply(	[ sort ( get_all_languages() )             ],
		[ sort @languages                          ]);

is_deeply(	[ sort ( deactivate_language('fr') )       ],
		[ sort grep {! /^fr$/ } @languages         ]);

is_deeply(	[ sort ( get_active_languages() )          ],
		[ sort grep {! /^fr$/ } @languages         ]);

is_deeply(	[ get_inactive_languages()                 ],
		[ qw/fr/                                   ]);

is(is_active('fr'), 0);

is_deeply(	[ deactivate_all_languages()               ],
		[                                          ]);

is_deeply(	[ get_inactive_languages()                 ],
		[ get_all_languages()                      ]);

is_deeply(	[ activate_language('pt')                  ],
		[ qw/pt/                                   ]);

is(is_active('pt'), 1);

is_deeply(	[ sort ( set_active_languages(qw/it fr/) ) ],
		[ qw/fr it/                                ]);

is_deeply(	[ sort ( get_active_languages() )          ],
		[ qw/fr it/                                ]);

is_deeply(	[ activate_all_languages()                 ],
		[ get_all_languages()                      ]);

is(name_of('pt'), 'portuguese');

deactivate_all_languages();

is_deeply(	[ get_active_languages()                   ],
		[                                          ]);

is_deeply(      [ activate_all_languages()                 ],
                [ get_all_languages                        ]);

is_deeply(	[ sort ( get_all_languages() )             ],
		[ sort @languages                          ]);

is_deeply(	[ sort ( get_active_languages() )          ],
		[ sort @languages                          ]);

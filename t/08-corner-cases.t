use Test::More tests => 19;
BEGIN { use_ok('Lingua::Identify', qw/:language_manipulation :language_identification/) };

is(langof(), undef);

my @undef = langof();
is_deeply( [ @undef ] , [ ] );

is(langof( { method => 'smallwords' }, ' '), undef);

my @pt = langof( { method => 'suffixes4' }, 'melhor');

is_deeply( [ @pt ], [ 'pt', 1 ]);
is_deeply(confidence(@pt), 1 );



@pt = langof_file( { 'max-size' => 0 }, 't/files/pt');

is($pt[0],'pt');
cmp_ok($pt[1],'>','0.19');
cmp_ok(confidence(@pt),'>','0.55');


my @xx = langof( { method => 'suffixes4' }, 'z');

is_deeply( [ @xx ], [ ]);
is_deeply(confidence(@xx), 0 );


is_deeply(	[ deactivate_all_languages()               ],
		[                                          ]);

is_deeply(	[ get_active_languages()                   ],
		[                                          ]);

@pt = langof( { method => 'suffixes4' }, 'melhor');

is_deeply( [ @pt ], [  ]);
is_deeply(confidence(@pt), 0 );


is_deeply(	[ sort ( set_active_languages(qw/pt/) )    ],
		[ qw/pt/                                   ]);


is_deeply(	[ get_active_languages()                   ],
		[ qw/pt/                                   ]);


@pt = langof( { method => 'suffixes4' }, 'zzzzzz');

is_deeply( [ @pt ], [ ]);
is_deeply(confidence(@pt), 0 );

__END__




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

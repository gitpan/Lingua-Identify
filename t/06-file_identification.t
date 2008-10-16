use Test::More tests => 19;
BEGIN { use_ok('Lingua::Identify', qw/:language_identification/) };

my @de = langof_file('t/files/de');

is($de[0],'de');
cmp_ok($de[1],'>','0.15');
cmp_ok(confidence(@de),'>','0.60');

my @pt = langof_file('t/files/pt');

is($pt[0],'pt');
cmp_ok($pt[1],'>','0.19');
cmp_ok(confidence(@pt),'>','0.55');

my @en = langof_file('t/files/en');

is($en[0],'en');
cmp_ok($en[1],'>','0.25');
cmp_ok(confidence(@en),'>','0.74');

@pt = langof_file({method=>'smallwords'},'t/files/pt_big');

is($pt[0],'pt');
cmp_ok($pt[1],'>','0.14');
cmp_ok(confidence(@pt),'>','0.50');

@pt = langof_file('t/files/pt_big');

is($pt[0],'pt');
cmp_ok($pt[1],'>','0.14');
cmp_ok(confidence(@pt),'>','0.50');

@pt = langof_file('t/files/en', 't/files/pt_big');
is($pt[0],'pt');
cmp_ok($pt[1],'>','0.14');
cmp_ok(confidence(@pt),'>','0.50');

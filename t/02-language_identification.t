use Test::More tests => 7;
BEGIN { use_ok('Lingua::Identify', qw/:language_manipulation langof/) };

my @de = langof(<<EOT);
soviel nehmen darf, als man ihr giebt, wenn sie nur ihre Tugend
behauptet?  Das gilt auch fuer Minister und erlaubt mir, in dieser
kargen Zeit unter Umstaenden auf mein Gehalt zu verzichten.  Dafuer
kannst du dir zuweilen ein gutes Bild kaufen, Fraenzchen.  Du musst
auch deine ehrbare Ergoetzung haben.
EOT

is($de[0],'de');
cmp_ok($de[1],'>','0.50');

my @pt = langof(<<EOT);
As armas e os barões assinalados,
que da ocidental praia lusitana,
por mares nunca de antes navegados
EOT

is($pt[0],'pt');
cmp_ok($pt[1],'>','0.35');

my @en = langof(<<EOT);
this is an example of an english text; hopefully, it won't be mistaken
for a gaellic text, this time! That is not the purpose for this line.
EOT

is($en[0],'en');
cmp_ok($pt[1],'>','0.35');

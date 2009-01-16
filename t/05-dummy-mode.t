use Test::More tests => 10;
BEGIN { use_ok('Lingua::Identify', qw/:language_manipulation :language_identification/) };

my $text = '
As armas e os bar�es assinalados 
Que, da Ocidental praia Lusitana, 
Por mares nunca de antes navegados 
Passaram ainda al�m da Taprobana 
E em perigos e guerras esfor�ados 
Mais do que prometia a for�a humana, 
E entre gente remota edificaram 
Novo Reino, que tanto sublimaram; 

E tamb�m as mem�rias gloriosas 
Daqueles Reis que foram dilatando 
A F�, o Imp�rio, e as terras viciosas 
De �frica e de �sia andaram devastando, 
E aqueles que por obras valerosas 
Se v�o da lei da Morte libertando: 
Cantando espalharei por toda parte, 
Se a tanto me ajudar o engenho e arte. 

Cessem do s�bio Grego e do Troiano 
As navega��es grandes que fizeram; 
Cale-se de Alexandro e de Trajano 
A fama das vit�rias que tiveram; 
Que eu canto o peito ilustre Lusitano, 
A quem Neptuno e Marte obedeceram. 
Cesse tudo o que a Musa antiga canta, 
Que outro valor mais alto se alevanta. 

E v�s, T�gides minhas, pois criado 
Tendes em mi um novo engenho ardente 
Se sempre, em verso humilde, celebrado 
Foi de mi vosso rio alegremente, 
Dai-me agora um som alto e sublimado, 
Um estilo grand�loco e corrente, 
Por que de vossas �guas Febo ordene 
Que n�o tenham enveja �s de Hipocrene. 

Dai-me h�a f�ria grande e sonorosa, 
E n�o de agreste avena ou frauta ruda, 
Mas de tuba canora e belicosa, 
Que o peito acende e a cor ao gesto muda; 
Dai-me igual canto aos feitos da famosa 
Gente vossa, que a Marte tanto ajuda; 
Que se espalhe e se cante no Universo, 
Se t�o sublime pre�o cabe em verso. 

E v�s, � bem nascida seguran�a 
Da Lusitana antiga liberdade, 
E n�o menos cert�ssima esperan�a 
De aumento da pequena Cristandade; 
V�s, � novo temor da Maura lan�a, 
Maravilha fatal da nossa idade, 
Dada ao mundo por Deus (que todo o mande, 
Pera do mundo a Deus dar parte grande); 

V�s, tenro e novo ramo florecente, 
De h�a �rvore, de Cristo mais amada 
Que nenh�a nascida no Ocidente, 
Ces�rea ou Cristian�ssima chamada, 
(Vede-o no vosso escudo, que presente
Vos amostra a vit�ria j� passada, 
Na qual vos deu por armas e deixou
As que Ele pera Si na Cruz tomou); 

V�s, poderoso Rei, cujo alto Imp�rio 
O Sol, logo em nascendo, v� primeiro;
V�-o tamb�m no meio do Hemisf�rio, 
E, quando dece, o deixa derradeiro;
V�s, que esperamos jugo e vitup�rio 
Do torpe lsmaelita cavaleiro, 
Do Turco Oriental e do Gentio 
Que inda bebe o licor do santo Rio: 

Inclinai por um pouco a majestade, 
Que nesse tenro gesto vos contemplo,
Que j� se mostra qual na inteira idade,
Quando subindo ireis ao eterno Templo;
Os olhos da real benignidade 
Ponde no ch�o: vereis um novo exemplo
De amor dos p�trios feitos valerosos, 
Em versos devulgado numerosos. 

Vereis amor da p�tria, n�o movido 
De pr�mio vil, mas alto e quase eterno;
Que n�o � pr�mio vil ser conhecido 
Por um preg�o do ninho meu paterno. 
Ouvi: vereis o nome engrandecido 
Daqueles de quem sois senhor superno, 
E julgareis qual � mais excelente, 
Se ser do mundo Rei, se de tal gente. 

Ouvi: que n�o vereis com v�s fa�anhas,
Fant�sticas, fingidas, mentirosas,
Louvar os vossos, como nas estranhas Musas,
de engrandecer-se desejosas: 
As verdadeiras vossas s�o tamanhas, 
Que excedem as sonhadas, fabulosas, 
Que excedem Rodamonte e o v�o Rugeiro,
E Orlando, inda que fora verdadeiro. 

Por estes vos darei um Nuno fero, 
Que fez ao Rei e ao Reino tal servi�o, 
Um Egas e um Dom Fuas, que de Homero
A c�tara para eles s� cobi�o; 
Pois polos Doze Pares dar-vos quero 
Os Doze de Inglaterra e o seu Magri�o;
Dou-vos tamb�m aquele ilustre Gama,
Que para si de Eneias toma a fama. 

Pois, se a troco de Carlos, Rei de Fran�a,
Ou de C�sar, quereis igual mem�ria,
Vede o primeiro Afonso, cuja lan�a
Escura faz qualquer estranha gl�ria; 
E aquele que a seu Reino a seguran�a
Deixou, co a grande e pr�spera vit�ria;
Outro Joanne, invicto cavaleiro; 
O quarto e quinto Afonsos e o terceiro. 

Nem deixar�o meus versos esquecidos
Aqueles que, nos Reinos l� da Aurora, 
Se fizeram por armas t�o subidos, 
Vossa bandeira sempre vencedora: 
Um Pacheeo fort�ssimo e os temidos
Almeidas, por quem sempre o Tejo chora,
Albuquerque terribil, Castro forte, 
E outros em quem poder n�o teve a morte. 

E, enquanto eu estes canto, e a v�s n�o posso,
Sublime Rei, que n�o me atrevo a tanto,
Tomai as r�deas v�s do Reino vosso: 
Dareis mat�ria a nunca ouvido canto.
Comecem a sentir o peso grosso 
(Que polo mundo todo fa�a espanto) 
De ex�rcitos e feitos singulares 
De �frica as terras e do Oriente os mares.
';

my $t1 = langof( { 'mode' => 'dummy' }, $text);

is_deeply( $t1 ,
           {
           'method' => {
                         'smallwords' => '0.5',
                         'prefixes2' => '1',
                         'suffixes3' => '1',
                         'ngrams3' => '1.3',
                       },
           'config' => {
                         'mode' => 'dummy',
                       },
           'max-size' => 1000000,
           'active-languages' => [ sort (get_all_languages()) ],
           'text' => $text,
           'mode' => 'dummy',
           });

$t1 = langof( { method => { smallwords => 1, prefixes2 => 2 }, 'mode' => 'dummy' }, $text);

is_deeply( $t1 ,
           {
           'method' => {
                         'smallwords' => '1',
                         'prefixes2'  => '2',
                       },
           'config' => {
                         'mode' => 'dummy',
                         'method' => {
                                       'smallwords' => '1',
                                       'prefixes2'  => '2',
                                     },
                       },
           'max-size' => 1000000,
           'active-languages' => [ sort (get_all_languages()) ],
           'text' => $text,
           'mode' => 'dummy',
           });

$t1 = langof( { method => [ qw/smallwords prefixes2/ ], 'mode' => 'dummy' }, $text);

is_deeply( $t1 ,
           {
           'method' => {
                         'smallwords' => '1',
                         'prefixes2'  => '1',
                       },
           'config' => {
                         'mode' => 'dummy',
                         'method' => [
                                       'smallwords' ,
                                       'prefixes2'  ,
                                     ],
                       },
           'max-size' => 1000000,
           'active-languages' => [ sort (get_all_languages()) ],
           'text' => $text,
           'mode' => 'dummy',
           });

$t1 = langof( { method => 'smallwords', 'mode' => 'dummy' }, $text);

is_deeply( $t1 ,
           {
           'method' => {
                         'smallwords' => '1',
                       },
           'config' => {
                         'mode' => 'dummy',
                         'method' => 'smallwords',
                       },
           'max-size' => 1000000,
           'active-languages' => [ sort (get_all_languages()) ],
           'text' => $text,
           'mode' => 'dummy',
           });




is_deeply( [ set_active_languages( qw/pt es af/ ) ] , [ qw/pt es af/ ] );

is_deeply( [ get_active_languages(              ) ] , [ qw/pt es af/ ] );





my $t2 = langof( { 'method' => 'smallwords', 'mode' => 'dummy' }, $text);

is_deeply( $t2 ,
           {
           'method' => {
                          'smallwords' => '1',
                        },
           'config'  => {
                          'mode'       => 'dummy',
                          'method'     => 'smallwords',
                        },
           'max-size'          => 1000000,
           'active-languages' => [
				   'af', 'es', 'pt',
                                 ],
           'text' => $text,
           'mode' => 'dummy',
           });

my $t3 = langof( { 'max-size' => 100, 'method' => 'smallwords', 'mode' => 'dummy' }, $text);

is_deeply( $t3 ,
           {
           'method' => {
                          'smallwords' => '1',
                        },
           'config'  => {
                          'mode'       => 'dummy',
                          'method'     => 'smallwords',
                          'max-size'   => 100,
                        },
           'max-size'         => 100,
           'active-languages' => [
				   'af', 'es', 'pt',
                                 ],
           'text' => substr($text,0,100),
           'mode' => 'dummy',
           });

$t3 = langof( { 'max-size' => 0, 'method' => 'smallwords', 'mode' => 'dummy' }, $text);

is_deeply( $t3 ,
           {
           'method' => {
                          'smallwords' => '1',
                        },
           'config'  => {
                          'mode'       => 'dummy',
                          'method'     => 'smallwords',
                          'max-size'   => 0,
                        },
           'max-size'         => 0,
           'active-languages' => [
				   'af', 'es', 'pt',
                                 ],
           'text' => $text,
           'mode' => 'dummy',
           });


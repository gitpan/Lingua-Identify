package Lingua::Identify;

use 5.008;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
  'all' => [
    qw(
      langof active_languages set_active_languages
      )
  ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
  langof active_languages set_active_languages
);

our $VERSION = '0.01';

=head1 NAME

Lingua::Identify - Perl extension for language identification

=head1 SYNOPSIS

  use Lingua::Identify;
  $a = langof($textstring); # gives the most probable language

  @a = langof($textstring); # gives pairs of languages / probabilities
			    # sorted from most to least probable

  %a = langof($textstring); # gives a hash of language / probability

=head1 DESCRIPTION

C<Lingua::Identify> identifies the language a given string or file is written
in.

=head2 HOW IT ALL WORKS

It doesn't, yet... O:-)

Though the code already exists, I am currently in the process of migrating all
of it to this module, in the best possible way.

=cut

my @active_languages;
my $all_languages;
our %sets;

# This will hold the information with which we're going to identify languages
our %languages;
my ($charexpr, $noncharexpr);

use Class::Factory::Util;

BEGIN {

  %{$languages{names}} = (
    'ca' => 'catalan',
    'da' => 'danish',
    'de' => 'german',
    'en' => 'english',
    'es' => 'spanish',
    'et' => 'estonian',
    'eu' => 'basque',
    'fo' => 'faroese',
    'fr' => 'french',
    'fy' => 'frisian',
    'ga' => 'irish',
    'gd' => 'gaelic',
    'hu' => 'hungarian',
    'is' => 'icelandic',
    'it' => 'italian',
    'lt' => 'lithuanian',
    'lv' => 'latvian',
    'nb' => 'norwegian_bokmal',
    'nl' => 'dutch',
    'nn' => 'norwegian_nynorsk',
    'pt' => 'portuguese',
    'rm' => 'rumantsch',
    'ru' => 'russian',
    'sl' => 'slovene',
    'sv' => 'swedish',
  );

  %{$languages{tags}} = (
    'ca' => 'ca',
    'da' => 'da',
    'de' => 'de',
    'en' => 'en',
    'es' => 'es',
    'et' => 'et',
    'eu' => 'eu',
    'fo' => 'fo',
    'fr' => 'fr',
    'fy' => 'fy',
    'ga' => 'ga',
    'gd' => 'gd',
    'hu' => 'hu',
    'is' => 'is',
    'it' => 'it',
    'lt' => 'lt',
    'lv' => 'lv',
    'nb' => 'nb',
    'nl' => 'nl',
    'nn' => 'nn',
    'pt' => 'pt',
    'rm' => 'rm',
    'ru' => 'ru',
    'sl' => 'sl',
    'sv' => 'sv',
  );

  %{$languages{smallwords}{ca}} = (
    'de'      => 5.34929505137272,
    'la'      => 3.66307519731452,
    'que'     => 3.21807162219684,
    'i'       => 2.65136191336945,
    'a'       => 2.50810882639583,
    'el'      => 2.34178745948692,
    'del'     => 1.37475150370722,
    'en'      => 1.37434788642707,
    'va'      => 1.35019294458366,
    'per'     => 1.32197078245556,
    'un'      => 1.120969376936,
    'les'     => 1.10771210165691,
    'els'     => 1.04723160459913,
    'una'     => 0.881903757149071,
    'amb'     => 0.84054850967424,
    'no'      => 0.811984825232165,
    'al'      => 0.690123454107008,
    'ha'      => 0.630574381541899,
    'es'      => 0.627655918131513,
    'frag'    => 0.539605256090507,
  );
  %{$languages{smallwords}{da}} = (
    'i'       => 3.09486823335627,
    'at'      => 2.62090929152802,
    'og'      => 2.57403264633807,
    'er'      => 1.97112687127962,
    'en'      => 1.60289279383363,
    'til'     => 1.53885208471259,
    'af'      => 1.47134971563906,
    'det'     => 1.40730900651802,
    'for'     => 1.33576803416658,
    'med'     => 1.12965503116215,
    'de'      => 1.09864432742111,
    'den'     => 1.0731145852715,
    'der'     => 1.06373925623351,
    'har'     => 0.98758273727876,
    'som'     => 0.939407969606626,
    'ikke'    => 0.888636956970124,
    'et'      => 0.741949116483415,
    'om'      => 0.712669242718615,
    'fra'     => 0.551557819096536,
    'art'     => 0.535547641816275,
  );
  %{$languages{smallwords}{de}} = (
    'der'     => 3.35230178770635,
    'die'     => 3.04421542687077,
    'und'     => 2.18117088926208,
    'in'      => 1.61574180349326,
    'den'     => 1.13649635330458,
    'zu'      => 0.997555445476769,
    'von'     => 0.989500900095446,
    'das'     => 0.843713628693513,
    'nicht'   => 0.792969992791182,
    'mit'     => 0.790150901907719,
    'ist'     => 0.776860902028537,
    'im'      => 0.748267265924843,
    'auf'     => 0.730949993355,
    'f¸r'     => 0.728533629740603,
    'sich'    => 0.712021811708893,
    'des'     => 0.706786357211033,
    'dem'     => 0.621810903438083,
    'eine'    => 0.596036358217851,
    'Die'     => 0.593619994603455,
    'ein'     => 0.576302722033612,
  );
  %{$languages{smallwords}{en}} = (
    'the'     => 6.96050462996671,
    'of'      => 3.87540458429584,
    'in'      => 3.36574420344054,
    'and'     => 2.99574400487156,
    'to'      => 2.01547514247324,
    'for'     => 1.2959935398892,
    'The'     => 1.04513472905263,
    'by'      => 1.03322059027939,
    'a'       => 0.952469205260754,
    'on'      => 0.856494198476314,
    'with'    => 0.633435044777305,
    'is'      => 0.618211423011497,
    'are'     => 0.550697969963132,
    'data'    => 0.499070035279089,
    'from'    => 0.485170206710308,
    'that'    => 0.477889344126661,
    'as'      => 0.465313308754906,
    'was'     => 0.398461752305055,
    'be'      => 0.380590544145194,
    'p'       => 0.365366922379386,
  );
  %{$languages{smallwords}{es}} = (
    'de'      => 6.86375266675644,
    'la'      => 3.78087590102701,
    'que'     => 3.13778300694361,
    'el'      => 2.78301875648231,
    'en'      => 2.59528855308824,
    'y'       => 2.18741361835437,
    'a'       => 2.04102847611555,
    'los'     => 1.58155490505993,
    'del'     => 1.40516506129701,
    'se'      => 1.09944786624046,
    'un'      => 1.07256176361493,
    'las'     => 0.957882376844876,
    'por'     => 0.895274141381209,
    'con'     => 0.837343804265393,
    'una'     => 0.804976527818138,
    'su'      => 0.745108879265334,
    'no'      => 0.709528500922585,
    'para'    => 0.667474667290386,
    'al'      => 0.590927239780092,
    'El'      => 0.57287716736717,
  );
  %{$languages{smallwords}{et}} = (
    'ja'      => 2.28455745853968,
    'on'      => 2.22396279827066,
    'et'      => 1.12909592150139,
    'ei'      => 0.927422090377013,
    'art'     => 0.779867154302067,
    'dt'      => 0.779558784529705,
    'ka'      => 0.681034642260227,
    'kui'     => 0.578655877836231,
    'Eesti'   => 0.50310528360768,
    'ning'    => 0.498017182363716,
    'num'     => 0.389779392264853,
    'oma'     => 0.387929173630684,
    'oli'     => 0.374515088532962,
    'mis'     => 0.319008529507904,
    'ta'      => 0.317929235304639,
    'aga'     => 0.302510746686567,
    'a'       => 0.293413838401904,
    'see'     => 0.273986542743134,
    'aasta'   => 0.270748660133339,
    'krooni'  => 0.263501970482845,
  );
  %{$languages{smallwords}{eu}} = (
    'eta'     => 3.72283766510439,
    'du'      => 1.62974009373669,
    'da'      => 1.47528760119301,
    'art'     => 1.33148700468683,
    'dute'    => 1.26224968044312,
    'ere'     => 1.17170856412441,
    'ez'      => 0.963996591393268,
    'dira'    => 0.889433319130805,
    'egin'    => 0.862803579037069,
    'izan'    => 0.761610566680869,
    'bat'     => 0.71900298253089,
    'ditu'    => 0.521942905837239,
    'izango'  => 0.484661269706008,
    'dituzte' => 0.468683425649766,
    'bi'      => 0.436727737537282,
    'beste'   => 0.410097997443545,
    'baina'   => 0.356838517256072,
    'zuen'    => 0.346186621218577,
    'dela'    => 0.335534725181082,
    'den'     => 0.314230933106093,
  );
  %{$languages{smallwords}{fo}} = (
    'at'      => 3.9927879721988,
    'og'      => 3.17271061738448,
    'art'     => 2.4078867013697,
    'er'      => 1.57036089219763,
    'sum'     => 1.43077325733562,
    'vi'     => 1.3318986826417,
    'um'      => 1.3289906069154,
    'til'     => 1.31735830401024,
    'av'      => 1.25628871375811,
    'fyri'    => 1.09343647308576,
    'ikki'    => 0.901503475150493,
    'hevur'   => 0.793904673277692,
    'hava'    => 0.756099688835897,
    'hj·'     => 0.74446738593073,
    'var'     => 0.65431703841568,
    'eru'     => 0.65431703841568,
    'verur'  => 0.540902085090296,
    'ta'     => 0.540902085090296,
    'sigur'   => 0.529269782185128,
    'fr·'     => 0.465292116206706,
  );
  %{$languages{smallwords}{fr}} = (
    'de'      => 5.52521639178436,
    'la'      => 3.0188239680993,
    'le'      => 2.10184296612476,
    'et'      => 1.97041292764135,
    'les'     => 1.81817968810931,
    'des'     => 1.71046496409565,
    'en'      => 1.35696117282523,
    'du'      => 1.29450136082725,
    'un'      => 1.20743921130596,
    'est'     => 1.12437703366771,
    'une'     => 1.03172496528058,
    'qui'     => 0.885014699478263,
    'que'     => 0.879023109795714,
    'dans'    => 0.83478911110583,
    'pour'    => 0.830320523269962,
    'au'      => 0.676447127903034,
    'il'      => 0.664212904277493,
    'pas'     => 0.646572860910434,
    'par'     => 0.611694444993023,
    'sur'     => 0.56396256294098,
  );
  %{$languages{smallwords}{fy}} = (
    'de'      => 5.40767134772584,
    'fan'     => 3.2802347516244,
    'it'      => 2.65143575770279,
    'yn'      => 2.50471599245441,
    'in'      => 2.23223642842171,
    'De'      => 2.07503667994131,
    'art'     => 1.8759169985328,
    'en'      => 1.49863760217984,
    'is'      => 1.38335778662754,
    'op'      => 1.33095787046741,
    'foar'    => 1.27855795430727,
    'mei'     => 0.964158457346468,
    'dat'     => 0.880318591490254,
    'net'     => 0.8593586250262,
    'hat'     => 0.785998742402012,
    'nei'     => 0.702158876545798,
    'om'      => 0.691678893313771,
    'te'      => 0.639278977153637,
    'It'      => 0.62879899392161,
    'by'      => 0.607839027457556,
  );
  %{$languages{smallwords}{ga}} = (
    'an'      => 5.02789535875077,
    'a'       => 3.95695289947201,
    'ar'      => 2.88900189957671,
    'na'      => 2.68034760758036,
    'go'      => 2.40064615522683,
    'agus'    => 2.14338064824925,
    'ag'      => 1.94070927501982,
    'i'       => 1.73579430725279,
    'le'      => 1.28109248096684,
    'seo'     => 0.818912006222235,
    'de'      => 0.703740819959017,
    'at·'     => 0.665599712819899,
    'bhfuil'  => 0.659616794052979,
    'leis'    => 0.640172308060487,
    'sa'      => 0.614744903301075,
    'mar'     => 0.584830309466473,
    'is'      => 0.581090985237148,
    'raibh'   => 0.577351661007823,
    'T·'      => 0.54743706717322,
    'sin'     => 0.516774608492753,
  );
  %{$languages{smallwords}{gd}} = (
    'a'       => 5.58277149924819,
    'an'      => 4.29014890624242,
    'air'     => 2.95023524276083,
    'a'      => 2.47732453800262,
    'na'      => 2.00320124169375,
    'agus'    => 1.88679245283019,
    'tha'     => 1.70490372023088,
    'ann'     => 1.47814910025707,
    'e'       => 1.23805597322598,
    'gu'      => 1.11679681815977,
    'Tha'     => 0.833050395304845,
    'bha'     => 0.727554930397245,
    'iad'     => 0.7130038317893,
    'am'      => 0.682689043022748,
    'aig'     => 0.662074986661493,
    'sin'     => 0.653586845806858,
    'mi'      => 0.625697240141631,
    'ach'     => 0.517776592132706,
    'seo'     => 0.498375127322113,
    'mar'     => 0.492312169568802,
  );
  %{$languages{smallwords}{hu}} = (
    'a'       => 7.6695308222622,
    'az'      => 2.64813345698738,
    'A'       => 1.61904868319608,
    'Ès'      => 1.53077756796317,
    'hogy'    => 1.14417243036079,
    'nem'     => 0.906175625998637,
    'is'      => 0.902823558331564,
    'art'     => 0.744159022090126,
    'egy'     => 0.553091165066986,
    'Az'      => 0.541917606176743,
    'febru·r' => 0.401130764159693,
    'NÈpszava'=> 0.393309272936523,
    'id'      => 0.372079511045063,
    'Napilap' => 0.343028257930433,
    'szerint' => 0.319563784260925,
    'm·r'     => 0.317329072482877,
    'meg'     => 0.310624937148731,
    'volt'    => 0.277104260478005,
    'de'      => 0.263695989809714,
    'csak'    => 0.253639786808496,
  );
  %{$languages{smallwords}{is}} = (
    'a'      => 4.44668297596777,
    'og'      => 2.98748021298029,
    'art'     => 2.01755648294719,
    'sem'     => 1.57432724132969,
    'er'      => 1.39588429989927,
    'til'     => 1.34983450856238,
    'um'      => 1.24910059001295,
    'id'      => 1.00877824147359,
    'vi'     => 0.967045618074543,
    'var'     => 0.863433587566556,
    'en'      => 0.850482083753058,
    'fyrir'   => 0.814505684271118,
    'ekki'    => 0.699381205928911,
    'me'     => 0.699381205928911,
    'hefur'   => 0.644697078716362,
    'fr·'     => 0.631745574902864,
    'af'      => 0.595769175420924,
    '˛vÌ'     => 0.523816376457044,
    'hafa'    => 0.483522809037272,
    'veri'   => 0.431716793783278,
  );
  %{$languages{smallwords}{it}} = (
    'di'      => 3.9072279660624,
    'e'       => 2.33395150447401,
    'che'     => 2.09462654735964,
    'a'       => 1.85112893504567,
    'il'      => 1.8161713570402,
    'la'      => 1.71644489776995,
    'in'      => 1.3222217070796,
    'un'      => 1.30409383837916,
    'per'     => 1.12596782419213,
    'del'     => 1.10964810607817,
    'non'     => 0.938893782743753,
    'della'   => 0.933376605313181,
    'una'     => 0.845704483286198,
    'i'       => 0.816032268533543,
    'si'      => 0.787843664518522,
    'ha'      => 0.687560851221661,
    'le'      => 0.680235523204599,
    'con'     => 0.675321062636191,
    'da'      => 0.606843154527331,
    'al'      => 0.516389262367286,
  );
  %{$languages{smallwords}{lt}} = (
    'ir'      => 2.71899314802354,
    'kad'     => 1.11593392533904,
    'su'      => 0.634494915511245,
    'i'      => 0.588530758076898,
    'buvo'    => 0.567681037178843,
    'yra'     => 0.401830984580684,
    'tik'     => 0.398040126235583,
    'art'     => 0.379085834510079,
    'apie'    => 0.365343973009089,
    'o'       => 0.357762256318887,
    'savo'    => 0.344020394817897,
    'ne'      => 0.337860250007108,
    'kaip'    => 0.33549096354142,
    'Lietuvos'=> 0.30184709572865,
    'tai'     => 0.296634665504137,
    'Kauno'   => 0.291422235279623,
    'ar'      => 0.286683662348247,
    'met¯'    => 0.272467943554119,
    'dÎl'     => 0.270572514381569,
    'jau'     => 0.268677085209018,
  );
  %{$languages{smallwords}{lv}} = (
    'un'      => 2.55169633085652,
    'par'     => 1.15776740971142,
    'ir'      => 1.14624733598295,
    'no'      => 0.967686193191636,
    'ar'      => 0.950406082598929,
    'art'     => 0.829445308449974,
    't'       => 0.794885087264559,
    'ka'      => 0.789125050400323,
    'arÓ'     => 0.662404239387132,
    'uz'      => 0.558723575830885,
    'kas'     => 0.483843096595818,
    'id'      => 0.414722654224987,
    'nav'     => 0.362882322446864,
    'k‚'      => 0.345602211854156,
    'bija'    => 0.33984217498992,
    'to'      => 0.33984217498992,
    'darba'   => 0.316802027532976,
    'lÓdz'    => 0.31104199066874,
    'Latvijas'=> 0.31104199066874,
    'gan'     => 0.305281953804504,
  );
  %{$languages{smallwords}{nb}} = (
    'i'       => 3.45744031188779,
    'og'      => 2.4710658608914,
    'er'      => 2.07583211603946,
    'til'     => 1.58728607790355,
    'som'     => 1.47834031139924,
    'det'     => 1.47736321932297,
    'en'      => 1.43583680608142,
    'at'      => 1.41727205663226,
    'av'      => 1.39089057057292,
    'for'     => 1.38014255773393,
    'har'     => 1.19693779343296,
    'med'     => 1.11681624317868,
    'ikke'    => 0.960481510975187,
    'art'     => 0.940939669449751,
    'de'      => 0.834436633136124,
    'om'      => 0.721093952288594,
    'Det'     => 0.625338928813957,
    'et'      => 0.588697975953764,
    'den'     => 0.587720883877492,
    'fra'     => 0.557431029513066,
  );
  %{$languages{smallwords}{nl}} = (
    'de'      => 5.60284043949065,
    'van'     => 3.25899923887615,
    'het'     => 2.60451444500997,
    'een'     => 2.35131235495454,
    'en'      => 2.0601708092661,
    'in'      => 2.04622076327181,
    'is'      => 1.34072199367754,
    'dat'     => 1.30342459037062,
    'te'      => 1.14775608548868,
    'zijn'    => 1.10567247393268,
    'die'     => 1.01607699024547,
    'op'      => 0.943349972216645,
    'niet'    => 0.87114826972735,
    'met'     => 0.776007788678399,
    'voor'    => 0.712094398035086,
    'De'      => 0.667734419141097,
    'als'     => 0.637557959814529,
    'aan'     => 0.581874512623916,
    'hij'     => 0.510314862460718,
    'Het'     => 0.451712995606027,
  );
  %{$languages{smallwords}{nn}} = (
    'i'       => 3.37489183039005,
    'og'      => 2.71145155603987,
    'er'      => 2.22108265760713,
    'det'     => 1.91981026249159,
    'som'     => 1.80442934521329,
    'at'      => 1.71789365725458,
    'til'     => 1.67622832601519,
    'har'     => 1.48392679721804,
    'for'     => 1.3781609563796,
    'av'      => 1.22752475882183,
    'med'     => 1.02881317906477,
    'ein'     => 1.00958302618506,
    'ikkje'   => 0.990352873305343,
    'dei'     => 0.903817185346623,
    'om'      => 0.900612159866671,
    'Det'     => 0.71151565654947,
    'var'     => 0.692285503669754,
    'frÂ'     => 0.621774943110798,
    'han'     => 0.580109611871414,
    'den'     => 0.576904586391462,
  );
  %{$languages{smallwords}{pt}} = (
    'de'      => 5.17704165599457,
    'a'       => 3.54235435911928,
    'que'     => 2.74365415882829,
    'e'       => 2.69077456044867,
    'o'       => 2.34900832564308,
    'da'      => 1.99489028971505,
    'do'      => 1.77333502433404,
    'para'    => 1.07320120488761,
    'em'      => 1.06475171308899,
    'se'      => 0.972898627098132,
    'com'     => 0.900309059591405,
    'os'      => 0.895464243354623,
    'um'      => 0.892024919882779,
    'uma'     => 0.789126314280418,
    'no'      => 0.73164992779901,
    'n„o'     => 0.686657624112039,
    'na'      => 0.684160807553151,
    'dos'     => 0.637763011101243,
    'N'       => 0.615820788759233,
    'as'      => 0.605602029597693,
  );
  %{$languages{smallwords}{rm}} = (
    'da'      => 3.74291606449832,
    'la'      => 2.21976844258968,
    'e'       => 1.94371823392819,
    'il'      => 1.42247048698504,
    'in'      => 1.34127924914343,
    'per'     => 1.17240147443288,
    'a'       => 1.12206290697108,
    'che'     => 1.02788107107481,
    'cun'     => 1.00677134923599,
    'en'      => 0.907718039069224,
    'ch'      => 0.620301057109917,
    'ina'     => 0.60081516002793,
    'las'     => 0.558595716350291,
    'ei'      => 0.552100417322963,
    'ils'     => 0.548852767809298,
    'ha'      => 0.53586216975464,
    'ed'      => 0.53586216975464,
    'ins'     => 0.469285354724518,
    'el'      => 0.44168033385837,
    'es'      => 0.435185034831041,
  );
  %{$languages{smallwords}{ru}} = (
    'art'             => 36.8041912246234,
    'id'              => 18.4020956123117,
    'The'             => 1.30975769482646,
    'ru'              => 1.04780615586117,
    'Altavista'       => 0.91683038637852,
    'Columbia'        => 0.851342501637197,
    'Inopressa'       => 0.785854616895874,
    'Reuters'         => 0.720366732154551,
    'com'             => 0.720366732154551,
    'Yahoo'           => 0.589390962671906,
    'McKinsey'        => 0.589390962671906,
    'Ru'              => 0.589390962671906,
    'Al'              => 0.523903077930583,
    'Times'           => 0.45841519318926,
    'British'         => 0.45841519318926,
    'Guardian'        => 0.392927308447937,
    'Coldplay'        => 0.392927308447937,
    'Airways'         => 0.392927308447937,
    'BAFTA'           => 0.392927308447937,
    'NASA'            => 0.392927308447937,
  );
  %{$languages{smallwords}{sl}} = (
    'je'      => 3.76829182247936,
    'in'      => 2.31171946659141,
    'na'      => 1.67699146264023,
    'za'      => 1.47830381711705,
    'da'      => 1.46701474634869,
    'se'      => 1.37952444789388,
    'so'      => 1.32251464051365,
    'ki'      => 1.10435334791505,
    'pa'      => 1.09391095745431,
    'tudi'    => 0.791363860862203,
    'bi'      => 0.686939956254851,
    'bo'      => 0.646017074719537,
    'ne'      => 0.556551188880265,
    'po'      => 0.547802159034784,
    'πe'      => 0.542157623650603,
    'art'     => 0.494743526423481,
    'kot'     => 0.439144852889297,
    'o'       => 0.433218090735906,
    'ni'      => 0.426444648274889,
    'æe'      => 0.343752204896634,
  );
  %{$languages{smallwords}{sv}} = (
    'i'       => 2.81366953103766,
    'att'     => 2.63124882393527,
    'och'     => 2.42948838570742,
    'som'     => 1.74893892826528,
    'en'      => 1.50484015973573,
    '‰r'      => 1.4619791339982,
    'fˆr'     => 1.34855422442451,
    'det'     => 1.28530807668987,
    'av'      => 1.21265341111041,
    'till'    => 1.11595475548308,
    'med'     => 1.1075916285099,
    'har'     => 1.08145685671873,
    'inte'    => 0.913671621819398,
    'den'     => 0.774111940454536,
    'de'      => 0.763658031738067,
    'ett'     => 0.717660833385603,
    'om'      => 0.699366493131782,
    'art'     => 0.6173033097075,
    'Det'     => 0.593782015095444,
    'han'     => 0.497083359468105,
  );

  for (keys %{$languages{tags}}) {
    $languages{_smallwords}{$_} = join "|", keys %{$languages{smallwords}{$_}};
  }

  @active_languages = keys %{$languages{tags}};
  $all_languages = join "|", @active_languages;

  for ( Lingua::Identify->subclasses() ) {
    eval "require Lingua::Identify::$_;";
  }

  $charexpr = "[a-zA-Z'Òﬁ˛ﬂÿ¯∆Ê˝≈‚ÍÓÙ˚„ı·ÈÌÛ˙‡ËÏÚ˘‰ÎÔˆ¸Á¬ Œ‘€√’¡…Õ”⁄¿»Ã“ŸƒÀœ÷‹«Â]";
  $noncharexpr = "[\\\t\\\n\\\ \\\*\\\$\\\[\\\]\\\^\\\{\\\}\\\`\\\_\\\.\\\,\\\\\\\-";
  $noncharexpr .= "\\\(\\\)\\\?\\\&\\\;\\\:\\\/\\\´\\\ª\\\!\\\°\\\"\\\%\\\~\\\@\\\#";
  $noncharexpr .= "\\\+\\\=\\\'\\\\\\\|\\\<\\\>0-9]";

}

#for (keys %names) {print}

=head2 EXPORT

=head3 language identification in general

...

=cut

sub langof {
  my $text = join "\n", @_;

  return langof_by_small_word_technique($text);
}

sub filelangof { die "not implemented yet" }

=head3 n-gram based methods

...

=cut

sub langof_by_ngram { die "not implemented yet" }

=head3 prefix and sufix based methods

...

=cut

sub langof_by_prefix { die "not implemented yet" }

sub langof_by_sufix { die "not implemented yet" }

=head3 word based methods

...

=cut

sub langof_by_small_word_technique { # good method for big texts / few languages
  my $text  = shift;
  my %result;
  my $total = 0;

  for my $language (@active_languages) {
    $result{$language} = 0;
    #print "$language -> $languages{_smallwords}{$language}\n";
    while ( $text =~ /(?:$languages{_smallwords}{$language})/g ) {
      #print "mais um em $language ($1 - $languages{smallwords}{$language}{$&})\n";
      $result{$language}++;#$languages{smallwords}{$language}{$1};
      #$result{$language}++;
      #$total++
      $total++;#$languages{smallwords}{$language}{$1};
    }
  }

  my @result = (
    map { ( $_, ($total ? $result{$_} / $total : 0)) }
    #map { ( $_, $result{$_} ) }
      sort { $result{$b} <=> $result{$a} } keys %result
  );

  return wantarray ? @result : $result[0];
}

=head2 ACTIVATING / DEACTIVATING LANGUAGES

...

=cut

sub active_languages {
  return @active_languages;
}

sub set_active_languages {
  @active_languages = grep { /$all_languages/ } @_;
}

sub set_inactive_languages { die "not implemented yet" }

sub activate { die "not implemented yet" }

sub deactivate { die "not implemented yet" }

=head2 LEARNING NEW LANGUAGES

...

=cut

sub learn { die "not implemented yet" }

sub exam_gram_of{ die "not implemented yet" }

#sub in { die "not implemented yet" }
#sub sets { die "not implemented yet" }
#sub uniq { die "not implemented yet" }
#sub set_examine_size { die "not implemented yet" }
#sub set_position { die "not implemented yet" }
#sub newcharacters { die "not implemented yet" }
#sub wordsof {return exam_of("$noncharexpr($charexpr+)$noncharexpr",@_)}
#sub prefsof {return exam_of("(?:^|$noncharexpr)($charexpr\{3})$charexpr",@_)}
#sub sufisof {return exam_of("$charexpr($charexpr\{3})(?:$noncharexpr|\$)",@_)}
#sub exam_of { die "not implemented yet" }
#sub csof {return exam_gram_of(1,@_)}
#sub bisof {return exam_gram_of(2,@_)}
#sub trisof {return exam_gram_of(3,@_)}
#sub quadsof {return exam_gram_of(4,@_)}
#sub quintsof {return exam_gram_of(5,@_)}
#sub sextagsof {return exam_gram_of(6,@_)}
#sub sectagrsof {return exam_gram_of(7,@_)}
#sub octagramsof {return exam_gram_of(8,@_)}
#sub give_tags { die "not implemented yet" }
#sub give_names { die "not implemented yet" }

1;
__END__

=head1 TO DO

Information about languages should be in separate modules.

Those modules should be read by this one automatically.

Language learning on-the-fly (?).

More languages.

More algorithms.

Improve documentation.

File recognition and treatment.

Several other stuff I can't think of at the moment. :-)

=head1 SEE ALSO

A linguistic.

=head1 AUTHOR

Jose Alves de Castro, E<lt>jac@natura.di.uminho.ptE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Jose Alves de Castro

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

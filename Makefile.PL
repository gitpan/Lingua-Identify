use 5.006;
use ExtUtils::MakeMaker;

warn <<"EOD";
 ** WARNING **
----------------------------------------------------------------------------
 Lingua::Identify is now based on UTF-8. Old language modules are no longer
 compatible. Before continuing you should be sure to remove them.

 Basically, remove all two letter packages inside the Lingua/Identify
 folder in your local installation.

 If tests fail, probably that is the reason why.

 Good luck.
----------------------------------------------------------------------------
EOD

sleep 5;

WriteMakefile(
    NAME              => 'Lingua::Identify',
    VERSION_FROM      => 'lib/Lingua/Identify.pm', # finds $VERSION
    PREREQ_PM    => {
        'Class::Factory::Util' => 1.6,
        'Text::Affixes'        => 0.04,
        'Text::Ngram'          => 0.03,
    },
    'EXE_FILES'         => ['langident', 'make-lingua-identify-language'],
);

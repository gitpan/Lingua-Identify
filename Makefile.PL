use 5.006;
use ExtUtils::MakeMaker;

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

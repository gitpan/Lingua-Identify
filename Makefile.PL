use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Lingua::Identify',
    VERSION_FROM      => 'lib/Lingua/Identify.pm', # finds $VERSION
    PREREQ_PM    => {
        'Class::Factory::Util' => 1.6,
        'Text::Affixes'        => 0.04,
        'Text::Ngram'          => 0.03,
	'Text::ExtractWords'   => 0.08,
    },                                           # e.g., Module::Name => 1.1
    'EXE_FILES'         => ['langident', 'make-lingua-identify-language'],
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Lingua/Identify.pm', # retrieve abstract from module
       AUTHOR         => 'Jose Alves de Castro <cog@cpan.org>') : ()),
);

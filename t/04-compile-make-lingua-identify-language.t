# $Id: 04-compile-make-lingua-identify-language.t 1692 2004-12-20 12:18:29Z jac $

use Test::More tests => 1;

my $file = "langident";

print "bail out! Script file is missing!" unless -e $file;

my $output = `perl -c $file 2>&1`;

print "bail out! Script file is missing!" unless
	like( $output, qr/syntax OK$/, 'script compiles' );

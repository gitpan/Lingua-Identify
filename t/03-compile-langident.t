# $Id: 03-compile-langident.t 6657 2008-12-11 19:40:15Z ambs $

use Test::More tests => 1;

my $file = "langident";

print "bail out! Script file is missing!" unless -e $file;

my $output = `$^X -c $file 2>&1`;

print "bail out! Script file is missing!" unless
	like( $output, qr/syntax OK$/, 'script compiles' );

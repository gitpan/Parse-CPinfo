#!/usr/bin/perl -wT

use Test::More tests => 1;
use Parse::CPinfo;

$p2 = Parse::CPinfo->new();
eval {
	$p2->read('t/file-does-not-exist');    # this WILL fail, but that's OK
};
ok($@, 'Try to open a non-existent file and it actually existed.  Weird.');


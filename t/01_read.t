#!/usr/bin/perl -wT

use Test::More tests => 1;
use Parse::CPinfo;

# Test 1
$parser = Parse::CPinfo->new();
$parser->read('t/small.cpinfo');

my @l = @{$parser->{'_cpinfo_data'}};

# must be 1158 lines in the array to pass
ok($#l == 1158, 'FAIL: There are not 1158 lines in the array');


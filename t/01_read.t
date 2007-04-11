#!/usr/bin/perl -wT

use Test::More tests => 4;
use Parse::CPinfo;

# Test 1
$p = Parse::CPinfo->new();
$p->readfile('t/small.cpinfo');
ok(defined($p), 'Parser is defined');

# Test 2
my $ipaddr = $p->getInterfaceInfo('eth0')->{'inetaddr'};
ok($ipaddr eq '192.168.1.10', 'I was expecting 192.168.1.10');

# Test 3
my @list = $p->getInterfaceList();
ok($list[1] eq 'eth0', "I was looking for 'eth0' and got '$list[0]' instead");

# Test 4
$p2 = Parse::CPinfo->new();
eval {
	$p2->readfile('t/file-does-not-exist');    # this WILL fail, but that's OK
};
ok($@, 'Tried to open a non-existent file and it actually existed.  Weird.');


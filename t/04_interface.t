#!/usr/bin/perl -wT
#
use strict;
use Test::More tests => 1;
use Parse::CPinfo;

my $p = Parse::CPinfo->new();
$p->read('t/small.cpinfo');

print "eth0\n";
my $ipaddr = $p->getInterfaceInfo('eth0')->{'inetaddr'};
ok($ipaddr eq '192.168.1.10', 'I was expecting 192.168.1.10');


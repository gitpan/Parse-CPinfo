#!/usr/bin/perl -wT
#
use strict;
use Test::More tests => 1;
use Parse::CPinfo;

my $p = Parse::CPinfo->new();
$p->read('t/small.cpinfo');

my @list = $p->getInterfaceList();
ok($list[1] eq 'eth0' , "I was looking for 'eth0' and got '$list[0]' instead");



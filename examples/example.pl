#!/usr/bin/perl
#
#
#
use strict;
use Data::Dumper;
use Parse::CPinfo;

my $p = Parse::CPinfo->new();
my $fn = $ARGV[0] || '../t/small.cpinfo';

$p->readfile($fn);

print "Here is a list of sections in the cpinfo file:\n";
foreach my $section ($p->getSectionList()) {
	print "$section\n";
}

print "\n\n\n\n";
print "List of interfaces\n";

print "IP Interface Section\n";
print $p->getSection('IP Interfaces');

print "eth0\n";
print Dumper($p->getInterfaceInfo('eth0'));


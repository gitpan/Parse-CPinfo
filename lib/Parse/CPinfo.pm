package Parse::CPinfo;

use 5.006_001;
use strict;
no warnings;
use base qw/Exporter/;
use Carp;
use IO::File;
use Net::CIDR;
use Net::IPv4Addr qw( :all );
use Regexp::Common;

require Exporter;

our $VERSION = '0.881';

sub new {
	my $class = shift;
	my $self  = {};
	bless $self, $class;
	return $self;
}

sub readfile {
	my $self     = shift;
	my $filename = shift;

	# keep copy of filename in object
	$self->{'_filename'} = $filename;
	my $fh = new IO::File($filename, 'r');
	if (!defined $fh) {
		croak "Unable to open $filename for reading";
	}

	# ensure we are in binary mode as some system (win32 for example)
	# will assume we are handling text otherwise.
	binmode $fh, ':raw';

	my @lines = <$fh>;
	chomp @lines;
	my $linenumber = 0;
	while ($linenumber < $#lines) {
		$linenumber++;
		if ($lines[$linenumber] =~ m/^\={46}$/o) {
			$linenumber++;
			my $section = $lines[$linenumber];
			$linenumber++;

			foreach (0 .. $linenumber) {
				$linenumber++;
				if ($lines[$linenumber] !~ m/^\={46}$/o) {
					$self->{'config'}->{$section} = $self->{'config'}->{$section} . "$lines[$linenumber]\n";
				}
				else {
					$linenumber--;
					last;
				}
			}
		}
	}
	$self->_parseinterfacelist();
	return 1;
}

sub _parseinterfacelist {
	my $self         = shift;
	my $ifconfigtext = $self->{'config'}->{'IP Interfaces'};
	if (!$ifconfigtext) {
		return;
	}
	my @s = split /\n/, $ifconfigtext;
	my ($int);
	foreach my $line (@s) {
		chomp $line;
		if ($line =~ m/^(\w+)\s+/o) {
			my $match = $1;
			if ($match !~ m/ifconfig/o) {
				$int = $1;
				$self->{'interface'}->{$int}->{'name'} = $int;
			}
		}
		if ($line =~ m/Link encap:(\w+)\s+/io) {
			$self->{'interface'}->{$int}->{'encap'} = $1;
		}
		if ($line =~ m/HWaddr ($RE{net}{MAC})/io) {
			$self->{'interface'}->{$int}->{'hwaddr'} = $1;
		}
		if ($line =~ m/inet addr:($RE{net}{IPv4})/io) {
			$self->{'interface'}->{$int}->{'inetaddr'} = $1;
		}
		if ($line =~ m/bcast:($RE{net}{IPv4})/io) {
			$self->{'interface'}->{$int}->{'broadcast'} = $1;
		}
		if ($line =~ m/mask:($RE{net}{IPv4})/io) {
			$self->{'interface'}->{$int}->{'mask'}       = $1;
			$self->{'interface'}->{$int}->{'masklength'} = ipv4_msk2cidr($self->{'interface'}->{$int}->{'mask'});
		}
		if ($line =~ m/MTU:(\d+)/io) {
			$self->{'interface'}->{$int}->{'mtu'} = $1;
		}
	}
	return 1;
}

sub getInterfaceList {
	my $self = shift;
	return keys %{$self->{'interface'}};
}

sub getInterfaceInfo {
	my $self      = shift;
	my $interface = shift;
	return $self->{'interface'}{$interface};
}

sub getSectionList {
	my $self = shift;
	my @r;
	foreach my $section (sort keys %{$self->{config}}) {
		push @r, $section;
	}
	return @r;
}

sub getSection {
	my $self    = shift;
	my $section = shift;
	return $self->{'config'}->{$section};
}

1;
__END__

=head1 NAME

Parse::CPinfo - Perl extension to parse output from cpinfo 

=head1 SYNOPSIS

  use Parse::CPinfo;
  my $p = Parse::CPinfo->new();
  $p->readfile('cpinfofile');

  # print the section containing the fwm version string 
  print $p->getSection('FireWall-1 Management (fwm) Version Information');

  # Get a list of interfaces
  my @l = $p->getInterfaceList();

  foreach my $int(@l) {
      print "Interface $int\n";
	  print "IP Address: " . $int->{'inetaddr'} . "\n";
  }


=head1 DESCRIPTION

This module parses the output from B<cpinfo>.  B<cpinfo> is a utility provided
by Check Point Software, used for diagnostic purposes.


=head1 SUBROUTINES/METHODS

The following are the object methods:

=head2 new

Create a new parser object like this:
my $p = Parse::CPinfo->new();

=head2 readfile

After creating the parser object, ask it to read the B<cpinfo> file
for you:
$parser->readfile('/full/path/to/cpinfofile');

=head2 getSectionList

Use this method to get a list of valid sections.  Returns an array.

=head2 getSection

Use this method to get a section of the cpinfo file.  Returns a scalar.

=head2 getInterfaceList

Use this method to get a list of the active interfaces.  Returns an array.

=head2 getInterfaceInfo

Use this method to get information about a specific interface.  Takes a
scalar (interface name) and returns a hash.

=head1 SEE ALSO

Check Point Software Technologies, Ltd., at
http://www.checkpoint.com/

=head1 AUTHOR

Matthew M. Lange, E<lt>mmlange@cpan.orgE<gt>

=head1 BUGS AND LIMITATIONS

This library hasn't been extensively tested.  I'm sure there are bugs in the code.
Please file a bug report at http://rt.cpan.org/ if you find a bug.

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2007 by Matthew M. Lange

This library is released under the GNU Public License.

=cut


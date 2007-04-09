package Parse::CPinfo;

use 5.008008;
use strict;
no warnings;
use Carp;
use IO::File;
use Net::CIDR;
use Net::IPv4Addr qw( :all );
use Regexp::Common;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Parse::CPinfo ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (
	'all' => [
		qw(

		  )
	]
);

our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});

our @EXPORT = qw(

);

our $VERSION = '0.88';

sub new {
	my $class = shift;
	my $self  = {};
	bless $self, $class;
	return $self;
}

sub read {
	my $self     = shift;
	my $filename = shift;

	# keep copy of filename in object
	$self->{'_filename'} = $filename;
	my $fh = new IO::File($filename, 'r');
	croak "Unable to open $filename for reading" unless (defined($fh));

	# ensure we are in binary mode as some system (win32 for example)
	# will assume we are handling text otherwise.
	binmode $fh, ':raw';
	if (defined($fh)) {
		@{$self->{'_cpinfo_data'}} = <$fh>;
	}
	undef $fh;
	$self->_parse();
}

sub _parse {
	my $self  = shift;
	my @lines = @{$self->{'_cpinfo_data'}};
	chomp @lines;
	my $linenumber = 0;
	while ($linenumber < $#lines) {
		$linenumber++;
		if ($lines[$linenumber] =~ m/^\={46}$/) {
			$linenumber++;
			my $section = $lines[$linenumber];
			$linenumber++;

			foreach (0 .. $linenumber) {
				$linenumber++;
				if ($lines[$linenumber] !~ m/^\={46}$/) {

					#print "L($linenumber): $lines[$linenumber]\n";
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
}

sub _parseinterfacelist {
	my $self         = shift;
	my $ifconfigtext = $self->{'config'}->{'IP Interfaces'};
	if (!$ifconfigtext) {
		return;
	}
	my @s = split(/\n/, $ifconfigtext);
	my ($int);
	foreach my $line (@s) {
		chomp $line;
		if ($line =~ m/^(\w+)\s+/) {
			my $match = $1;
			if ($match !~ m/ifconfig/) {
				$int = $1;
				$self->{'interface'}->{$int}->{'name'} = $int;
			}
		}
		if ($line =~ m/Link encap:(\w+)\s+/i) {
			$self->{'interface'}->{$int}->{'encap'} = $1;
		}
		if ($line =~ m/HWaddr ($RE{net}{MAC})/i) {
			$self->{'interface'}->{$int}->{'hwaddr'} = $1;
		}
		if ($line =~ m/inet addr:($RE{net}{IPv4})/i) {
			$self->{'interface'}->{$int}->{'inetaddr'} = $1;
		}
		if ($line =~ m/bcast:($RE{net}{IPv4})/i) {
			$self->{'interface'}->{$int}->{'broadcast'} = $1;
		}
		if ($line =~ m/mask:($RE{net}{IPv4})/i) {
			$self->{'interface'}->{$int}->{'mask'}       = $1;
			$self->{'interface'}->{$int}->{'masklength'} = ipv4_msk2cidr($self->{'interface'}->{$int}->{'mask'});
		}
		if ($line =~ m/MTU:(\d+)/i) {
			$self->{'interface'}->{$int}->{'mtu'} = $1;
		}
	}
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
	foreach my $section (sort keys(%{$self->{config}})) {
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

Parse::CPinfo - Perl extension to parse cpinfo files

=head1 SYNOPSIS

  use Parse::CPinfo;
  my $parser = Parse::CPinfo->new();
  $parser->read('cpinfofile');

  # print the fwm version string that was parsed
  print $p->{config}{'FireWall-1 Management (fwm) Version Information'};


=head1 DESCRIPTION

This module parses a B<cpinfo> file created by Check Point
Software.

The following are the object methods:

=head2 new

Create a new parser object like this:
my $parser = Parse::CPinfo->new();

=head2 read

After creating the parser object, ask it to read the B<cpinfo> file
for you:
$parser->read('/full/path/to/cpinfofile');

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Matthew M. Lange

This library is released under the GNU Public License.

=cut


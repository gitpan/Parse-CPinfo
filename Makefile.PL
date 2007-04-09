use 5.008008;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME         => 'Parse::CPinfo',
	VERSION_FROM => 'lib/Parse/CPinfo.pm',    # finds $VERSION
	LICENSE      => 'GPL',
	PREREQ_PM    => {
		'Carp'           => 0,
		'IO::File'       => 0,
		'Net::CIDR'      => 0,
		'Net::IPv4Addr'  => 0,
		'Regexp::Common' => 0,
	},
	(
		$] >= 5.005
		?    ## Add these new keywords supported since 5.005
		  (
			ABSTRACT_FROM =>
			  'lib/Parse/CPinfo.pm',    # retrieve abstract from module
			AUTHOR => 'Matthew M. Lange <mmlange@cpan.org>'
		  )
		: ()
	),

);

#! /usr/bin/env perl

=head1 NAME

=head1 SYNOPSIS

  perl make_tool_desc_for_multiqc.pl [-l tool1,tool2,tool3,...] [-c conf file] [-h help]

=head1 DESCRIPTION

  This script gives you the version of the used tools and their reference. 
  The command line for getting the version and the reference information are stored in a separate 
  configuration file in a form of tab sep file:
  tool_id	command line	reference paper	

Typical usage is as follows:

  % perl make_tool_desc_for_multiqc.pl -l bowtie,bwa 

=head2 Options

The following options are accepted:

 --l=<list of tools> 		Specify a listlist of tools

 --c=<conf file> 			Specify the configuration file

 --help                   	This documentation.


=head1 AUTHOR

Luca Cozzuto <luca.cozzuto@crg.es> 

=cut
use warnings;
use strict;
use Data::Dumper;
use File::Basename;
use Pod::Usage;
use Getopt::Long;

my $USAGE = "perl make_tool_desc_for_multiqc.pl [-l tool,tool] [-c conf.txt] [-h help]";

my ($list,$conf, $show_help);

&GetOptions(    	
			'list|f=s'		=> \$list,
			'help|h'        	=> \$show_help,
			'conf|c=s'        	=> \$conf
			)
  or pod2usage(-verbose=>2);
pod2usage(-verbose=>2) if $show_help;


my %cmdLines;
my %papers;

if (!$conf) {
	$conf = "conf_tools.txt";
}

# Read configuration file and fill two hashes
open(my $handle, '<', $conf) 
    or die "Unable to open file, $!";

while( my $line = <$handle> ) { 
	chomp($line);
	if ($line ne "") {
		my @vals = split ("\t", $line);
		$cmdLines{$vals[0]} = $vals[1];
		$papers{$vals[0]} = $vals[2];
	}
}

close($handle);

# Write to stdout the description for multiQC 
my @tools = split(",",$list);
print "# id: 'tools-html'
# section_name: 'Tool description'
# description: 'This section describes the tools used during the analysis and their reference'\n";
print "# plot_type: 'html'\n";
print "<dl class=dl-horizontal>\n";
print "<dt>"."Tool version</dt><dd><strong>Reference</strong></dd>\n";
foreach my $tool (@tools) {
	print "<dt>".getVersion($tool, \%cmdLines)."</dt> <dd>".getReferencePaper($tool, \%papers)."</dd>\n";
}
print "</dl>\n";


# Function for getting version using the command line stored within the conf file
sub getVersion {
	my($tool, $infos) = @_;
	my $res = "";
	my %info = %{$infos};

	if ($info{$tool}) {
		$res = `$info{$tool}`;
		$res =~ s/^\s+|\s+$//g
	}
	else {
		$res = "*** Tool $tool not recognized";
	}
	return $res;

}

# Function for getting the reference paper stored in the conf file
sub getReferencePaper {
	my($tool, $infos) = @_;
	my $res = "";
	my %info = %{$infos};

	if ($info{$tool}) {
		$res = $info{$tool};
		$res =~ s/^\s+|\s+$//g
	}
	else {
		$res = "*** Tool $tool not recognized";
	}
	return $res;

}


#!/usr/bin/perl
use strict;
use Fcntl ':flock';
use Cwd;
use warnings;
use File::Find::Rule;
use File::Copy;
use File::Copy::Recursive qw(fcopy rcopy dircopy);
use File::Path;
open ("SCRIPT", "$0");
flock("SCRIPT",2|4) || die "another instance of the script is running";


rmtree ("/var/lib/apt/newpackages/pool");
chdir '/var/lib/apt';

my @files = File::Find::Rule->file()
        ->name( "*.deb" )      
        ->in( '.');
#print "@files\n";
my $flag;
my $result;

my $indexfile = "/var/lib/apt/dists/squeeze/binary-amd64/Packages";
my @newpkgs;
{
	open("FH", $indexfile) or die ;
	local $/ = '';

	my @linearray = <FH>;
	close ("FH");

	open (NFH, '>', "/var/lib/apt/dists/squeeze/binary-amd64/Packages.temp") or die "cannot create";
	foreach my $pattern (@files)
	{
		if (my @matches = grep /$pattern/, @linearray) {
			print NFH "@matches";
		} else {
			push @newpkgs,$pattern;
		}
	}
	close (NFH);
}
move ("/var/lib/apt/dists/squeeze/binary-amd64/Packages.temp", "/var/lib/apt/dists/squeeze/binary-amd64/Packages");


mkpath "/var/lib/apt/newpackages/pool" or die "cannot create directory $!";
#my $pwd = cwd();
#print $pwd;
foreach my $newfiles (@newpkgs){
	fcopy ("$newfiles", "/var/lib/apt/newpackages/$newfiles") or die "Cannot copy file $!";
}

close (SCRIPT);

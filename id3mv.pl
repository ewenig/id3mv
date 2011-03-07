#!/usr/bin/perl -w
#
# id3mv.pl - organize your entire music library!
#
# Copyright (C) 2010 by Eli Wenig
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself, either Perl version 5.10.1 or,
# at your option, any later version of Perl 5 you may have available.

use strict;
use File::Find;
use File::Copy;
use MP3::Tag;

our $DIR = "/path/to/music/library/"; #Don't forget the trailing slash
find (\&handle_file,$DIR);
print "Done!";

sub handle_file {
	unless ($_ =~ m/\.mp3$/) {
		return 0;
	}

	my $mp3 = MP3::Tag->new($File::Find::name);
	my @mp3data;
	if (defined($mp3)) {
		@mp3data = $mp3->autoinfo();
	} else {
		return 0; #fail quietly because there's nothing worse than having your perl
	}             #script die on you after sorting through 2000 or so files

	my $sindex = rindex($mp3data[1],"/");
	if ($sindex != -1) {
		$mp3data[1] = substr($mp3data[1],0,$sindex);
	}

	my $artistdir = $DIR . sanitize_ntfs($mp3data[2]) . "/";
	my $albumdir = $artistdir . sanitize_ntfs($mp3data[3]) . "/";
	my $file = $albumdir . $mp3data[1] . " " . sanitize_ntfs($mp3data[0]) . ".mp3";
	unless (-d $artistdir) {
		mkdir($artistdir);
	}
	unless (-d $albumdir) {
		mkdir($albumdir);
	}
	if (-e $file) {
		return 0;
	}

	print "Renaming $File::Find::name to $file" . "\n";
	move ($File::Find::name,$file) or die "Move failed: $!";
}

sub sanitize_ntfs {
	#make sure the file name won't break anything
	unless (defined($_[0])) {
		return "";
	}

	my $file = $_[0];
	$file =~ tr{?"\/<>|:*}{_};

	return $file;
}

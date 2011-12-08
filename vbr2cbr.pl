#!/usr/bin/perl
######################################################
#	This script converts VBR MP3's to CBR MP3's. The conversion process detects the VBR_AVERAGE and selects the CBR rate just below it. 
#	The process also uses LAME's options to provide the highest compatibility and quality. The standard MP3 tags are aggregated, stored, and used in the resulting MP3.
#	It was originally designed to convert MP3 for DJ's. Some CDJ's (Pioneer CDJ-200) do not work well with VBR files. This only does files one at a time.
#	I'm working on trying to make the lame processes be parallel.
#
#	BE SURE TO CHECK THE $VBR_ARCHIVE VARIABLE!!!!
#
#	Standard usage on Linux computers:
#	$ find ~/mp3_library -type f -iname "*.mp3" -exec vbr.pl {} \;
#	
#	Original script Author:	void(at)member.fsf.org
#	Script version:		0.1
#	Last Update:		02DEC10
######################################################
use strict; use warnings;
use MP3::Info;

#	Declare Variables! Not War!
my $file = $ARGV[0];
my $tag = get_mp3tag($file);
my $artist = "$tag->{ARTIST}";
my $album = "$tag->{ALBUM}";
my $title = "$tag->{TITLE}";
my $tracknum = "$tag->{TRACKNUM}";
my $genre = "$tag->{GENRE}";
my $vbr = `mp3_check -v "$file" | grep "VBR_AVERAGE" | awk '{ print \$2 }'`;
my $cbr = "";
my $comm = "$tag->{COMMENT}";
my $vbr_archive="/home/psyber/vbr_archive";

#	Let's get started...
printf "File: $file";

#	Determine if file is CBR or VBR
if ( $vbr eq '') {
	printf "\n";
#	printf "File is CBR.\n";
}else{
#	For VBR detected files, select the appropriate CBR.
	if ( $vbr lt "320" ) {
		if ( $vbr lt "256" ) {
			if ( $vbr lt "224" ) {
				if ( $vbr lt "192" ) {
					if ( $vbr lt "160" ) {
						if ( $vbr lt "128" ) {
							if ( $vbr lt "112" ) {
								if ( $vbr lt "96" ) {
									if ( $vbr lt "80" ) {
										if ( $vbr lt "64" ) {
											if ( $vbr lt "56" ) {
												if ( $vbr lt "48" ) {
													if ( $vbr lt "40" ) {
														$cbr="32";
													}else{
														$cbr="40";
													}
												}else{
													$cbr="48";
												}
											}else{
												$cbr="56";
											}
										}else{
											$cbr="64";
										}
									}else{
										$cbr="80";
									}
								}else{
									$cbr="96";
								}
							}else{
								$cbr="112";
							}
						}else{
							$cbr="128";
						}
					}else{
						$cbr="160";
					}
				}else{
					$cbr="192";
				}
			}else{
				$cbr="224";
			}
		}else{
			$cbr="256";
		}
	} else {
		$cbr="320";
	}
#	Add a conversion information in the MP3 comments tag.
	$comm = "$comm Converted to $cbr CBR from $vbr VBR on `date`";
	$vbr = chomp($vbr);
#	Show me the tag and conversion information... So, I know you're not being lazy.
	printf "\n=============================================================================\n";
	printf "File:\t\t$file\n";
	printf "Title:\t\t$title\n";
	printf "Artist:\t\t$artist\n";
	printf "Album:\t\t$album\n";
	printf "Track #:\t$tracknum\n";
	printf "Genre:\t\t$genre\n";
	printf "CBR:\t\t$cbr\n";
	printf "VBR:\t\t$vbr\n";
	printf "Comment:\t$comm\n";
	printf "+--------------------------------------------------------------+\n";
	printf "Start Transcoding:\t";
	printf `date`;
	printf "\nCommand:\tlame --mp3input -o --add-id3v2 --cbr -q 0 -b \"$cbr\" --tt \"$title\" --ta \"$artist\" --tl \"$album\" --tn \"$tracknum\" --tg \"$genre\" --tc \"$comm\" \"$file\" \"$file\_CBR.mp3\"\n\n";

#       The actual transcoding from VBR to CBR
	`lame --mp3input -o --add-id3v2 --cbr -q 0 -b \"$cbr\" --tt \"$title\" --ta \"$artist\" --tl \"$album\" --tn \"$tracknum\" --tg \"$genre\" --tc \"$comm\" \"$file\" \"$file\_CBR.mp3\"`;
	printf "End Transcoding:\t";
	printf `date`;
	printf "+--------------------------------------------------------------+\n";


#	Make folders to move VBR files to and move the files. Folder structure is $VBR_ARCHIVE/$ARTIST/$ALBUM
	if ( -d "$vbr_archive") {
		printf "Archive folder found:\t$vbr_archive.\n";
		if ( -d "$vbr_archive/$artist"){
			printf "Archive artist sub-folder found:\t$vbr_archive/$artist.\n";
			if ( -d "$vbr_archive/$artist/$album" ) {
				printf "Archive album sub-folder found:\t$vbr_archive/$artist/$album.\n";
				printf "Moving $file to $vbr_archive/$artist/$album.\n";
				`mv \"$file\" \"$vbr_archive/$artist/$album\"`;
			} else {
				printf "Archive Album sub-folder not found. Making directory $vbr_archive/$artist/$album and moving $file to it.\n";
				mkdir("$vbr_archive/$artist/$album", 0777);
				`mv \"$file\" \"$vbr_archive/$artist/$album\"`;
			}
		} else {
			printf "Archive artist sub-folder not found. Making directory $vbr_archive/$artist/$album and moving $file to it.\n";
			mkdir("$vbr_archive/$artist", 0777);
			mkdir("$vbr_archive/$artist/$album", 0777);
			`mv \"$file\" \"$vbr_archive/$artist/$album\"`;
		}
	} else {
		printf "No archive folder found. Making $vbr_archive/$artist/$album and moving $file to it.\n";
		mkdir("$vbr_archive", 0777);
		mkdir("$vbr_archive/$artist", 0777);
		mkdir("$vbr_archive/$artist/$album", 0777);
		`mv \"$file\" \"$vbr_archive/$artist/$album\"`;
	}

#	Next it archives the file... Don't do that. Script will take WAY too long
#	`7z a VBR_files.7z \"$file\"`;

}


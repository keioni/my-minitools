#!/usr/bin/perl

# sort by extension
# input: file list
# output: stdout

use strict;
use warnings;

my $in_file = $ARGV[0] or die "Usage: $0 <file list>";

my @ext_reverse_files = ();
open(FIN, "<", $in_file) or die "Could not open file '$in_file'";
while ( <FIN> ) {
    chomp;
    if ( /([^\.]+)$/ ) {
        push( @ext_reverse_files, "$1::$_" );
    }
}
close(FIN);

foreach my $file ( sort @ext_reverse_files ) {
    my @file_info = split(/::/, $file);
    print "$file_info[1]\n";
}

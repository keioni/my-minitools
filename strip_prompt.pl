#!/usr/bin/perl

$add_enter = 1 if ( $0 =~ /strprompti/ );

while ( <> ) {
    s/^.* ❯ (.*)  +\S.*$/\$ $1/;
    print "\n" if $add_enter;
    print;
}

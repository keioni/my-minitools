#!/usr/bin/perl

while ( <> ) {
    s/^.* ❯ (.*)  +\S.*$/\$ $1/;
    print;
}

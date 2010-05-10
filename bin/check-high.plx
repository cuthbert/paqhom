#!/usr/bin/perl -w
#
# [2002­01­25]
# Output all lines on standard in that contains characters above
# 127 (upper part of latin­1). Don't count occurances of `\×'.
#
# Useful for checking if everything is LaTeX:ed correctly.
#
while (<>) {
    $high=0;
    s/\\×//g;
    while (/(.)/g) {
        $high=1 if ord($1) > 127;
    }
    print if $high;
}

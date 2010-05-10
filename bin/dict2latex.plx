#!/usr/bin/perl -w
#
# [2002-01-21, 17.58-21.12]
# [2002­01­22, 07.29-14.37]
# [2002­01­25,~19.00-19.44]
#   Now ZDb is specified on command line, instead of hardcoded.
#   Also LaTeXifies the $extra field (previously the hyphen did not
#   get translated into a correct LaTeX hyphen (i.e. minus) which resulted
#   in an ugly black square instead. (This occured once in the dictionary.)
#

($Direction, $Dict_File) = @ARGV;
if ( $#ARGV < 1 ) {
    print "usage: dict2latex.plx <DIR> <DICTFILE>\n";
    print "Where <DIR> is \`ek' (English­Klingon) or \`ke' (Klingon­English).\n";
    print "Output is sent to standard out.\n";
    exit;
}
if ( $Direction !~ /^(ke|ek)$/i ) {
    print "First argument must specify `ke' (Klingon­English) or `ek' (English­Klingon).\n";
    exit;
}
if ( ! -r $Dict_File ) {
    print "Second argument must be the name of a ZDb Klingon­English dictionary.\n";
    exit;
}

# define alphabet
# string = regex that matches klingon letter
# array  = sort order
# hash   = letter to sort­letter
$alpha = "(tlh|ch|gh|ng|[abDeHIjlmnopqQrStuvwy' ])";
@alpha = (" ");                                # <space>
push @alpha, qw( a b ch D e gh H I j l m n ng o p q Q r S t tlh u v w y );
push @alpha, "'"; my $i;                       # add glottal stop
foreach (@alpha) { $alpha{$_} = chr 96+$i++ }  # produce sort order hash

$Fields = '^(klin|eng|def):\s*';               # fields we need
$En_POS = '\((v|n|name|pro|adv|num|excl|ques|conj)\)';
#$Sv_POS = '\((v|s|namn|pro|adv|räkn|interj|fråg|konj)\)';

$az  = 'A-ZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ';
$az .= lower($az) . "ßÿ";


@file   = ();

if ($Direction =~ /^ke$/i) {
    print "% Klingon-English dictionary.\n";
    print "% LaTeX conversion started: ",`date +"%Y-%m-%d, %H.%m.%S"`;
} else {
    print "% English-Klingon dictionary.\n";
    print "% LaTeX conversion started: ",`date +"%Y-%m-%d, %H.%m.%S"`;
}



# open file and skip header
open DICT, "$Dict_File";                       # open file
while(<DICT>) {                                # skip past data file header
    last if /^=== start­of­word­list ===$/;    #
}                                              #

# read from the dictionary
@buf = ();                                     #
while(<DICT>) { chomp;                         # remove eol
    last if /^=== end­of­word­list ===$/;      # done at end­of­dict

    # beginning of a new post
    if (s/^(:|\s*$)//) {                       # beginning of new post?
        push @file, &buffer_to_LaTeX(@buf);    #   output processed buffer
	@buf = ();                             #   clear buffer
        next if /^$/;                          #   skip to next line in file
    }                                          #   if this one is empty now

    # add read line to buffer
    $buf[$#buf] .= $_, next if s/^\s+/ /;      # inital space: add to last line
    push @buf, $_;                             #   add a new line to buffer
}
close DICT;

print "% There are ", $#file+1, " words in this file.\n\n";

# output main body of file
$oldfirst = "";
foreach (sort @file) {
    ($first) = /^(.)/;                         # get sortstring's 1st letter
    print "\\newletter%\n"                     # new letter in alphabet
        if $first ne $oldfirst;                #
    s/[^ ]* //;                                # remove sortstring
    print "  $_";                              # output
} continue { $oldfirst = $first }              # remember 1st letter

print "% LaTeX conversion ended: ",`date +"%Y-%m-%d, %H.%m.%S"`;
print "% [eof]";


sub buffer_to_LaTeX {
    my (@buf) = @_;                            # get buffer
    return unless @buf;                        # don't process empty buffers
    my (@return) = ();                         # reset returnbuffer

    # get fields
    my %field = ();                            # clear %field hash
    foreach ( grep /$Fields/o, @buf ) {        #
       s/$Fields//o;                           #   remove `xxx:\t'
       $field{$1} = $_;                        #   assign to %field
    }                                          #

    # process `klin:'­field
    $klin =  $field{klin};                     #
    $klin =~ s/^{(.*)}.*/$1/;                  # remove all outside {...}
    $klin =  &LaTeX($klin);                    # LaTeXify

    # split `eng:'­field into:
    #   `English', `part­of­speech' and `slang/regional'
    $eng =  $field{eng};                       #
    $eng =~ /(.*)$En_POS(.*)/;                 # fetch transl., pos & category
    ($eng, $pos, $extra) = ($1, $2, $3);       #
    $eng =~ s/ *$//;                           # remove trailing space
    $extra =~ s/^\s*\((.*)\)\s*/$1/;           # remove surrounding parentheses
    $extra =  &LaTeX($extra);                  # LaTeXify


    # Klingon-English direction   
    if ($Direction =~ /^ke/i) {
        #  #1 = Klingon (lookup) word
        #  #2 = part­of­speech
        #  #3 = 'slang' or 'regional' etc.
        #  #4 = English explanation of the word
        #  #5 = source
        #       (if Ø then source=TKD)
	
        # process `def:'­field
        $ref =  $field{def};                   #
        $ref =~ s/\[(.*)\]/$1/;                # remove brackets
	$ref =~ s/\s*\(.*\)//g;                # remove parentesis & contents
        $ref =  "" if $ref eq "TKD";           # clear if "TKD"
	$ref =  &LaTeX($ref);                  # LaTeXify
        substr($ref, -6, 6) =~ s/ /~/g;        # no line break in end

        # process `eng:'­field
        $eng =~ s/[<>«»]//g;                   # remove «»<> from english
        {                                      #
	    # if all english definitions begin with the word 'be'
	    # and remove `be' in all but the first one if so
	    ($tmp  = $eng) =~ s/\(.*\)//g;     # disregard parenthesis cont
	    $tmp = grep !/^be /,split(', ',$tmp);# num of defs NOT beg with "be"
	    if ($tmp == 0) {                   # all fields began with 'be'
                $eng =~ s/, be /, /g;          # replace `, be ' with `, '
            }                                  #
	}                                      #
        $eng =  &LaTeX($eng);                  # LaTeXify
	$off    =  -6 + length($ref);          # use non­breaking spaces 
	substr($eng, $off, 6) =~ s/ /~/g       #   at the end of english
	    unless $off >= 0;                  #   definition
	    

        # make sortkey
        $sort  =  $field{klin};                    #
	$sort  =~ s/[{}() ]//g;                    # remove <space> {} and ()
        $sort  =~ s/($alpha)/$alpha{$1}/g;         # translate
        $sort .=  "_$pos";                         # attach part­of­speech
        $sort  =~ s/([0-9])_(.*)/_$2_$1/;          # swap pos and lemma number

        push @return, "$sort \\lukli" .            # return value
	    "{$klin}{$pos}{$extra}{$eng}{$ref}%\n";#
    } else {
        # English-Klingon Direction
        #   #1 = English lookup word                (done)
        #   #2 = Klingon word                       (done)
        #   #3 = Part­of­speech                     (done)
        #   #4 = 'slang' or 'regional' etc.         (done)
        #   #5 = English explanation of the word
        #        (if Ø then the explanation equals the lookup word)
        #        (the lookup word is replaced by \×, which generates a tilde)

        # extract all lookup words
        $eng =~ tr/<>/«»/;                     # make <> into «»
	pos($eng) = 0;                         #
	@stack    = ();                        # init stack
        while ( $eng =~ /«/g ) {               # find first `«'
	   $beg = pos($eng);                   # beg of this definiton
	   push @stack, "»";                   # stack it
	   do {                                # until stack is empty
	       $eng =~ /([«»])/g;              #   find next `«' or `»'
	       if ($1 eq $stack[$#stack] ) {   #   if equal to on stack
	           pop @stack;                 #     pop it
	       } else {                        #   otherwise
	           push @stack, "»";           #     push `»'
	       }                               #
	       $len = pos($eng)-$beg-1;        #   length of lookup word
	   } while @stack;                     # 
	   $lookup = substr($eng, $beg, $len); # lookup word
	   $lookup =~ s/\s*\(.*\)//g;          # remove parentesis & contents

           # create sort string
           $sort  =  $lookup;                  # sort based on lookup word
           $sort  =~ tr/«»<>{}~\' ­//d;        # remove interpunct
           $sort  = &lower($sort);             # make lowercase
	   $sort  =~ tr/àáâãäèéêëìíîïòóôõöùúûüýÿ/aaaaaeeeeiiiiooooouuuuyy/;
           $sort .=  "_$pos";                  # attach part­of­speech
	   ($tmp  = $klin) =~ s/($alpha)/$alpha{$1}/g;
           $sort  .= "_$tmp";                  # klingon sort word (useful for
	                                       # many similar words, e.g. bird)
           # lookup word
           $lookup =~ s/[<>«»]//g;             # remove «»<> from english
           $lookup =  &LaTeX($lookup);         # LaTeXify
	   
	   # English definition
	   # ($xng temp for this loop, $eng must be perserved)
	   $xng =  $eng;
           $xng =~ s/[<>«»]//g;                # remove «»<> from english
           $xng =  &LaTeX($xng);               # LaTeXify
	   $xng =  "" if ( $xng eq $lookup );  # no def. if same as lookup

           # tilde implosion
           $xng =~ s{                          #
	     ( ^ | [ ] )                       # space or beg­of­string
	     \Q$lookup\E                       # lookup word
	     ( $ | [, ])                       # end­of­string or 
	   }{$1\\×$2}gx;                       # tilde replacement
	   
	   # tilde removal (of parts w/ only tilde as transl.)
           $xng = join ', ', grep { ! /^\\×$/ }# remove all part­definitions
	       split(', ', $xng);              #   containing only \×

           # multiple `be' removal
           {                                   #
	       # if all english definitions begin with the word 'be'
	       # and remove `be' in all but the first one if so
	       ($tmp  = $xng) =~ s/\(.*\)//g;  # disregard parenthesis cont
	       $tmp = grep !/^be /,split(', ',$tmp);# num of defs NOT beg with "be"
	       if ($tmp == 0) {                # all fields began with 'be'
                   $xng =~ s/, be /, /g;       # replace `, be ' with `, '
               }                               #
	   }                                   #
	   
           substr($xng, -6, 6) =~ s/ /~/g;     # nbsp at end of english

           push @return, "$sort \\lueng".      # return value
	       "{$lookup}{$klin}{$pos}{$extra}{$xng}%\n";
           
	} continue { pos($eng) = $beg }
    }
    return @return;
}
    

sub LaTeX {
    my ($x) = @_;
    foreach ($x) {
        s/{/\\B{/g;                            # bold    {...} => \B{...}
#	$tildes = s/~/~/g;
#	print "italics marker '~' not terminated before line' num\n"
#            if $tildes%2 == 1;
        s/~([^~]*)~/\\I{$1}/g;                 # italics ~...~ => \I{...}
        s/''/'{}'/g;                           # double aphostrophe
        s/(^| )\"/$1``/g;                      # initial quote
        s/\"/''/g;                             # ending quote
        s/-/--/g;                              # minus
        s/­/-/g;                               # hyphen
        s/\.\.\. /\ldots\ /g;                  # ... + <space>
        s/\.\.\./\ldots/g;                     # ...
        s/ /~/g;                               # non­breaking space
        s/×/\\×/g;                             # special ~ comand
        s/¿?//g;                               # remove ¿?
        s/([%#\$])/\\$1/g;                      # escape %, #, $
    }
    return $x;
}


# make string into lowercase
sub lower {
    my ($str) = @_;                            # get args
    $str =~ s{                                 #
      ([A-ZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ])    #
    }{chr(ord $1 | 0x20)}gexo;                 # or %0010 0000 to all chars
    return $str;                               #   in alphabet
}


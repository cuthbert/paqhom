#!/bin/bash

if [[ "$1" == "" ]]; then
    echo "Please provide a language [english, swedish, german, all]."
    exit
fi

zdb_location="/home/rhartung/cuthbert/klingon-data/data/dict-gen.zdb"

make distclean
make clean

lang_code="";
if [[ "$1" == "english" || "$1" == "all" ]]; then
    ./bin/zdb2tex run tlh en $zdb_location > tex/en/include/tlh-en.tex
    ./bin/zdb2tex run en tlh $zdb_location > tex/en/include/en-tlh.tex
    make english
fi

if [[ "$1" == "german" || "$1" == "all" ]]; then
    ./bin/zdb2tex run tlh de $zdb_location > tex/de/include/tlh-de.tex
    ./bin/zdb2tex run de tlh $zdb_location > tex/de/include/de-tlh.tex
    make german
fi

if [[ "$1" == "swedish" || "$1" == "all" ]]; then
    ./bin/zdb2tex run tlh sv $zdb_location > tex/sv/include/tlh-sv.tex
    ./bin/zdb2tex run sv tlh $zdb_location > tex/sv/include/sv-tlh.tex
    make swedish
fi

make clean
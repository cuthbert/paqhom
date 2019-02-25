#!/bin/bash

if [[ "$1" == "" ]]; then
    echo "Please provide a language [english, swedish, german, all]."
    exit
fi

make distclean
make clean

lang_code="";
if [[ "$1" == "english" || "$1" == "all" ]]; then
    ./bin/zdb2tex run tlh en ~/cuthbert/klingon-data/data/dict-gen.zdb > tex/en/include/tlh-en.tex
    ./bin/zdb2tex run en tlh ~/cuthbert/klingon-data/data/dict-gen.zdb > tex/en/include/en-tlh.tex
    make english
fi

if [[ "$1" == "german" || "$1" == "all" ]]; then
    ./bin/zdb2tex run tlh de ~/cuthbert/klingon-data/data/dict-gen.zdb > tex/de/include/tlh-de.tex
    ./bin/zdb2tex run de tlh ~/cuthbert/klingon-data/data/dict-gen.zdb > tex/de/include/de-tlh.tex
    make german
fi

if [[ "$1" == "swedish" || "$1" == "all" ]]; then
    ./bin/zdb2tex run tlh sv ~/cuthbert/klingon-data/data/dict-gen.zdb > tex/sv/include/tlh-sv.tex
    ./bin/zdb2tex run sv tlh ~/cuthbert/klingon-data/data/dict-gen.zdb > tex/sv/include/sv-tlh.tex
    make swedish
fi

make clean
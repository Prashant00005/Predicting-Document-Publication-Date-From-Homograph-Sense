#!/bin/bash

# Base Script File (extract_context.sh)
# Created: lun. 26 mars 2018 08:16:53 IST
# Version: 1.0
#

selected=select_words.txt
wsd=./word_sense_disambigation_corpora/masc/
masc_org=./MASC-3.0.0/data/
n_words_before=5
n_words_after=5
out_file=table_wcnmdy.csv
tmpfile=$(mktemp /tmp/abc-script.XXXXXX)

rm -f $out_file
echo "word;context;noad_url;wordnet_id;wordnet_text;masc_file;date;year" >> $out_file
cat $selected | while read word; do
  echo $word
  grep 'text="'$word'"' -lr $wsd | while read file; do
    echo $file
    # get date year
    path=${file#./word_sense_disambigation_corpora/masc/}
    path=${path%.*}
    hdr=$masc_org/$path.hdr
    if [ -f "$hdr" ]; then
        date=`sed -n 's/.*pubDate value="\([^"]*\).*/\1/p' $hdr`
        year=`echo $date | sed -n 's/.*\([12][0-9][0-9][0-9]\).*/\1/p'`
        #echo date=$date year=$year
    fi
    if [ "$year" = "" ]; then continue; fi
    # extract senses
    #text=`grep  -e "\"[^A-Za-z]+\"" $file`
    sed -En '/.*text="[A-Za-z]*".*/p' $file > $tmpfile
    grep -n 'text="'$word'"' $tmpfile | grep 'sense=' | while read line; do
      sense=`echo $line | sed -n 's/.*sense="\([^"]*\).*/\1/p'`
      ln=`echo $line | cut -d: -f 1`
      #echo sense=$sense ln=$ln
      context=`awk "NR>=$ln-$n_words_before && NR<=$ln+$n_words_after" $tmpfile |\
      sed -n 's/.*text="\([^"]*\).*/\1 /p' | tr '[A-Z]' '[a-z]' | xargs`
      ##Code for getting wordnet id and wordnet context
      out=$(grep $sense word_sense_disambigation_corpora/manual_map.txt | awk '{print $2}' | awk -F ',' '{print $1}' ) 
      if [ "$out" = "" ]; then
          continue
      fi
      temp=$(echo $out | cut -d'%' -f 1)
      out2=$(grep "$out" WordNet-3.0/dict/index.sense_filtered | awk -F ' ' '{print $3}')
      if [ "$out2" = "" ]; then
        continue
      fi
      echo "$out" >> "test2.txt"
      echo "$out2" >> "test3.txt"
      out3=$(wn $temp -n$out2 -synsn)
      echo "$out3" >> "test4.txt"
      out4=$(echo "${out3#*"Sense" }")
      if [ "$out4" = "" ]; then
          continue
      fi
      out4=$(echo "Sense" $out4)
      echo "$out4" >> "test5.txt"
      echo "$word;\"$context\";$sense;$out;$out4;$path;$date;$year" >> $out_file
    done
  done
done
rm "$tmpfile"


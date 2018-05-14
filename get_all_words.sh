#!/bin/bash

# Base Script File (get_all_words.sh)
# Created: sam. 24 mars 2018 10:49:47 GMT
# Version: 1.0

out=stats/all_words_raw.txt
sorted_count=stats/words_count.txt
sorted_word=stats/words_count_sorted_by_word.txt
duplicate_sense=stats/words_duplicates.txt
triples_sense=stats/words_triples.txt

mkdir -p stats

# find all files and extract the text key.
rm -f $out
find "./word_sense_disambigation_corpora/masc/" -type f -print0 | \
while IFS= read -r -d $'\0' file; do
  echo Procesing $file
  grep 'sense=' $file |\
  sed -n 's/.*text="\([^"]*\).*sense="\([^"]*\).*/\1 \2/p' | tr '[:upper:]' '[:lower:]' >> $out
done

cat $out | sort | uniq -c | sort -rn -k 1,1 > $sorted_count
cat $out | sort | uniq -c | sort -k 2,2 > $sorted_word
awk '$1 > 10' $sorted_word | awk 'n=x[$2]{print n"\n"$0;} {x[$2]=$0;}' > $duplicate_sense
awk 'seen[$2]++==3 {print $2}' $duplicate_sense > $triples_sense
echo done'!'

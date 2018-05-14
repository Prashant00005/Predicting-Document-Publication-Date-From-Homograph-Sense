rm -f test2.txt test3.txt test4.txt test5.txt
for line in `awk -F ';' 'NR>1{print $3}' table_wcnmdy.txt`;
do
	arr[$i]=$line

	out=$(grep $line word_sense_disambigation_corpora/manual_map.txt | awk '{print $2}' | awk -F ',' '{print $1}' ) 
	#if [ "" == "$out" ]; then
		#$out='x'
	#fi
	if [ "$out" = "" ]; then
		#echo "'$out'"
		#echo out empty
		echo "" >> "test2.txt"
		echo "" >> "test3.txt"

		continue
	fi
	
	temp=$(echo $out | cut -d'%' -f 1)
	#echo $temp
	out2=$(grep "$out" WordNet-3.0/dict/index.sense_filtered | awk -F ' ' '{print $3}')
	if [ "$out2" = "" ]; then
		#echo "'$out2'"
		#echo out2 empty
		echo "" >> "test5.txt"
	fi

	#echo $i	
	echo "$out" >> "test2.txt"
	echo "$out2" >> "test3.txt"
	#echo $out2
	out3=$(wn $temp -n$out2 -synsn)
	echo "$out3" >> "test4.txt"
	out4=$(echo "${out3#*"Sense" }")
	out4=$(echo "Sense" $out4)
	echo "$out4" >> "test5.txt"
	

done

#echo ${arr[*]}

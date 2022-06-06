#!/bin/bash

# Print total hits of each day

(find . -maxdepth 1 -iname '*.log*' -not -name '*.gz*' -exec cat {} \; ; zcat access*gz) |awk '{ print $4}' |cut -d ':' -f 1 | sed -e 's/^.//' |sort -f|uniq -c |awk '{printf("%s = %s hits\n",$2,$1)}' |sort -t '/' -k2M -k1n  > days.txt



# Print total hits of each hour of the day

(find . -maxdepth 1 -iname '*.log*' -not -name '*.gz*' -exec cat {} \; && zcat access*gz) > lines.tmp
output=$(cat lines.tmp |awk '{ print $4}' |cut -d ':' -f 1-2 | sed -e 's/^.//' |sort -f|uniq -c)

while IFS= read -r line
do
	date=$(echo "$line" |awk '{ print $2 }' |cut -d ':' -f 1)
	hour=$(echo "$line" |awk '{ print $2 }' |cut -d ':' -f 2 |date +"%I %p" -f -)
	hits=$(echo "$line" |awk '{ print $1 }')
	echo "$date $hour = $hits hits"
done < <(printf '%s\n' "$output") > hours.txt


# Extract peak hours

sort -n -t ' ' -k5 hours.txt |tail -10 >peak_hours.txt




cat hours.txt |awk '{ printf ("%s,%s %s,%s\n",$1,$2,$3,$5) }' >hours.csv
cat days.txt |awk '{ printf ("%s,%s\n",$1,$3) }' >days.csv
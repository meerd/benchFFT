#!/bin/bash

cd "$(dirname "$0")/.."

rm -rf report/
mkdir report/
mkdir report/images
cp -rf tools/html-report-template/* report/

cd plots/
echo "Generating html report..."

cat ../report/index.head > ../report/index.html

INDEX=0

for f in *.ps ; do 
	INDEX=$((INDEX + 1));
	convert "$f" -rotate 90 "../report/images/$f".png ; 
	printf "\t\t<a href=\"images/$f.png\" class\"big\"><img src=\"images/$f.png\" alt=\"\" title=\"\"/></a>\n" >> ../report/index.html
	if [ `expr $INDEX % 3` -eq 0 ]
	then
   		printf "\t\t<div class=\"clear\"></div>\n\n" >> ../report/index.html
	fi
done

cat ../report/index.tail >> ../report/index.html

rm -f ../report/index.tail
rm -f ../report/index.head
rm -f ../report/LICENSE

echo "The report generated successfully."

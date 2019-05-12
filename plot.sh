#!/bin/bash

make collect

rm -rf plots/

sh scripts/standard-plots.sh $(hostname).speed
sh scripts/standard-plots.sh $(hostname).accuracy

mkdir -p plots/
mv *.ps plots/
cd plots/

for f in *.ps ; do convert "$f" -rotate 90 "$f".png ; done


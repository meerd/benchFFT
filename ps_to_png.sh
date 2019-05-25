#!/bin/bash

cd "$(dirname "$0")"
cd plots/

echo "Converting *.ps to *.png..."

for f in *.ps ; do convert "$f" -rotate 90 "../report/$f".png ; done



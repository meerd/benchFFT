#!/bin/bash

cd "$(dirname "$0")"
cd plots/

for f in *.ps ; do convert "$f" -rotate 90 "$f".png ; done



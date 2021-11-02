#!/usr/bin/env bash

# Squash all PDF files in the current directory into one merged.pdf file
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=merged.pdf $(ls -1tr | xargs -I {} find $(pwd) -name {} | tr '\n' ' ')

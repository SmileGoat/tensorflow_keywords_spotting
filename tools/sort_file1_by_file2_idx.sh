#! /bin/bash

awk 'FNR==NR{a[$1]=$0;next} $1 in a {print a[$1]}' $1 $2

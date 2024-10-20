#!/bin/bash
tmp="3.7G"
if(($(echo "tmp" | grep -o '[a-zA-Z]*'| head -n 1) == )); then
    entier=$(echo "$tmp" | grep -o '[0-9]*.'| grep -o '[0-9]*' | head -n 1);
    decimal=$(echo "$tmp" | grep -o '[0-9]*.'| grep -o '[0-9]*' | head -n 2 | tail -n 1);
    
#echo $tmp
echo "nb : "
echo $res
#!/usr/bin/bash
cat $1 | while read line;do
  sox --i "$line"
done

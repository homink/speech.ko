#!/usr/bin/bash

echo "$0 $@"  # Print the command line for logging

new_dir=$2
cat $1 | while read x;do
  echo $x
  read begin end <<< $(auditok -i $x | tr '\n' ' ' | awk '{print $2" "$NF}')
  diff=$(echo $begin $end | awk '{print $2-$1}')
  # 0.1 below is to set margin for the front trimming. 
  # You can put such 0.3 if you need 300msec silence in the beginning. 
  cbegin=$(echo $begin | awk '{print $1-0.1}')
  if [ $(echo "0.0"'>'$cbegin | bc -l) -eq 1 ];then cbegin=$begin; fi
  if [ $(echo $(echo "$cbegin+$diff" | bc)'>='$end | bc -l) -eq 1 ];then diff=$end; fi

  folder=$(dirname "${x}")
  mkdir -p $new_dir/$folder
  sox $x $new_dir/$x trim $cbegin $diff
done


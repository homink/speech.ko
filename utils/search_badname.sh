#!/usr/bin/bash
cat $1 | while read wavfile;do
  fname=$(basename "$wavfile")
  uid=${fname/.wav/}
  tid=$(cut -d'_' -f2,3 <<< $uid)

  if ! grep -q $tid $2;then
    echo $wavfile
  fi
done


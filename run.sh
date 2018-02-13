#!/usr/bin/bash

stage=0
corpus=.
:<<"SKIP"
This script assumes that corpus folder contains the following zip files, which is a full set of Korean reading speech in National Institute of Korean Language.

3-1 #1 (20대 남성) 4-1.zip
3-1 #1 (20대 남성) 4-2.zip
3-1 #1 (20대 남성) 4-3.zip
3-1 #1 (20대 남성) 4-4.zip
3-1 #2 (20대 여성) 5-1.zip
3-1 #2 (20대 여성) 5-2.zip
3-1 #2 (20대 여성) 5-3.zip
3-1 #2 (20대 여성) 5-4.zip
3-1 #2 (20대 여성) 5-5.zip
3-2 #1 (30대 남성) 5-1.zip
3-2 #1 (30대 남성) 5-2.zip
3-2 #1 (30대 남성) 5-3.zip
3-2 #1 (30대 남성) 5-4.zip
3-2 #1 (30대 남성) 5-5.zip
3-2 #2 (40대 여성) 5-1.zip
3-2 #2 (40대 여성) 5-2.zip
3-2 #2 (40대 여성) 5-3.zip
3-2 #2 (40대 여성) 5-4.zip
3-2 #2 (40대 여성) 5-5.zip
3-3 #3 (50대 이상 남성여성) 6-1.zip
3-3 #3 (50대 이상 남성여성) 6-2.zip
3-3 #3 (50대 이상 남성여성) 6-3.zip
3-3 #3 (50대 이상 남성여성) 6-4.zip
3-3 #3 (50대 이상 남성여성) 6-5.zip
3-3 #3 (50대 이상 남성여성) 6-6.zip
SKIP

. utils/parse_options.sh  # e.g. this parses the --stage option if supplied.

if [ $stage -le 0 ]; then
  zl=$(ls $corpus/*.zip | wc -l)
  if [ "$zl" -ne 25 ];then
    echo "25 zip files should be found here"
    exit
  fi

  ls -1 $corpus/*.zip | while read file;do
    echo "extracing $file ... "
    unzip -o "$file" -d $corpus
  done

  if [ -d $corpus/"3-3(50female)" ];then
    for x in "3-3(50female)" "3-3(50male)";do
      echo "movinig $corpus/$x/* to $corpus"
      mv $corpus/$x/* $corpus
      rm -rf $corpus/$x
    done
  fi
  find $corpus -name "*.wav" -exec ls -l {} \; | awk '{print $6" "$NF}' > $corpus/wav_all.lst
  if [ "$(wc -l $corpus/wav_all.lst | awk '{print $1}')" -ne 87407 ];then
    echo "87407 wav files should be found here"
    exit
  fi
fi

if [ $stage -le 1 ]; then

  #This file is not recorded correctly
  line=$(sort -n $corpus/wav_all.lst | head -1)
  IFS=" " read sl fname <<< $line
  if [ "$sl" -eq 44 ];then
    mkdir -p $corpus/Invalid
    if [ -f $fname ];then
      mv $(awk '{print $2}' <<< $line) $corpus/Invalid
    fi
  fi

  find $corpus -name "*.wav" | grep -v "Bad\|Non\|Invalid" > $corpus/wav.lst

  rm -f $corpus/*.slst $corpus/*.info
  split -l $(echo $(($(wc -l $corpus/wav.lst | awk '{print $1}') / 9))) \
    $corpus/wav.lst -d $corpus/wav. --additional-suffix=.slst
  cn=1;for x in $corpus/*.slst;do mv $x $corpus/wav.$cn.slst; cn=$((cn+1));done

  utils/run.pl JOB=1:10 $corpus/sox.JOB.info \
    utils/check_wavinfo.sh $corpus/wav.JOB.slst JOB || exit 1;

  #echo -n "NIKL corpus has ";
  #echo $(expr $(grep Duration $corpus/sox.*.info | awk '{print $5}' | paste -sd+ | bc) / 57600000)" hours"

  grep "Input\|Sample Rate" $corpus/sox.*.info | \
    sed 's/.*: //g' | sed "s/'//g" | tr '\n' ' ' | \
    sed 's/16000/16000\n/g' | sed 's/44100/44100\n/g' |
    sed 's/48000/48000\n/g' | sed 's/^ //g' | \
    grep -v 16000 > $corpus/Non16KHz_wav.lst

  if [ $(wc -l $corpus/Non16KHz_wav.lst | awk '{print $1}') -gt 0 ];then
    mkdir -p $corpus/Non16KHz
    cat $corpus/Non16KHz_wav.lst | while read line;do
      IFS=" " read wavfile samplerate <<< $line
      if [ "$samplerate" -ne 16000 ];then
        fn=$(basename "$wavfile")
        cp $wavfile $corpus/Non16KHz/
        sox $corpus/Non16KHz/$fn -r 16000 $wavfile
      fi
    done
    echo "$(wc -l $corpus/Non16KHz_wav.lst) files are not sampled with 16KHz thus forcely resampled to 16KHz."
  fi
fi

if [ $stage -le 2 ]; then
  file_enc=$(file -i $corpus/script_nmbd_by_sentence.txt | sed 's/.*charset=//g')

  #For Python2
  python utils/extract_trans_p2.py $corpus/script_nmbd_by_sentence.txt "$file_enc" > $corpus/trans.txt
  #For Python3
  #python utils/extract_trans_p2.py $corpus/script_nmbd_by_sentence.txt "$file_enc" > $corpus/trans.txt

  if [ "$(wc -l $corpus/trans.txt | awk '{print $1}')" -ne 930 ];then
    echo "$corpus/trans.txt should have 930 lines. Please check!"
    exit
  fi

  rm -f $corpus/wav.*.bad
  awk '{print $1}' $corpus/trans.txt > $corpus/tid.lst
  utils/run.pl JOB=1:10 $corpus/wav.JOB.bad \
    utils/search_badname.sh $corpus/wav.JOB.slst $corpus/tid.lst JOB || exit 1;

  grep -v "\#" $corpus/wav.*.bad | sed 's/.*bad://g' | sort > $corpus/BadName_wav.lst

  mkdir -p $corpus/BadName
  cat $corpus/BadName_wav.lst | while read wavfile;do
    if [ -f $wavfile ];then
      cp $wavfile $corpus/BadName
    fi
  done

  bl=$(wc -l $corpus/BadName_wav.lst | awk '{print $1}')

  if [ "$bl" -gt 0 ];then
    # ./mv11/mv11_t07_s4`.wav
    bad_wavname=$(grep "\`" $corpus/BadName_wav.lst)
    [ ! -z $bad_wavname ] && mv $bad_wavname ${bad_wavname/\`/1}

    # ./fv18/fv18_t08_s02(└ч│ь└╜).wav
    bad_wavname=$(grep "(" $corpus/BadName_wav.lst)
    [ ! -z $bad_wavname ] && mv $bad_wavname $(cut -d'(' -f1 <<< $bad_wavname).wav

    for wavfile in `grep "_S" $corpus/BadName_wav.lst`;do
      cp $wavfile $corpus/BadName
      mv $wavfile ${wavfile/_S/_s}
    done

    for wavfile in `grep "_P" $corpus/BadName_wav.lst`;do
      cp $wavfile $corpus/BadName
      mv $wavfile ${wavfile/_P/_s}
    done

    for wavfile in `grep "nfy_s06" $corpus/BadName_wav.lst`;do
      cp $wavfile $corpus/BadName
      mv $wavfile ${wavfile/nfy_s06/fx08}
    done

    [ -f $corpus/mw15/mw15_t08_s28.wav ] && mv $corpus/mw15/mw15_t08_s28.wav $corpus/mw15/mw15_t08_s29.wav
    [ -f $corpus/mw15/mw15_t08_s26.wav ] && mv $corpus/mw15/mw15_t08_s26.wav $corpus/mw15/mw15_t08_s28.wav
    [ -f $corpus/mw15/mw15_t08_s25.wav ] && mv $corpus/mw15/mw15_t08_s25.wav $corpus/mw15/mw15_t08_s27.wav
    [ -f $corpus/mw15/mw15_t08_s24.wav ] && mv $corpus/mw15/mw15_t08_s24.wav $corpus/mw15/mw15_t08_s26.wav
    [ -f $corpus/mw15/mw15_t08_s23.wav ] && mv $corpus/mw15/mw15_t08_s23.wav $corpus/mw15/mw15_t08_s25.wav

    [ -f $corpus/fv13/fv13_t10_w43.wav ] && mv $corpus/fv13/fv13_t10_w43.wav $corpus/fv13/fv13_t10_s43.wav
    [ -f $corpus/fv13/fv13_t13_233.wav ] && mv $corpus/fv13/fv13_t13_233.wav $corpus/fv13/fv13_t13_s33.wav
    [ -f $corpus/fv18/fv18_t07_s63.wav ] && mv $corpus/fv18/fv18_t07_s63.wav $corpus/fv18/fv18_t07_s62.wav
    [ -f $corpus/mw11/mw11_t16_s37.wav ] && mv $corpus/mw11/mw11_t16_s37.wav $corpus/mw11/mw11_t17_s02.wav
    [ -f $corpus/fy17/fy17_t15_s18.wav ] && mv $corpus/fy17/fy17_t15_s18.wav $corpus/fy17/fy17_t16_s01.wav

    [ -f $corpus/fx02/fx02_t09_s42.wav ] && mv $corpus/fx02/fx02_t09_s42.wav $corpus/fx02/fx02_t09_s44.wav
    [ -f $corpus/fx02/fx02_t09_s41.wav ] && mv $corpus/fx02/fx02_t09_s41.wav $corpus/fx02/fx02_t09_s43.wav
    [ -f $corpus/fx02/fx02_t09_s40.wav ] && mv $corpus/fx02/fx02_t09_s40.wav $corpus/fx02/fx02_t09_s42.wav
    [ -f $corpus/fx02/fx02_t09_s39.wav ] && mv $corpus/fx02/fx02_t09_s39.wav $corpus/fx02/fx02_t09_s41.wav
    [ -f $corpus/fx02/fx02_t09_s38.wav ] && mv $corpus/fx02/fx02_t09_s38.wav $corpus/fx02/fx02_t09_s40.wav
    [ -f $corpus/fx02/fx02_t09_s37.wav ] && mv $corpus/fx02/fx02_t09_s37.wav $corpus/fx02/fx02_t09_s39.wav

    [ -f $corpus/fx01/fx01_t01_s39.wav ] && mv $corpus/fx01/fx01_t01_s39.wav $corpus/fx01/fx01_t01_s41.wav
    [ -f $corpus/fx01/fx01_t01_s38.wav ] && mv $corpus/fx01/fx01_t01_s38.wav $corpus/fx01/fx01_t01_s40.wav

    cat $corpus/BadName_wav.lst | while read wavfile;do
      rm -f $wavfile
    done
  fi
fi
exit
if [ $stage -le 3 ]; then

  if ! type sox > /dev/null;then
    echo "sox is not found. please install it!"
    exit
  fi

  if ! type auditok > /dev/null;then
    echo "auditok (https://github.com/amsehili/auditok) is not found. please install it!"
    exit
  fi

  find $corpus -name "*.wav" | grep -v "Bad\|Non\|Invalid" > $corpus/wav_list

  rm -f $corpus/*.slst
  split -l $(echo $(($(wc -l $corpus/wav_list | awk '{print $1}') / 9))) \
    $corpus/wav_list -d wav. --additional-suffix=.slst
  cn=1;for x in $corpus/*.slst;do mv $x $corpus/wav.$cn.slst; cn=$((cn+1));done

  mkdir -p $corpus/trimmed_data
  utils/run.pl JOB=1:10 $corpus/trim.JOB.info \
    utils/trim_nikl.sh $corpus/wav.JOB.slst $corpus/trimmed_data JOB || exit 1;

fi

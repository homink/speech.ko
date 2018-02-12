# speech.ko
Korean read speech corpus (about 120 hours, 17GB) from National Institute of Korean Language

## Location
http://www.korean.go.kr/front/board/boardStandardView.do?board_id=4&mn_id=17&b_seq=464

https://ithub.korean.go.kr/user/corpus/referenceManager.do

Once you download all corpus files from above, you will find the following zip files.

```
[kwon@master-01 speech.ko]$ ls *.zip
3-1 #1 (20대 남성) 4-1.zip  3-2 #1 (30대 남성) 5-1.zip  3-2 #2 (40대 여성) 5-5.zip
3-1 #1 (20대 남성) 4-2.zip  3-2 #1 (30대 남성) 5-2.zip  3-3 #3 (50대 이상 남성여성) 6-1.zip
3-1 #1 (20대 남성) 4-3.zip  3-2 #1 (30대 남성) 5-3.zip  3-3 #3 (50대 이상 남성여성) 6-2.zip
3-1 #1 (20대 남성) 4-4.zip  3-2 #1 (30대 남성) 5-4.zip  3-3 #3 (50대 이상 남성여성) 6-3.zip
3-1 #2 (20대 여성) 5-1.zip  3-2 #1 (30대 남성) 5-5.zip  3-3 #3 (50대 이상 남성여성) 6-4.zip
3-1 #2 (20대 여성) 5-2.zip  3-2 #2 (40대 여성) 5-1.zip  3-3 #3 (50대 이상 남성여성) 6-5.zip
3-1 #2 (20대 여성) 5-3.zip  3-2 #2 (40대 여성) 5-2.zip  3-3 #3 (50대 이상 남성여성) 6-6.zip
3-1 #2 (20대 여성) 5-4.zip  3-2 #2 (40대 여성) 5-3.zip
3-1 #2 (20대 여성) 5-5.zip  3-2 #2 (40대 여성) 5-4.zip
```

## Command

```
./run.sh --corpus <directory where above zip files are>
```

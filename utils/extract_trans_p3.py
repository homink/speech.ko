import sys,codecs,re

#fin=codecs.open(sys.argv[1],'r','utf-8')
#fin=codecs.open(sys.argv[1],'r','utf-16le')
fin=codecs.open(sys.argv[1],'r',sys.argv[2])

ccn=0
topic_ind=0;topic_detected=0
sent_ind=0;
for c in fin:
  if topic_detected:
    if re.search(u"^\d",c):
      found=re.findall(r"^\d+",c)
      if int(found[0])<10:
        sent_ind="0"+str(found[0])
      else:
        sent_ind=str(found[0])

      cc = re.sub(r"\ufeff",u"",c)
      cc = re.sub(r"\r\n",u"\n",cc)
      cc = re.sub(r"찌익ꠏꠏꠏ깔기는",u"찌익 깔기는",cc)
      cc = re.sub(r"들이켰으면⋯⋯",u"들이켰으면",cc)
      cc = re.sub(r"흐흐흐⋯⋯",u"흐흐흐",cc)
      cc = re.sub(r"삐익ꠏꠏꠏꠏ하고",u"삐익하고",cc)
      cc = re.sub(r"3의",u"삼의",cc)
      cc = re.sub(r"3 배",u"세 배",cc)
      cc = re.sub(r"5호선이",u"오호선이",cc)
      cc = re.sub(r"11월",u"십일월",cc)
      cc = re.sub(r"6 25 전쟁",u"육이오 전쟁",cc)
      cc = re.sub(r"3. 나이 많은 용왕님이 시름시름 앓다가 자리에 누웠기 때문이지요.   4. 신하들은 좋다는 약은 다 써보았지만 용왕님의 병을 낫게 하지는
 못했어요.",
                  u"3. 나이 많은 용왕님이 시름시름 앓다가 자리에 누웠기 때문이지요.\nt09_s04 신하들은 좋다는 약은 다 써보았지만 용왕님의 병을 낫게 하
지는 못했어요",cc)
      cc = re.sub(r'11."살려 주세요."',u'11. "살려 주세요."',cc)
      cc = re.sub(r"63. 선녀는 날개옷을 보자 너무나 기뻐서 날개옷을 입어 보았어요.   64. 그런데 이게 웬 일이죠?",
                  u"63. 선녀는 날개옷을 보자 너무나 기뻐서 날개옷을 입어 보았어요.\nt10_s64 그런데 이게 웬 일이죠",cc)

      cc = re.sub(r"^\d+\. ","",cc)
      cc = re.sub(r"^\d+\.","",cc)
      cc = re.sub(r" [ ]+"," ",cc)

      cc2 = cc.split(")")
      cc3 = []
      for l in cc2:
        ll=re.sub(r"\(.*$",u"",l)
        ll=re.sub(r"[‘“]"," ",ll)
        ll=re.sub(r" [ ]+"," ",ll)
        cc3.append(re.sub(r"[’…”「」\"~]+","",ll))

      cc4 = "".join(cc3)
      cc4 = re.sub(r"  "," ",cc4)
      cc=re.sub(r"\r\n",u"\n",cc4)

      print("t"+topic_ind+"_s"+sent_ind+" "+cc.strip())

  if re.search(u"<\d",c):
    topic_detected=1
    found=re.findall(r"\d+",c)
    if int(found[0])<10:
      topic_ind="0"+str(found[0])
    else:
      topic_ind=str(found[0])

fin.close()

#!/usr/bin/env python3

import sys, datetime

def roundTime5min(val) :
  #epoch0 = datetime.datetime.utcfromtimestamp(0)
  #epoch1 = (val - epoch0).total_seconds()
  epoch1 = val.timestamp();  intInterval = 5*60
  epoch1 = round(epoch1/intInterval) * intInterval
  return datetime.datetime.fromtimestamp(epoch1)
#

def matchCronParam(cfgParam, actVal) :
  print(cfgParam + " :: " + actVal)
  l_param = cfgParam.strip()
  if (len(l_param)>0 and l_param!="*") :
    if l_param.startswith("*/") :
      mod = int(actVal) % int(l_param[2:])
      print(l_param + " => " + str(mod))
      if mod != 0 : return False
    elif not (","+actVal+"," in ","+l_param+",") :
      print(actVal + ' <> ' + l_param)
      return False
    #
  #
  return True
#

def cronchk(*args) :
  argc = len(args)
  if argc==1 :
    import re;  paramList = re.split(r"\s+", args[0])
    (mi, hr, dd, mm, wd) = paramList[0:5]
  elif argc>=5 :
    (mi, hr, dd, mm, wd) = args[0:5]
  else :
    return False
  #

  thisTime = datetime.datetime.now()
  ## thisTime = roundTime5min(thisTime)
  print(str(thisTime))

  if not matchCronParam(mi, str(thisTime.minute)): return False
  if not matchCronParam(hr, str(thisTime.hour)): return False
  if not matchCronParam(dd, str(thisTime.day)): return False
  if not matchCronParam(mm, str(thisTime.month)): return False
  wd1 = thisTime.weekday();  wd1 = 0 if (wd1==6) else wd1+1
  if not matchCronParam(wd, str(wd1)): return False

  return True
# 

argc = len(sys.argv); 
if argc > 1 :
  print("arg: " + str(sys.argv[1:]))
  sys.exit(
    # 0 if cronchk(" ".join(sys.argv[1:])) else 1 ## single string argument
    0 if cronchk(*sys.argv[1:]) else 1 ## arguments unpacked with "splat" operator
  )
#

sys.exit("""
 usage: cronchk.py mi hr dd mm wd

   mi    minute [*, 0 - 59]
   hr    hour [*, 0 - 23]
   dd    day of month [*, 1 - 31]
   mm    month [*, 1 - 12]
   wd    day of week [*, 0 - 6] [Sunday=0]

 examples:

   cronchk.py 0 0 * * *
     runs daily at 12:00am
   cronchk.py 0,15,30,45 * * * 1-5
     runs every 15 minutes, on weekdays only
""")

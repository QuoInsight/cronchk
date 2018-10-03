
while (True) :
  import datetime
  currentTime = datetime.datetime.now()
  #currentTime = datetime.datetime(2018, 10, 3, 15, 45, 0)
  #nextMinute = currentTime.replace(microsecond=0, second=0) + datetime.timedelta(minutes=1)

  offsetMinutes = 3
  intervalMinutes = 15
  thisMinutes = currentTime.timetuple().tm_min - offsetMinutes
  countDownMinutes = intervalMinutes - (thisMinutes % intervalMinutes)
  nextTime = currentTime.replace(microsecond=0, second=0) + datetime.timedelta(minutes=countDownMinutes)

  countDownSeconds = (nextTime-currentTime).total_seconds()

  print( str(currentTime) )
  print( "countDownSeconds: " + str(countDownSeconds) + " (" + str(countDownSeconds/60) + " minutes)")
  print( str(nextTime) )

  break

  import time
  time.sleep(countDownSeconds)
#

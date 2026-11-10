#!/bin/sh
#date "+%M %H %d %m %u"
#hcron-match "0 9 * * 1-5"

while true; do
  date +"%H %M %S" | {
    read -r hh mm ss
    printf "\r%s" "$ss"
    if [ "$ss" = "00" ]; then
      ~/run-every-minute.sh
      python3 cronchk.py '*/5 * * * *' && date > ./cron5.log
    fi
  }
  sleep 1
done
